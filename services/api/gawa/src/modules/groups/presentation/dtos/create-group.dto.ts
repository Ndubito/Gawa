import { IsString, IsNotEmpty, IsOptional } from 'class-validator';

export class CreateGroupDto {
  constructor(name: string, description?: string) {
    this.name = name;
    this.description = description;
  }

  @IsString()
  @IsNotEmpty()
  name: string;

  @IsString()
  @IsOptional()
  description?: string;
}
