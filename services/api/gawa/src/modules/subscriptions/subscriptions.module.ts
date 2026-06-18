import { Module } from '@nestjs/common';
import { UsersModule } from '../users/users.module';
import { GroupsModule } from '../groups/groups.module';
import { SubscriptionController } from './presentation/subscription.controller';
import { CreateSubscriptionUseCase } from './application/create-subscription.usecase';
import { GetSubscriptionUseCase } from './application/get-subscription.usecase';
import { UpdateSubscriptionUseCase } from './application/update-subscription.usecase';
import { DeleteSubscriptionUseCase } from './application/delete-subscription.usecase';
import { SUBSCRIPTION_REPOSITORY_TOKEN } from './domain/repos/subscription.repository';
import { SubscriptionRepositoryImpl } from './infrastructure/prisma/subscription.repository.impl';
import { PrismaService } from '../../../prisma/prisma.service';

@Module({
  imports: [UsersModule, GroupsModule],
  controllers: [SubscriptionController],
  providers: [
    PrismaService,
    {
      provide: SUBSCRIPTION_REPOSITORY_TOKEN,
      useClass: SubscriptionRepositoryImpl,
    },
    CreateSubscriptionUseCase,
    GetSubscriptionUseCase,
    UpdateSubscriptionUseCase,
    DeleteSubscriptionUseCase,
  ],
  exports: [
    CreateSubscriptionUseCase,
    GetSubscriptionUseCase,
    UpdateSubscriptionUseCase,
    DeleteSubscriptionUseCase,
    SUBSCRIPTION_REPOSITORY_TOKEN,
  ],
})
export class SubscriptionsModule {}
