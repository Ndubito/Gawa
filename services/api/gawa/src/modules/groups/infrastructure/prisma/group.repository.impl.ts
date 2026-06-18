import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../../../prisma/prisma.service';
import { IGroupRepository } from '../../domain/repos/group.repository';
import { Group } from '../../domain/entities/group.entity';
import { GroupMember } from '../../domain/entities/group-member.entity';
import { GroupMapper } from './group.orm.entity';

@Injectable()
export class GroupRepositoryImpl implements IGroupRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findById(id: number): Promise<Group | null> {
    const raw = await this.prisma.group.findFirst({
      where: { group_id: id, deleted_at: null },
    });
    return raw ? GroupMapper.toDomain(raw) : null;
  }

  async findByOwnerId(ownerId: number): Promise<Group[]> {
    const raws = await this.prisma.group.findMany({
      where: { owner_id: ownerId, deleted_at: null },
      orderBy: { created_at: 'desc' },
    });
    return raws.map((raw) => GroupMapper.toDomain(raw));
  }

  async findByUser(userId: number): Promise<Group[]> {
    const raws = await this.prisma.group.findMany({
      where: {
        deleted_at: null,
        OR: [
          { owner_id: userId },
          { members: { some: { user_id: userId } } },
        ],
      },
      orderBy: { created_at: 'desc' },
    });
    return raws.map((raw) => GroupMapper.toDomain(raw));
  }

  async findAll(): Promise<Group[]> {
    const raws = await this.prisma.group.findMany({
      where: { deleted_at: null },
    });
    return raws.map((raw) => GroupMapper.toDomain(raw));
  }

  async save(group: Group): Promise<Group> {
    const data = GroupMapper.toOrm(group);
    delete data.group_id;

    const saved = await this.prisma.group.create({ data: data as any });
    group.assignId(saved.group_id);
    return GroupMapper.toDomain(saved);
  }

  async update(group: Group): Promise<Group> {
    const data = GroupMapper.toOrm(group);
    delete data.group_id;

    const updated = await this.prisma.group.update({
      where: { group_id: group.id },
      data: data as any,
    });
    return GroupMapper.toDomain(updated);
  }

  async delete(id: number): Promise<void> {
    await this.prisma.group.update({
      where: { group_id: id },
      data: {
        deleted_at: new Date(),
        updated_at: new Date(),
      },
    });
  }

  async addMember(groupId: number, userId: number, role?: string): Promise<void> {
    await this.prisma.groupMember.create({
      data: {
        group_id: groupId,
        user_id: userId,
        role: role ?? 'member',
      },
    });
  }

  async removeMember(groupId: number, userId: number): Promise<void> {
    await this.prisma.groupMember.delete({
      where: {
        group_id_user_id: { group_id: groupId, user_id: userId },
      },
    });
  }

  async findMembers(groupId: number): Promise<GroupMember[]> {
    const raws = await this.prisma.groupMember.findMany({
      where: { group_id: groupId },
      include: { user: true },
    });
    return raws.map(
      (raw) =>
        new GroupMember({
          groupId: raw.group_id,
          userId: raw.user_id,
          role: raw.role,
          fullName: raw.user.full_name,
          phoneNumber: raw.user.phone_number,
        }),
    );
  }

  async isMember(groupId: number, userId: number): Promise<boolean> {
    const count = await this.prisma.groupMember.count({
      where: { group_id: groupId, user_id: userId },
    });
    return count > 0;
  }
}
