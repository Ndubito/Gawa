import { IsString, IsNotEmpty, IsOptional, IsInt } from 'class-validator';

export class CreateGroupDto {
  constructor(name: string, ownerId: number, description?: string) {
    this.name = name;
    this.ownerId = ownerId;
    this.description = description;
  }

  @IsString()
  @IsNotEmpty()
  name: string;

  @IsString()
  @IsOptional()
  description?: string;

  @IsInt()
  @IsNotEmpty()
  ownerId: number;
}
