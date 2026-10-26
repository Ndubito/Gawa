import { Injectable, Inject } from '@nestjs/common';
import { Group } from '../domain/entities/group.entity';
import {
  type IGroupRepository,
  GROUP_REPOSITORY_TOKEN,
} from '../domain/repos/group.repository';
import { GroupAccessPolicy, OWNER_ONLY } from './group-access.policy';

export interface UpdateGroupInput {
  id: number;
  name?: string;
  description?: string;
}

@Injectable()
export class UpdateGroupUseCase {
  constructor(
    @Inject(GROUP_REPOSITORY_TOKEN)
    private readonly groupRepository: IGroupRepository,
    private readonly access: GroupAccessPolicy,
  ) {}

  async execute(input: UpdateGroupInput, requesterId: number): Promise<Group> {
    const { group } = await this.access.require(
      input.id,
      requesterId,
      OWNER_ONLY,
    );
    group.update(input.name, input.description);
    return this.groupRepository.update(group);
  }
}
