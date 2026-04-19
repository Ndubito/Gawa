import { Expense } from '../../domain/entities/expense.entity';

export interface ExpenseOrmEntity {
  expense_id: number;
  organizer_id: number;
  group_id: number | null;
  payer_id: number;
  total_amount: number;
  name: string;
  description: string | null;
  created_at: Date;
  updated_at: Date;
  deleted_at: Date | null;
}

export class ExpenseMapper {
  static toDomain(raw: ExpenseOrmEntity): Expense {
    return new Expense({
      id: raw.expense_id,
      organizerId: raw.organizer_id,
      groupId: raw.group_id,
      payerId: raw.payer_id,
      totalAmount: raw.total_amount,
      name: raw.name,
      description: raw.description,
      createdAt: raw.created_at,
      updatedAt: raw.updated_at,
      deletedAt: raw.deleted_at,
    });
  }

  static toOrm(expense: Expense): Omit<ExpenseOrmEntity, 'expense_id' | 'created_at' | 'updated_at' | 'deleted_at'> & Partial<ExpenseOrmEntity> {
    return {
      expense_id: expense.id,
      organizer_id: expense.organizerId,
      group_id: expense.groupId ?? null,
      payer_id: expense.payerId,
      total_amount: expense.totalAmount,
      name: expense.name,
      description: expense.description ?? null,
    };
  }
}
