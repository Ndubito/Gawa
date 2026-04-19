import { TransactionProps } from '../types/transaction.types';

export class Transaction {
  private props: TransactionProps;

  constructor(props: TransactionProps) {
    this.props = {
      ...props,
      createdAt: props.createdAt ?? new Date(),
    };
  }

  get id(): number | undefined { return this.props.id; }
  get paymentId(): number { return this.props.paymentId; }
  get provider(): string { return this.props.provider; }
  get providerReference(): string { return this.props.providerReference; }
  get providerName(): string { return this.props.providerName; }
  get rawResponse(): Record<string, any> { return this.props.rawResponse; }
  get status(): string { return this.props.status; }
  get createdAt(): Date { return this.props.createdAt!; }

  public assignId(id: number): void {
    if (this.props.id) throw new Error('ID is already assigned');
    this.props.id = id;
  }
}
