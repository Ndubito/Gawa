import { Injectable, Inject } from '@nestjs/common';
import { CLOCK, type Clock } from '../../../common/clock';
import {
  BILLING_REPOSITORY_TOKEN,
  type IBillingRepository,
} from '../domain/billing.repository';
import { periodsToBill, planCycle } from '../domain/billing-calendar';

export interface BillingTickResult {
  cyclesCreated: number;
  obligationsCreated: number;
  obligationsMarkedOverdue: number;
}

// One pass of the billing engine. Safe to run repeatedly or concurrently:
// it only creates periods that don't exist yet, and the database rejects duplicates.
@Injectable()
export class RunBillingTickUseCase {
  constructor(
    @Inject(BILLING_REPOSITORY_TOKEN)
    private readonly billingRepository: IBillingRepository,
    @Inject(CLOCK)
    private readonly clock: Clock,
  ) {}

  async execute(): Promise<BillingTickResult> {
    const now = this.clock();
    const result: BillingTickResult = {
      cyclesCreated: 0,
      obligationsCreated: 0,
      obligationsMarkedOverdue: 0,
    };

    const [subscriptions, billed] = await Promise.all([
      this.billingRepository.findBillableSubscriptions(),
      this.billingRepository.findOpenCyclePeriodStarts(now),
    ]);

    for (const subscription of subscriptions) {
      const alreadyBilled = billed.get(subscription.id) ?? new Set<number>();
      for (const period of periodsToBill(subscription, now)) {
        if (alreadyBilled.has(period.periodStart.getTime())) continue;
        const plan = planCycle(subscription, period, now);
        if (await this.billingRepository.createCycle(plan)) {
          result.cyclesCreated++;
          result.obligationsCreated += plan.obligations.length;
        }
      }
    }

    await this.billingRepository.advanceCycleStatuses(now);
    result.obligationsMarkedOverdue =
      await this.billingRepository.markOverdueObligations(now);
    return result;
  }
}
