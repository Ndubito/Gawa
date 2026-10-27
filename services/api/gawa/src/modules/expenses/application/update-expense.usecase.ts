import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { Expense } from '../domain/entities/expense.entity';
import {
  type IExpenseRepository,
  EXPENSE_REPOSITORY_TOKEN,
} from '../domain/repos/expense.repository';
import { GetExpenseUseCase } from './get-expense.usecase';

export interface UpdateExpenseInput {
  id: number;
  name?: string;
  description?: string;
}

@Injectable()
export class UpdateExpenseUseCase {
  constructor(
    @Inject(EXPENSE_REPOSITORY_TOKEN)
    private readonly expenseRepository: IExpenseRepository,
    private readonly getExpense: GetExpenseUseCase,
  ) {}

  // Only the payer may rename; other group members get a 404 like strangers.
  async execute(
    input: UpdateExpenseInput,
    requesterId: number,
  ): Promise<Expense> {
    const expense = await this.getExpense.execute(input.id, requesterId);
    if (!expense.isPaidBy(requesterId)) {
      throw new NotFoundException(`Expense ${input.id} not found`);
    }

    expense.rename(input.name, input.description);
    return this.expenseRepository.update(expense);
  }
}
