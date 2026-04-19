import { IsString, IsOptional, IsInt, IsEnum } from 'class-validator';
import { SubscriptionStatus } from '../../domain/types/subscription.types';

export class UpdateSubscriptionDto {
  @IsString()
  @IsOptional()
  name?: string;

  @IsString()
  @IsOptional()
  description?: string;

  @IsInt()
  @IsOptional()
  amountCents?: number;

  @IsInt()
  @IsOptional()
  graceHours?: number;

  @IsEnum(SubscriptionStatus)
  @IsOptional()
  status?: SubscriptionStatus;
}
