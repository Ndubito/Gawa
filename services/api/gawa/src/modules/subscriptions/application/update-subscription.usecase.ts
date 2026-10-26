import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { Subscription } from '../domain/entities/subscription.entity';
import {
  type ISubscriptionRepository,
  SUBSCRIPTION_REPOSITORY_TOKEN,
} from '../domain/repos/subscription.repository';
import { SubscriptionStatus } from '../domain/types/subscription.types';
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
    return this.subscriptionRepository.update(subscription);
  }
}
