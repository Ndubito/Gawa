import {
  Controller,
  Post,
  Get,
  Patch,
  Delete,
  Body,
  Param,
  ParseIntPipe,
} from '@nestjs/common';
import { CurrentUserId } from '../../auth/current-user.decorator';
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
  async createSubscription(
    @CurrentUserId() userId: number,
    @Body() dto: CreateSubscriptionDto,
  ): Promise<SubscriptionResponseDto> {
    const subscription = await this.createSubscriptionUseCase.execute(
      {
        groupId: dto.groupId,
        name: dto.name,
        description: dto.description,
        amountCents: dto.amountCents,
        schedule: dto.schedule,
        graceHours: dto.graceHours,
        startDate: new Date(dto.startDate),
      },
      userId,
    );
    return new SubscriptionResponseDto(subscription);
  }

  @Get('mine')
  async getMySubscriptions(
    @CurrentUserId() userId: number,
  ): Promise<SubscriptionResponseDto[]> {
    const subscriptions =
      await this.getSubscriptionUseCase.executeForUser(userId);
    return subscriptions.map((s) => new SubscriptionResponseDto(s));
  }

  @Get('group/:groupId')
  async getGroupSubscriptions(
    @CurrentUserId() userId: number,
    @Param('groupId', ParseIntPipe) groupId: number,
  ): Promise<SubscriptionResponseDto[]> {
    const subscriptions = await this.getSubscriptionUseCase.executeByGroupId(
      groupId,
      userId,
    );
    return subscriptions.map((s) => new SubscriptionResponseDto(s));
  }

  @Get(':id')
  async getSubscription(
    @CurrentUserId() userId: number,
    @Param('id', ParseIntPipe) id: number,
  ): Promise<SubscriptionResponseDto> {
    const subscription = await this.getSubscriptionUseCase.execute(id, userId);
    return new SubscriptionResponseDto(subscription);
  }

  @Patch(':id')
  async updateSubscription(
    @CurrentUserId() userId: number,
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateSubscriptionDto,
  ): Promise<SubscriptionResponseDto> {
    const subscription = await this.updateSubscriptionUseCase.execute(
      { id, ...dto },
      userId,
    );
    return new SubscriptionResponseDto(subscription);
  }

  @Delete(':id')
  async deleteSubscription(
    @CurrentUserId() userId: number,
    @Param('id', ParseIntPipe) id: number,
  ): Promise<{ success: boolean }> {
    await this.deleteSubscriptionUseCase.execute(id, userId);
    return { success: true };
  }
}
