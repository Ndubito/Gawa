import { Group } from '../entities/group.entity';

export interface IGroupRepository {
  findById(id: number): Promise<Group | null>;
  findByOwnerId(ownerId: number): Promise<Group[]>;
  findAll(): Promise<Group[]>;
  save(group: Group): Promise<Group>;
  update(group: Group): Promise<Group>;
  delete(id: number): Promise<void>;
}

export const GROUP_REPOSITORY_TOKEN = Symbol('GROUP_REPOSITORY_TOKEN');
