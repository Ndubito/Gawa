import { IsInt, IsNotEmpty, IsOptional, IsEnum, IsString } from 'class-validator';
import { Currency } from '../../domain/types/payment.types';

export class CreatePaymentDto {
  @IsInt()
  @IsNotEmpty()
  obligationId: number;

  @IsInt()
  @IsNotEmpty()
  payerId: number;

  @IsInt()
  @IsNotEmpty()
  amount: number;

  @IsEnum(Currency)
  @IsOptional()
  currency?: Currency;

  @IsString()
  @IsOptional()
  paymentMethod?: string;

  @IsString()
  @IsOptional()
  idempotencyKey?: string;
}
