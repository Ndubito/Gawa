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
import { CreateSubscriptionUseCase } from '../application/create-subscription.usecase';
import { GetSubscriptionUseCase } from '../application/get-subscription.usecase';
import { UpdateSubscriptionUseCase } from '../application/update-subscription.usecase';
import { DeleteSubscriptionUseCase } from '../application/delete-subscription.usecase';
import { CreateSubscriptionDto } from './dtos/create-subscription.dto';
import { UpdateSubscriptionDto } from './dtos/update-subscription.dto';
import { SubscriptionResponseDto } from './dtos/subscription-response.dto';

@Controller('subscriptions')
export class SubscriptionController {
  constructor(
    private readonly createSubscriptionUseCase: CreateSubscriptionUseCase,
    private readonly getSubscriptionUseCase: GetSubscriptionUseCase,
    private readonly updateSubscriptionUseCase: UpdateSubscriptionUseCase,
    private readonly deleteSubscriptionUseCase: DeleteSubscriptionUseCase,
  ) {}

  @Post()
  async createSubscription(@Body() dto: CreateSubscriptionDto): Promise<SubscriptionResponseDto> {
    try {
      const subscription = await this.createSubscriptionUseCase.execute(dto);
      return new SubscriptionResponseDto(subscription);
    } catch (error: any) {
      throw new HttpException(error.message, HttpStatus.BAD_REQUEST);
    }
  }

  @Get()
  async getAllSubscriptions(): Promise<SubscriptionResponseDto[]> {
    try {
      const subscriptions = await this.getSubscriptionUseCase.executeAll();
      return subscriptions.map((s) => new SubscriptionResponseDto(s));
    } catch (error: any) {
      throw new HttpException(error.message, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  @Get(':id')
  async getSubscription(@Param('id') id: number): Promise<SubscriptionResponseDto> {
    try {
      const subscription = await this.getSubscriptionUseCase.execute(id);
      return new SubscriptionResponseDto(subscription);
    } catch (error: any) {
      throw new HttpException(error.message, HttpStatus.NOT_FOUND);
    }
  }

  @Patch(':id')
  async updateSubscription(
    @Param('id') id: number,
    @Body() dto: UpdateSubscriptionDto,
  ): Promise<SubscriptionResponseDto> {
    try {
      const subscription = await this.updateSubscriptionUseCase.execute({ id, ...dto });
      return new SubscriptionResponseDto(subscription);
    } catch (error: any) {
      throw new HttpException(error.message, HttpStatus.BAD_REQUEST);
    }
  }

  @Delete(':id')
  async deleteSubscription(@Param('id') id: number): Promise<{ success: boolean }> {
    try {
      await this.deleteSubscriptionUseCase.execute(id);
      return { success: true };
    } catch (error: any) {
      throw new HttpException(error.message, HttpStatus.NOT_FOUND);
    }
  }
}
