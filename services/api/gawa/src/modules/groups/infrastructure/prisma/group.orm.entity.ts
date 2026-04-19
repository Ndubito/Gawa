import { Group } from '../../domain/entities/group.entity';

export interface GroupOrmEntity {
  group_id: number;
  group_name: string;
  group_description: string | null;
  owner_id: number;
  created_at: Date;
  updated_at: Date;
  deleted_at: Date | null;
}

export class GroupMapper {
  static toDomain(raw: GroupOrmEntity): Group {
    return new Group({
      id: raw.group_id,
      name: raw.group_name,
      description: raw.group_description,
      ownerId: raw.owner_id,
      createdAt: raw.created_at,
      updatedAt: raw.updated_at,
      deletedAt: raw.deleted_at,
    });
  }

  static toOrm(group: Group): Omit<GroupOrmEntity, 'group_id' | 'created_at' | 'updated_at' | 'deleted_at'> & Partial<GroupOrmEntity> {
    return {
      group_id: group.id,
      group_name: group.name,
      group_description: group.description ?? null,
      owner_id: group.ownerId,
    };
  }
}
