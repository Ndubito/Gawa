import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { Subscription } from '../domain/entities/subscription.entity';
import {
  type ISubscriptionRepository,
  SUBSCRIPTION_REPOSITORY_TOKEN,
} from '../domain/repos/subscription.repository';
import { SubscriptionStatus } from '../domain/types/subscription.types';
import { CancelUpcomingObligationsUseCase } from '../../obligations/application/cancel-upcoming-obligations.usecase';
import {
  GroupAccessPolicy,
  OWNER_ONLY,
} from '../../groups/application/group-access.policy';

export interface UpdateSubscriptionInput {
  id: number;
  name?: string;
  description?: string;
  amountCents?: number;
  graceHours?: number;
  status?: SubscriptionStatus;
}

@Injectable()
export class UpdateSubscriptionUseCase {
  constructor(
    @Inject(SUBSCRIPTION_REPOSITORY_TOKEN)
    private readonly subscriptionRepository: ISubscriptionRepository,
    private readonly access: GroupAccessPolicy,
    private readonly cancelUpcomingObligations: CancelUpcomingObligationsUseCase,
  ) {}

  async execute(
    input: UpdateSubscriptionInput,
    requesterId: number,
  ): Promise<Subscription> {
    const subscription = await this.subscriptionRepository.findById(input.id);
    if (!subscription)
      throw new NotFoundException(`Subscription ${input.id} not found`);

    await this.access.require(
      subscription.groupId,
      requesterId,
      OWNER_ONLY,
      `Subscription ${input.id} not found`,
    );

    subscription.update(
      input.name,
      input.description,
      input.amountCents,
      input.graceHours,
      input.status,
    );
    const updated = await this.subscriptionRepository.update(subscription);

    // Amount and grace changes apply from the next cycle; stopping billing
    // also withdraws obligations that aren't due yet.
    if (subscription.status !== SubscriptionStatus.ACTIVE) {
      await this.cancelUpcomingObligations.forStoppedSubscription(input.id);
    }
    return updated;
  }
}
