import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { Subscription } from '../domain/entities/subscription.entity';
import { type ISubscriptionRepository, SUBSCRIPTION_REPOSITORY_TOKEN } from '../domain/repos/subscription.repository';

@Injectable()
export class GetSubscriptionUseCase {
  constructor(
    @Inject(SUBSCRIPTION_REPOSITORY_TOKEN)
    private readonly subscriptionRepository: ISubscriptionRepository,
  ) {}

  async execute(id: number): Promise<Subscription> {
    const subscription = await this.subscriptionRepository.findById(id);
    if (!subscription) throw new NotFoundException(`Subscription with ID ${id} not found`);
    return subscription;
  }

  async executeAll(): Promise<Subscription[]> {
    return this.subscriptionRepository.findAll();
  }
}
