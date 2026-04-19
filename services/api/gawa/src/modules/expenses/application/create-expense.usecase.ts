import { Injectable, Inject } from '@nestjs/common';
import { Expense } from '../domain/entities/expense.entity';
import { type IExpenseRepository, EXPENSE_REPOSITORY_TOKEN } from '../domain/repos/expense.repository';
import { CreateExpenseDto } from '../presentation/dtos/create-expense.dto';

@Injectable()
export class CreateExpenseUseCase {
  constructor(
    @Inject(EXPENSE_REPOSITORY_TOKEN)
    private readonly expenseRepository: IExpenseRepository,
  ) {}

  async execute(dto: CreateExpenseDto): Promise<Expense> {
    const expense = new Expense({
      organizerId: dto.organizerId,
      groupId: dto.groupId,
      payerId: dto.payerId,
      totalAmount: dto.totalAmount,
      name: dto.name,
      description: dto.description,
    });
    return this.expenseRepository.save(expense);
  }
}
