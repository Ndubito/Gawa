import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../../../prisma/prisma.service';
import { IExpenseRepository } from '../../domain/repos/expense.repository';
import { Expense } from '../../domain/entities/expense.entity';
import { ExpenseMapper } from './expense.orm.entity';

@Injectable()
export class ExpenseRepositoryImpl implements IExpenseRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findById(id: number): Promise<Expense | null> {
    const raw = await this.prisma.expense.findUnique({ where: { expense_id: id } });
    return raw ? ExpenseMapper.toDomain(raw) : null;
  }

  async findAll(): Promise<Expense[]> {
    const raws = await this.prisma.expense.findMany();
    return raws.map((raw) => ExpenseMapper.toDomain(raw));
  }

  async save(expense: Expense): Promise<Expense> {
    const data = ExpenseMapper.toOrm(expense);
    delete data.expense_id;

    const saved = await this.prisma.expense.create({ data: data as any });
    expense.assignId(saved.expense_id);
    return ExpenseMapper.toDomain(saved);
  }

  async update(expense: Expense): Promise<Expense> {
    const data = ExpenseMapper.toOrm(expense);
    delete data.expense_id;

    const updated = await this.prisma.expense.update({
      where: { expense_id: expense.id },
      data: data as any,
    });
    return ExpenseMapper.toDomain(updated);
  }

  async delete(id: number): Promise<void> {
    await this.prisma.expense.update({
      where: { expense_id: id },
      data: {
        deleted_at: new Date(),
        updated_at: new Date(),
      },
    });
  }
}
