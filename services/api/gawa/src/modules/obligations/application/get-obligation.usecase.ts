import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { CLOCK, type Clock } from '../../../common/clock';
import {
  type IObligationRepository,
  OBLIGATION_REPOSITORY_TOKEN,
} from '../domain/repos/obligation.repository';
import {
  ObligationView,
  SETTLED_HISTORY_DAYS,
} from '../domain/types/obligation-view';

const DAY_MS = 86_400_000;

@Injectable()
export class GetObligationUseCase {
  constructor(
    @Inject(OBLIGATION_REPOSITORY_TOKEN)
    private readonly obligationRepository: IObligationRepository,
    @Inject(CLOCK)
    private readonly clock: Clock,
  ) {}

  // Only the person who owes and the person owed may see a bill.
  async execute(id: number, requesterId: number): Promise<ObligationView> {
    const view = await this.obligationRepository.findViewById(id);
    if (
      !view ||
      (view.debtor.userId !== requesterId &&
        view.creditor.userId !== requesterId)
    ) {
      throw new NotFoundException(`Obligation ${id} not found`);
    }
    return view;
  }

  // Every open bill the requester owes or is owed, plus recent settled ones.
  async executeForUser(requesterId: number): Promise<ObligationView[]> {
    const settledSince = new Date(
      this.clock().getTime() - SETTLED_HISTORY_DAYS * DAY_MS,
    );
    return this.obligationRepository.findViewsForUser(
      requesterId,
      settledSince,
    );
  }
}
