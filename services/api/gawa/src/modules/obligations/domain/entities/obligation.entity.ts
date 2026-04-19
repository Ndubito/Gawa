import { ObligationProps, ObligationStatus, ObligationSourceType, Currency } from '../types/obligation.types';

export class Obligation {
  private props: ObligationProps;

  constructor(props: ObligationProps) {
    this.props = {
      ...props,
      amountPaid: props.amountPaid ?? 0,
      currency: props.currency ?? Currency.KES,
      status: props.status ?? ObligationStatus.PENDING,
      createdAt: props.createdAt ?? new Date(),
      updatedAt: props.updatedAt ?? new Date(),
    };
  }

  get id(): number | undefined { return this.props.id; }
  get subscriptionCycleId(): number | null | undefined { return this.props.subscriptionCycleId; }
  get expenseId(): number | null | undefined { return this.props.expenseId; }
  get userId(): number { return this.props.userId; }
  get recipientId(): number { return this.props.recipientId; }
  get sourceType(): ObligationSourceType { return this.props.sourceType; }
  get amountDue(): number { return this.props.amountDue; }
  get amountPaid(): number { return this.props.amountPaid!; }
  get currency(): Currency { return this.props.currency!; }
  get status(): ObligationStatus { return this.props.status!; }
  get dueAt(): Date { return this.props.dueAt; }
  get createdAt(): Date { return this.props.createdAt!; }
  get updatedAt(): Date { return this.props.updatedAt!; }

  public updatePayment(amountPaid: number, status: ObligationStatus): void {
    this.props.amountPaid = amountPaid;
    this.props.status = status;
    this.props.updatedAt = new Date();
  }

  public cancel(): void {
    this.props.status = ObligationStatus.CANCELLED;
    this.props.updatedAt = new Date();
  }

  public assignId(id: number): void {
    if (this.props.id) throw new Error('ID is already assigned');
    this.props.id = id;
  }
}
