import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { Expense } from '../domain/entities/expense.entity';
import {
  type IExpenseRepository,
  EXPENSE_REPOSITORY_TOKEN,
} from '../domain/repos/expense.repository';
import {
  GroupAccessPolicy,
  GROUP_VIEWERS,
} from '../../groups/application/group-access.policy';

// Expenses are visible to every accepted member of their group; who has paid
// stays private to the obligation's debtor and creditor.
@Injectable()
export class GetExpenseUseCase {
  constructor(
    @Inject(EXPENSE_REPOSITORY_TOKEN)
    private readonly expenseRepository: IExpenseRepository,
    private readonly access: GroupAccessPolicy,
  ) {}

  async execute(id: number, requesterId: number): Promise<Expense> {
    const expense = await this.expenseRepository.findById(id);
    if (!expense) throw new NotFoundException(`Expense ${id} not found`);

    await this.access.require(
      expense.groupId,
      requesterId,
      GROUP_VIEWERS,
      `Expense ${id} not found`,
    );
    return expense;
  }

  async executeForGroup(
    groupId: number,
    requesterId: number,
  ): Promise<Expense[]> {
    await this.access.require(groupId, requesterId, GROUP_VIEWERS);
    return this.expenseRepository.findByGroupId(groupId);
  }
}
