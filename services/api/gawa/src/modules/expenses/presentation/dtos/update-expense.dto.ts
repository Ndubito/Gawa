import { IsString, IsOptional, IsInt } from 'class-validator';

export class UpdateExpenseDto {
  @IsString()
  @IsOptional()
  name?: string;

  @IsString()
  @IsOptional()
  description?: string;

  @IsInt()
  @IsOptional()
  totalAmount?: number;
}
