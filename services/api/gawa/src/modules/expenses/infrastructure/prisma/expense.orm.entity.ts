import { Expense } from '../../domain/entities/expense.entity';

export interface ExpenseOrmEntity {
  expense_id: number;
  group_id: number | null;
  payer_id: number;
  total_amount: number;
  name: string;
  description: string | null;
  due_at: Date;
  created_at: Date;
  updated_at: Date;
  deleted_at: Date | null;
  splits: { user_id: number; share_value: number }[];
}

export class ExpenseMapper {
  static toDomain(raw: ExpenseOrmEntity): Expense {
    return new Expense({
      id: raw.expense_id,
      // Expenses are always created in a group; group_id is nullable only in the schema
      groupId: raw.group_id!,
      payerId: raw.payer_id,
      totalAmount: raw.total_amount,
      name: raw.name,
      description: raw.description,
      dueAt: raw.due_at,
      splits: raw.splits.map((s) => ({
        userId: s.user_id,
        amount: s.share_value,
      })),
      createdAt: raw.created_at,
      updatedAt: raw.updated_at,
      deletedAt: raw.deleted_at,
    });
  }
}
