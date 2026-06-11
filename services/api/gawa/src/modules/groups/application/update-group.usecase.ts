import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { Group } from '../domain/entities/group.entity';
import { type IGroupRepository, GROUP_REPOSITORY_TOKEN } from '../domain/repos/group.repository';

export interface UpdateGroupDto {
  id: number;
  name?: string;
  description?: string;
}

@Injectable()
export class UpdateGroupUseCase {
  constructor(
    @Inject(GROUP_REPOSITORY_TOKEN)
    private readonly groupRepository: IGroupRepository,
  ) {}

  async execute(dto: UpdateGroupDto, requesterId: number): Promise<Group> {
    const group = await this.groupRepository.findById(dto.id);
    if (!group || group.ownerId !== requesterId) {
      throw new NotFoundException(`Group with ID ${dto.id} not found`);
    }

    group.update(dto.name, dto.description);
    return this.groupRepository.update(group);
  }
}
