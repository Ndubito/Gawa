import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../../../prisma/prisma.service';
import { IUserRepository } from '../../domain/repos/user.repository';
import { User } from '../../domain/entities/user.entity';
import { UserMapper } from './user.orm.entity';

@Injectable()
export class UserRepositoryImpl implements IUserRepository {
  constructor(private readonly prisma: PrismaService) { }

  async findById(id: number): Promise<User | null> {
    const raw = await this.prisma.user.findUnique({
      where: { user_id: id },
    });
    return raw ? UserMapper.toDomain(raw) : null;
  }

  async findByEmail(email: string): Promise<User | null> {
    const raw = await this.prisma.user.findUnique({
      where: { email },
    });
    return raw ? UserMapper.toDomain(raw) : null;
  }

  async findByPhoneNumber(phoneNumber: string): Promise<User | null> {
    const raw = await this.prisma.user.findFirst({
      where: { phone_number: phoneNumber },
    });
    return raw ? UserMapper.toDomain(raw) : null;
  }

  async findAll(): Promise<User[]> {
    const raws = await this.prisma.user.findMany();
    return raws.map((raw) => UserMapper.toDomain(raw));
  }

  async save(user: User): Promise<User> {
    const persistenceData = UserMapper.toOrm(user);
    delete persistenceData.user_id;

    const saved = await this.prisma.user.create({
      data: persistenceData as any,
    });

    user.assignId(saved.user_id);
    return UserMapper.toDomain(saved);
  }

  async update(user: User): Promise<User> {
    const persistenceData = UserMapper.toOrm(user);
    delete persistenceData.user_id;

    const updated = await this.prisma.user.update({
      where: { user_id: user.id },
      data: persistenceData as any,
    });

    return UserMapper.toDomain(updated);
  }

  async delete(id: number): Promise<void> {
    await this.prisma.user.update({
      where: { user_id: id },
      data: {
        updated_at: new Date(),
        deleted_at: new Date(),
        status: 'INACTIVE',
      },
    });
  }
}
