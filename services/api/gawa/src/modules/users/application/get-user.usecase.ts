import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { User } from '../domain/entities/user.entity';
import { type IUserRepository, USER_REPOSITORY_TOKEN } from '../domain/repos/user.repository';

@Injectable()
export class GetUserUseCase {
  constructor(
    @Inject(USER_REPOSITORY_TOKEN)
    private readonly userRepository: IUserRepository,
  ) { }

  async execute(id: number): Promise<User> {
    const user = await this.userRepository.findById(id);
    if (!user) throw new NotFoundException(`User with ID ${id} not found`);
    return user;
  }
}
