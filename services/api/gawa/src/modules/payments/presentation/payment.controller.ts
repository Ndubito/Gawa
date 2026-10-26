import { Controller, Get, Param, ParseIntPipe } from '@nestjs/common';
import { CurrentUserId } from '../../auth/current-user.decorator';
import { GetPaymentUseCase } from '../application/get-payment.usecase';
import { PaymentResponseDto } from './dtos/payment-response.dto';

// Read-only until the pay flow defines how payments are recorded and confirmed.
@Controller('payments')
export class PaymentController {
  constructor(private readonly getPaymentUseCase: GetPaymentUseCase) {}

  @Get()
  async getMyPayments(
    @CurrentUserId() userId: number,
  ): Promise<PaymentResponseDto[]> {
    const payments = await this.getPaymentUseCase.executeForUser(userId);
    return payments.map((p) => new PaymentResponseDto(p));
  }

  @Get(':id')
  async getPayment(
    @CurrentUserId() userId: number,
    @Param('id', ParseIntPipe) id: number,
  ): Promise<PaymentResponseDto> {
    const payment = await this.getPaymentUseCase.execute(id, userId);
    return new PaymentResponseDto(payment);
  }
}
