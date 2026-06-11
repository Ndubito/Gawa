import {
  Controller,
  Post,
  Get,
  Patch,
  Delete,
  Body,
  Param,
  Req,
  UseGuards,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { CreateGroupUseCase } from '../application/create-group.usecase';
import { GetGroupUseCase } from '../application/get-group.usecase';
import { UpdateGroupUseCase } from '../application/update-group.usecase';
import { DeleteGroupUseCase } from '../application/delete-group.usecase';
import { SyncFirebaseUserUseCase } from '../../users/application/sync-firebase-user.usecase';
import { FirebaseAuthGuard } from '../../auth/guard';
import { CreateGroupDto } from './dtos/create-group.dto';
import { UpdateGroupDto } from './dtos/update-group.dto';
import { GroupResponseDto } from './dtos/group-response.dto';

@Controller('groups')
@UseGuards(FirebaseAuthGuard)
export class GroupController {
  constructor(
    private readonly createGroupUseCase: CreateGroupUseCase,
    private readonly getGroupUseCase: GetGroupUseCase,
    private readonly updateGroupUseCase: UpdateGroupUseCase,
    private readonly deleteGroupUseCase: DeleteGroupUseCase,
    private readonly syncFirebaseUserUseCase: SyncFirebaseUserUseCase,
  ) {}

  // Resolve the Firebase token (set on req.user by the guard) to the backend user id
  private async requesterId(req: any): Promise<number> {
    const user = await this.syncFirebaseUserUseCase.execute({
      uid: req.user.uid,
      phoneNumber: req.user.phone_number,
      fullName: req.user.name,
      email: req.user.email,
    });
    return user.id!;
  }

  @Post()
  async createGroup(
    @Req() req: any,
    @Body() dto: CreateGroupDto,
  ): Promise<GroupResponseDto> {
    try {
      const ownerId = await this.requesterId(req);
      const group = await this.createGroupUseCase.execute(dto, ownerId);
      return new GroupResponseDto(group);
    } catch (error: any) {
      throw new HttpException(error.message, HttpStatus.BAD_REQUEST);
    }
  }

  @Get()
  async getMyGroups(@Req() req: any): Promise<GroupResponseDto[]> {
    try {
      const ownerId = await this.requesterId(req);
      const groups = await this.getGroupUseCase.executeByOwner(ownerId);
      return groups.map((g) => new GroupResponseDto(g));
    } catch (error: any) {
      throw new HttpException(error.message, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  @Get(':id')
  async getGroup(
    @Req() req: any,
    @Param('id') id: number,
  ): Promise<GroupResponseDto> {
    try {
      const requesterId = await this.requesterId(req);
      const group = await this.getGroupUseCase.execute(id, requesterId);
      return new GroupResponseDto(group);
    } catch (error: any) {
      throw new HttpException(error.message, HttpStatus.NOT_FOUND);
    }
  }

  @Patch(':id')
  async updateGroup(
    @Req() req: any,
    @Param('id') id: number,
    @Body() dto: UpdateGroupDto,
  ): Promise<GroupResponseDto> {
    try {
      const requesterId = await this.requesterId(req);
      const group = await this.updateGroupUseCase.execute(
        { id, ...dto },
        requesterId,
      );
      return new GroupResponseDto(group);
    } catch (error: any) {
      throw new HttpException(error.message, HttpStatus.BAD_REQUEST);
    }
  }

  @Delete(':id')
  async deleteGroup(
    @Req() req: any,
    @Param('id') id: number,
  ): Promise<{ success: boolean }> {
    try {
      const requesterId = await this.requesterId(req);
      await this.deleteGroupUseCase.execute(id, requesterId);
      return { success: true };
    } catch (error: any) {
      throw new HttpException(error.message, HttpStatus.NOT_FOUND);
    }
  }
}
