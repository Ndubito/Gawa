import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ConfigModule } from '@nestjs/config';
import { UsersModule } from './modules/users/users.module';
import { GroupsModule } from './modules/groups/groups.module';
import { SubscriptionsModule } from './modules/subscriptions/subscriptions.module';
import { ExpensesModule } from './modules/expenses/expenses.module';
import { ObligationsModule } from './modules/obligations/obligations.module';
import { PaymentsModule } from './modules/payments/payments.module';
import { TransactionsModule } from './modules/transactions/transactions.module';

@Module({
  imports: [
    ConfigModule.forRoot(),
    UsersModule,
    GroupsModule,
    SubscriptionsModule,
    ExpensesModule,
    ObligationsModule,
    PaymentsModule,
    TransactionsModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}

