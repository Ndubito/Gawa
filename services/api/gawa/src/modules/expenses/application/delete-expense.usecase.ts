import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { type IExpenseRepository, EXPENSE_REPOSITORY_TOKEN } from '../domain/repos/expense.repository';

@Injectable()
export class DeleteExpenseUseCase {
  constructor(
    @Inject(EXPENSE_REPOSITORY_TOKEN)
    private readonly expenseRepository: IExpenseRepository,
  ) {}

  async execute(id: number): Promise<void> {
    const expense = await this.expenseRepository.findById(id);
    if (!expense) throw new NotFoundException(`Expense with ID ${id} not found`);

    expense.delete();
    await this.expenseRepository.delete(id);
  }
}
