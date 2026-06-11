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
import { CreateUserUseCase } from '../application/create-user.usecase';
import { GetUserUseCase } from '../application/get-user.usecase';
import { UpdateUserUseCase } from '../application/update-user.usecase';
import { DeleteUserUseCase } from '../application/delete-user.usecase';
import { SyncFirebaseUserUseCase } from '../application/sync-firebase-user.usecase';
import { FirebaseAuthGuard } from '../../auth/guard';
import { CreateUserDto } from './dtos/create-user.dto';
import { UpdateUserDto } from './dtos/update-user.dto';
import { UserResponseDto } from './dtos/user-response.dto';

@Controller('users')
export class UserController {
  constructor(
    private readonly createUserUseCase: CreateUserUseCase,
    private readonly getUserUseCase: GetUserUseCase,
    private readonly updateUserUseCase: UpdateUserUseCase,
    private readonly deleteUserUseCase: DeleteUserUseCase,
    private readonly syncFirebaseUserUseCase: SyncFirebaseUserUseCase,
  ) {}

  // Must be declared before @Get(':id') so 'me' is not captured as an id
  @Get('me')
  @UseGuards(FirebaseAuthGuard)
  async getMe(@Req() req: any): Promise<UserResponseDto> {
    try {
      const user = await this.syncFirebaseUserUseCase.execute({
        uid: req.user.uid,
        phoneNumber: req.user.phone_number,
        fullName: req.user.name,
        email: req.user.email,
      });
      return new UserResponseDto(user);
    } catch (error: any) {
      throw new HttpException(error.message, HttpStatus.BAD_REQUEST);
    }
  }

  @Post()
  async createUser(@Body() dto: CreateUserDto): Promise<UserResponseDto> {
    try {
      const user = await this.createUserUseCase.execute(dto);
      return new UserResponseDto(user);
    } catch (error: any) {
      throw new HttpException(error.message, HttpStatus.BAD_REQUEST);
    }
  }

  @Get(':id')
  async getUser(@Param('id') id: number): Promise<UserResponseDto> {
    try {
      const user = await this.getUserUseCase.execute(id);
      return new UserResponseDto(user);
    } catch (error: any) {
      throw new HttpException(error.message, HttpStatus.NOT_FOUND);
    }
  }

  @Patch(':id')
  async updateUser(
    @Param('id') id: number,
    @Body() dto: UpdateUserDto,
  ): Promise<UserResponseDto> {
    try {
      const user = await this.updateUserUseCase.execute({ id, ...dto });
      return new UserResponseDto(user);
    } catch (error: any) {
      throw new HttpException(error.message, HttpStatus.BAD_REQUEST);
    }
  }

  @Delete(':id')
  async deleteUser(@Param('id') id: number): Promise<{ success: boolean }> {
    try {
      await this.deleteUserUseCase.execute(id);
      return { success: true };
    } catch (error: any) {
      throw new HttpException(error.message, HttpStatus.NOT_FOUND);
    }
  }
}
