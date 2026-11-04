import { CancelUpcomingObligationsUseCase } from './cancel-upcoming-obligations.usecase';
import { IObligationRepository } from '../domain/repos/obligation.repository';

describe('CancelUpcomingObligationsUseCase', () => {
  const now = new Date('2026-11-05T06:00:00Z');
  let repo: jest.Mocked<IObligationRepository>;
  let useCase: CancelUpcomingObligationsUseCase;

  beforeEach(() => {
    repo = {
      findById: jest.fn(),
      findViewById: jest.fn(),
      findViewsForUser: jest.fn(),
      save: jest.fn(),
      update: jest.fn(),
      cancelUnpaid: jest.fn().mockResolvedValue(2),
    };
    useCase = new CancelUpcomingObligationsUseCase(repo, () => now);
  });

  it('cancels only the leaving member’s not-yet-due bills in that group', async () => {
    await expect(useCase.forMemberLeavingGroup(10, 2)).resolves.toBe(2);
    expect(repo.cancelUnpaid).toHaveBeenCalledWith({
      groupId: 10,
      userId: 2,
      dueAfter: now,
    });
  });

  it('cancels every member’s not-yet-due bills for a stopped subscription', async () => {
    await useCase.forStoppedSubscription(5);
    expect(repo.cancelUnpaid).toHaveBeenCalledWith({
      subscriptionId: 5,
      dueAfter: now,
    });
  });

  it('cancels not-yet-due bills across a deleted group', async () => {
    await useCase.forDeletedGroup(10);
    expect(repo.cancelUnpaid).toHaveBeenCalledWith({
      groupId: 10,
      dueAfter: now,
    });
  });
});
