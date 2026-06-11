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
    // Owners and members may read; everyone else gets "not found"
    // rather than "forbidden" so group ids don't leak.
    const allowed =
      group &&
      (group.ownerId === requesterId ||
        (await this.groupRepository.isMember(id, requesterId)));
    if (!allowed) {
      throw new NotFoundException(`Group with ID ${id} not found`);
    }
    return group;
  }

  /// Groups the user owns or is a member of.
  async executeForUser(userId: number): Promise<Group[]> {
    return this.groupRepository.findByUser(userId);
  }

  async executeByOwner(ownerId: number): Promise<Group[]> {
    return this.groupRepository.findByOwnerId(ownerId);
  }
}
