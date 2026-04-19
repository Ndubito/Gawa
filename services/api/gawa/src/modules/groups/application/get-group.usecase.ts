import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { Group } from '../domain/entities/group.entity';
import { type IGroupRepository, GROUP_REPOSITORY_TOKEN } from '../domain/repos/group.repository';

@Injectable()
export class GetGroupUseCase {
  constructor(
    @Inject(GROUP_REPOSITORY_TOKEN)
    private readonly groupRepository: IGroupRepository,
  ) {}

  async execute(id: number): Promise<Group> {
    const group = await this.groupRepository.findById(id);
    if (!group) throw new NotFoundException(`Group with ID ${id} not found`);
    return group;
  }

  async executeAll(): Promise<Group[]> {
    return this.groupRepository.findAll();
  }
}
