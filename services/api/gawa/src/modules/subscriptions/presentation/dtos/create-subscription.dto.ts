import { IsString, IsNotEmpty, IsOptional, IsInt, IsEnum, IsDateString } from 'class-validator';
import { Currency, SubscriptionSchedule } from '../../domain/types/subscription.types';

export class CreateSubscriptionDto {
  @IsInt()
  @IsNotEmpty()
  groupId: number;

  @IsInt()
  @IsNotEmpty()
  recipientId: number;

  @IsInt()
  @IsNotEmpty()
  organizerId: number;

  @IsString()
  @IsNotEmpty()
  name: string;

  @IsString()
  @IsOptional()
  description?: string;

  @IsInt()
  @IsNotEmpty()
  amountCents: number;

  @IsEnum(Currency)
  @IsOptional()
  currency?: Currency;

  @IsEnum(SubscriptionSchedule)
  @IsNotEmpty()
  schedule: SubscriptionSchedule;

  @IsInt()
  @IsNotEmpty()
  graceHours: number;

  @IsDateString()
  @IsNotEmpty()
  startDate: Date;
}
