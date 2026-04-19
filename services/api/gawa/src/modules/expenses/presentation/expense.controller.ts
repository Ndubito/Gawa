import {
  Controller,
  Post,
  Get,
  Patch,
  Delete,
  Body,
  Param,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { CreateExpenseUseCase } from '../application/create-expense.usecase';
import { GetExpenseUseCase } from '../application/get-expense.usecase';
import { UpdateExpenseUseCase } from '../application/update-expense.usecase';
import { DeleteExpenseUseCase } from '../application/delete-expense.usecase';
import { CreateExpenseDto } from './dtos/create-expense.dto';
import { UpdateExpenseDto } from './dtos/update-expense.dto';
import { ExpenseResponseDto } from './dtos/expense-response.dto';

@Controller('expenses')
export class ExpenseController {
  constructor(
    private readonly createExpenseUseCase: CreateExpenseUseCase,
    private readonly getExpenseUseCase: GetExpenseUseCase,
    private readonly updateExpenseUseCase: UpdateExpenseUseCase,
    private readonly deleteExpenseUseCase: DeleteExpenseUseCase,
  ) {}

  @Post()
  async createExpense(@Body() dto: CreateExpenseDto): Promise<ExpenseResponseDto> {
    try {
      const expense = await this.createExpenseUseCase.execute(dto);
      return new ExpenseResponseDto(expense);
    } catch (error: any) {
      throw new HttpException(error.message, HttpStatus.BAD_REQUEST);
    }
  }

  @Get()
  async getAllExpenses(): Promise<ExpenseResponseDto[]> {
    try {
      const expenses = await this.getExpenseUseCase.executeAll();
      return expenses.map((e) => new ExpenseResponseDto(e));
    } catch (error: any) {
      throw new HttpException(error.message, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  @Get(':id')
  async getExpense(@Param('id') id: number): Promise<ExpenseResponseDto> {
    try {
      const expense = await this.getExpenseUseCase.execute(id);
      return new ExpenseResponseDto(expense);
    } catch (error: any) {
      throw new HttpException(error.message, HttpStatus.NOT_FOUND);
    }
  }

  @Patch(':id')
  async updateExpense(
    @Param('id') id: number,
    @Body() dto: UpdateExpenseDto,
  ): Promise<ExpenseResponseDto> {
    try {
      const expense = await this.updateExpenseUseCase.execute({ id, ...dto });
      return new ExpenseResponseDto(expense);
    } catch (error: any) {
      throw new HttpException(error.message, HttpStatus.BAD_REQUEST);
    }
  }

  @Delete(':id')
  async deleteExpense(@Param('id') id: number): Promise<{ success: boolean }> {
    try {
      await this.deleteExpenseUseCase.execute(id);
      return { success: true };
    } catch (error: any) {
      throw new HttpException(error.message, HttpStatus.NOT_FOUND);
    }
  }
}
