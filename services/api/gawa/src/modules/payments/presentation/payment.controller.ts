import {
  Controller,
  Post,
  Get,
  Body,
  Param,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { CreatePaymentUseCase } from '../application/create-payment.usecase';
import { GetPaymentUseCase } from '../application/get-payment.usecase';
import { CreatePaymentDto } from './dtos/create-payment.dto';
import { PaymentResponseDto } from './dtos/payment-response.dto';

@Controller('payments')
export class PaymentController {
  constructor(
    private readonly createPaymentUseCase: CreatePaymentUseCase,
    private readonly getPaymentUseCase: GetPaymentUseCase,
  ) {}

  @Post()
  async createPayment(@Body() dto: CreatePaymentDto): Promise<PaymentResponseDto> {
    try {
      const payment = await this.createPaymentUseCase.execute(dto);
      return new PaymentResponseDto(payment);
    } catch (error: any) {
      throw new HttpException(error.message, HttpStatus.BAD_REQUEST);
    }
  }

  @Get()
  async getAllPayments(): Promise<PaymentResponseDto[]> {
    try {
      const payments = await this.getPaymentUseCase.executeAll();
      return payments.map((p) => new PaymentResponseDto(p));
    } catch (error: any) {
      throw new HttpException(error.message, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  @Get(':id')
  async getPayment(@Param('id') id: number): Promise<PaymentResponseDto> {
    try {
      const payment = await this.getPaymentUseCase.execute(id);
      return new PaymentResponseDto(payment);
    } catch (error: any) {
      throw new HttpException(error.message, HttpStatus.NOT_FOUND);
    }
  }
}
