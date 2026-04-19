import { PaymentProps, PaymentStatus, Currency } from '../types/payment.types';

export class Payment {
  private props: PaymentProps;

  constructor(props: PaymentProps) {
    this.props = {
      ...props,
      currency: props.currency ?? Currency.KES,
      status: props.status ?? PaymentStatus.PENDING,
      createdAt: props.createdAt ?? new Date(),
      updatedAt: props.updatedAt ?? new Date(),
    };
  }

  get id(): number | undefined { return this.props.id; }
  get obligationId(): number { return this.props.obligationId; }
  get payerId(): number { return this.props.payerId; }
  get amount(): number { return this.props.amount; }
  get currency(): Currency { return this.props.currency!; }
  get status(): PaymentStatus { return this.props.status!; }
  get paymentMethod(): string | null | undefined { return this.props.paymentMethod; }
  get idempotencyKey(): string | null | undefined { return this.props.idempotencyKey; }
  get createdAt(): Date { return this.props.createdAt!; }
  get updatedAt(): Date { return this.props.updatedAt!; }

  public assignId(id: number): void {
    if (this.props.id) throw new Error('ID is already assigned');
    this.props.id = id;
  }
}
