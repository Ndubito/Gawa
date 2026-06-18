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
import { AddGroupMemberUseCase } from '../application/add-group-member.usecase';
import { RemoveGroupMemberUseCase } from '../application/remove-group-member.usecase';
import { ListGroupMembersUseCase } from '../application/list-group-members.usecase';
import { SyncFirebaseUserUseCase } from '../../users/application/sync-firebase-user.usecase';
import { FirebaseAuthGuard } from '../../auth/guard';
import { CreateGroupDto } from './dtos/create-group.dto';
import { UpdateGroupDto } from './dtos/update-group.dto';
import { AddMemberDto } from './dtos/add-member.dto';
import { GroupResponseDto } from './dtos/group-response.dto';
import { GroupMemberResponseDto } from './dtos/group-member-response.dto';

@Controller('groups')
@UseGuards(FirebaseAuthGuard)
export class GroupController {
  constructor(
    private readonly createGroupUseCase: CreateGroupUseCase,
    private readonly getGroupUseCase: GetGroupUseCase,
    private readonly updateGroupUseCase: UpdateGroupUseCase,
    private readonly deleteGroupUseCase: DeleteGroupUseCase,
    private readonly addGroupMemberUseCase: AddGroupMemberUseCase,
    private readonly removeGroupMemberUseCase: RemoveGroupMemberUseCase,
    private readonly listGroupMembersUseCase: ListGroupMembersUseCase,
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
      const userId = await this.requesterId(req);
      const groups = await this.getGroupUseCase.executeForUser(userId);
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

  @Post(':id/members')
  async addMember(
    @Req() req: any,
    @Param('id') id: number,
    @Body() dto: AddMemberDto,
  ): Promise<GroupMemberResponseDto> {
    try {
      const requesterId = await this.requesterId(req);
      const member = await this.addGroupMemberUseCase.execute(
        { groupId: id, phoneNumber: dto.phoneNumber, role: dto.role },
        requesterId,
      );
      return new GroupMemberResponseDto(member);
    } catch (error: any) {
      if (error instanceof HttpException) throw error;
      throw new HttpException(error.message, HttpStatus.BAD_REQUEST);
    }
  }

  @Get(':id/members')
  async listMembers(
    @Req() req: any,
    @Param('id') id: number,
  ): Promise<GroupMemberResponseDto[]> {
    try {
      const requesterId = await this.requesterId(req);
      const members = await this.listGroupMembersUseCase.execute(
        id,
        requesterId,
      );
      return members.map((m) => new GroupMemberResponseDto(m));
    } catch (error: any) {
      if (error instanceof HttpException) throw error;
      throw new HttpException(error.message, HttpStatus.NOT_FOUND);
    }
  }

  @Delete(':id/members/:userId')
  async removeMember(
    @Req() req: any,
    @Param('id') id: number,
    @Param('userId') userId: number,
  ): Promise<{ success: boolean }> {
    try {
      const requesterId = await this.requesterId(req);
      await this.removeGroupMemberUseCase.execute(id, userId, requesterId);
      return { success: true };
    } catch (error: any) {
      if (error instanceof HttpException) throw error;
      throw new HttpException(error.message, HttpStatus.NOT_FOUND);
    }
  }
}
