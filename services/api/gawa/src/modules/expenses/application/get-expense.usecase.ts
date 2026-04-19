import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { Expense } from '../domain/entities/expense.entity';
import { type IExpenseRepository, EXPENSE_REPOSITORY_TOKEN } from '../domain/repos/expense.repository';

@Injectable()
export class GetExpenseUseCase {
  constructor(
    @Inject(EXPENSE_REPOSITORY_TOKEN)
    private readonly expenseRepository: IExpenseRepository,
  ) {}

  async execute(id: number): Promise<Expense> {
    const expense = await this.expenseRepository.findById(id);
    if (!expense) throw new NotFoundException(`Expense with ID ${id} not found`);
    return expense;
  }

  async executeAll(): Promise<Expense[]> {
    return this.expenseRepository.findAll();
  }
}
