import { IGroupRepository } from '../domain/repos/group.repository';
import { Group } from '../domain/entities/group.entity';
import { GroupMember } from '../domain/entities/group-member.entity';
import { GroupInvite } from '../domain/entities/group-invite.entity';
import { GroupMemberStatus } from '../domain/types/group.types';

// Behaves like the Prisma repository (soft deletes, owner implicit) so
// access rules are tested against realistic data rather than stubbed answers.
export class InMemoryGroupRepository implements IGroupRepository {
  private readonly groups = new Map<number, Group>();
  private members: GroupMember[] = [];
  private nextId = 1;

  seedGroup(props: { id: number; ownerId: number; name?: string }): Group {
    const group = new Group({
      id: props.id,
      ownerId: props.ownerId,
      name: props.name ?? `Group ${props.id}`,
    });
    this.groups.set(props.id, group);
    this.nextId = Math.max(this.nextId, props.id + 1);
    return group;
  }

  seedMember(groupId: number, userId: number, status: GroupMemberStatus): void {
    this.members.push(new GroupMember({ groupId, userId, status }));
  }

  async findById(id: number): Promise<Group | null> {
    const group = this.groups.get(id);
    return group && !group.deletedAt ? group : null;
  }

  async findByOwnerId(ownerId: number): Promise<Group[]> {
    return this.live().filter((g) => g.ownerId === ownerId);
  }

  async findByUser(userId: number): Promise<Group[]> {
    return this.live().filter(
      (g) =>
        g.ownerId === userId ||
        this.members.some(
          (m) => m.groupId === g.id && m.userId === userId && m.isActive,
        ),
    );
  }

  async findAll(): Promise<Group[]> {
    return this.live();
  }

  async save(group: Group): Promise<Group> {
    group.assignId(this.nextId++);
    this.groups.set(group.id!, group);
    return group;
  }

  async update(group: Group): Promise<Group> {
    this.groups.set(group.id!, group);
    return group;
  }

  async delete(id: number): Promise<void> {
    this.groups.get(id)?.delete();
  }

  async addMember(groupId: number, userId: number): Promise<void> {
    this.members.push(
      new GroupMember({ groupId, userId, status: GroupMemberStatus.INVITED }),
    );
  }

  async activateMember(groupId: number, userId: number): Promise<void> {
    this.members = this.members.map((m) =>
      m.groupId === groupId && m.userId === userId
        ? new GroupMember({ groupId, userId, status: GroupMemberStatus.ACTIVE })
        : m,
    );
  }

  async removeMember(groupId: number, userId: number): Promise<void> {
    this.members = this.members.filter(
      (m) => !(m.groupId === groupId && m.userId === userId),
    );
  }

  async findMembers(groupId: number): Promise<GroupMember[]> {
    return this.members.filter((m) => m.groupId === groupId);
  }

  async findMembership(
    groupId: number,
    userId: number,
  ): Promise<GroupMember | null> {
    return (
      this.members.find((m) => m.groupId === groupId && m.userId === userId) ??
      null
    );
  }

  async findInvitesForUser(userId: number): Promise<GroupInvite[]> {
    return this.members
      .filter(
        (m) =>
          m.userId === userId &&
          !m.isActive &&
          this.groups.get(m.groupId) &&
          !this.groups.get(m.groupId)!.deletedAt,
      )
      .map((m) => {
        const group = this.groups.get(m.groupId)!;
        return new GroupInvite({
          groupId: group.id!,
          groupName: group.name,
          invitedByName: `User ${group.ownerId}`,
        });
      });
  }

  private live(): Group[] {
    return [...this.groups.values()].filter((g) => !g.deletedAt);
  }
}
