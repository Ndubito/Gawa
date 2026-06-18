import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../../../prisma/prisma.service';
import { ISubscriptionRepository } from '../../domain/repos/subscription.repository';
import { Subscription } from '../../domain/entities/subscription.entity';
import { SubscriptionMapper } from './subscription.orm.entity';

@Injectable()
export class SubscriptionRepositoryImpl implements ISubscriptionRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findById(id: number): Promise<Subscription | null> {
    const raw = await this.prisma.subscription.findFirst({
      where: { subscription_id: id, deleted_at: null },
    });
    return raw ? SubscriptionMapper.toDomain(raw) : null;
  }

  async findByGroupId(groupId: number): Promise<Subscription[]> {
    const raws = await this.prisma.subscription.findMany({
      where: { group_id: groupId, deleted_at: null },
      orderBy: { created_at: 'desc' },
    });
    return raws.map((raw) => SubscriptionMapper.toDomain(raw));
  }

  async save(subscription: Subscription): Promise<Subscription> {
    const data = SubscriptionMapper.toOrm(subscription);
    delete data.subscription_id;

    const saved = await this.prisma.subscription.create({ data: data as any });
    subscription.assignId(saved.subscription_id);
    return SubscriptionMapper.toDomain(saved);
  }

  async update(subscription: Subscription): Promise<Subscription> {
    const data = SubscriptionMapper.toOrm(subscription);
    delete data.subscription_id;

    const updated = await this.prisma.subscription.update({
      where: { subscription_id: subscription.id },
      data: data as any,
    });
    return SubscriptionMapper.toDomain(updated);
  }

  async delete(id: number): Promise<void> {
    await this.prisma.subscription.update({
      where: { subscription_id: id },
      data: {
        status: 'CANCELLED',
        deleted_at: new Date(),
        updated_at: new Date(),
      },
    });
  }
}
