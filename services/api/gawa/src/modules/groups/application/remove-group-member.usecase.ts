import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { GroupRole } from '../domain/types/group.types';
import {
  type IGroupRepository,
  GROUP_REPOSITORY_TOKEN,
} from '../domain/repos/group.repository';
import { GroupAccessPolicy, GROUP_VIEWERS } from './group-access.policy';
import { CancelUpcomingObligationsUseCase } from '../../obligations/application/cancel-upcoming-obligations.usecase';

@Injectable()
export class RemoveGroupMemberUseCase {
  constructor(
    @Inject(GROUP_REPOSITORY_TOKEN)
    private readonly groupRepository: IGroupRepository,
    private readonly access: GroupAccessPolicy,
    private readonly cancelUpcomingObligations: CancelUpcomingObligationsUseCase,
  ) {}

  // The owner can remove anyone (including revoking a pending invite);
  // an accepted member can only remove themselves, i.e. leave.
  async execute(
    groupId: number,
    memberUserId: number,
    requesterId: number,
  ): Promise<void> {
    const { role } = await this.access.require(
      groupId,
      requesterId,
      GROUP_VIEWERS,
    );
    const isLeaving = role === GroupRole.MEMBER && memberUserId === requesterId;
    if (role !== GroupRole.OWNER && !isLeaving) {
      throw new NotFoundException(`Group ${groupId} not found`);
    }

    if (!(await this.groupRepository.findMembership(groupId, memberUserId))) {
      throw new NotFoundException('This person is not a member of the group');
    }

    await this.groupRepository.removeMember(groupId, memberUserId);
    await this.cancelUpcomingObligations.forMemberLeavingGroup(
      groupId,
      memberUserId,
    );
  }
}
