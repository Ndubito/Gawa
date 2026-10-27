import { NotFoundException } from '@nestjs/common';
import { GetObligationUseCase } from './get-obligation.usecase';
import { IObligationRepository } from '../domain/repos/obligation.repository';
import { Obligation } from '../domain/entities/obligation.entity';
import { ObligationSourceType } from '../domain/types/obligation.types';

const DEBTOR = 2;
const CREDITOR = 1;
const GROUPMATE = 3;

const makeObligation = () =>
  new Obligation({
    id: 7,
    userId: DEBTOR,
    recipientId: CREDITOR,
    sourceType: ObligationSourceType.SUBSCRIPTION_CYCLE,
    amountDue: 50000,
    dueAt: new Date('2026-11-01'),
    overdueAt: new Date('2026-11-02'),
  });

describe('GetObligationUseCase', () => {
  let repo: jest.Mocked<IObligationRepository>;
  let useCase: GetObligationUseCase;

  beforeEach(() => {
    repo = {
      findById: jest.fn().mockResolvedValue(makeObligation()),
      findForUser: jest.fn().mockResolvedValue([makeObligation()]),
      save: jest.fn(),
      update: jest.fn(),
      cancelUnpaid: jest.fn(),
    };
    useCase = new GetObligationUseCase(repo);
  });

  it.each([DEBTOR, CREDITOR])(
    'returns the obligation to party %i',
    async (userId) => {
      expect((await useCase.execute(7, userId)).id).toBe(7);
    },
  );

  it('404s anyone else, including people in the same group', async () => {
    await expect(useCase.execute(7, GROUPMATE)).rejects.toThrow(
      NotFoundException,
    );
  });

  it('404s a missing obligation', async () => {
    repo.findById.mockResolvedValue(null);
    await expect(useCase.execute(7, DEBTOR)).rejects.toThrow(NotFoundException);
  });

  it('lists only obligations the requester is party to', async () => {
    await useCase.executeForUser(DEBTOR);
    expect(repo.findForUser).toHaveBeenCalledWith(DEBTOR);
  });
});
