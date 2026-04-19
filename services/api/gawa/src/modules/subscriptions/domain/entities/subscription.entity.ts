import { SubscriptionProps, SubscriptionStatus, Currency, SubscriptionSchedule } from '../types/subscription.types';

export class Subscription {
  private props: SubscriptionProps;

  constructor(props: SubscriptionProps) {
    this.props = {
      ...props,
      currency: props.currency ?? Currency.KES,
      status: props.status ?? SubscriptionStatus.ACTIVE,
      createdAt: props.createdAt ?? new Date(),
      updatedAt: props.updatedAt ?? new Date(),
      deletedAt: props.deletedAt ?? null,
    };
  }

  get id(): number | undefined { return this.props.id; }
  get groupId(): number { return this.props.groupId; }
  get recipientId(): number { return this.props.recipientId; }
  get organizerId(): number { return this.props.organizerId; }
  get name(): string { return this.props.name; }
  get description(): string | null | undefined { return this.props.description; }
  get amountCents(): number { return this.props.amountCents; }
  get currency(): Currency { return this.props.currency!; }
  get schedule(): SubscriptionSchedule { return this.props.schedule; }
  get graceHours(): number { return this.props.graceHours; }
  get status(): SubscriptionStatus { return this.props.status!; }
  get startDate(): Date { return this.props.startDate; }
  get createdAt(): Date { return this.props.createdAt!; }
  get updatedAt(): Date { return this.props.updatedAt!; }
  get deletedAt(): Date | null | undefined { return this.props.deletedAt; }

  public update(name?: string, description?: string, amountCents?: number, graceHours?: number, status?: SubscriptionStatus): void {
    if (name) this.props.name = name;
    if (description !== undefined) this.props.description = description;
    if (amountCents !== undefined) this.props.amountCents = amountCents;
    if (graceHours !== undefined) this.props.graceHours = graceHours;
    if (status) this.props.status = status;
    this.props.updatedAt = new Date();
  }

  public delete(): void {
    this.props.status = SubscriptionStatus.CANCELLED;
    this.props.deletedAt = new Date();
    this.props.updatedAt = new Date();
  }

  public assignId(id: number): void {
    if (this.props.id) throw new Error('ID is already assigned');
    this.props.id = id;
  }
}
