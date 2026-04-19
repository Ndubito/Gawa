export enum PaymentStatus {
  PENDING = 'PENDING',
  SUCCEEDED = 'SUCCEEDED',
  FAILED = 'FAILED',
  REFUNDED = 'REFUNDED',
}

export enum Currency {
  KES = 'KES',
  USD = 'USD',
  EUR = 'EUR',
}

export interface PaymentProps {
  id?: number;
  obligationId: number;
  payerId: number;
  amount: number;
  currency?: Currency;
  status?: PaymentStatus;
  paymentMethod?: string | null;
  idempotencyKey?: string | null;
  createdAt?: Date;
  updatedAt?: Date;
}
