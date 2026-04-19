import { Module } from '@nestjs/common';
import { PaymentController } from './presentation/payment.controller';
import { CreatePaymentUseCase } from './application/create-payment.usecase';
import { GetPaymentUseCase } from './application/get-payment.usecase';
import { PAYMENT_REPOSITORY_TOKEN } from './domain/repos/payment.repository';
import { PaymentRepositoryImpl } from './infrastructure/prisma/payment.repository.impl';
import { PrismaService } from '../../../prisma/prisma.service';

@Module({
  controllers: [PaymentController],
  providers: [
    PrismaService,
    {
      provide: PAYMENT_REPOSITORY_TOKEN,
      useClass: PaymentRepositoryImpl,
    },
    CreatePaymentUseCase,
    GetPaymentUseCase,
  ],
  exports: [
    CreatePaymentUseCase,
    GetPaymentUseCase,
    PAYMENT_REPOSITORY_TOKEN,
  ],
})
export class PaymentsModule {}
