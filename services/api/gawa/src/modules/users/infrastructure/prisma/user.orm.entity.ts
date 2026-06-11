import { User } from '../../domain/entities/user.entity';
import { UserStatus } from '../../domain/types/user.types';

export interface UserOrmEntity {
  user_id: number;
  firebase_uid: string | null;
  full_name: string;
  phone_number: string;
  email: string | null;
  status: string;
  created_at: Date;
  updated_at: Date;
  deleted_at: Date | null;
}

export class UserMapper {
  static toDomain(raw: UserOrmEntity): User {
    return new User({
      id: raw.user_id,
      firebaseUid: raw.firebase_uid,
      fullName: raw.full_name,
      phoneNumber: raw.phone_number,
      email: raw.email,
      status: raw.status as UserStatus,
      createdAt: raw.created_at,
      updatedAt: raw.updated_at,
      deletedAt: raw.deleted_at,
    });
  }

  static toOrm(user: User): Omit<UserOrmEntity, 'user_id' | 'created_at' | 'updated_at' | 'deleted_at'> & Partial<UserOrmEntity> {
    return {
      user_id: user.id,
      firebase_uid: user.firebaseUid ?? null,
      full_name: user.fullName,
      phone_number: user.phoneNumber,
      email: user.email ?? null,
      status: user.status as string,
    };
  }
}
