import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { User } from '../domain/entities/user.entity';
import { type IUserRepository, USER_REPOSITORY_TOKEN } from '../domain/repos/user.repository';

export interface UpdateUserDto {
  id: number;
  fullName?: string;
  email?: string;
  phoneNumber?: string;
}

@Injectable()
export class UpdateUserUseCase {
  constructor(
    @Inject(USER_REPOSITORY_TOKEN)
    private readonly userRepository: IUserRepository,
  ) { }

  async execute(dto: UpdateUserDto): Promise<User> {
    const user = await this.userRepository.findById(dto.id);
    if (!user) throw new NotFoundException(`User with ID ${dto.id} not found`);

    user.updateProfile(dto.fullName, dto.email, dto.phoneNumber);
    return this.userRepository.update(user);
  }
}
