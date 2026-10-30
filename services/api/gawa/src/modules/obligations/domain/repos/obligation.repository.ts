import { Obligation } from '../entities/obligation.entity';
import { ObligationView } from '../types/obligation-view';

// Narrows which unpaid *subscription* obligations to cancel; all set fields must
// match. Expense debts are never matched: they were incurred when logged, so
// leaving or deleting a group does not wipe them.
export interface CancelUnpaidFilter {
  subscriptionId?: number;
  groupId?: number;
  userId?: number;
  // Only obligations due strictly after this instant
  dueAfter: Date;
}

export interface IObligationRepository {
  findById(id: number): Promise<Obligation | null>;
  findViewById(id: number): Promise<ObligationView | null>;
  // Bills where the user is the debtor or the creditor: every open one, plus
  // settled ones last changed on or after `settledSince`
  findViewsForUser(
    userId: number,
    settledSince: Date,
  ): Promise<ObligationView[]>;
  save(obligation: Obligation): Promise<Obligation>;
  update(obligation: Obligation): Promise<Obligation>;
  cancelUnpaid(filter: CancelUnpaidFilter): Promise<number>;
}

export const OBLIGATION_REPOSITORY_TOKEN = Symbol(
  'OBLIGATION_REPOSITORY_TOKEN',
);
