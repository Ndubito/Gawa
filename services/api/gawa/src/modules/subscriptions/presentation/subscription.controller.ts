import {
  Controller,
  Post,
  Get,
  Patch,
  Delete,
  Body,
  Param,
  ParseIntPipe,
  UseGuards,
  Req,
} from '@nestjs/common';
import { FirebaseAuthGuard } from '../../auth/guard';
import { SyncFirebaseUserUseCase } from '../../users/application/sync-firebase-user.usecase';
import { CreateSubscriptionUseCase } from '../application/create-subscription.usecase';
import { GetSubscriptionUseCase } from '../application/get-subscription.usecase';
import { UpdateSubscriptionUseCase } from '../application/update-subscription.usecase';
import { DeleteSubscriptionUseCase } from '../application/delete-subscription.usecase';
import { CreateSubscriptionDto } from './dtos/create-subscription.dto';
import { UpdateSubscriptionDto } from './dtos/update-subscription.dto';
import { SubscriptionResponseDto } from './dtos/subscription-response.dto';

@UseGuards(FirebaseAuthGuard)
@Controller('subscriptions')
export class SubscriptionController {
  constructor(
    private readonly syncUser: SyncFirebaseUserUseCase,
    private readonly createSubscriptionUseCase: CreateSubscriptionUseCase,
    private readonly getSubscriptionUseCase: GetSubscriptionUseCase,
    private readonly updateSubscriptionUseCase: UpdateSubscriptionUseCase,
    private readonly deleteSubscriptionUseCase: DeleteSubscriptionUseCase,
  ) {}

  private async requesterId(req: any): Promise<number> {
    const user = await this.syncUser.execute({
      uid: req.user.uid,
      phoneNumber: req.user.phone_number,
      email: req.user.email,
      fullName: req.user.name,
    });
    return user.id!;
  }

  @Post()
  async createSubscription(
    @Body() dto: CreateSubscriptionDto,
    @Req() req: any,
  ): Promise<SubscriptionResponseDto> {
    const requesterId = await this.requesterId(req);
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
      requesterId,
    );
    return new SubscriptionResponseDto(subscription);
  }

  @Get('mine')
  async getMySubscriptions(@Req() req: any): Promise<SubscriptionResponseDto[]> {
    const requesterId = await this.requesterId(req);
    const subscriptions = await this.getSubscriptionUseCase.executeForUser(requesterId);
    return subscriptions.map((s) => new SubscriptionResponseDto(s));
  }

  @Get('group/:groupId')
  async getGroupSubscriptions(
    @Param('groupId', ParseIntPipe) groupId: number,
    @Req() req: any,
  ): Promise<SubscriptionResponseDto[]> {
    const requesterId = await this.requesterId(req);
    const subscriptions = await this.getSubscriptionUseCase.executeByGroupId(groupId, requesterId);
    return subscriptions.map((s) => new SubscriptionResponseDto(s));
  }

  @Get(':id')
  async getSubscription(
    @Param('id', ParseIntPipe) id: number,
    @Req() req: any,
  ): Promise<SubscriptionResponseDto> {
    const requesterId = await this.requesterId(req);
    const subscription = await this.getSubscriptionUseCase.execute(id, requesterId);
    return new SubscriptionResponseDto(subscription);
  }

  @Patch(':id')
  async updateSubscription(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateSubscriptionDto,
    @Req() req: any,
  ): Promise<SubscriptionResponseDto> {
    const requesterId = await this.requesterId(req);
    const subscription = await this.updateSubscriptionUseCase.execute({ id, ...dto }, requesterId);
    return new SubscriptionResponseDto(subscription);
  }

  @Delete(':id')
  async deleteSubscription(
    @Param('id', ParseIntPipe) id: number,
    @Req() req: any,
  ): Promise<{ success: boolean }> {
    const requesterId = await this.requesterId(req);
    await this.deleteSubscriptionUseCase.execute(id, requesterId);
    return { success: true };
  }
}
