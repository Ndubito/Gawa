import { Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ConfigModule } from '@nestjs/config';
import { FirebaseAuthGuard } from './modules/auth/guard';
import { UsersModule } from './modules/users/users.module';
import { GroupsModule } from './modules/groups/groups.module';
import { SubscriptionsModule } from './modules/subscriptions/subscriptions.module';
import { ObligationsModule } from './modules/obligations/obligations.module';
import { PaymentsModule } from './modules/payments/payments.module';
import { BillingModule } from './modules/billing/billing.module';
import { ExpensesModule } from './modules/expenses/expenses.module';

// Transactions are not routed until the payment phase.
@Module({
  imports: [
    ConfigModule.forRoot(),
    UsersModule,
    GroupsModule,
    SubscriptionsModule,
    ObligationsModule,
    PaymentsModule,
    BillingModule,
    ExpensesModule,
  ],
  controllers: [AppController],
  providers: [AppService, { provide: APP_GUARD, useClass: FirebaseAuthGuard }],
})
export class AppModule {}
