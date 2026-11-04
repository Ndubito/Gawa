import {
  ArrayMinSize,
  IsArray,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
} from 'class-validator';
import {
  DEFAULT_DUE_IN_DAYS,
  MAX_DUE_IN_DAYS,
} from '../../domain/types/expense.types';

// No payer field: the payer is always the authenticated requester.
export class CreateExpenseDto {
  @IsInt()
  groupId: number;

  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  name: string;

  @IsString()
  @IsOptional()
  @MaxLength(500)
  description?: string;

  @IsInt()
  @Min(1)
  totalAmountCents: number;

  @IsInt()
  @Min(1)
  @Max(MAX_DUE_IN_DAYS)
  @IsOptional()
  dueInDays: number = DEFAULT_DUE_IN_DAYS;

  // Everyone sharing the cost, optionally including the payer
  @IsArray()
  @ArrayMinSize(1)
  @IsInt({ each: true })
  participantIds: number[];
}
