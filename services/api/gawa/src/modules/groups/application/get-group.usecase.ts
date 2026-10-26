import { Injectable, Inject } from '@nestjs/common';
import { Group } from '../domain/entities/group.entity';
import {
  type IGroupRepository,
  GROUP_REPOSITORY_TOKEN,
} from '../domain/repos/group.repository';
import { GroupAccessPolicy, GROUP_VIEWERS } from './group-access.policy';

@Injectable()
export class GetGroupUseCase {
  constructor(
    @Inject(GROUP_REPOSITORY_TOKEN)
    private readonly groupRepository: IGroupRepository,
    private readonly access: GroupAccessPolicy,
  ) {}

  async execute(id: number, requesterId: number): Promise<Group> {
    const { group } = await this.access.require(id, requesterId, GROUP_VIEWERS);
    return group;
  }

  /// Groups the user owns or has accepted membership of.
  async executeForUser(userId: number): Promise<Group[]> {
    return this.groupRepository.findByUser(userId);
  }
}
