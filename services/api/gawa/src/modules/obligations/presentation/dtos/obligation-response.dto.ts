import { ObligationView } from '../../domain/types/obligation-view';

export type ObligationDirection = 'OWE' | 'OWED';

// A bill phrased from the requester's side: whether they owe it or are owed it,
// and who the other person is.
export class ObligationResponseDto {
  id: number;
  direction: ObligationDirection;
  counterparty: { userId: number; name: string };
  source: {
    type: string;
    name: string;
    groupId: number | null;
    groupName: string | null;
    periodStart: Date | null;
    periodEnd: Date | null;
  };
  amountDue: number;
  amountPaid: number;
  currency: string;
  status: string;
  dueAt: Date;
  overdueAt: Date;
  updatedAt: Date;

  constructor(view: ObligationView, requesterId: number) {
    const owes = view.debtor.userId === requesterId;
    this.id = view.id;
    this.direction = owes ? 'OWE' : 'OWED';
    this.counterparty = owes ? view.creditor : view.debtor;
    this.source = view.source;
    this.amountDue = view.amountDue;
    this.amountPaid = view.amountPaid;
    this.currency = view.currency;
    this.status = view.status;
    this.dueAt = view.dueAt;
    this.overdueAt = view.overdueAt;
    this.updatedAt = view.updatedAt;
  }
}
