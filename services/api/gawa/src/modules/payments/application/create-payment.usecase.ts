import { Injectable, Inject } from '@nestjs/common';
import { Payment } from '../domain/entities/payment.entity';
import { type IPaymentRepository, PAYMENT_REPOSITORY_TOKEN } from '../domain/repos/payment.repository';
import { CreatePaymentDto } from '../presentation/dtos/create-payment.dto';

@Injectable()
export class CreatePaymentUseCase {
  constructor(
    @Inject(PAYMENT_REPOSITORY_TOKEN)
    private readonly paymentRepository: IPaymentRepository,
  ) {}

  async execute(dto: CreatePaymentDto): Promise<Payment> {
    const payment = new Payment({
      obligationId: dto.obligationId,
      payerId: dto.payerId,
      amount: dto.amount,
      currency: dto.currency,
      paymentMethod: dto.paymentMethod,
      idempotencyKey: dto.idempotencyKey,
    });
    return this.paymentRepository.save(payment);
  }
}
