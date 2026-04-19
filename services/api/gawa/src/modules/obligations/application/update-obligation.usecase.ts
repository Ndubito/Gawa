import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { Obligation } from '../domain/entities/obligation.entity';
import { type IObligationRepository, OBLIGATION_REPOSITORY_TOKEN } from '../domain/repos/obligation.repository';
import { ObligationStatus } from '../domain/types/obligation.types';

export interface UpdateObligationDto {
  id: number;
  amountPaid?: number;
  status?: ObligationStatus;
}

@Injectable()
export class UpdateObligationUseCase {
  constructor(
    @Inject(OBLIGATION_REPOSITORY_TOKEN)
    private readonly obligationRepository: IObligationRepository,
  ) {}

  async execute(dto: UpdateObligationDto): Promise<Obligation> {
    const obligation = await this.obligationRepository.findById(dto.id);
    if (!obligation) throw new NotFoundException(`Obligation with ID ${dto.id} not found`);

    const newAmountPaid = dto.amountPaid ?? obligation.amountPaid;
    const newStatus = dto.status ?? obligation.status;
    obligation.updatePayment(newAmountPaid, newStatus);
    return this.obligationRepository.update(obligation);
  }
}
