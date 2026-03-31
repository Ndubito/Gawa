import { Injectable, Inject } from '@nestjs/common';
import { type IUserRepository, USER_REPOSITORY_TOKEN } from '../domain/repos/user.repository';

@Injectable()
export class DeleteUserUseCase {
  constructor(
    @Inject(USER_REPOSITORY_TOKEN)
    private readonly userRepository: IUserRepository,
  ) { }

  async execute(id: number): Promise<void> {
    const user = await this.userRepository.findById(id);
    if (!user) throw new Error(`User with ID ${id} not found`);

    user.delete();
    await this.userRepository.update(user); // Soft delete updating status/deletedAt
  }
}
