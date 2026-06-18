import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { type ISubscriptionRepository, SUBSCRIPTION_REPOSITORY_TOKEN } from '../domain/repos/subscription.repository';
import { type IGroupRepository, GROUP_REPOSITORY_TOKEN } from '../../groups/domain/repos/group.repository';

@Injectable()
export class DeleteSubscriptionUseCase {
  constructor(
    @Inject(SUBSCRIPTION_REPOSITORY_TOKEN)
    private readonly subscriptionRepository: ISubscriptionRepository,
    @Inject(GROUP_REPOSITORY_TOKEN)
    private readonly groupRepository: IGroupRepository,
  ) {}

  async execute(id: number, requesterId: number): Promise<void> {
    const subscription = await this.subscriptionRepository.findById(id);
    if (!subscription) throw new NotFoundException(`Subscription ${id} not found`);

    const group = await this.groupRepository.findById(subscription.groupId);
    if (!group || group.ownerId !== requesterId) {
      throw new NotFoundException(`Subscription ${id} not found`);
    }

    subscription.delete();
    await this.subscriptionRepository.delete(id);
  }
}
