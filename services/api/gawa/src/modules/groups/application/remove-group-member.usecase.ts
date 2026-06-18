import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { type IGroupRepository, GROUP_REPOSITORY_TOKEN } from '../domain/repos/group.repository';

@Injectable()
export class RemoveGroupMemberUseCase {
  constructor(
    @Inject(GROUP_REPOSITORY_TOKEN)
    private readonly groupRepository: IGroupRepository,
  ) {}

  async execute(
    groupId: number,
    memberUserId: number,
    requesterId: number,
  ): Promise<void> {
    const group = await this.groupRepository.findById(groupId);
    if (!group || group.ownerId !== requesterId) {
      throw new NotFoundException(`Group with ID ${groupId} not found`);
    }

    if (!(await this.groupRepository.isMember(groupId, memberUserId))) {
      throw new NotFoundException('This person is not a member of the group');
    }

    await this.groupRepository.removeMember(groupId, memberUserId);
  }
}
