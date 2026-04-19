import {
  Controller,
  Get,
  Param,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { GetTransactionUseCase } from '../application/get-transaction.usecase';
import { TransactionResponseDto } from './dtos/transaction-response.dto';

@Controller('transactions')
export class TransactionController {
  constructor(
    private readonly getTransactionUseCase: GetTransactionUseCase,
  ) {}

  @Get()
  async getAllTransactions(): Promise<TransactionResponseDto[]> {
    try {
      const transactions = await this.getTransactionUseCase.executeAll();
      return transactions.map((t) => new TransactionResponseDto(t));
    } catch (error: any) {
      throw new HttpException(error.message, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  @Get(':id')
  async getTransaction(@Param('id') id: number): Promise<TransactionResponseDto> {
    try {
      const transaction = await this.getTransactionUseCase.execute(id);
      return new TransactionResponseDto(transaction);
    } catch (error: any) {
      throw new HttpException(error.message, HttpStatus.NOT_FOUND);
    }
  }
}
