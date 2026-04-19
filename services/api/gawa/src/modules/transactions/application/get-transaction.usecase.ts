import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { Transaction } from '../domain/entities/transaction.entity';
import { type ITransactionRepository, TRANSACTION_REPOSITORY_TOKEN } from '../domain/repos/transaction.repository';

@Injectable()
export class GetTransactionUseCase {
  constructor(
    @Inject(TRANSACTION_REPOSITORY_TOKEN)
    private readonly transactionRepository: ITransactionRepository,
  ) {}

  async execute(id: number): Promise<Transaction> {
    const transaction = await this.transactionRepository.findById(id);
    if (!transaction) throw new NotFoundException(`Transaction with ID ${id} not found`);
    return transaction;
  }

  async executeAll(): Promise<Transaction[]> {
    return this.transactionRepository.findAll();
  }
}
