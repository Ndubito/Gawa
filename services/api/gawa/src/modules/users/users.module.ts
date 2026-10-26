import { Module } from '@nestjs/common';
import { UserController } from './presentation/user.controller';
import { GetCurrentUserUseCase } from './application/get-current-user.usecase';
import { UpdateUserUseCase } from './application/update-user.usecase';
import { SyncFirebaseUserUseCase } from './application/sync-firebase-user.usecase';
import { USER_REPOSITORY_TOKEN } from './domain/repos/user.repository';
import { UserRepositoryImpl } from './infrastructure/prisma/user.repository.impl';
import { PrismaService } from '../../../prisma/prisma.service';

@Module({
  controllers: [UserController],
  providers: [
    PrismaService,
    {
      provide: USER_REPOSITORY_TOKEN,
      useClass: UserRepositoryImpl,
    },
    GetCurrentUserUseCase,
    UpdateUserUseCase,
    SyncFirebaseUserUseCase,
  ],
  exports: [SyncFirebaseUserUseCase, USER_REPOSITORY_TOKEN],
})
export class UsersModule {}
