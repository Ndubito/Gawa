import { Injectable, Inject } from '@nestjs/common';
import {
  type IGroupRepository,
  GROUP_REPOSITORY_TOKEN,
} from '../domain/repos/group.repository';
import { GroupAccessPolicy, OWNER_ONLY } from './group-access.policy';
import { CancelUpcomingObligationsUseCase } from '../../obligations/application/cancel-upcoming-obligations.usecase';

@Injectable()
export class DeleteGroupUseCase {
  constructor(
    @Inject(GROUP_REPOSITORY_TOKEN)
    private readonly groupRepository: IGroupRepository,
    private readonly access: GroupAccessPolicy,
    private readonly cancelUpcomingObligations: CancelUpcomingObligationsUseCase,
  ) {}

  async execute(id: number, requesterId: number): Promise<void> {
    await this.access.require(id, requesterId, OWNER_ONLY);
    await this.groupRepository.delete(id);
    await this.cancelUpcomingObligations.forDeletedGroup(id);
  }
}
