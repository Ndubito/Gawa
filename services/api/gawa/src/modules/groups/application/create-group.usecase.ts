import { Injectable, Inject } from '@nestjs/common';
import { Group } from '../domain/entities/group.entity';
import { type IGroupRepository, GROUP_REPOSITORY_TOKEN } from '../domain/repos/group.repository';
import { CreateGroupDto } from '../presentation/dtos/create-group.dto';

@Injectable()
export class CreateGroupUseCase {
  constructor(
    @Inject(GROUP_REPOSITORY_TOKEN)
    private readonly groupRepository: IGroupRepository,
  ) {}

  async execute(dto: CreateGroupDto): Promise<Group> {
    const group = new Group({
      name: dto.name,
      description: dto.description,
      ownerId: dto.ownerId,
    });
    return this.groupRepository.save(group);
  }
}
