import { Injectable } from '@nestjs/common';
import { Prisma } from 'generated/prisma/client';
import { PrismaService } from '../../../../../prisma/prisma.service';
import {
  CancelUnpaidFilter,
  IObligationRepository,
} from '../../domain/repos/obligation.repository';
import { Obligation } from '../../domain/entities/obligation.entity';
import {
  ObligationView,
  OPEN_STATUSES,
} from '../../domain/types/obligation-view';
import {
  Currency,
  ObligationSourceType,
  ObligationStatus,
} from '../../domain/types/obligation.types';
import { ObligationMapper } from './obligation.orm.entity';

const group = { select: { group_id: true, group_name: true } } as const;

const viewInclude = {
  user: { select: { user_id: true, full_name: true } },
  recipient: { select: { user_id: true, full_name: true } },
  subscription_cycle: {
    select: {
      period_start: true,
      period_end: true,
      subscription: { select: { name: true, group } },
    },
  },
  expense: { select: { name: true, group } },
} as const;

type ViewRow = Prisma.ObligationGetPayload<{ include: typeof viewInclude }>;

function toView(raw: ViewRow): ObligationView {
  const cycle = raw.subscription_cycle;
  const origin = cycle?.subscription ?? raw.expense;
  return {
    id: raw.obligation_id,
    debtor: { userId: raw.user.user_id, name: raw.user.full_name },
    creditor: { userId: raw.recipient.user_id, name: raw.recipient.full_name },
    source: {
      type: raw.source_type as ObligationSourceType,
      name: origin?.name ?? '',
      groupId: origin?.group?.group_id ?? null,
      groupName: origin?.group?.group_name ?? null,
      periodStart: cycle?.period_start ?? null,
      periodEnd: cycle?.period_end ?? null,
    },
    amountDue: raw.amount_due,
    amountPaid: raw.amount_paid,
    currency: raw.currency as Currency,
    status: raw.status as ObligationStatus,
    dueAt: raw.due_at,
    overdueAt: raw.overdue_at,
    updatedAt: raw.updated_at,
  };
}

@Injectable()
export class ObligationRepositoryImpl implements IObligationRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findById(id: number): Promise<Obligation | null> {
    const raw = await this.prisma.obligation.findUnique({
      where: { obligation_id: id },
    });
    return raw ? ObligationMapper.toDomain(raw) : null;
  }

  async findViewById(id: number): Promise<ObligationView | null> {
    const raw = await this.prisma.obligation.findUnique({
      where: { obligation_id: id },
      include: viewInclude,
    });
    return raw ? toView(raw) : null;
  }

  async findViewsForUser(
    userId: number,
    settledSince: Date,
  ): Promise<ObligationView[]> {
    const raws = await this.prisma.obligation.findMany({
      where: {
        AND: [
          { OR: [{ user_id: userId }, { recipient_id: userId }] },
          {
            OR: [
              { status: { in: OPEN_STATUSES } },
              { updated_at: { gte: settledSince } },
            ],
          },
        ],
      },
      include: viewInclude,
      orderBy: { due_at: 'asc' },
    });
    return raws.map(toView);
  }

  async save(obligation: Obligation): Promise<Obligation> {
    const data = ObligationMapper.toOrm(obligation);
    delete data.obligation_id;

    const saved = await this.prisma.obligation.create({ data: data as any });
    obligation.assignId(saved.obligation_id);
    return ObligationMapper.toDomain(saved);
  }

  async cancelUnpaid(filter: CancelUnpaidFilter): Promise<number> {
    const { count } = await this.prisma.obligation.updateMany({
      where: {
        status: { in: ['PENDING', 'PARTIAL'] },
        due_at: { gt: filter.dueAfter },
        user_id: filter.userId,
        subscription_cycle: {
          subscription_id: filter.subscriptionId,
          subscription: { group_id: filter.groupId },
        },
      },
      data: { status: 'CANCELLED', updated_at: new Date() },
    });
    return count;
  }

  async update(obligation: Obligation): Promise<Obligation> {
    const data = ObligationMapper.toOrm(obligation);
    delete data.obligation_id;

    const updated = await this.prisma.obligation.update({
      where: { obligation_id: obligation.id },
      data: data as any,
    });
    return ObligationMapper.toDomain(updated);
  }
}
