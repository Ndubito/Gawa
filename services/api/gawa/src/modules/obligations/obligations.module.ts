import { Module } from '@nestjs/common';
import { ObligationController } from './presentation/obligation.controller';
import { CreateObligationUseCase } from './application/create-obligation.usecase';
import { GetObligationUseCase } from './application/get-obligation.usecase';
import { UpdateObligationUseCase } from './application/update-obligation.usecase';
import { OBLIGATION_REPOSITORY_TOKEN } from './domain/repos/obligation.repository';
import { ObligationRepositoryImpl } from './infrastructure/prisma/obligation.repository.impl';
import { PrismaService } from '../../../prisma/prisma.service';

@Module({
  controllers: [ObligationController],
  providers: [
    PrismaService,
    {
      provide: OBLIGATION_REPOSITORY_TOKEN,
      useClass: ObligationRepositoryImpl,
    },
    CreateObligationUseCase,
    GetObligationUseCase,
    UpdateObligationUseCase,
  ],
  exports: [
    CreateObligationUseCase,
    GetObligationUseCase,
    UpdateObligationUseCase,
    OBLIGATION_REPOSITORY_TOKEN,
  ],
})
export class ObligationsModule {}
