import { Module } from '@nestjs/common';
import { UsersModule } from '../users/users.module';
import { GroupController } from './presentation/group.controller';
import { CreateGroupUseCase } from './application/create-group.usecase';
import { GetGroupUseCase } from './application/get-group.usecase';
import { UpdateGroupUseCase } from './application/update-group.usecase';
import { DeleteGroupUseCase } from './application/delete-group.usecase';
import { GROUP_REPOSITORY_TOKEN } from './domain/repos/group.repository';
import { GroupRepositoryImpl } from './infrastructure/prisma/group.repository.impl';
import { PrismaService } from '../../../prisma/prisma.service';

@Module({
  imports: [UsersModule],
  controllers: [GroupController],
  providers: [
    PrismaService,
    {
      provide: GROUP_REPOSITORY_TOKEN,
      useClass: GroupRepositoryImpl,
    },
    CreateGroupUseCase,
    GetGroupUseCase,
    UpdateGroupUseCase,
    DeleteGroupUseCase,
  ],
  exports: [
    CreateGroupUseCase,
    GetGroupUseCase,
    UpdateGroupUseCase,
    DeleteGroupUseCase,
    GROUP_REPOSITORY_TOKEN,
  ],
})
export class GroupsModule {}
