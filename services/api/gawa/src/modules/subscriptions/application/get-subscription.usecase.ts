import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { Subscription } from '../domain/entities/subscription.entity';
import { type ISubscriptionRepository, SUBSCRIPTION_REPOSITORY_TOKEN } from '../domain/repos/subscription.repository';
import { type IGroupRepository, GROUP_REPOSITORY_TOKEN } from '../../groups/domain/repos/group.repository';

@Injectable()
export class GetSubscriptionUseCase {
  constructor(
    @Inject(SUBSCRIPTION_REPOSITORY_TOKEN)
    private readonly subscriptionRepository: ISubscriptionRepository,
    @Inject(GROUP_REPOSITORY_TOKEN)
    private readonly groupRepository: IGroupRepository,
  ) {}

  async execute(id: number, requesterId: number): Promise<Subscription> {
    const subscription = await this.subscriptionRepository.findById(id);
    if (!subscription) throw new NotFoundException(`Subscription ${id} not found`);

    const isMember = await this.groupRepository.isMember(subscription.groupId, requesterId);
    if (!isMember) throw new NotFoundException(`Subscription ${id} not found`);

    return subscription;
  }

  async executeByGroupId(groupId: number, requesterId: number): Promise<Subscription[]> {
    const isMember = await this.groupRepository.isMember(groupId, requesterId);
    if (!isMember) throw new NotFoundException(`Group ${groupId} not found`);
    return this.subscriptionRepository.findByGroupId(groupId);
  }

  // Every subscription across the groups the requester owns or belongs to.
  async executeForUser(requesterId: number): Promise<Subscription[]> {
    const [owned, member] = await Promise.all([
      this.groupRepository.findByOwnerId(requesterId),
      this.groupRepository.findByUser(requesterId),
    ]);
    const groupIds = [...new Set([...owned, ...member].map((g) => g.id!))];
    return this.subscriptionRepository.findByGroupIds(groupIds);
  }
}
