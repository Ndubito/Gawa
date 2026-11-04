import {
  Currency,
  ObligationSourceType,
  ObligationStatus,
} from './obligation.types';

// Read model for showing a bill to the people involved: who, what for, how much.
export interface ObligationParty {
  userId: number;
  name: string;
}

export interface ObligationSource {
  type: ObligationSourceType;
  // Subscription or expense name, e.g. "Netflix" or "Dinner"
  name: string;
  groupId: number | null;
  groupName: string | null;
  // Billing period, for subscription bills only
  periodStart: Date | null;
  periodEnd: Date | null;
}

export interface ObligationView {
  id: number;
  debtor: ObligationParty;
  creditor: ObligationParty;
  source: ObligationSource;
  amountDue: number;
  amountPaid: number;
  currency: Currency;
  status: ObligationStatus;
  dueAt: Date;
  overdueAt: Date;
  updatedAt: Date;
}

export const OPEN_STATUSES = [
  ObligationStatus.PENDING,
  ObligationStatus.PARTIAL,
  ObligationStatus.OVERDUE,
];

// Paid or cancelled bills stay visible this long as recent history.
export const SETTLED_HISTORY_DAYS = 90;
