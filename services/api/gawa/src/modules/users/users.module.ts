import { Module } from '@nestjs/common';
import { UserController } from './presentation/user.controller';
import { CreateUserUseCase } from './application/create-user.usecase';
import { GetUserUseCase } from './application/get-user.usecase';
import { UpdateUserUseCase } from './application/update-user.usecase';
import { DeleteUserUseCase } from './application/delete-user.usecase';
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
    CreateUserUseCase,
    GetUserUseCase,
    UpdateUserUseCase,
    DeleteUserUseCase,
  ],
  exports: [
    CreateUserUseCase,
    GetUserUseCase,
    UpdateUserUseCase,
    DeleteUserUseCase,
    USER_REPOSITORY_TOKEN,
  ],
})
export class UsersModule { }
