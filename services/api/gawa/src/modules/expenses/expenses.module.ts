import { Module } from '@nestjs/common';
import { GroupsModule } from '../groups/groups.module';
import { ExpenseController } from './presentation/expense.controller';
import { CreateExpenseUseCase } from './application/create-expense.usecase';
import { GetExpenseUseCase } from './application/get-expense.usecase';
import { UpdateExpenseUseCase } from './application/update-expense.usecase';
import { DeleteExpenseUseCase } from './application/delete-expense.usecase';
import { EXPENSE_REPOSITORY_TOKEN } from './domain/repos/expense.repository';
import { ExpenseRepositoryImpl } from './infrastructure/prisma/expense.repository.impl';
import { PrismaService } from '../../../prisma/prisma.service';
import { clockProvider } from '../../common/clock';

@Module({
  imports: [GroupsModule],
  controllers: [ExpenseController],
  providers: [
    PrismaService,
    clockProvider,
    {
      provide: EXPENSE_REPOSITORY_TOKEN,
      useClass: ExpenseRepositoryImpl,
    },
    CreateExpenseUseCase,
    GetExpenseUseCase,
    UpdateExpenseUseCase,
    DeleteExpenseUseCase,
  ],
})
export class ExpensesModule {}
