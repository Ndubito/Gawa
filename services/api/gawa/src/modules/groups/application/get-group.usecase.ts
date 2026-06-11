import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { Group } from '../domain/entities/group.entity';
import { type IGroupRepository, GROUP_REPOSITORY_TOKEN } from '../domain/repos/group.repository';

@Injectable()
export class GetGroupUseCase {
  constructor(
    @Inject(GROUP_REPOSITORY_TOKEN)
    private readonly groupRepository: IGroupRepository,
  ) {}

  async execute(id: number, requesterId: number): Promise<Group> {
    const group = await this.groupRepository.findById(id);
    // A group someone else owns is "not found", not "forbidden" — don't leak existence
    if (!group || group.ownerId !== requesterId) {
      throw new NotFoundException(`Group with ID ${id} not found`);
    }
    return group;
  }

  async executeByOwner(ownerId: number): Promise<Group[]> {
    return this.groupRepository.findByOwnerId(ownerId);
  }
}
