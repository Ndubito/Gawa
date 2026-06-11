import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { type IGroupRepository, GROUP_REPOSITORY_TOKEN } from '../domain/repos/group.repository';

@Injectable()
export class DeleteGroupUseCase {
  constructor(
    @Inject(GROUP_REPOSITORY_TOKEN)
    private readonly groupRepository: IGroupRepository,
  ) {}

  async execute(id: number, requesterId: number): Promise<void> {
    const group = await this.groupRepository.findById(id);
    if (!group || group.ownerId !== requesterId) {
      throw new NotFoundException(`Group with ID ${id} not found`);
    }

    group.delete();
    await this.groupRepository.delete(id);
  }
}
