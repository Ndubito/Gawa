export class UserResponseDto{
    id: number
    fullName: string
    email: string
    phoneNumber: string
    status: string
    

    constructor(user: any){
        this.id = user.id
        this.fullName = user.fullName
        this.email = user.email
        this.phoneNumber = user.phoneNumber
        this.status = user.status       
    }
}