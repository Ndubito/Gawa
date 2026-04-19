import { IsString, IsOptional } from 'class-validator';

export class UpdateGroupDto {
  constructor(name?: string, description?: string) {
    this.name = name;
    this.description = description;
  }

  @IsString()
  @IsOptional()
  name?: string;

  @IsString()
  @IsOptional()
  description?: string;
}
