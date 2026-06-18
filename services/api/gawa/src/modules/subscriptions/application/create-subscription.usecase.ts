import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { Subscription } from '../domain/entities/subscription.entity';
import { type ISubscriptionRepository, SUBSCRIPTION_REPOSITORY_TOKEN } from '../domain/repos/subscription.repository';
import { type IGroupRepository, GROUP_REPOSITORY_TOKEN } from '../../groups/domain/repos/group.repository';
import { SubscriptionSchedule } from '../domain/types/subscription.types';

export interface CreateSubscriptionInput {
  groupId: number;
  name: string;
  description?: string;
  amountCents: number;
  schedule: SubscriptionSchedule;
  graceHours: number;
  startDate: Date;
}

@Injectable()
export class CreateSubscriptionUseCase {
  constructor(
    @Inject(SUBSCRIPTION_REPOSITORY_TOKEN)
    private readonly subscriptionRepository: ISubscriptionRepository,
    @Inject(GROUP_REPOSITORY_TOKEN)
    private readonly groupRepository: IGroupRepository,
  ) {}

  async execute(input: CreateSubscriptionInput, requesterId: number): Promise<Subscription> {
    const group = await this.groupRepository.findById(input.groupId);
    if (!group || group.ownerId !== requesterId) {
      throw new NotFoundException(`Group ${input.groupId} not found`);
    }

    const subscription = new Subscription({
      groupId: input.groupId,
      recipientId: requesterId,
      organizerId: requesterId,
      name: input.name,
      description: input.description,
      amountCents: input.amountCents,
      schedule: input.schedule,
      graceHours: input.graceHours,
      startDate: input.startDate,
    });
    return this.subscriptionRepository.save(subscription);
  }
}
