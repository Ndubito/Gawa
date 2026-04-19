import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { Subscription } from '../domain/entities/subscription.entity';
import { type ISubscriptionRepository, SUBSCRIPTION_REPOSITORY_TOKEN } from '../domain/repos/subscription.repository';
import { SubscriptionStatus } from '../domain/types/subscription.types';

export interface UpdateSubscriptionDto {
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
  ) {}

  async execute(dto: UpdateSubscriptionDto): Promise<Subscription> {
    const subscription = await this.subscriptionRepository.findById(dto.id);
    if (!subscription) throw new NotFoundException(`Subscription with ID ${dto.id} not found`);

    subscription.update(dto.name, dto.description, dto.amountCents, dto.graceHours, dto.status);
    return this.subscriptionRepository.update(subscription);
  }
}
