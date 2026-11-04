import { IsNotEmpty, IsOptional, IsString, MaxLength } from 'class-validator';

// Amount and participants are fixed once logged; delete and re-log to change them.
export class UpdateExpenseDto {
  @IsString()
  @IsNotEmpty()
  @IsOptional()
  @MaxLength(100)
  name?: string;

  @IsString()
  @IsOptional()
  @MaxLength(500)
  description?: string;
}
