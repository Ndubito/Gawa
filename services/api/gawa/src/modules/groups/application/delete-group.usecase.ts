import { Injectable, Inject } from '@nestjs/common';
import {
  type IGroupRepository,
  GROUP_REPOSITORY_TOKEN,
} from '../domain/repos/group.repository';
import { GroupAccessPolicy, OWNER_ONLY } from './group-access.policy';

@Injectable()
export class DeleteGroupUseCase {
  constructor(
    @Inject(GROUP_REPOSITORY_TOKEN)
    private readonly groupRepository: IGroupRepository,
    private readonly access: GroupAccessPolicy,
  ) {}

  async execute(id: number, requesterId: number): Promise<void> {
    await this.access.require(id, requesterId, OWNER_ONLY);
    await this.groupRepository.delete(id);
  }
}
