import { Injectable, Inject } from '@nestjs/common';
import { GroupMember } from '../domain/entities/group-member.entity';
import { GroupMemberStatus, GroupRole } from '../domain/types/group.types';
import {
  type IGroupRepository,
  GROUP_REPOSITORY_TOKEN,
} from '../domain/repos/group.repository';
import {
  type IUserRepository,
  USER_REPOSITORY_TOKEN,
} from '../../users/domain/repos/user.repository';
import { GroupAccessPolicy, GROUP_VIEWERS } from './group-access.policy';

@Injectable()
export class ListGroupMembersUseCase {
  constructor(
    @Inject(GROUP_REPOSITORY_TOKEN)
    private readonly groupRepository: IGroupRepository,
    @Inject(USER_REPOSITORY_TOKEN)
    private readonly userRepository: IUserRepository,
    private readonly access: GroupAccessPolicy,
  ) {}

  // Owner first, then members. Only the owner sees pending invitees —
  // they haven't agreed to share their details with the group yet.
  async execute(groupId: number, requesterId: number): Promise<GroupMember[]> {
    const { group, role } = await this.access.require(
      groupId,
      requesterId,
      GROUP_VIEWERS,
    );

    const owner = await this.userRepository.findById(group.ownerId);
    const members = await this.groupRepository.findMembers(groupId);
    const visible =
      role === GroupRole.OWNER ? members : members.filter((m) => m.isActive);

    return [
      new GroupMember({
        groupId,
        userId: group.ownerId,
        role: 'owner',
        status: GroupMemberStatus.ACTIVE,
        fullName: owner?.fullName,
        phoneNumber: owner?.phoneNumber,
      }),
      ...visible,
    ];
  }
}
