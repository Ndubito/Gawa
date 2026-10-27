import {
  billingPeriod,
  memberShare,
  nextReminderSlot,
  periodsToBill,
  planCycle,
  reminderLadder,
} from './billing-calendar';
import { CycleStatus, ReminderKind } from './billing.types';
import {
  Currency,
  SubscriptionSchedule,
} from '../../subscriptions/domain/types/subscription.types';

// All expectations are written in Nairobi time (UTC+3) for readability.
const eat = (local: string) => new Date(`${local}+03:00`);

describe('billing calendar', () => {
  describe('billingPeriod', () => {
    it('is due at 09:00 Nairobi on the billing date and spans to the next one', () => {
      const p = billingPeriod(
        eat('2026-11-05T15:30:00'),
        SubscriptionSchedule.MONTHLY,
        0,
      );
      expect(p.dueAt).toEqual(eat('2026-11-05T09:00:00'));
      expect(p.periodStart).toEqual(eat('2026-11-05T00:00:00'));
      expect(p.periodEnd).toEqual(eat('2026-12-05T00:00:00'));
    });

    it('uses the Nairobi calendar date, not the UTC one', () => {
      // 01:00 Nairobi on the 1st is still the 31st in UTC
      const p = billingPeriod(
        eat('2026-11-01T01:00:00'),
        SubscriptionSchedule.MONTHLY,
        0,
      );
      expect(p.dueAt).toEqual(eat('2026-11-01T09:00:00'));
    });

    it('clamps month-end anchors without drifting', () => {
      const start = eat('2027-01-31T10:00:00');
      const due = (n: number) =>
        billingPeriod(start, SubscriptionSchedule.MONTHLY, n).dueAt;
      expect(due(1)).toEqual(eat('2027-02-28T09:00:00'));
      expect(due(2)).toEqual(eat('2027-03-31T09:00:00'));
      expect(due(3)).toEqual(eat('2027-04-30T09:00:00'));
      expect(due(12)).toEqual(eat('2028-01-31T09:00:00'));
    });

    it('uses Feb 29 in leap years and Feb 28 otherwise for yearly plans', () => {
      const start = eat('2028-02-29T10:00:00');
      expect(
        billingPeriod(start, SubscriptionSchedule.YEARLY, 1).dueAt,
      ).toEqual(eat('2029-02-28T09:00:00'));
      expect(
        billingPeriod(start, SubscriptionSchedule.YEARLY, 4).dueAt,
      ).toEqual(eat('2032-02-29T09:00:00'));
    });

    it.each([
      [SubscriptionSchedule.DAILY, '2026-11-06T09:00:00'],
      [SubscriptionSchedule.WEEKLY, '2026-11-12T09:00:00'],
      [SubscriptionSchedule.YEARLY, '2027-11-05T09:00:00'],
    ])('steps %s periods correctly', (schedule, expected) => {
      expect(
        billingPeriod(eat('2026-11-05T12:00:00'), schedule, 1).dueAt,
      ).toEqual(eat(expected));
    });
  });

  describe('nextReminderSlot', () => {
    it.each([
      ['2026-11-05T07:00:00', '2026-11-05T09:00:00'],
      ['2026-11-05T09:00:00', '2026-11-05T09:00:00'],
      ['2026-11-05T09:01:00', '2026-11-06T09:00:00'],
      ['2026-11-05T23:30:00', '2026-11-06T09:00:00'],
    ])('rounds %s up to %s', (instant, expected) => {
      expect(nextReminderSlot(eat(instant))).toEqual(eat(expected));
    });
  });

  describe('periodsToBill', () => {
    const monthly = (start: string, created: string) => ({
      startDate: eat(start),
      createdAt: eat(created),
      schedule: SubscriptionSchedule.MONTHLY,
    });

    it('bills a period three days before it is due', () => {
      const sub = monthly('2026-11-01T00:00:00', '2026-10-20T12:00:00');
      expect(periodsToBill(sub, eat('2026-10-29T08:59:00'))).toEqual([]);
      expect(
        periodsToBill(sub, eat('2026-10-29T09:00:00')).map((p) => p.dueAt),
      ).toEqual([eat('2026-11-01T09:00:00')]);
    });

    it('bills a new subscription due today straight away', () => {
      const sub = monthly('2026-11-05T00:00:00', '2026-11-05T14:00:00');
      expect(
        periodsToBill(sub, eat('2026-11-05T14:00:00')).map((p) => p.index),
      ).toEqual([0]);
    });

    it('never back-bills periods due before the subscription was created', () => {
      // Created on the 27th with a start date of the 1st: the first bill is next month's
      const sub = monthly('2026-10-01T00:00:00', '2026-10-27T12:00:00');
      expect(periodsToBill(sub, eat('2026-10-27T12:00:00'))).toEqual([]);
      expect(
        periodsToBill(sub, eat('2026-10-29T09:00:00')).map((p) => p.dueAt),
      ).toEqual([eat('2026-11-01T09:00:00')]);
    });

    it('catches up the current period of an older subscription, but not ended ones', () => {
      const sub = monthly('2026-07-01T00:00:00', '2026-07-01T08:00:00');
      expect(
        periodsToBill(sub, eat('2026-10-27T12:00:00')).map((p) => p.dueAt),
      ).toEqual([eat('2026-10-01T09:00:00')]);
    });

    it('keeps every upcoming daily period inside the lead window', () => {
      const sub = {
        startDate: eat('2026-01-01T00:00:00'),
        createdAt: eat('2026-01-01T00:00:00'),
        schedule: SubscriptionSchedule.DAILY,
      };
      expect(
        periodsToBill(sub, eat('2026-11-05T10:00:00')).map((p) => p.dueAt),
      ).toEqual([
        eat('2026-11-05T09:00:00'),
        eat('2026-11-06T09:00:00'),
        eat('2026-11-07T09:00:00'),
        eat('2026-11-08T09:00:00'),
      ]);
    });

    it('waits for a start date in the future', () => {
      const sub = monthly('2027-03-15T00:00:00', '2026-11-05T12:00:00');
      expect(periodsToBill(sub, eat('2026-11-05T12:00:00'))).toEqual([]);
    });
  });

  describe('memberShare', () => {
    it('splits equally between the owner and members', () => {
      expect(memberShare(150_000, 2)).toBe(50_000);
    });

    it('leaves leftover cents with the owner rather than overcharging', () => {
      expect(memberShare(100_000, 2)).toBe(33_333);
    });
  });

  describe('reminderLadder', () => {
    const due = eat('2026-11-01T09:00:00');
    const overdue = eat('2026-11-03T09:00:00'); // 48h grace

    it('schedules the balanced ladder at 09:00 Nairobi', () => {
      const ladder = reminderLadder(due, overdue, eat('2026-10-20T12:00:00'));
      expect(ladder.map((r) => [r.kind, r.sequence, r.scheduledFor])).toEqual([
        [ReminderKind.UPCOMING, 0, eat('2026-10-29T09:00:00')],
        [ReminderKind.DUE, 0, eat('2026-11-01T09:00:00')],
        [ReminderKind.OVERDUE, 0, eat('2026-11-03T09:00:00')],
        [ReminderKind.NUDGE, 1, eat('2026-11-06T09:00:00')],
        [ReminderKind.NUDGE, 2, eat('2026-11-09T09:00:00')],
        [ReminderKind.NUDGE, 3, eat('2026-11-12T09:00:00')],
      ]);
    });

    it('sends an overdue reminder at the next 09:00 after grace runs out', () => {
      const ladder = reminderLadder(
        due,
        eat('2026-11-02T15:00:00'),
        eat('2026-10-20T12:00:00'),
      );
      expect(
        ladder.find((r) => r.kind === ReminderKind.OVERDUE)!.scheduledFor,
      ).toEqual(eat('2026-11-03T09:00:00'));
    });

    it('sends only the latest missed reminder, immediately', () => {
      const now = eat('2026-11-02T10:00:00');
      const ladder = reminderLadder(due, overdue, now);
      expect(ladder.map((r) => [r.kind, r.scheduledFor])).toEqual([
        [ReminderKind.DUE, now],
        [ReminderKind.OVERDUE, eat('2026-11-03T09:00:00')],
        [ReminderKind.NUDGE, eat('2026-11-06T09:00:00')],
        [ReminderKind.NUDGE, eat('2026-11-09T09:00:00')],
        [ReminderKind.NUDGE, eat('2026-11-12T09:00:00')],
      ]);
    });
  });

  describe('planCycle', () => {
    const subscription = {
      id: 5,
      recipientId: 1,
      amountCents: 150_000,
      currency: Currency.KES,
      schedule: SubscriptionSchedule.MONTHLY,
      graceHours: 48,
      startDate: eat('2026-11-01T00:00:00'),
      createdAt: eat('2026-10-20T12:00:00'),
      memberIds: [2, 3],
    };

    it('creates one obligation per member, payable to the owner', () => {
      const period = billingPeriod(
        subscription.startDate,
        subscription.schedule,
        0,
      );
      const plan = planCycle(subscription, period, eat('2026-10-29T09:00:00'));

      expect(plan.status).toBe(CycleStatus.UPCOMING);
      expect(
        plan.obligations.map((o) => [o.userId, o.recipientId, o.amountDue]),
      ).toEqual([
        [2, 1, 50_000],
        [3, 1, 50_000],
      ]);
      expect(plan.obligations[0].overdueAt).toEqual(eat('2026-11-03T09:00:00'));
    });

    it('marks a cycle created after its due date as active', () => {
      const period = billingPeriod(
        subscription.startDate,
        subscription.schedule,
        0,
      );
      expect(
        planCycle(subscription, period, eat('2026-11-01T12:00:00')).status,
      ).toBe(CycleStatus.ACTIVE);
    });

    it('creates a cycle with no obligations when the owner is alone', () => {
      const period = billingPeriod(
        subscription.startDate,
        subscription.schedule,
        0,
      );
      expect(
        planCycle(
          { ...subscription, memberIds: [] },
          period,
          eat('2026-10-29T09:00:00'),
        ).obligations,
      ).toEqual([]);
    });
  });
});
