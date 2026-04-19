import { Transaction } from '../entities/transaction.entity';

export interface ITransactionRepository {
  findById(id: number): Promise<Transaction | null>;
  findAll(): Promise<Transaction[]>;
}

export const TRANSACTION_REPOSITORY_TOKEN = Symbol('TRANSACTION_REPOSITORY_TOKEN');
