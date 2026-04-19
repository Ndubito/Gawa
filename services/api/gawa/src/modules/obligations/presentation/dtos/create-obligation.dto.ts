import { IsInt, IsNotEmpty, IsOptional, IsEnum, IsDateString } from 'class-validator';
import { Currency, ObligationSourceType } from '../../domain/types/obligation.types';

export class CreateObligationDto {
  @IsInt()
  @IsOptional()
  subscriptionCycleId?: number;

  @IsInt()
  @IsOptional()
  expenseId?: number;

  @IsInt()
  @IsNotEmpty()
  userId: number;

  @IsInt()
  @IsNotEmpty()
  recipientId: number;

  @IsEnum(ObligationSourceType)
  @IsNotEmpty()
  sourceType: ObligationSourceType;

  @IsInt()
  @IsNotEmpty()
  amountDue: number;

  @IsEnum(Currency)
  @IsOptional()
  currency?: Currency;

  @IsDateString()
  @IsNotEmpty()
  dueAt: Date;
}
