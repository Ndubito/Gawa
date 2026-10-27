import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../../../prisma/prisma.service';
import {
  CancelUnpaidFilter,
  IObligationRepository,
} from '../../domain/repos/obligation.repository';
import { Obligation } from '../../domain/entities/obligation.entity';
import { ObligationMapper } from './obligation.orm.entity';

@Injectable()
export class ObligationRepositoryImpl implements IObligationRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findById(id: number): Promise<Obligation | null> {
    const raw = await this.prisma.obligation.findUnique({
      where: { obligation_id: id },
    });
    return raw ? ObligationMapper.toDomain(raw) : null;
  }

  async findForUser(userId: number): Promise<Obligation[]> {
    const raws = await this.prisma.obligation.findMany({
      where: { OR: [{ user_id: userId }, { recipient_id: userId }] },
      orderBy: { due_at: 'desc' },
    });
    return raws.map((raw) => ObligationMapper.toDomain(raw));
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
