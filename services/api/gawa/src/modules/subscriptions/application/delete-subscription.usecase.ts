import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import {
  type ISubscriptionRepository,
  SUBSCRIPTION_REPOSITORY_TOKEN,
} from '../domain/repos/subscription.repository';
import {
  GroupAccessPolicy,
  OWNER_ONLY,
} from '../../groups/application/group-access.policy';
import { CancelUpcomingObligationsUseCase } from '../../obligations/application/cancel-upcoming-obligations.usecase';

@Injectable()
export class DeleteSubscriptionUseCase {
  constructor(
    @Inject(SUBSCRIPTION_REPOSITORY_TOKEN)
    private readonly subscriptionRepository: ISubscriptionRepository,
    private readonly access: GroupAccessPolicy,
    private readonly cancelUpcomingObligations: CancelUpcomingObligationsUseCase,
  ) {}

  async execute(id: number, requesterId: number): Promise<void> {
    const subscription = await this.subscriptionRepository.findById(id);
    if (!subscription)
      throw new NotFoundException(`Subscription ${id} not found`);

    await this.access.require(
      subscription.groupId,
      requesterId,
      OWNER_ONLY,
      `Subscription ${id} not found`,
    );
    await this.subscriptionRepository.delete(id);
    await this.cancelUpcomingObligations.forStoppedSubscription(id);
  }
}
