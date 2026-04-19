export enum SubscriptionStatus {
  ACTIVE = 'ACTIVE',
  PAUSED = 'PAUSED',
  CANCELLED = 'CANCELLED',
}

export enum SubscriptionSchedule {
  DAILY = 'DAILY',
  WEEKLY = 'WEEKLY',
  MONTHLY = 'MONTHLY',
  YEARLY = 'YEARLY',
}

export enum Currency {
  KES = 'KES',
  USD = 'USD',
  EUR = 'EUR',
}

export interface SubscriptionProps {
  id?: number;
  groupId: number;
  recipientId: number;
  organizerId: number;
  name: string;
  description?: string | null;
  amountCents: number;
  currency?: Currency;
  schedule: SubscriptionSchedule;
  graceHours: number;
  status?: SubscriptionStatus;
  startDate: Date;
  createdAt?: Date;
  updatedAt?: Date;
  deletedAt?: Date | null;
}
