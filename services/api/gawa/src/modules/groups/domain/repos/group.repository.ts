import { Group } from '../entities/group.entity';
import { GroupMember } from '../entities/group-member.entity';
import { GroupInvite } from '../entities/group-invite.entity';

export interface IGroupRepository {
  findById(id: number): Promise<Group | null>;
  findByOwnerId(ownerId: number): Promise<Group[]>;
  // Groups the user owns or has accepted membership of (pending invites excluded)
  findByUser(userId: number): Promise<Group[]>;
  findAll(): Promise<Group[]>;
  save(group: Group): Promise<Group>;
  update(group: Group): Promise<Group>;
  delete(id: number): Promise<void>;

  // Membership
  addMember(groupId: number, userId: number): Promise<void>;
  activateMember(groupId: number, userId: number): Promise<void>;
  removeMember(groupId: number, userId: number): Promise<void>;
  findMembers(groupId: number): Promise<GroupMember[]>;
  findMembership(groupId: number, userId: number): Promise<GroupMember | null>;
  findInvitesForUser(userId: number): Promise<GroupInvite[]>;
}

export const GROUP_REPOSITORY_TOKEN = Symbol('GROUP_REPOSITORY_TOKEN');
