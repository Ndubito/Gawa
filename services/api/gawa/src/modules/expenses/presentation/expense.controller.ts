import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseIntPipe,
  Patch,
  Post,
} from '@nestjs/common';
import { CurrentUserId } from '../../auth/current-user.decorator';
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
  async createExpense(
    @CurrentUserId() userId: number,
    @Body() dto: CreateExpenseDto,
  ): Promise<ExpenseResponseDto> {
    const expense = await this.createExpenseUseCase.execute(
      {
        groupId: dto.groupId,
        name: dto.name,
        description: dto.description,
        totalAmount: dto.totalAmountCents,
        dueInDays: dto.dueInDays,
        participantIds: dto.participantIds,
      },
      userId,
    );
    return new ExpenseResponseDto(expense);
  }

  @Get('group/:groupId')
  async getGroupExpenses(
    @CurrentUserId() userId: number,
    @Param('groupId', ParseIntPipe) groupId: number,
  ): Promise<ExpenseResponseDto[]> {
    const expenses = await this.getExpenseUseCase.executeForGroup(
      groupId,
      userId,
    );
    return expenses.map((e) => new ExpenseResponseDto(e));
  }

  @Get(':id')
  async getExpense(
    @CurrentUserId() userId: number,
    @Param('id', ParseIntPipe) id: number,
  ): Promise<ExpenseResponseDto> {
    const expense = await this.getExpenseUseCase.execute(id, userId);
    return new ExpenseResponseDto(expense);
  }

  @Patch(':id')
  async updateExpense(
    @CurrentUserId() userId: number,
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateExpenseDto,
  ): Promise<ExpenseResponseDto> {
    const expense = await this.updateExpenseUseCase.execute(
      { id, ...dto },
      userId,
    );
    return new ExpenseResponseDto(expense);
  }

  @Delete(':id')
  async deleteExpense(
    @CurrentUserId() userId: number,
    @Param('id', ParseIntPipe) id: number,
  ): Promise<{ success: boolean }> {
    await this.deleteExpenseUseCase.execute(id, userId);
    return { success: true };
  }
}
