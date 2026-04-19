import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { Payment } from '../domain/entities/payment.entity';
import { type IPaymentRepository, PAYMENT_REPOSITORY_TOKEN } from '../domain/repos/payment.repository';

@Injectable()
export class GetPaymentUseCase {
  constructor(
    @Inject(PAYMENT_REPOSITORY_TOKEN)
    private readonly paymentRepository: IPaymentRepository,
  ) {}

  async execute(id: number): Promise<Payment> {
    const payment = await this.paymentRepository.findById(id);
    if (!payment) throw new NotFoundException(`Payment with ID ${id} not found`);
    return payment;
  }

  async executeAll(): Promise<Payment[]> {
    return this.paymentRepository.findAll();
  }
}
