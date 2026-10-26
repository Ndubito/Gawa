import { Injectable, Inject } from '@nestjs/common';
import { Subscription } from '../domain/entities/subscription.entity';
import {
  type ISubscriptionRepository,
  SUBSCRIPTION_REPOSITORY_TOKEN,
} from '../domain/repos/subscription.repository';
import { SubscriptionSchedule } from '../domain/types/subscription.types';
import {
  GroupAccessPolicy,
  OWNER_ONLY,
} from '../../groups/application/group-access.policy';

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
    private readonly access: GroupAccessPolicy,
  ) {}

  async execute(
    input: CreateSubscriptionInput,
    requesterId: number,
  ): Promise<Subscription> {
    await this.access.require(input.groupId, requesterId, OWNER_ONLY);

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
