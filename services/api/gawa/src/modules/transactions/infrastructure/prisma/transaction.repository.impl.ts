import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../../../prisma/prisma.service';
import { ITransactionRepository } from '../../domain/repos/transaction.repository';
import { Transaction } from '../../domain/entities/transaction.entity';
import { TransactionMapper } from './transaction.orm.entity';

@Injectable()
export class TransactionRepositoryImpl implements ITransactionRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findById(id: number): Promise<Transaction | null> {
    const raw = await this.prisma.transaction.findUnique({ where: { transaction_id: id } });
    return raw ? TransactionMapper.toDomain(raw) : null;
  }

  async findAll(): Promise<Transaction[]> {
    const raws = await this.prisma.transaction.findMany();
    return raws.map((raw) => TransactionMapper.toDomain(raw));
  }
}
