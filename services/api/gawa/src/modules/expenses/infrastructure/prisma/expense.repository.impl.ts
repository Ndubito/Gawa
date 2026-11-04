import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../../../prisma/prisma.service';
import { IExpenseRepository } from '../../domain/repos/expense.repository';
import { Expense } from '../../domain/entities/expense.entity';
import { ExpenseDebt } from '../../domain/types/expense.types';
import { ExpenseMapper } from './expense.orm.entity';

const withSplits = { splits: { orderBy: { user_id: 'asc' as const } } };

@Injectable()
export class ExpenseRepositoryImpl implements IExpenseRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findById(id: number): Promise<Expense | null> {
    const raw = await this.prisma.expense.findFirst({
      where: { expense_id: id, deleted_at: null },
      include: withSplits,
    });
    return raw ? ExpenseMapper.toDomain(raw) : null;
  }

  async findByGroupId(groupId: number): Promise<Expense[]> {
    const raws = await this.prisma.expense.findMany({
      where: { group_id: groupId, deleted_at: null },
      include: withSplits,
      orderBy: { created_at: 'desc' },
    });
    return raws.map((raw) => ExpenseMapper.toDomain(raw));
  }

  async create(expense: Expense, debts: ExpenseDebt[]): Promise<Expense> {
    return this.prisma.$transaction(async (tx) => {
      const saved = await tx.expense.create({
        data: {
          group_id: expense.groupId,
          organizer_id: expense.payerId,
          payer_id: expense.payerId,
          total_amount: expense.totalAmount,
          name: expense.name,
          description: expense.description ?? null,
          due_at: expense.dueAt,
          splits: {
            create: expense.splits.map((s) => ({
              user_id: s.userId,
              share_value: s.amount,
              share_type: 'FIXED',
            })),
          },
        },
        include: withSplits,
      });

      for (const debt of debts) {
        await tx.obligation.create({
          data: {
            expense_id: saved.expense_id,
            user_id: debt.userId,
            recipient_id: expense.payerId,
            source_type: 'EXPENSE',
            amount_due: debt.amountDue,
            status: 'PENDING',
            due_at: expense.dueAt,
            overdue_at: debt.overdueAt,
            reminders: {
              create: debt.reminders.map((r) => ({
                kind: r.kind,
                sequence: r.sequence,
                scheduled_for: r.scheduledFor,
              })),
            },
          },
        });
      }
      return ExpenseMapper.toDomain(saved);
    });
  }

  async update(expense: Expense): Promise<Expense> {
    const updated = await this.prisma.expense.update({
      where: { expense_id: expense.id },
      data: {
        name: expense.name,
        description: expense.description ?? null,
        updated_at: expense.updatedAt,
      },
      include: withSplits,
    });
    return ExpenseMapper.toDomain(updated);
  }

  async deleteAndCancelUnpaid(id: number): Promise<void> {
    const now = new Date();
    await this.prisma.$transaction([
      this.prisma.expense.update({
        where: { expense_id: id },
        data: { deleted_at: now, updated_at: now },
      }),
      this.prisma.obligation.updateMany({
        where: {
          expense_id: id,
          status: { in: ['PENDING', 'PARTIAL', 'OVERDUE'] },
        },
        data: { status: 'CANCELLED', updated_at: now },
      }),
    ]);
  }
}
