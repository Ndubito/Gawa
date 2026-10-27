import { BadRequestException, NotFoundException } from '@nestjs/common';
import {
  CreateExpenseUseCase,
  CreateExpenseInput,
} from './create-expense.usecase';
import { GetExpenseUseCase } from './get-expense.usecase';
import { UpdateExpenseUseCase } from './update-expense.usecase';
import { DeleteExpenseUseCase } from './delete-expense.usecase';
import { IExpenseRepository } from '../domain/repos/expense.repository';
import { Expense } from '../domain/entities/expense.entity';
import { ExpenseDebt } from '../domain/types/expense.types';
import { GroupAccessPolicy } from '../../groups/application/group-access.policy';
import { InMemoryGroupRepository } from '../../groups/testing/in-memory-group.repository';
import { GroupMemberStatus } from '../../groups/domain/types/group.types';
import { ReminderKind } from '../../billing/domain/billing.types';

const OWNER = 1;
const MARY = 2;
const JOHN = 3;
const INVITEE = 4;
const STRANGER = 99;
const GROUP = 10;

const eat = (local: string) => new Date(`${local}+03:00`);
const NOW = eat('2026-11-05T20:00:00');

describe('Expense use cases', () => {
  let groupRepo: InMemoryGroupRepository;
  let access: GroupAccessPolicy;
  let expenseRepo: jest.Mocked<IExpenseRepository>;
  let savedDebts: ExpenseDebt[];

  const dinner = (
    overrides: Partial<CreateExpenseInput> = {},
  ): CreateExpenseInput => ({
    groupId: GROUP,
    name: 'Dinner',
    totalAmount: 400_000,
    dueInDays: 3,
    participantIds: [OWNER, MARY, JOHN],
    ...overrides,
  });

  const existing = (payerId = MARY) =>
    new Expense({
      id: 7,
      groupId: GROUP,
      payerId,
      totalAmount: 300_000,
      name: 'Dinner',
      dueAt: eat('2026-11-08T09:00:00'),
      splits: [],
    });

  beforeEach(() => {
    groupRepo = new InMemoryGroupRepository();
    groupRepo.seedGroup({ id: GROUP, ownerId: OWNER });
    groupRepo.seedMember(GROUP, MARY, GroupMemberStatus.ACTIVE);
    groupRepo.seedMember(GROUP, JOHN, GroupMemberStatus.ACTIVE);
    groupRepo.seedMember(GROUP, INVITEE, GroupMemberStatus.INVITED);
    access = new GroupAccessPolicy(groupRepo);
    savedDebts = [];
    expenseRepo = {
      findById: jest.fn().mockResolvedValue(existing()),
      findByGroupId: jest.fn().mockResolvedValue([existing()]),
      create: jest
        .fn()
        .mockImplementation(async (e: Expense, debts: ExpenseDebt[]) => {
          savedDebts = debts;
          return e;
        }),
      update: jest.fn().mockImplementation(async (e: Expense) => e),
      deleteAndCancelUnpaid: jest.fn(),
    };
  });

  describe('CreateExpenseUseCase', () => {
    const create = (input: CreateExpenseInput, requester: number) =>
      new CreateExpenseUseCase(
        expenseRepo,
        groupRepo,
        access,
        () => NOW,
      ).execute(input, requester);

    it('makes the requester the payer and bills everyone else their share', async () => {
      const expense = await create(dinner(), MARY);

      expect(expense.payerId).toBe(MARY);
      expect(savedDebts.map((d) => [d.userId, d.amountDue])).toEqual([
        [OWNER, 133_333],
        [JOHN, 133_333],
      ]);
      expect(expense.splits.find((s) => s.userId === MARY)!.amount).toBe(
        133_334,
      );
    });

    it('is due at 09:00 Nairobi after the chosen number of days, overdue a day later', async () => {
      const expense = await create(dinner({ dueInDays: 3 }), MARY);

      expect(expense.dueAt).toEqual(eat('2026-11-08T09:00:00'));
      expect(savedDebts[0].overdueAt).toEqual(eat('2026-11-09T09:00:00'));
    });

    it('tells people they owe straight away, then follows the reminder ladder', async () => {
      await create(dinner(), MARY);

      const ladder = savedDebts[0].reminders;
      expect(ladder[0]).toEqual({
        kind: ReminderKind.UPCOMING,
        sequence: 0,
        scheduledFor: NOW,
      });
      expect(ladder.map((r) => r.kind)).toEqual([
        ReminderKind.UPCOMING,
        ReminderKind.DUE,
        ReminderKind.OVERDUE,
        ReminderKind.NUDGE,
        ReminderKind.NUDGE,
        ReminderKind.NUDGE,
      ]);
    });

    it('lets the owner log expenses too', async () => {
      await create(dinner({ participantIds: [OWNER, MARY] }), OWNER);
      expect(savedDebts.map((d) => d.userId)).toEqual([MARY]);
    });

    it('lets the payer stay out of the split', async () => {
      await create(dinner({ participantIds: [OWNER, JOHN] }), MARY);
      expect(savedDebts.map((d) => [d.userId, d.amountDue])).toEqual([
        [OWNER, 200_000],
        [JOHN, 200_000],
      ]);
    });

    it.each([INVITEE, STRANGER])(
      'rejects user %i as a participant',
      async (userId) => {
        await expect(
          create(dinner({ participantIds: [MARY, userId] }), MARY),
        ).rejects.toThrow(BadRequestException);
        expect(expenseRepo.create).not.toHaveBeenCalled();
      },
    );

    it('rejects an expense with nobody else in it', async () => {
      await expect(
        create(dinner({ participantIds: [MARY, MARY] }), MARY),
      ).rejects.toThrow('at least one other member');
    });

    it('rejects an amount too small to split', async () => {
      await expect(create(dinner({ totalAmount: 2 }), MARY)).rejects.toThrow(
        'too small',
      );
    });

    it.each([INVITEE, STRANGER])(
      '404s user %i who is not in the group',
      async (userId) => {
        await expect(create(dinner(), userId)).rejects.toThrow(
          NotFoundException,
        );
      },
    );
  });

  describe('GetExpenseUseCase', () => {
    const get = () => new GetExpenseUseCase(expenseRepo, access);

    it.each([OWNER, MARY, JOHN])(
      'shows an expense to group member %i',
      async (userId) => {
        expect((await get().execute(7, userId)).id).toBe(7);
      },
    );

    it.each([INVITEE, STRANGER])('404s user %i', async (userId) => {
      await expect(get().execute(7, userId)).rejects.toThrow(NotFoundException);
      await expect(get().executeForGroup(GROUP, userId)).rejects.toThrow(
        NotFoundException,
      );
    });

    it('404s a deleted or missing expense', async () => {
      expenseRepo.findById.mockResolvedValue(null);
      await expect(get().execute(7, MARY)).rejects.toThrow(NotFoundException);
    });
  });

  describe('Update and delete', () => {
    const getUseCase = () => new GetExpenseUseCase(expenseRepo, access);

    it('lets the payer rename the expense', async () => {
      const updated = await new UpdateExpenseUseCase(
        expenseRepo,
        getUseCase(),
      ).execute({ id: 7, name: 'Birthday dinner' }, MARY);
      expect(updated.name).toBe('Birthday dinner');
      expect(updated.totalAmount).toBe(300_000);
    });

    it('lets the payer delete, cancelling unpaid shares', async () => {
      await new DeleteExpenseUseCase(expenseRepo, getUseCase()).execute(
        7,
        MARY,
      );
      expect(expenseRepo.deleteAndCancelUnpaid).toHaveBeenCalledWith(7);
    });

    it.each([OWNER, JOHN, STRANGER])(
      '404s user %i who did not pay',
      async (userId) => {
        await expect(
          new UpdateExpenseUseCase(expenseRepo, getUseCase()).execute(
            { id: 7, name: 'x' },
            userId,
          ),
        ).rejects.toThrow(NotFoundException);
        await expect(
          new DeleteExpenseUseCase(expenseRepo, getUseCase()).execute(
            7,
            userId,
          ),
        ).rejects.toThrow(NotFoundException);
        expect(expenseRepo.update).not.toHaveBeenCalled();
        expect(expenseRepo.deleteAndCancelUnpaid).not.toHaveBeenCalled();
      },
    );
  });
});
