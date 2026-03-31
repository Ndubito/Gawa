export class UserResponseDto{
    id: String
    fullName: String
    email: String
    phoneNumber: String
    status: String
    

    constructor(user: any){
        this.id = user.id
        this.fullName = user.fullName
        this.email = user.email
        this.phoneNumber = user.phoneNumber
        this.status = user.status
    }
}