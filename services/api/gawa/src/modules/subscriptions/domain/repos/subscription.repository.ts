import { Subscription } from '../entities/subscription.entity';

export interface ISubscriptionRepository {
  findById(id: number): Promise<Subscription | null>;
  findByGroupId(groupId: number): Promise<Subscription[]>;
  findByGroupIds(groupIds: number[]): Promise<Subscription[]>;
  save(subscription: Subscription): Promise<Subscription>;
  update(subscription: Subscription): Promise<Subscription>;
  delete(id: number): Promise<void>;
}

export const SUBSCRIPTION_REPOSITORY_TOKEN = Symbol('SUBSCRIPTION_REPOSITORY_TOKEN');
