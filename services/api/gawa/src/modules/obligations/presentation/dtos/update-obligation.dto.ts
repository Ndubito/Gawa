import { IsInt, IsOptional, IsEnum } from 'class-validator';
import { ObligationStatus } from '../../domain/types/obligation.types';

export class UpdateObligationDto {
  @IsInt()
  @IsOptional()
  amountPaid?: number;

  @IsEnum(ObligationStatus)
  @IsOptional()
  status?: ObligationStatus;
}
