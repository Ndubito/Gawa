import { Payment } from '../entities/payment.entity';

export interface IPaymentRepository {
  findById(id: number): Promise<Payment | null>;
  findAll(): Promise<Payment[]>;
  save(payment: Payment): Promise<Payment>;
}

export const PAYMENT_REPOSITORY_TOKEN = Symbol('PAYMENT_REPOSITORY_TOKEN');
