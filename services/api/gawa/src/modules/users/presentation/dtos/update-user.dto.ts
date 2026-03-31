import { IsString, IsEmail, IsNotEmpty, IsOptional } from 'class-validator';

export class UpdateUserDto{

    constructor(fullName: string, email: string, phoneNumber: string){
        this.fullName = fullName;
        this.email = email;
        this.phoneNumber = phoneNumber;
    }
    
    @IsString()
    @IsOptional()
    fullName: string

    @IsEmail()
    @IsOptional()
    email: string

    @IsString()
    @IsOptional()
    phoneNumber: string

}