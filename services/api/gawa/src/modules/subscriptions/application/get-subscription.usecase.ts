import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { Subscription } from '../domain/entities/subscription.entity';
import {
  type ISubscriptionRepository,
  SUBSCRIPTION_REPOSITORY_TOKEN,
} from '../domain/repos/subscription.repository';
import {
  type IGroupRepository,
  GROUP_REPOSITORY_TOKEN,
} from '../../groups/domain/repos/group.repository';
import {
  GroupAccessPolicy,
  GROUP_VIEWERS,
} from '../../groups/application/group-access.policy';

@Injectable()
export class GetSubscriptionUseCase {
  constructor(
    @Inject(SUBSCRIPTION_REPOSITORY_TOKEN)
    private readonly subscriptionRepository: ISubscriptionRepository,
    @Inject(GROUP_REPOSITORY_TOKEN)
    private readonly groupRepository: IGroupRepository,
    private readonly access: GroupAccessPolicy,
  ) {}

  async execute(id: number, requesterId: number): Promise<Subscription> {
    const subscription = await this.subscriptionRepository.findById(id);
    if (!subscription)
      throw new NotFoundException(`Subscription ${id} not found`);

    await this.access.require(
      subscription.groupId,
      requesterId,
      GROUP_VIEWERS,
      `Subscription ${id} not found`,
    );
    return subscription;
  }

  async executeByGroupId(
    groupId: number,
    requesterId: number,
  ): Promise<Subscription[]> {
    await this.access.require(groupId, requesterId, GROUP_VIEWERS);
    return this.subscriptionRepository.findByGroupId(groupId);
  }

  // Every subscription across the groups the requester owns or has joined.
  async executeForUser(requesterId: number): Promise<Subscription[]> {
    const groups = await this.groupRepository.findByUser(requesterId);
    return this.subscriptionRepository.findByGroupIds(groups.map((g) => g.id!));
  }
}
