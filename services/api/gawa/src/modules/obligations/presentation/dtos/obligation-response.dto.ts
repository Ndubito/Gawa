export class ObligationResponseDto {
  id: number;
  subscriptionCycleId: number | null | undefined;
  expenseId: number | null | undefined;
  userId: number;
  recipientId: number;
  sourceType: string;
  amountDue: number;
  amountPaid: number;
  currency: string;
  status: string;
  dueAt: Date;
  createdAt: Date;
  updatedAt: Date;

  constructor(obligation: any) {
    this.id = obligation.id;
    this.subscriptionCycleId = obligation.subscriptionCycleId;
    this.expenseId = obligation.expenseId;
    this.userId = obligation.userId;
    this.recipientId = obligation.recipientId;
    this.sourceType = obligation.sourceType;
    this.amountDue = obligation.amountDue;
    this.amountPaid = obligation.amountPaid;
    this.currency = obligation.currency;
    this.status = obligation.status;
    this.dueAt = obligation.dueAt;
    this.createdAt = obligation.createdAt;
    this.updatedAt = obligation.updatedAt;
  }
}
