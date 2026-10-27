import { ExpenseProps, ExpenseSplit } from '../types/expense.types';

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

  get id(): number | undefined {
    return this.props.id;
  }
  get groupId(): number {
    return this.props.groupId;
  }
  get payerId(): number {
    return this.props.payerId;
  }
  get totalAmount(): number {
    return this.props.totalAmount;
  }
  get name(): string {
    return this.props.name;
  }
  get description(): string | null | undefined {
    return this.props.description;
  }
  get dueAt(): Date {
    return this.props.dueAt;
  }
  get splits(): ExpenseSplit[] {
    return this.props.splits;
  }
  get createdAt(): Date {
    return this.props.createdAt!;
  }
  get updatedAt(): Date {
    return this.props.updatedAt!;
  }
  get deletedAt(): Date | null | undefined {
    return this.props.deletedAt;
  }

  public isPaidBy(userId: number): boolean {
    return this.props.payerId === userId;
  }

  // Amount and split are fixed once logged; only the labels can change.
  public rename(name?: string, description?: string): void {
    if (name) this.props.name = name;
    if (description !== undefined) this.props.description = description;
    this.props.updatedAt = new Date();
  }
}
