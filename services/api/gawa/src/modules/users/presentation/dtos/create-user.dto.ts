import { IsString, IsEmail, IsNotEmpty, IsOptional } from 'class-validator';

export class CreateUserDto {
    constructor(fullName: string, email: string, phoneNumber: string) {
        this.fullName = fullName;
        this.email = email;
        this.phoneNumber = phoneNumber;
    }
    @IsString()
    @IsNotEmpty()
    fullName: string

    @IsEmail()
    @IsOptional()
    email: string

    @IsString()
    @IsNotEmpty()
    phoneNumber: string
}