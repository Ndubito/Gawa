import { Expense } from '../entities/expense.entity';
import { ExpenseDebt } from '../types/expense.types';

export interface IExpenseRepository {
  // Non-deleted expense with its splits
  findById(id: number): Promise<Expense | null>;
  findByGroupId(groupId: number): Promise<Expense[]>;
  // Saves the expense, its splits, and each debtor's obligation and reminders atomically
  create(expense: Expense, debts: ExpenseDebt[]): Promise<Expense>;
  update(expense: Expense): Promise<Expense>;
  // Soft-deletes the expense and cancels every unpaid obligation from it
  deleteAndCancelUnpaid(id: number): Promise<void>;
}

export const EXPENSE_REPOSITORY_TOKEN = Symbol('EXPENSE_REPOSITORY_TOKEN');
