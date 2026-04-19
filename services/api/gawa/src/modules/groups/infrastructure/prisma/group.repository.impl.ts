import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../../../prisma/prisma.service';
import { IGroupRepository } from '../../domain/repos/group.repository';
import { Group } from '../../domain/entities/group.entity';
import { GroupMapper } from './group.orm.entity';

@Injectable()
export class GroupRepositoryImpl implements IGroupRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findById(id: number): Promise<Group | null> {
    const raw = await this.prisma.group.findUnique({ where: { group_id: id } });
    return raw ? GroupMapper.toDomain(raw) : null;
  }

  async findAll(): Promise<Group[]> {
    const raws = await this.prisma.group.findMany();
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
}
