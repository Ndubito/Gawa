import { IsString, IsNotEmpty, IsOptional, IsInt, IsEnum, IsDateString, Min } from 'class-validator';
import { SubscriptionSchedule } from '../../domain/types/subscription.types';

export class CreateSubscriptionDto {
  @IsInt()
  @IsNotEmpty()
  groupId: number;

  @IsString()
  @IsNotEmpty()
  name: string;

  @IsString()
  @IsOptional()
  description?: string;

  @IsInt()
  @Min(1)
  amountCents: number;

  @IsEnum(SubscriptionSchedule)
  @IsNotEmpty()
  schedule: SubscriptionSchedule;

  @IsInt()
  @Min(0)
  graceHours: number;

  @IsDateString()
  @IsNotEmpty()
  startDate: Date;
}
