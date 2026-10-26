import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { Payment } from '../domain/entities/payment.entity';
import {
  type IPaymentRepository,
  PAYMENT_REPOSITORY_TOKEN,
} from '../domain/repos/payment.repository';
import {
  type IObligationRepository,
  OBLIGATION_REPOSITORY_TOKEN,
} from '../../obligations/domain/repos/obligation.repository';

@Injectable()
export class GetPaymentUseCase {
  constructor(
    @Inject(PAYMENT_REPOSITORY_TOKEN)
    private readonly paymentRepository: IPaymentRepository,
    @Inject(OBLIGATION_REPOSITORY_TOKEN)
    private readonly obligationRepository: IObligationRepository,
  ) {}

  // A payment is visible to exactly the people who can see its obligation.
  async execute(id: number, requesterId: number): Promise<Payment> {
    const payment = await this.paymentRepository.findById(id);
    const obligation = payment
      ? await this.obligationRepository.findById(payment.obligationId)
      : null;
    if (!payment || !obligation?.involves(requesterId)) {
      throw new NotFoundException(`Payment ${id} not found`);
    }
    return payment;
  }

  async executeForUser(requesterId: number): Promise<Payment[]> {
    return this.paymentRepository.findForUser(requesterId);
  }
}
