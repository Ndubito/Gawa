import { ExpenseProps } from '../types/expense.types';

export class Expense {
  private props: ExpenseProps;

  constructor(props: ExpenseProps) {
    this.props = {
      ...props,
      createdAt: props.createdAt ?? new Date(),
      updatedAt: props.updatedAt ?? new Date(),
      deletedAt: props.deletedAt ?? null,
    };
  }

  get id(): number | undefined { return this.props.id; }
  get organizerId(): number { return this.props.organizerId; }
  get groupId(): number | null | undefined { return this.props.groupId; }
  get payerId(): number { return this.props.payerId; }
  get totalAmount(): number { return this.props.totalAmount; }
  get name(): string { return this.props.name; }
  get description(): string | null | undefined { return this.props.description; }
  get createdAt(): Date { return this.props.createdAt!; }
  get updatedAt(): Date { return this.props.updatedAt!; }
  get deletedAt(): Date | null | undefined { return this.props.deletedAt; }

  public update(name?: string, description?: string, totalAmount?: number): void {
    if (name) this.props.name = name;
    if (description !== undefined) this.props.description = description;
    if (totalAmount !== undefined) this.props.totalAmount = totalAmount;
    this.props.updatedAt = new Date();
  }

  public delete(): void {
    this.props.deletedAt = new Date();
    this.props.updatedAt = new Date();
  }

  public assignId(id: number): void {
    if (this.props.id) throw new Error('ID is already assigned');
    this.props.id = id;
  }
}
