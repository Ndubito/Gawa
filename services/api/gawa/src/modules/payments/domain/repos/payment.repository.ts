import { Payment } from '../entities/payment.entity';

export interface IPaymentRepository {
  findById(id: number): Promise<Payment | null>;
  // Payments on obligations where the user is the debtor or the creditor
  findForUser(userId: number): Promise<Payment[]>;
  save(payment: Payment): Promise<Payment>;
}

export const PAYMENT_REPOSITORY_TOKEN = Symbol('PAYMENT_REPOSITORY_TOKEN');
