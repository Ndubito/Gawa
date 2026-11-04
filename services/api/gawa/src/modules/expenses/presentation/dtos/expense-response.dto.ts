import { Expense } from '../../domain/entities/expense.entity';

export class ExpenseSplitResponseDto {
  userId: number;
  amountCents: number;
}

export class ExpenseResponseDto {
  id: number;
  groupId: number;
  payerId: number;
  name: string;
  description: string | null;
  totalAmountCents: number;
  dueAt: Date;
  createdAt: Date;
  splits: ExpenseSplitResponseDto[];

  constructor(expense: Expense) {
    this.id = expense.id!;
    this.groupId = expense.groupId;
    this.payerId = expense.payerId;
    this.name = expense.name;
    this.description = expense.description ?? null;
    this.totalAmountCents = expense.totalAmount;
    this.dueAt = expense.dueAt;
    this.createdAt = expense.createdAt;
    this.splits = expense.splits.map((s) => ({
      userId: s.userId,
      amountCents: s.amount,
    }));
  }
}
