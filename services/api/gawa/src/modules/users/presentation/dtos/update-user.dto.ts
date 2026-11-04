import { IsString, IsNotEmpty, MaxLength } from 'class-validator';

// Phone number is the Firebase-verified identity and cannot be changed here.
export class UpdateUserDto {
  constructor(fullName: string) {
    this.fullName = fullName;
  }

  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  fullName: string;
}
