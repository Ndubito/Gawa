export class ExpenseResponseDto {
  id: number;
  organizerId: number;
  groupId: number | null | undefined;
  payerId: number;
  totalAmount: number;
  name: string;
  description: string | null | undefined;
  createdAt: Date;
  updatedAt: Date;

  constructor(expense: any) {
    this.id = expense.id;
    this.organizerId = expense.organizerId;
    this.groupId = expense.groupId;
    this.payerId = expense.payerId;
    this.totalAmount = expense.totalAmount;
    this.name = expense.name;
    this.description = expense.description;
    this.createdAt = expense.createdAt;
    this.updatedAt = expense.updatedAt;
  }
}
