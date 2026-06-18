import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { Subscription } from '../domain/entities/subscription.entity';
import { type ISubscriptionRepository, SUBSCRIPTION_REPOSITORY_TOKEN } from '../domain/repos/subscription.repository';
import { type IGroupRepository, GROUP_REPOSITORY_TOKEN } from '../../groups/domain/repos/group.repository';
import { SubscriptionStatus } from '../domain/types/subscription.types';

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
    @Inject(GROUP_REPOSITORY_TOKEN)
    private readonly groupRepository: IGroupRepository,
  ) {}

  async execute(input: UpdateSubscriptionInput, requesterId: number): Promise<Subscription> {
    const subscription = await this.subscriptionRepository.findById(input.id);
    if (!subscription) throw new NotFoundException(`Subscription ${input.id} not found`);

    const group = await this.groupRepository.findById(subscription.groupId);
    if (!group || group.ownerId !== requesterId) {
      throw new NotFoundException(`Subscription ${input.id} not found`);
    }

    subscription.update(input.name, input.description, input.amountCents, input.graceHours, input.status);
    return this.subscriptionRepository.update(subscription);
  }
}
