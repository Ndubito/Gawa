import { BillableSubscription, CyclePlan } from './billing.types';

export interface IBillingRepository {
  // Active, non-deleted subscriptions in live groups, with their accepted members
  findBillableSubscriptions(): Promise<BillableSubscription[]>;
  // period_start (ms) of every cycle that hasn't ended yet, keyed by subscription id
  findOpenCyclePeriodStarts(now: Date): Promise<Map<number, Set<number>>>;
  // Persists a cycle with its obligations and reminders atomically.
  // Returns false if that period was already billed (e.g. by a concurrent run).
  createCycle(plan: CyclePlan): Promise<boolean>;
  advanceCycleStatuses(now: Date): Promise<void>;
  markOverdueObligations(now: Date): Promise<number>;
}

export const BILLING_REPOSITORY_TOKEN = Symbol('BILLING_REPOSITORY_TOKEN');
