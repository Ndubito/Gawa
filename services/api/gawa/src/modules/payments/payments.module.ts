import { Module } from '@nestjs/common';
import { ObligationsModule } from '../obligations/obligations.module';
import { PaymentController } from './presentation/payment.controller';
import { GetPaymentUseCase } from './application/get-payment.usecase';
import { PAYMENT_REPOSITORY_TOKEN } from './domain/repos/payment.repository';
import { PaymentRepositoryImpl } from './infrastructure/prisma/payment.repository.impl';
import { PrismaService } from '../../../prisma/prisma.service';

@Module({
  imports: [ObligationsModule],
  controllers: [PaymentController],
  providers: [
    PrismaService,
    {
      provide: PAYMENT_REPOSITORY_TOKEN,
      useClass: PaymentRepositoryImpl,
    },
    GetPaymentUseCase,
  ],
  exports: [GetPaymentUseCase, PAYMENT_REPOSITORY_TOKEN],
})
export class PaymentsModule {}
