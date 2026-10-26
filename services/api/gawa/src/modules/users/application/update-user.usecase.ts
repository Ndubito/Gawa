import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { User } from '../domain/entities/user.entity';
import {
  type IUserRepository,
  USER_REPOSITORY_TOKEN,
} from '../domain/repos/user.repository';

export interface UpdateUserInput {
  id: number;
  fullName: string;
}

@Injectable()
export class UpdateUserUseCase {
  constructor(
    @Inject(USER_REPOSITORY_TOKEN)
    private readonly userRepository: IUserRepository,
  ) {}

  async execute(input: UpdateUserInput): Promise<User> {
    const user = await this.userRepository.findById(input.id);
    if (!user) throw new NotFoundException(`User ${input.id} not found`);

    user.updateProfile(input.fullName.trim());
    return this.userRepository.update(user);
  }
}
