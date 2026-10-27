import { Module } from '@nestjs/common';
import { ObligationController } from './presentation/obligation.controller';
import { GetObligationUseCase } from './application/get-obligation.usecase';
import { CancelUpcomingObligationsUseCase } from './application/cancel-upcoming-obligations.usecase';
import { OBLIGATION_REPOSITORY_TOKEN } from './domain/repos/obligation.repository';
import { ObligationRepositoryImpl } from './infrastructure/prisma/obligation.repository.impl';
import { PrismaService } from '../../../prisma/prisma.service';
import { clockProvider } from '../../common/clock';

@Module({
  controllers: [ObligationController],
  providers: [
    PrismaService,
    clockProvider,
    {
      provide: OBLIGATION_REPOSITORY_TOKEN,
      useClass: ObligationRepositoryImpl,
    },
    GetObligationUseCase,
    CancelUpcomingObligationsUseCase,
  ],
  exports: [
    GetObligationUseCase,
    CancelUpcomingObligationsUseCase,
    OBLIGATION_REPOSITORY_TOKEN,
  ],
})
export class ObligationsModule {}
