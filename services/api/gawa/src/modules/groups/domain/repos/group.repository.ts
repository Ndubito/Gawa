import { Group } from '../entities/group.entity';
import { GroupMember } from '../entities/group-member.entity';

export interface IGroupRepository {
  findById(id: number): Promise<Group | null>;
  findByOwnerId(ownerId: number): Promise<Group[]>;
  findByUser(userId: number): Promise<Group[]>;
  findAll(): Promise<Group[]>;
  save(group: Group): Promise<Group>;
  update(group: Group): Promise<Group>;
  delete(id: number): Promise<void>;

  // Membership
  addMember(groupId: number, userId: number, role?: string): Promise<void>;
  removeMember(groupId: number, userId: number): Promise<void>;
  findMembers(groupId: number): Promise<GroupMember[]>;
  isMember(groupId: number, userId: number): Promise<boolean>;
}

export const GROUP_REPOSITORY_TOKEN = Symbol('GROUP_REPOSITORY_TOKEN');
