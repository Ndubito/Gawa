import { Module } from '@nestjs/common';
import { ScheduleModule } from '@nestjs/schedule';
import { PrismaService } from '../../../prisma/prisma.service';
import { clockProvider } from '../../common/clock';
import { BILLING_REPOSITORY_TOKEN } from './domain/billing.repository';
import { BillingRepositoryImpl } from './infrastructure/billing.repository.impl';
import { RunBillingTickUseCase } from './application/run-billing-tick.usecase';
import { BillingScheduler } from './application/billing.scheduler';

@Module({
  imports: [ScheduleModule.forRoot()],
  providers: [
    PrismaService,
    clockProvider,
    { provide: BILLING_REPOSITORY_TOKEN, useClass: BillingRepositoryImpl },
    RunBillingTickUseCase,
    BillingScheduler,
  ],
})
export class BillingModule {}
