export enum ObligationStatus {
  PENDING = 'PENDING',
  PARTIAL = 'PARTIAL',
  PAID = 'PAID',
  CANCELLED = 'CANCELLED',
  OVERDUE = 'OVERDUE',
}

export enum ObligationSourceType {
  SUBSCRIPTION_CYCLE = 'SUBSCRIPTION_CYCLE',
  EXPENSE = 'EXPENSE',
}

export enum Currency {
  KES = 'KES',
  USD = 'USD',
  EUR = 'EUR',
}

export interface ObligationProps {
  id?: number;
  subscriptionCycleId?: number | null;
  expenseId?: number | null;
  userId: number;
  recipientId: number;
  sourceType: ObligationSourceType;
  amountDue: number;
  amountPaid?: number;
  currency?: Currency;
  status?: ObligationStatus;
  dueAt: Date;
  createdAt?: Date;
  updatedAt?: Date;
}
