import { Injectable } from '@nestjs/common';
import { Prisma } from 'generated/prisma/client';
import { PrismaService } from '../../../../prisma/prisma.service';
import { IBillingRepository } from '../domain/billing.repository';
import {
  BillableSubscription,
  CyclePlan,
  CycleStatus,
} from '../domain/billing.types';
import {
  Currency,
  SubscriptionSchedule,
} from '../../subscriptions/domain/types/subscription.types';

const UNPAID = ['PENDING', 'PARTIAL'] as const;

@Injectable()
export class BillingRepositoryImpl implements IBillingRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findBillableSubscriptions(): Promise<BillableSubscription[]> {
    const raws = await this.prisma.subscription.findMany({
      where: {
        status: 'ACTIVE',
        deleted_at: null,
        group: { deleted_at: null },
      },
      include: {
        group: {
          include: {
            members: { where: { status: 'ACTIVE' }, select: { user_id: true } },
          },
        },
      },
    });
    return raws.map((raw) => ({
      id: raw.subscription_id,
      recipientId: raw.recipient_id,
      amountCents: raw.amount_cents,
      currency: raw.currency as Currency,
      schedule: raw.schedule as SubscriptionSchedule,
      graceHours: raw.grace_hours,
      startDate: raw.start_date,
      createdAt: raw.created_at,
      memberIds: raw.group.members
        .map((m) => m.user_id)
        .filter((id) => id !== raw.recipient_id),
    }));
  }

  async findOpenCyclePeriodStarts(
    now: Date,
  ): Promise<Map<number, Set<number>>> {
    const cycles = await this.prisma.subscriptionCycle.findMany({
      where: { period_end: { gt: now } },
      select: { subscription_id: true, period_start: true },
    });
    const bySubscription = new Map<number, Set<number>>();
    for (const cycle of cycles) {
      const starts =
        bySubscription.get(cycle.subscription_id) ?? new Set<number>();
      starts.add(cycle.period_start.getTime());
      bySubscription.set(cycle.subscription_id, starts);
    }
    return bySubscription;
  }

  async createCycle(plan: CyclePlan): Promise<boolean> {
    try {
      await this.prisma.$transaction(async (tx) => {
        const cycle = await tx.subscriptionCycle.create({
          data: {
            subscription_id: plan.subscriptionId,
            period_start: plan.periodStart,
            period_end: plan.periodEnd,
            due_at: plan.dueAt,
            status: plan.status,
          },
        });
        for (const obligation of plan.obligations) {
          await tx.obligation.create({
            data: {
              subscription_cycle_id: cycle.subscription_cycle_id,
              user_id: obligation.userId,
              recipient_id: obligation.recipientId,
              source_type: 'SUBSCRIPTION_CYCLE',
              amount_due: obligation.amountDue,
              currency: obligation.currency,
              status: 'PENDING',
              due_at: obligation.dueAt,
              overdue_at: obligation.overdueAt,
              reminders: {
                create: obligation.reminders.map((r) => ({
                  kind: r.kind,
                  sequence: r.sequence,
                  scheduled_for: r.scheduledFor,
                })),
              },
            },
          });
        }
      });
      return true;
    } catch (error) {
      if (
        error instanceof Prisma.PrismaClientKnownRequestError &&
        error.code === 'P2002'
      ) {
        return false;
      }
      throw error;
    }
  }

  async advanceCycleStatuses(now: Date): Promise<void> {
    await this.prisma.subscriptionCycle.updateMany({
      where: { status: CycleStatus.UPCOMING, due_at: { lte: now } },
      data: { status: CycleStatus.ACTIVE, updated_at: now },
    });
    await this.prisma.subscriptionCycle.updateMany({
      where: { status: { not: CycleStatus.CLOSED }, period_end: { lte: now } },
      data: { status: CycleStatus.CLOSED, updated_at: now },
    });
  }

  async markOverdueObligations(now: Date): Promise<number> {
    const { count } = await this.prisma.obligation.updateMany({
      where: { status: { in: [...UNPAID] }, overdue_at: { lte: now } },
      data: { status: 'OVERDUE', updated_at: now },
    });
    return count;
  }
}
