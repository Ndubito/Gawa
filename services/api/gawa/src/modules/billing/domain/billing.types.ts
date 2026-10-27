import {
  Currency,
  SubscriptionSchedule,
} from '../../subscriptions/domain/types/subscription.types';

export enum CycleStatus {
  UPCOMING = 'UPCOMING',
  ACTIVE = 'ACTIVE',
  CLOSED = 'CLOSED',
}

export enum ReminderKind {
  UPCOMING = 'UPCOMING',
  DUE = 'DUE',
  OVERDUE = 'OVERDUE',
  NUDGE = 'NUDGE',
}

export interface BillingPeriod {
  index: number;
  periodStart: Date;
  periodEnd: Date;
  dueAt: Date;
}

// What the engine needs to know about a subscription to bill it.
export interface BillableSubscription {
  id: number;
  recipientId: number;
  amountCents: number;
  currency: Currency;
  schedule: SubscriptionSchedule;
  graceHours: number;
  startDate: Date;
  createdAt: Date;
  // Accepted members other than the recipient (the owner), at billing time
  memberIds: number[];
}

export interface PlannedReminder {
  kind: ReminderKind;
  sequence: number;
  scheduledFor: Date;
}

export interface ObligationPlan {
  userId: number;
  recipientId: number;
  amountDue: number;
  currency: Currency;
  dueAt: Date;
  overdueAt: Date;
  reminders: PlannedReminder[];
}

export interface CyclePlan {
  subscriptionId: number;
  periodStart: Date;
  periodEnd: Date;
  dueAt: Date;
  status: CycleStatus;
  obligations: ObligationPlan[];
}
