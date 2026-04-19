import { Expense } from '../entities/expense.entity';

export interface IExpenseRepository {
  findById(id: number): Promise<Expense | null>;
  findAll(): Promise<Expense[]>;
  save(expense: Expense): Promise<Expense>;
  update(expense: Expense): Promise<Expense>;
  delete(id: number): Promise<void>;
}

export const EXPENSE_REPOSITORY_TOKEN = Symbol('EXPENSE_REPOSITORY_TOKEN');
