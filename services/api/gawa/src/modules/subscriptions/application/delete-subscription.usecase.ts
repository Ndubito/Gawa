import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { type ISubscriptionRepository, SUBSCRIPTION_REPOSITORY_TOKEN } from '../domain/repos/subscription.repository';

@Injectable()
export class DeleteSubscriptionUseCase {
  constructor(
    @Inject(SUBSCRIPTION_REPOSITORY_TOKEN)
    private readonly subscriptionRepository: ISubscriptionRepository,
  ) {}

  async execute(id: number): Promise<void> {
    const subscription = await this.subscriptionRepository.findById(id);
    if (!subscription) throw new NotFoundException(`Subscription with ID ${id} not found`);

    subscription.delete();
    await this.subscriptionRepository.delete(id);
  }
}
