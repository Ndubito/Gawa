import { NotFoundException } from '@nestjs/common';
import { GetPaymentUseCase } from './get-payment.usecase';
import { IPaymentRepository } from '../domain/repos/payment.repository';
import { Payment } from '../domain/entities/payment.entity';
import { IObligationRepository } from '../../obligations/domain/repos/obligation.repository';
import { Obligation } from '../../obligations/domain/entities/obligation.entity';
import { ObligationSourceType } from '../../obligations/domain/types/obligation.types';

const DEBTOR = 2;
const CREDITOR = 1;
const STRANGER = 99;

describe('GetPaymentUseCase', () => {
  let paymentRepo: jest.Mocked<IPaymentRepository>;
  let obligationRepo: jest.Mocked<IObligationRepository>;
  let useCase: GetPaymentUseCase;

  beforeEach(() => {
    paymentRepo = {
      findById: jest.fn().mockResolvedValue(
        new Payment({
          id: 3,
          obligationId: 7,
          payerId: DEBTOR,
          amount: 50000,
        }),
      ),
      findForUser: jest.fn().mockResolvedValue([]),
      save: jest.fn(),
    };
    obligationRepo = {
      findById: jest.fn().mockResolvedValue(
        new Obligation({
          id: 7,
          userId: DEBTOR,
          recipientId: CREDITOR,
          sourceType: ObligationSourceType.SUBSCRIPTION_CYCLE,
          amountDue: 50000,
          dueAt: new Date('2026-11-01'),
        }),
      ),
      findForUser: jest.fn(),
      save: jest.fn(),
      update: jest.fn(),
    };
    useCase = new GetPaymentUseCase(paymentRepo, obligationRepo);
  });

  it.each([DEBTOR, CREDITOR])(
    'returns the payment to obligation party %i',
    async (userId) => {
      expect((await useCase.execute(3, userId)).id).toBe(3);
    },
  );

  it('404s anyone not party to the obligation', async () => {
    await expect(useCase.execute(3, STRANGER)).rejects.toThrow(
      NotFoundException,
    );
  });

  it('404s a missing payment', async () => {
    paymentRepo.findById.mockResolvedValue(null);
    await expect(useCase.execute(3, DEBTOR)).rejects.toThrow(NotFoundException);
  });

  it('404s a payment whose obligation is missing', async () => {
    obligationRepo.findById.mockResolvedValue(null);
    await expect(useCase.execute(3, DEBTOR)).rejects.toThrow(NotFoundException);
  });

  it('lists only payments the requester can see', async () => {
    await useCase.executeForUser(CREDITOR);
    expect(paymentRepo.findForUser).toHaveBeenCalledWith(CREDITOR);
  });
});
