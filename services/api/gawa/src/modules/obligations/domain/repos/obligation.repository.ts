import { Obligation } from '../entities/obligation.entity';

// Narrows which unpaid subscription obligations to cancel; all set fields must match.
export interface CancelUnpaidFilter {
  subscriptionId?: number;
  groupId?: number;
  userId?: number;
  // Only obligations due strictly after this instant
  dueAfter: Date;
}

export interface IObligationRepository {
  findById(id: number): Promise<Obligation | null>;
  // Obligations where the user is the debtor or the creditor
  findForUser(userId: number): Promise<Obligation[]>;
  save(obligation: Obligation): Promise<Obligation>;
  update(obligation: Obligation): Promise<Obligation>;
  cancelUnpaid(filter: CancelUnpaidFilter): Promise<number>;
}

export const OBLIGATION_REPOSITORY_TOKEN = Symbol(
  'OBLIGATION_REPOSITORY_TOKEN',
);
