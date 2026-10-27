import { RunBillingTickUseCase } from './run-billing-tick.usecase';
import { IBillingRepository } from '../domain/billing.repository';
import { BillableSubscription, CyclePlan } from '../domain/billing.types';
import {
  Currency,
  SubscriptionSchedule,
} from '../../subscriptions/domain/types/subscription.types';

const eat = (local: string) => new Date(`${local}+03:00`);

// Mirrors the database's (subscription, period_start) uniqueness.
class InMemoryBillingRepository implements IBillingRepository {
  subscriptions: BillableSubscription[] = [];
  cycles: CyclePlan[] = [];
  overdueMarked = 0;

  async findBillableSubscriptions() {
    return this.subscriptions;
  }

  async findOpenCyclePeriodStarts(now: Date) {
    const map = new Map<number, Set<number>>();
    for (const c of this.cycles.filter((c) => c.periodEnd > now)) {
      const set = map.get(c.subscriptionId) ?? new Set<number>();
      set.add(c.periodStart.getTime());
      map.set(c.subscriptionId, set);
    }
    return map;
  }

  async createCycle(plan: CyclePlan) {
    const exists = this.cycles.some(
      (c) =>
        c.subscriptionId === plan.subscriptionId &&
        c.periodStart.getTime() === plan.periodStart.getTime(),
    );
    if (!exists) this.cycles.push(plan);
    return !exists;
  }

  async advanceCycleStatuses() {}

  async markOverdueObligations() {
    return this.overdueMarked;
  }
}

const netflix = (
  overrides: Partial<BillableSubscription> = {},
): BillableSubscription => ({
  id: 5,
  recipientId: 1,
  amountCents: 150_000,
  currency: Currency.KES,
  schedule: SubscriptionSchedule.MONTHLY,
  graceHours: 48,
  startDate: eat('2026-11-01T00:00:00'),
  createdAt: eat('2026-10-20T12:00:00'),
  memberIds: [2, 3],
  ...overrides,
});

describe('RunBillingTickUseCase', () => {
  let repo: InMemoryBillingRepository;
  let now: Date;
  let tick: RunBillingTickUseCase;

  beforeEach(() => {
    repo = new InMemoryBillingRepository();
    now = eat('2026-10-29T09:00:00');
    tick = new RunBillingTickUseCase(repo, () => now);
  });

  it('bills a due-soon period with obligations for each member', async () => {
    repo.subscriptions = [netflix()];

    const result = await tick.execute();

    expect(result).toEqual({
      cyclesCreated: 1,
      obligationsCreated: 2,
      obligationsMarkedOverdue: 0,
    });
    expect(repo.cycles[0].dueAt).toEqual(eat('2026-11-01T09:00:00'));
  });

  it('never bills the same period twice across ticks', async () => {
    repo.subscriptions = [netflix()];

    await tick.execute();
    now = eat('2026-10-29T09:15:00');
    const second = await tick.execute();

    expect(second.cyclesCreated).toBe(0);
    expect(repo.cycles).toHaveLength(1);
  });

  it('bills the next period when its lead window opens', async () => {
    repo.subscriptions = [netflix()];
    await tick.execute();

    now = eat('2026-11-28T09:00:00');
    await tick.execute();

    expect(repo.cycles.map((c) => c.dueAt)).toEqual([
      eat('2026-11-01T09:00:00'),
      eat('2026-12-01T09:00:00'),
    ]);
  });

  it('snapshots the members at billing time', async () => {
    repo.subscriptions = [netflix()];
    await tick.execute();

    repo.subscriptions = [netflix({ memberIds: [2, 3, 4] })];
    now = eat('2026-11-28T09:00:00');
    await tick.execute();

    expect(repo.cycles[0].obligations.map((o) => o.userId)).toEqual([2, 3]);
    expect(
      repo.cycles[1].obligations.map((o) => [o.userId, o.amountDue]),
    ).toEqual([
      [2, 37_500],
      [3, 37_500],
      [4, 37_500],
    ]);
  });

  it('reports obligations that went overdue', async () => {
    repo.overdueMarked = 3;
    expect((await tick.execute()).obligationsMarkedOverdue).toBe(3);
  });
});
