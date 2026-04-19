import { Module } from '@nestjs/common';
import { ExpenseController } from './presentation/expense.controller';
import { CreateExpenseUseCase } from './application/create-expense.usecase';
import { GetExpenseUseCase } from './application/get-expense.usecase';
import { UpdateExpenseUseCase } from './application/update-expense.usecase';
import { DeleteExpenseUseCase } from './application/delete-expense.usecase';
import { EXPENSE_REPOSITORY_TOKEN } from './domain/repos/expense.repository';
import { ExpenseRepositoryImpl } from './infrastructure/prisma/expense.repository.impl';
import { PrismaService } from '../../../prisma/prisma.service';

@Module({
  controllers: [ExpenseController],
  providers: [
    PrismaService,
    {
      provide: EXPENSE_REPOSITORY_TOKEN,
      useClass: ExpenseRepositoryImpl,
    },
    CreateExpenseUseCase,
    GetExpenseUseCase,
    UpdateExpenseUseCase,
    DeleteExpenseUseCase,
  ],
  exports: [
    CreateExpenseUseCase,
    GetExpenseUseCase,
    UpdateExpenseUseCase,
    DeleteExpenseUseCase,
    EXPENSE_REPOSITORY_TOKEN,
  ],
})
export class ExpensesModule {}
