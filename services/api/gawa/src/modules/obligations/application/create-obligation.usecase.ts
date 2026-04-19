import { Injectable, Inject } from '@nestjs/common';
import { Obligation } from '../domain/entities/obligation.entity';
import { type IObligationRepository, OBLIGATION_REPOSITORY_TOKEN } from '../domain/repos/obligation.repository';
import { CreateObligationDto } from '../presentation/dtos/create-obligation.dto';

@Injectable()
export class CreateObligationUseCase {
  constructor(
    @Inject(OBLIGATION_REPOSITORY_TOKEN)
    private readonly obligationRepository: IObligationRepository,
  ) {}

  async execute(dto: CreateObligationDto): Promise<Obligation> {
    const obligation = new Obligation({
      subscriptionCycleId: dto.subscriptionCycleId,
      expenseId: dto.expenseId,
      userId: dto.userId,
      recipientId: dto.recipientId,
      sourceType: dto.sourceType,
      amountDue: dto.amountDue,
      currency: dto.currency,
      dueAt: dto.dueAt,
    });
    return this.obligationRepository.save(obligation);
  }
}
