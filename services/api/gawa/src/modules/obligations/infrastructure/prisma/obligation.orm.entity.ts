import { Obligation } from '../../domain/entities/obligation.entity';
import { Currency, ObligationSourceType, ObligationStatus } from '../../domain/types/obligation.types';

export interface ObligationOrmEntity {
  obligation_id: number;
  subscription_cycle_id: number | null;
  expense_id: number | null;
  user_id: number;
  recipient_id: number;
  source_type: string;
  amount_due: number;
  amount_paid: number;
  currency: string;
  status: string;
  due_at: Date;
  created_at: Date;
  updated_at: Date;
}

export class ObligationMapper {
  static toDomain(raw: ObligationOrmEntity): Obligation {
    return new Obligation({
      id: raw.obligation_id,
      subscriptionCycleId: raw.subscription_cycle_id,
      expenseId: raw.expense_id,
      userId: raw.user_id,
      recipientId: raw.recipient_id,
      sourceType: raw.source_type as ObligationSourceType,
      amountDue: raw.amount_due,
      amountPaid: raw.amount_paid,
      currency: raw.currency as Currency,
      status: raw.status as ObligationStatus,
      dueAt: raw.due_at,
      createdAt: raw.created_at,
      updatedAt: raw.updated_at,
    });
  }

  static toOrm(obligation: Obligation): Omit<ObligationOrmEntity, 'obligation_id' | 'created_at' | 'updated_at'> & Partial<ObligationOrmEntity> {
    return {
      obligation_id: obligation.id,
      subscription_cycle_id: obligation.subscriptionCycleId ?? null,
      expense_id: obligation.expenseId ?? null,
      user_id: obligation.userId,
      recipient_id: obligation.recipientId,
      source_type: obligation.sourceType as string,
      amount_due: obligation.amountDue,
      amount_paid: obligation.amountPaid,
      currency: obligation.currency as string,
      status: obligation.status as string,
      due_at: obligation.dueAt,
    };
  }
}
