export class PaymentResponseDto {
  id: number;
  obligationId: number;
  payerId: number;
  amount: number;
  currency: string;
  status: string;
  paymentMethod: string | null | undefined;
  idempotencyKey: string | null | undefined;
  createdAt: Date;
  updatedAt: Date;

  constructor(payment: any) {
    this.id = payment.id;
    this.obligationId = payment.obligationId;
    this.payerId = payment.payerId;
    this.amount = payment.amount;
    this.currency = payment.currency;
    this.status = payment.status;
    this.paymentMethod = payment.paymentMethod;
    this.idempotencyKey = payment.idempotencyKey;
    this.createdAt = payment.createdAt;
    this.updatedAt = payment.updatedAt;
  }
}
