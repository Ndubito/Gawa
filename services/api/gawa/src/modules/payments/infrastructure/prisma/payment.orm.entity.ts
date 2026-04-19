import { Payment } from '../../domain/entities/payment.entity';
import { Currency, PaymentStatus } from '../../domain/types/payment.types';

export interface PaymentOrmEntity {
  payment_id: number;
  obligation_id: number;
  payer_id: number;
  amount: number;
  currency: string;
  status: string;
  payment_method: string | null;
  idempotency_key: string | null;
  created_at: Date;
  updated_at: Date;
}

export class PaymentMapper {
  static toDomain(raw: PaymentOrmEntity): Payment {
    return new Payment({
      id: raw.payment_id,
      obligationId: raw.obligation_id,
      payerId: raw.payer_id,
      amount: raw.amount,
      currency: raw.currency as Currency,
      status: raw.status as PaymentStatus,
      paymentMethod: raw.payment_method,
      idempotencyKey: raw.idempotency_key,
      createdAt: raw.created_at,
      updatedAt: raw.updated_at,
    });
  }

  static toOrm(payment: Payment): Omit<PaymentOrmEntity, 'payment_id' | 'created_at' | 'updated_at'> & Partial<PaymentOrmEntity> {
    return {
      payment_id: payment.id,
      obligation_id: payment.obligationId,
      payer_id: payment.payerId,
      amount: payment.amount,
      currency: payment.currency as string,
      status: payment.status as string,
      payment_method: payment.paymentMethod ?? null,
      idempotency_key: payment.idempotencyKey ?? null,
    };
  }
}
