import { Injectable, Inject } from '@nestjs/common';
import { CLOCK, type Clock } from '../../../common/clock';
import {
  type IObligationRepository,
  OBLIGATION_REPOSITORY_TOKEN,
} from '../domain/repos/obligation.repository';

// Cancels unpaid obligations that aren't due yet, which also silences their
// reminders. Anything already due still stands — stopping or leaving can't
// erase a bill someone has already incurred.
@Injectable()
export class CancelUpcomingObligationsUseCase {
  constructor(
    @Inject(OBLIGATION_REPOSITORY_TOKEN)
    private readonly obligationRepository: IObligationRepository,
    @Inject(CLOCK)
    private readonly clock: Clock,
  ) {}

  async forMemberLeavingGroup(
    groupId: number,
    userId: number,
  ): Promise<number> {
    return this.obligationRepository.cancelUnpaid({
      groupId,
      userId,
      dueAfter: this.clock(),
    });
  }

  async forDeletedGroup(groupId: number): Promise<number> {
    return this.obligationRepository.cancelUnpaid({
      groupId,
      dueAfter: this.clock(),
    });
  }

  async forStoppedSubscription(subscriptionId: number): Promise<number> {
    return this.obligationRepository.cancelUnpaid({
      subscriptionId,
      dueAfter: this.clock(),
    });
  }
}
