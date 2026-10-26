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
import { CreateGroupUseCase } from '../application/create-group.usecase';
import { GetGroupUseCase } from '../application/get-group.usecase';
import { UpdateGroupUseCase } from '../application/update-group.usecase';
import { DeleteGroupUseCase } from '../application/delete-group.usecase';
import { AddGroupMemberUseCase } from '../application/add-group-member.usecase';
import { RemoveGroupMemberUseCase } from '../application/remove-group-member.usecase';
import { ListGroupMembersUseCase } from '../application/list-group-members.usecase';
import { GroupInvitesUseCase } from '../application/group-invites.usecase';
import { CurrentUserId } from '../../auth/current-user.decorator';
import { CreateGroupDto } from './dtos/create-group.dto';
import { UpdateGroupDto } from './dtos/update-group.dto';
import { AddMemberDto } from './dtos/add-member.dto';
import { GroupResponseDto } from './dtos/group-response.dto';
import { GroupMemberResponseDto } from './dtos/group-member-response.dto';
import { GroupInviteResponseDto } from './dtos/group-invite-response.dto';

@Controller('groups')
export class GroupController {
  constructor(
    private readonly createGroupUseCase: CreateGroupUseCase,
    private readonly getGroupUseCase: GetGroupUseCase,
    private readonly updateGroupUseCase: UpdateGroupUseCase,
    private readonly deleteGroupUseCase: DeleteGroupUseCase,
    private readonly addGroupMemberUseCase: AddGroupMemberUseCase,
    private readonly removeGroupMemberUseCase: RemoveGroupMemberUseCase,
    private readonly listGroupMembersUseCase: ListGroupMembersUseCase,
    private readonly groupInvitesUseCase: GroupInvitesUseCase,
  ) {}

  @Post()
  async createGroup(
    @CurrentUserId() userId: number,
    @Body() dto: CreateGroupDto,
  ): Promise<GroupResponseDto> {
    const group = await this.createGroupUseCase.execute(dto, userId);
    return new GroupResponseDto(group);
  }

  @Get()
  async getMyGroups(
    @CurrentUserId() userId: number,
  ): Promise<GroupResponseDto[]> {
    const groups = await this.getGroupUseCase.executeForUser(userId);
    return groups.map((g) => new GroupResponseDto(g));
  }

  // Declared before ':id' so 'invites' is not parsed as a group id
  @Get('invites')
  async getMyInvites(
    @CurrentUserId() userId: number,
  ): Promise<GroupInviteResponseDto[]> {
    const invites = await this.groupInvitesUseCase.listForUser(userId);
    return invites.map((i) => new GroupInviteResponseDto(i));
  }

  @Get(':id')
  async getGroup(
    @CurrentUserId() userId: number,
    @Param('id', ParseIntPipe) id: number,
  ): Promise<GroupResponseDto> {
    const group = await this.getGroupUseCase.execute(id, userId);
    return new GroupResponseDto(group);
  }

  @Patch(':id')
  async updateGroup(
    @CurrentUserId() userId: number,
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateGroupDto,
  ): Promise<GroupResponseDto> {
    const group = await this.updateGroupUseCase.execute({ id, ...dto }, userId);
    return new GroupResponseDto(group);
  }

  @Delete(':id')
  async deleteGroup(
    @CurrentUserId() userId: number,
    @Param('id', ParseIntPipe) id: number,
  ): Promise<{ success: boolean }> {
    await this.deleteGroupUseCase.execute(id, userId);
    return { success: true };
  }

  @Post(':id/members')
  async addMember(
    @CurrentUserId() userId: number,
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: AddMemberDto,
  ): Promise<GroupMemberResponseDto> {
    const member = await this.addGroupMemberUseCase.execute(
      { groupId: id, phoneNumber: dto.phoneNumber },
      userId,
    );
    return new GroupMemberResponseDto(member);
  }

  @Get(':id/members')
  async listMembers(
    @CurrentUserId() userId: number,
    @Param('id', ParseIntPipe) id: number,
  ): Promise<GroupMemberResponseDto[]> {
    const members = await this.listGroupMembersUseCase.execute(id, userId);
    return members.map((m) => new GroupMemberResponseDto(m));
  }

  @Delete(':id/members/:userId')
  async removeMember(
    @CurrentUserId() requesterId: number,
    @Param('id', ParseIntPipe) id: number,
    @Param('userId', ParseIntPipe) memberUserId: number,
  ): Promise<{ success: boolean }> {
    await this.removeGroupMemberUseCase.execute(id, memberUserId, requesterId);
    return { success: true };
  }

  @Post(':id/invite/accept')
  async acceptInvite(
    @CurrentUserId() userId: number,
    @Param('id', ParseIntPipe) id: number,
  ): Promise<{ success: boolean }> {
    await this.groupInvitesUseCase.accept(id, userId);
    return { success: true };
  }

  @Post(':id/invite/decline')
  async declineInvite(
    @CurrentUserId() userId: number,
    @Param('id', ParseIntPipe) id: number,
  ): Promise<{ success: boolean }> {
    await this.groupInvitesUseCase.decline(id, userId);
    return { success: true };
  }
}
