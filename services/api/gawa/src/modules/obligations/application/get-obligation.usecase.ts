import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { Obligation } from '../domain/entities/obligation.entity';
import { type IObligationRepository, OBLIGATION_REPOSITORY_TOKEN } from '../domain/repos/obligation.repository';

@Injectable()
export class GetObligationUseCase {
  constructor(
    @Inject(OBLIGATION_REPOSITORY_TOKEN)
    private readonly obligationRepository: IObligationRepository,
  ) {}

  async execute(id: number): Promise<Obligation> {
    const obligation = await this.obligationRepository.findById(id);
    if (!obligation) throw new NotFoundException(`Obligation with ID ${id} not found`);
    return obligation;
  }

  async executeAll(): Promise<Obligation[]> {
    return this.obligationRepository.findAll();
  }
}
