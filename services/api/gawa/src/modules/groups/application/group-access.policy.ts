import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { Group } from '../domain/entities/group.entity';
import { GroupRole } from '../domain/types/group.types';
import {
  type IGroupRepository,
  GROUP_REPOSITORY_TOKEN,
} from '../domain/repos/group.repository';

export const OWNER_ONLY: readonly GroupRole[] = [GroupRole.OWNER];
export const GROUP_VIEWERS: readonly GroupRole[] = [
  GroupRole.OWNER,
  GroupRole.MEMBER,
];

export interface GroupAccess {
  group: Group;
  role: GroupRole;
}

@Injectable()
export class GroupAccessPolicy {
  constructor(
    @Inject(GROUP_REPOSITORY_TOKEN)
    private readonly groupRepository: IGroupRepository,
  ) {}

  async roleOf(group: Group, userId: number): Promise<GroupRole | null> {
    if (group.ownerId === userId) return GroupRole.OWNER;
    const membership = await this.groupRepository.findMembership(
      group.id!,
      userId,
    );
    if (!membership) return null;
    return membership.isActive ? GroupRole.MEMBER : GroupRole.INVITED;
  }

  // Missing groups and insufficient roles both 404 so ids don't leak.
  async require(
    groupId: number,
    userId: number,
    allowed: readonly GroupRole[],
    notFoundMessage = `Group ${groupId} not found`,
  ): Promise<GroupAccess> {
    const group = await this.groupRepository.findById(groupId);
    const role = group ? await this.roleOf(group, userId) : null;
    if (!group || !role || !allowed.includes(role)) {
      throw new NotFoundException(notFoundMessage);
    }
    return { group, role };
  }
}
