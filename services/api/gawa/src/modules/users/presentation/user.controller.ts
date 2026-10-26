import { Controller, Get, Patch, Body } from '@nestjs/common';
import { CurrentUserId } from '../../auth/current-user.decorator';
import { GetCurrentUserUseCase } from '../application/get-current-user.usecase';
import { UpdateUserUseCase } from '../application/update-user.usecase';
import { UpdateUserDto } from './dtos/update-user.dto';
import { UserResponseDto } from './dtos/user-response.dto';

// Users are created by the auth sync on sign-in and can only act on themselves.
@Controller('users')
export class UserController {
  constructor(
    private readonly getCurrentUserUseCase: GetCurrentUserUseCase,
    private readonly updateUserUseCase: UpdateUserUseCase,
  ) {}

  @Get('me')
  async getMe(@CurrentUserId() userId: number): Promise<UserResponseDto> {
    const user = await this.getCurrentUserUseCase.execute(userId);
    return new UserResponseDto(user);
  }

  @Patch('me')
  async updateMe(
    @CurrentUserId() userId: number,
    @Body() dto: UpdateUserDto,
  ): Promise<UserResponseDto> {
    const user = await this.updateUserUseCase.execute({
      id: userId,
      fullName: dto.fullName,
    });
    return new UserResponseDto(user);
  }
}
