import { Subscription } from '../../domain/entities/subscription.entity';
import { Currency, SubscriptionSchedule, SubscriptionStatus } from '../../domain/types/subscription.types';

export interface SubscriptionOrmEntity {
  subscription_id: number;
  group_id: number;
  recipient_id: number;
  organizer_id: number;
  name: string;
  description: string | null;
  amount_cents: number;
  currency: string;
  schedule: string;
  grace_hours: number;
  status: string;
  start_date: Date;
  created_at: Date;
  updated_at: Date;
  deleted_at: Date | null;
}

export class SubscriptionMapper {
  static toDomain(raw: SubscriptionOrmEntity): Subscription {
    return new Subscription({
      id: raw.subscription_id,
      groupId: raw.group_id,
      recipientId: raw.recipient_id,
      organizerId: raw.organizer_id,
      name: raw.name,
      description: raw.description,
      amountCents: raw.amount_cents,
      currency: raw.currency as Currency,
      schedule: raw.schedule as SubscriptionSchedule,
      graceHours: raw.grace_hours,
      status: raw.status as SubscriptionStatus,
      startDate: raw.start_date,
      createdAt: raw.created_at,
      updatedAt: raw.updated_at,
      deletedAt: raw.deleted_at,
    });
  }

  static toOrm(sub: Subscription): Omit<SubscriptionOrmEntity, 'subscription_id' | 'created_at' | 'updated_at' | 'deleted_at'> & Partial<SubscriptionOrmEntity> {
    return {
      subscription_id: sub.id,
      group_id: sub.groupId,
      recipient_id: sub.recipientId,
      organizer_id: sub.organizerId,
      name: sub.name,
      description: sub.description ?? null,
      amount_cents: sub.amountCents,
      currency: sub.currency as string,
      schedule: sub.schedule as string,
      grace_hours: sub.graceHours,
      status: sub.status as string,
      start_date: sub.startDate,
    };
  }
}
