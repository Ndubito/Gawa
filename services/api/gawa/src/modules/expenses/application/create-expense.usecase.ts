import { Injectable, Inject, BadRequestException } from '@nestjs/common';
import { CLOCK, type Clock } from '../../../common/clock';
import { Expense } from '../domain/entities/expense.entity';
import { splitEqually } from '../domain/expense-split';
import {
  type IExpenseRepository,
  EXPENSE_REPOSITORY_TOKEN,
} from '../domain/repos/expense.repository';
import { EXPENSE_GRACE_HOURS } from '../domain/types/expense.types';
import {
  type IGroupRepository,
  GROUP_REPOSITORY_TOKEN,
} from '../../groups/domain/repos/group.repository';
import {
  GroupAccessPolicy,
  GROUP_VIEWERS,
} from '../../groups/application/group-access.policy';
import {
  reminderLadder,
  reminderSlotDaysAfter,
} from '../../billing/domain/billing-calendar';

export interface CreateExpenseInput {
  groupId: number;
  name: string;
  description?: string;
  totalAmount: number;
  dueInDays: number;
  participantIds: number[];
}

const HOUR_MS = 3_600_000;

@Injectable()
export class CreateExpenseUseCase {
  constructor(
    @Inject(EXPENSE_REPOSITORY_TOKEN)
    private readonly expenseRepository: IExpenseRepository,
    @Inject(GROUP_REPOSITORY_TOKEN)
    private readonly groupRepository: IGroupRepository,
    private readonly access: GroupAccessPolicy,
    @Inject(CLOCK)
    private readonly clock: Clock,
  ) {}

  // The requester is always the payer: nobody can log a debt owed to someone else.
  async execute(
    input: CreateExpenseInput,
    requesterId: number,
  ): Promise<Expense> {
    const { group } = await this.access.require(
      input.groupId,
      requesterId,
      GROUP_VIEWERS,
    );

    const participants = [...new Set(input.participantIds)];
    const members = await this.groupRepository.findMembers(input.groupId);
    const eligible = new Set([
      group.ownerId,
      ...members.filter((m) => m.isActive).map((m) => m.userId),
    ]);
    if (participants.some((id) => !eligible.has(id))) {
      throw new BadRequestException(
        'Everyone in an expense must be an accepted member of the group',
      );
    }
    if (!participants.some((id) => id !== requesterId)) {
      throw new BadRequestException(
        'Split the expense with at least one other member',
      );
    }
    if (input.totalAmount < participants.length) {
      throw new BadRequestException('The amount is too small to split');
    }

    const now = this.clock();
    const dueAt = reminderSlotDaysAfter(now, input.dueInDays);
    const overdueAt = new Date(dueAt.getTime() + EXPENSE_GRACE_HOURS * HOUR_MS);
    const splits = splitEqually(input.totalAmount, participants, requesterId);

    const expense = new Expense({
      groupId: input.groupId,
      payerId: requesterId,
      totalAmount: input.totalAmount,
      name: input.name,
      description: input.description,
      dueAt,
      splits,
    });
    const debts = splits
      .filter((s) => s.userId !== requesterId)
      .map((s) => ({
        userId: s.userId,
        amountDue: s.amount,
        overdueAt,
        reminders: reminderLadder(dueAt, overdueAt, now),
      }));

    return this.expenseRepository.create(expense, debts);
  }
}
