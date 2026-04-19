import { IsString, IsNotEmpty, IsOptional, IsInt } from 'class-validator';

export class CreateExpenseDto {
  @IsInt()
  @IsNotEmpty()
  organizerId: number;

  @IsInt()
  @IsOptional()
  groupId?: number;

  @IsInt()
  @IsNotEmpty()
  payerId: number;

  @IsInt()
  @IsNotEmpty()
  totalAmount: number;

  @IsString()
  @IsNotEmpty()
  name: string;

  @IsString()
  @IsOptional()
  description?: string;
}
