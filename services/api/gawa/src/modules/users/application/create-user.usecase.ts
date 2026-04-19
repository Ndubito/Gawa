import { Injectable, Inject, ConflictException } from '@nestjs/common';
import { User } from '../domain/entities/user.entity';
import { type IUserRepository, USER_REPOSITORY_TOKEN } from '../domain/repos/user.repository';
import { CreateUserDto } from '../presentation/dtos/create-user.dto';


@Injectable()
export class CreateUserUseCase {
  constructor(
    @Inject(USER_REPOSITORY_TOKEN)
    private readonly userRepository: IUserRepository,
  ) { }

  async execute(dto: CreateUserDto): Promise<User> {
    if (dto.email) {
      const existingUser = await this.userRepository.findByEmail(dto.email);
      if (existingUser) throw new ConflictException(`User with email ${dto.email} already exists`);
    }

    const existingPhone = await this.userRepository.findByPhoneNumber(dto.phoneNumber);
    if (existingPhone) throw new ConflictException(`User with phone number ${dto.phoneNumber} already exists`);

    const user = new User({
      fullName: dto.fullName,
      phoneNumber: dto.phoneNumber,
      email: dto.email,
    });

    return this.userRepository.save(user);
  }
}
