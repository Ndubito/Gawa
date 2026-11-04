import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import {
  type IExpenseRepository,
  EXPENSE_REPOSITORY_TOKEN,
} from '../domain/repos/expense.repository';
import { GetExpenseUseCase } from './get-expense.usecase';

@Injectable()
export class DeleteExpenseUseCase {
  constructor(
    @Inject(EXPENSE_REPOSITORY_TOKEN)
    private readonly expenseRepository: IExpenseRepository,
    private readonly getExpense: GetExpenseUseCase,
  ) {}

  // Only the payer may delete. It's their money, so deleting waives every
  // unpaid share — including ones already due.
  async execute(id: number, requesterId: number): Promise<void> {
    const expense = await this.getExpense.execute(id, requesterId);
    if (!expense.isPaidBy(requesterId)) {
      throw new NotFoundException(`Expense ${id} not found`);
    }
    await this.expenseRepository.deleteAndCancelUnpaid(id);
  }
}
