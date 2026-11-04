import { Injectable, Inject } from '@nestjs/common';
import { GroupInvite } from '../domain/entities/group-invite.entity';
import { GroupRole } from '../domain/types/group.types';
import {
  type IGroupRepository,
  GROUP_REPOSITORY_TOKEN,
} from '../domain/repos/group.repository';
import { GroupAccessPolicy } from './group-access.policy';

@Injectable()
export class GroupInvitesUseCase {
  constructor(
    @Inject(GROUP_REPOSITORY_TOKEN)
    private readonly groupRepository: IGroupRepository,
    private readonly access: GroupAccessPolicy,
  ) {}

  async listForUser(userId: number): Promise<GroupInvite[]> {
    return this.groupRepository.findInvitesForUser(userId);
  }

  async accept(groupId: number, userId: number): Promise<void> {
    await this.requirePendingInvite(groupId, userId);
    await this.groupRepository.activateMember(groupId, userId);
  }

  // Declining deletes the row, so the owner can simply invite again later.
  async decline(groupId: number, userId: number): Promise<void> {
    await this.requirePendingInvite(groupId, userId);
    await this.groupRepository.removeMember(groupId, userId);
  }

  private async requirePendingInvite(
    groupId: number,
    userId: number,
  ): Promise<void> {
    await this.access.require(
      groupId,
      userId,
      [GroupRole.INVITED],
      `Invite to group ${groupId} not found`,
    );
  }
}
