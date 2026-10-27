import { PlannedReminder } from '../../../billing/domain/billing.types';

export const DEFAULT_DUE_IN_DAYS = 3;
export const MAX_DUE_IN_DAYS = 14;
export const EXPENSE_GRACE_HOURS = 24;

// What one participant's share of an expense came to, in cents.
export interface ExpenseSplit {
  userId: number;
  amount: number;
}

export interface ExpenseProps {
  id?: number;
  groupId: number;
  // Always the person who logged it; they are owed everyone else's share
  payerId: number;
  totalAmount: number;
  name: string;
  description?: string | null;
  dueAt: Date;
  splits: ExpenseSplit[];
  createdAt?: Date;
  updatedAt?: Date;
  deletedAt?: Date | null;
}

// An obligation to create for one participant who isn't the payer.
export interface ExpenseDebt {
  userId: number;
  amountDue: number;
  overdueAt: Date;
  reminders: PlannedReminder[];
}
