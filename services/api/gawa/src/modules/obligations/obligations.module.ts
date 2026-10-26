import { Module } from '@nestjs/common';
import { ObligationController } from './presentation/obligation.controller';
import { GetObligationUseCase } from './application/get-obligation.usecase';
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
    GetObligationUseCase,
  ],
  exports: [GetObligationUseCase, OBLIGATION_REPOSITORY_TOKEN],
})
export class ObligationsModule {}
