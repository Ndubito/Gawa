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
import { CreateGroupUseCase } from '../application/create-group.usecase';
import { GetGroupUseCase } from '../application/get-group.usecase';
import { UpdateGroupUseCase } from '../application/update-group.usecase';
import { DeleteGroupUseCase } from '../application/delete-group.usecase';
import { CreateGroupDto } from './dtos/create-group.dto';
import { UpdateGroupDto } from './dtos/update-group.dto';
import { GroupResponseDto } from './dtos/group-response.dto';

@Controller('groups')
export class GroupController {
  constructor(
    private readonly createGroupUseCase: CreateGroupUseCase,
    private readonly getGroupUseCase: GetGroupUseCase,
    private readonly updateGroupUseCase: UpdateGroupUseCase,
    private readonly deleteGroupUseCase: DeleteGroupUseCase,
  ) {}

  @Post()
  async createGroup(@Body() dto: CreateGroupDto): Promise<GroupResponseDto> {
    try {
      const group = await this.createGroupUseCase.execute(dto);
      return new GroupResponseDto(group);
    } catch (error: any) {
      throw new HttpException(error.message, HttpStatus.BAD_REQUEST);
    }
  }

  @Get()
  async getAllGroups(): Promise<GroupResponseDto[]> {
    try {
      const groups = await this.getGroupUseCase.executeAll();
      return groups.map((g) => new GroupResponseDto(g));
    } catch (error: any) {
      throw new HttpException(error.message, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  @Get(':id')
  async getGroup(@Param('id') id: number): Promise<GroupResponseDto> {
    try {
      const group = await this.getGroupUseCase.execute(id);
      return new GroupResponseDto(group);
    } catch (error: any) {
      throw new HttpException(error.message, HttpStatus.NOT_FOUND);
    }
  }

  @Patch(':id')
  async updateGroup(
    @Param('id') id: number,
    @Body() dto: UpdateGroupDto,
  ): Promise<GroupResponseDto> {
    try {
      const group = await this.updateGroupUseCase.execute({ id, ...dto });
      return new GroupResponseDto(group);
    } catch (error: any) {
      throw new HttpException(error.message, HttpStatus.BAD_REQUEST);
    }
  }

  @Delete(':id')
  async deleteGroup(@Param('id') id: number): Promise<{ success: boolean }> {
    try {
      await this.deleteGroupUseCase.execute(id);
      return { success: true };
    } catch (error: any) {
      throw new HttpException(error.message, HttpStatus.NOT_FOUND);
    }
  }
}
