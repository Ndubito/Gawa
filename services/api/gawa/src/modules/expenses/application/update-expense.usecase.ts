import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { Expense } from '../domain/entities/expense.entity';
import { type IExpenseRepository, EXPENSE_REPOSITORY_TOKEN } from '../domain/repos/expense.repository';

export interface UpdateExpenseDto {
  id: number;
  name?: string;
  description?: string;
  totalAmount?: number;
}

@Injectable()
export class UpdateExpenseUseCase {
  constructor(
    @Inject(EXPENSE_REPOSITORY_TOKEN)
    private readonly expenseRepository: IExpenseRepository,
  ) {}

  async execute(dto: UpdateExpenseDto): Promise<Expense> {
    const expense = await this.expenseRepository.findById(dto.id);
    if (!expense) throw new NotFoundException(`Expense with ID ${dto.id} not found`);

    expense.update(dto.name, dto.description, dto.totalAmount);
    return this.expenseRepository.update(expense);
  }
}
