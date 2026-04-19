export class SubscriptionResponseDto {
  id: number;
  groupId: number;
  recipientId: number;
  organizerId: number;
  name: string;
  description: string | null | undefined;
  amountCents: number;
  currency: string;
  schedule: string;
  graceHours: number;
  status: string;
  startDate: Date;
  createdAt: Date;
  updatedAt: Date;

  constructor(subscription: any) {
    this.id = subscription.id;
    this.groupId = subscription.groupId;
    this.recipientId = subscription.recipientId;
    this.organizerId = subscription.organizerId;
    this.name = subscription.name;
    this.description = subscription.description;
    this.amountCents = subscription.amountCents;
    this.currency = subscription.currency;
    this.schedule = subscription.schedule;
    this.graceHours = subscription.graceHours;
    this.status = subscription.status;
    this.startDate = subscription.startDate;
    this.createdAt = subscription.createdAt;
    this.updatedAt = subscription.updatedAt;
  }
}
