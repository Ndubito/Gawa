import { SubscriptionSchedule } from '../../subscriptions/domain/types/subscription.types';
import {
  BillableSubscription,
  BillingPeriod,
  CyclePlan,
  CycleStatus,
  PlannedReminder,
  ReminderKind,
} from './billing.types';

// Gawa bills in Kenyan time. Nairobi is UTC+3 all year (no daylight saving),
// so a fixed offset is exact.
export const NAIROBI_UTC_OFFSET_HOURS = 3;
export const REMINDER_HOUR = 9;
export const CYCLE_LEAD_DAYS = 3;
export const UPCOMING_REMINDER_DAYS = 3;
export const NUDGE_INTERVAL_DAYS = 3;
export const MAX_NUDGES = 3;

const HOUR_MS = 3_600_000;
const DAY_MS = 24 * HOUR_MS;

interface LocalDate {
  year: number;
  month: number; // 0-11
  day: number;
}

function toLocalDate(instant: Date): LocalDate {
  const shifted = new Date(
    instant.getTime() + NAIROBI_UTC_OFFSET_HOURS * HOUR_MS,
  );
  return {
    year: shifted.getUTCFullYear(),
    month: shifted.getUTCMonth(),
    day: shifted.getUTCDate(),
  };
}

function atLocalHour(date: LocalDate, hour: number): Date {
  return new Date(
    Date.UTC(date.year, date.month, date.day, hour - NAIROBI_UTC_OFFSET_HOURS),
  );
}

function addDays(date: LocalDate, days: number): LocalDate {
  const d = new Date(Date.UTC(date.year, date.month, date.day + days));
  return {
    year: d.getUTCFullYear(),
    month: d.getUTCMonth(),
    day: d.getUTCDate(),
  };
}

function daysInMonth(year: number, month: number): number {
  return new Date(Date.UTC(year, month + 1, 0)).getUTCDate();
}

// Months and years stay anchored to the start day, clamped to short months:
// a subscription starting on the 31st is due Feb 28, then Mar 31 — it never drifts.
function nthBillingDate(
  anchor: LocalDate,
  schedule: SubscriptionSchedule,
  n: number,
): LocalDate {
  switch (schedule) {
    case SubscriptionSchedule.DAILY:
      return addDays(anchor, n);
    case SubscriptionSchedule.WEEKLY:
      return addDays(anchor, 7 * n);
    case SubscriptionSchedule.MONTHLY: {
      const months = anchor.month + n;
      const year = anchor.year + Math.floor(months / 12);
      const month = months % 12;
      return {
        year,
        month,
        day: Math.min(anchor.day, daysInMonth(year, month)),
      };
    }
    case SubscriptionSchedule.YEARLY: {
      const year = anchor.year + n;
      return {
        year,
        month: anchor.month,
        day: Math.min(anchor.day, daysInMonth(year, anchor.month)),
      };
    }
  }
}

// Periods run from local midnight on one billing date to the next; payment is
// due at the start of the period, at the reminder hour.
export function billingPeriod(
  startDate: Date,
  schedule: SubscriptionSchedule,
  index: number,
): BillingPeriod {
  const anchor = toLocalDate(startDate);
  const date = nthBillingDate(anchor, schedule, index);
  return {
    index,
    periodStart: atLocalHour(date, 0),
    periodEnd: atLocalHour(nthBillingDate(anchor, schedule, index + 1), 0),
    dueAt: atLocalHour(date, REMINDER_HOUR),
  };
}

export function startOfLocalDay(instant: Date): Date {
  return atLocalHour(toLocalDate(instant), 0);
}

// 09:00 Nairobi, a whole number of calendar days after the given instant.
export function reminderSlotDaysAfter(instant: Date, days: number): Date {
  return atLocalHour(addDays(toLocalDate(instant), days), REMINDER_HOUR);
}

// First reminder slot (09:00 Nairobi) at or after the given instant.
export function nextReminderSlot(instant: Date): Date {
  const local = toLocalDate(instant);
  const sameDay = atLocalHour(local, REMINDER_HOUR);
  return sameDay >= instant
    ? sameDay
    : atLocalHour(addDays(local, 1), REMINDER_HOUR);
}

// Skips ahead so long-running daily subscriptions don't scan from period 0
// every tick. Undershooting is harmless; overshooting is not, hence the margin.
function firstCandidateIndex(
  startDate: Date,
  schedule: SubscriptionSchedule,
  now: Date,
): number {
  const start = toLocalDate(startDate);
  const today = toLocalDate(now);
  const elapsedDays = Math.floor(
    (now.getTime() - startDate.getTime()) / DAY_MS,
  );
  const estimate = {
    [SubscriptionSchedule.DAILY]: elapsedDays - 2,
    [SubscriptionSchedule.WEEKLY]: Math.floor(elapsedDays / 7) - 2,
    [SubscriptionSchedule.MONTHLY]:
      (today.year - start.year) * 12 + (today.month - start.month) - 2,
    [SubscriptionSchedule.YEARLY]: today.year - start.year - 2,
  }[schedule];
  return Math.max(0, estimate);
}

// Periods that should exist right now: due within the lead window, not already
// over, and never due before the subscription was created (no back-billing).
export function periodsToBill(
  subscription: Pick<
    BillableSubscription,
    'startDate' | 'schedule' | 'createdAt'
  >,
  now: Date,
): BillingPeriod[] {
  const horizon = now.getTime() + CYCLE_LEAD_DAYS * DAY_MS;
  const earliestDue = startOfLocalDay(subscription.createdAt).getTime();
  const periods: BillingPeriod[] = [];

  for (
    let i = firstCandidateIndex(
      subscription.startDate,
      subscription.schedule,
      now,
    );
    ;
    i++
  ) {
    const period = billingPeriod(
      subscription.startDate,
      subscription.schedule,
      i,
    );
    if (period.dueAt.getTime() > horizon) break;
    if (period.periodEnd <= now || period.dueAt.getTime() < earliestDue)
      continue;
    periods.push(period);
  }
  return periods;
}

// The owner shares the cost but is the one being paid, so each member owes an
// equal share of (members + 1). Leftover cents stay with the owner — nobody is
// ever charged more than an exact split.
export function memberShare(amountCents: number, memberCount: number): number {
  return Math.floor(amountCents / (memberCount + 1));
}

// Reminder schedule for one obligation. Reminders whose time has already
// passed are dropped, except the most recent one, which is sent straight away —
// so a bill created late still announces itself once rather than staying silent.
export function reminderLadder(
  dueAt: Date,
  overdueAt: Date,
  now: Date,
): PlannedReminder[] {
  const overdueSlot = nextReminderSlot(overdueAt);
  const ladder: PlannedReminder[] = [
    {
      kind: ReminderKind.UPCOMING,
      sequence: 0,
      scheduledFor: nextReminderSlot(
        new Date(dueAt.getTime() - UPCOMING_REMINDER_DAYS * DAY_MS),
      ),
    },
    {
      kind: ReminderKind.DUE,
      sequence: 0,
      scheduledFor: nextReminderSlot(dueAt),
    },
    { kind: ReminderKind.OVERDUE, sequence: 0, scheduledFor: overdueSlot },
    ...Array.from({ length: MAX_NUDGES }, (_, i) => ({
      kind: ReminderKind.NUDGE,
      sequence: i + 1,
      scheduledFor: new Date(
        overdueSlot.getTime() + (i + 1) * NUDGE_INTERVAL_DAYS * DAY_MS,
      ),
    })),
  ];

  const past = ladder.filter((r) => r.scheduledFor < now);
  const future = ladder.filter((r) => r.scheduledFor >= now);
  const latestPast = past.at(-1);
  return latestPast
    ? [{ ...latestPast, scheduledFor: now }, ...future]
    : future;
}

export function planCycle(
  subscription: BillableSubscription,
  period: BillingPeriod,
  now: Date,
): CyclePlan {
  const overdueAt = new Date(
    period.dueAt.getTime() + subscription.graceHours * HOUR_MS,
  );
  const amountDue = memberShare(
    subscription.amountCents,
    subscription.memberIds.length,
  );

  return {
    subscriptionId: subscription.id,
    periodStart: period.periodStart,
    periodEnd: period.periodEnd,
    dueAt: period.dueAt,
    status: period.dueAt > now ? CycleStatus.UPCOMING : CycleStatus.ACTIVE,
    obligations: subscription.memberIds.map((userId) => ({
      userId,
      recipientId: subscription.recipientId,
      amountDue,
      currency: subscription.currency,
      dueAt: period.dueAt,
      overdueAt,
      reminders: reminderLadder(period.dueAt, overdueAt, now),
    })),
  };
}
