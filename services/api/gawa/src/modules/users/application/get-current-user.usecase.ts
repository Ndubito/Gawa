import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { User } from '../domain/entities/user.entity';
import {
  type IUserRepository,
  USER_REPOSITORY_TOKEN,
} from '../domain/repos/user.repository';

@Injectable()
export class GetCurrentUserUseCase {
  constructor(
    @Inject(USER_REPOSITORY_TOKEN)
    private readonly userRepository: IUserRepository,
  ) {}

  async execute(userId: number): Promise<User> {
    const user = await this.userRepository.findById(userId);
    if (!user) throw new NotFoundException('User not found');
    return user;
  }
}
