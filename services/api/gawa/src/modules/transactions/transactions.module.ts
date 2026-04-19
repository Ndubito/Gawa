import { Module } from '@nestjs/common';
import { TransactionController } from './presentation/transaction.controller';
import { GetTransactionUseCase } from './application/get-transaction.usecase';
import { TRANSACTION_REPOSITORY_TOKEN } from './domain/repos/transaction.repository';
import { TransactionRepositoryImpl } from './infrastructure/prisma/transaction.repository.impl';
import { PrismaService } from '../../../prisma/prisma.service';

@Module({
  controllers: [TransactionController],
  providers: [
    PrismaService,
    {
      provide: TRANSACTION_REPOSITORY_TOKEN,
      useClass: TransactionRepositoryImpl,
    },
    GetTransactionUseCase,
  ],
  exports: [
    GetTransactionUseCase,
    TRANSACTION_REPOSITORY_TOKEN,
  ],
})
export class TransactionsModule {}
