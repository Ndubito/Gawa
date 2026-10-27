import { Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { RunBillingTickUseCase } from './run-billing-tick.usecase';

@Injectable()
export class BillingScheduler {
  private readonly logger = new Logger(BillingScheduler.name);
  private running = false;

  constructor(private readonly runBillingTick: RunBillingTickUseCase) {}

  @Cron('*/15 * * * *', { name: 'billing-tick' })
  async tick(): Promise<void> {
    // A slow tick must not overlap the next one in this process.
    if (this.running) return;
    this.running = true;
    try {
      const result = await this.runBillingTick.execute();
      if (result.cyclesCreated || result.obligationsMarkedOverdue) {
        this.logger.log(
          `Billing tick: ${result.cyclesCreated} cycles, ${result.obligationsCreated} obligations created, ` +
            `${result.obligationsMarkedOverdue} marked overdue`,
        );
      }
    } catch (error) {
      this.logger.error(
        'Billing tick failed',
        error instanceof Error ? error.stack : String(error),
      );
    } finally {
      this.running = false;
    }
  }
}
