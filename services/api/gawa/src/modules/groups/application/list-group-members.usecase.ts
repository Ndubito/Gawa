import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { GroupMember } from '../domain/entities/group-member.entity';
import { type IGroupRepository, GROUP_REPOSITORY_TOKEN } from '../domain/repos/group.repository';
import { type IUserRepository, USER_REPOSITORY_TOKEN } from '../../users/domain/repos/user.repository';

@Injectable()
export class ListGroupMembersUseCase {
  constructor(
    @Inject(GROUP_REPOSITORY_TOKEN)
    private readonly groupRepository: IGroupRepository,
    @Inject(USER_REPOSITORY_TOKEN)
    private readonly userRepository: IUserRepository,
  ) {}

  async execute(groupId: number, requesterId: number): Promise<GroupMember[]> {
    const group = await this.groupRepository.findById(groupId);
    const allowed =
      group &&
      (group.ownerId === requesterId ||
        (await this.groupRepository.isMember(groupId, requesterId)));
    if (!allowed) {
      throw new NotFoundException(`Group with ID ${groupId} not found`);
    }

    // Owner first, then members
    const owner = await this.userRepository.findById(group.ownerId);
    const members = await this.groupRepository.findMembers(groupId);

    return [
      new GroupMember({
        groupId,
        userId: group.ownerId,
        role: 'owner',
        fullName: owner?.fullName,
        phoneNumber: owner?.phoneNumber,
      }),
      ...members,
    ];
  }
}
