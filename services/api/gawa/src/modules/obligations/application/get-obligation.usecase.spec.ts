import { NotFoundException } from '@nestjs/common';
import { GetObligationUseCase } from './get-obligation.usecase';
import { IObligationRepository } from '../domain/repos/obligation.repository';
import { ObligationView } from '../domain/types/obligation-view';
import {
  Currency,
  ObligationSourceType,
  ObligationStatus,
} from '../domain/types/obligation.types';
import { ObligationResponseDto } from '../presentation/dtos/obligation-response.dto';

const DEBTOR = 2;
const CREDITOR = 1;
const GROUPMATE = 3;
const NOW = new Date('2026-11-05T06:00:00Z');

const dinner = (): ObligationView => ({
  id: 7,
  debtor: { userId: DEBTOR, name: 'Mary' },
  creditor: { userId: CREDITOR, name: 'Nathan' },
  source: {
    type: ObligationSourceType.EXPENSE,
    name: 'Dinner',
    groupId: 10,
    groupName: 'Diani trip',
    periodStart: null,
    periodEnd: null,
  },
  amountDue: 100_000,
  amountPaid: 0,
  currency: Currency.KES,
  status: ObligationStatus.PENDING,
  dueAt: new Date('2026-11-08T06:00:00Z'),
  overdueAt: new Date('2026-11-09T06:00:00Z'),
  updatedAt: NOW,
});

describe('GetObligationUseCase', () => {
  let repo: jest.Mocked<IObligationRepository>;
  let useCase: GetObligationUseCase;

  beforeEach(() => {
    repo = {
      findById: jest.fn(),
      findViewById: jest.fn().mockResolvedValue(dinner()),
      findViewsForUser: jest.fn().mockResolvedValue([dinner()]),
      save: jest.fn(),
      update: jest.fn(),
      cancelUnpaid: jest.fn(),
    };
    useCase = new GetObligationUseCase(repo, () => NOW);
  });

  it.each([DEBTOR, CREDITOR])(
    'returns the bill to party %i',
    async (userId) => {
      expect((await useCase.execute(7, userId)).id).toBe(7);
    },
  );

  it('404s anyone else, including people in the same group', async () => {
    await expect(useCase.execute(7, GROUPMATE)).rejects.toThrow(
      NotFoundException,
    );
  });

  it('404s a missing bill', async () => {
    repo.findViewById.mockResolvedValue(null);
    await expect(useCase.execute(7, DEBTOR)).rejects.toThrow(NotFoundException);
  });

  it('lists open bills plus those settled in the last 90 days', async () => {
    await useCase.executeForUser(DEBTOR);
    expect(repo.findViewsForUser).toHaveBeenCalledWith(
      DEBTOR,
      new Date('2026-08-07T06:00:00Z'),
    );
  });
});

describe('ObligationResponseDto', () => {
  it('tells the debtor they owe the creditor', () => {
    const dto = new ObligationResponseDto(dinner(), DEBTOR);
    expect(dto.direction).toBe('OWE');
    expect(dto.counterparty).toEqual({ userId: CREDITOR, name: 'Nathan' });
  });

  it('tells the creditor who owes them', () => {
    const dto = new ObligationResponseDto(dinner(), CREDITOR);
    expect(dto.direction).toBe('OWED');
    expect(dto.counterparty).toEqual({ userId: DEBTOR, name: 'Mary' });
    expect(dto.source.name).toBe('Dinner');
  });
});
