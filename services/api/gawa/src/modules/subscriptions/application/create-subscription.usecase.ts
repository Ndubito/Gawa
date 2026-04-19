import { Injectable, Inject } from '@nestjs/common';
import { Subscription } from '../domain/entities/subscription.entity';
import { type ISubscriptionRepository, SUBSCRIPTION_REPOSITORY_TOKEN } from '../domain/repos/subscription.repository';
import { CreateSubscriptionDto } from '../presentation/dtos/create-subscription.dto';

@Injectable()
export class CreateSubscriptionUseCase {
  constructor(
    @Inject(SUBSCRIPTION_REPOSITORY_TOKEN)
    private readonly subscriptionRepository: ISubscriptionRepository,
  ) {}

  async execute(dto: CreateSubscriptionDto): Promise<Subscription> {
    const subscription = new Subscription({
      groupId: dto.groupId,
      recipientId: dto.recipientId,
      organizerId: dto.organizerId,
      name: dto.name,
      description: dto.description,
      amountCents: dto.amountCents,
      currency: dto.currency,
      schedule: dto.schedule,
      graceHours: dto.graceHours,
      startDate: dto.startDate,
    });
    return this.subscriptionRepository.save(subscription);
  }
}
