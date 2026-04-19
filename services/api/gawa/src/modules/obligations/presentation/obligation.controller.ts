import {
  Controller,
  Post,
  Get,
  Patch,
  Body,
  Param,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { CreateObligationUseCase } from '../application/create-obligation.usecase';
import { GetObligationUseCase } from '../application/get-obligation.usecase';
import { UpdateObligationUseCase } from '../application/update-obligation.usecase';
import { CreateObligationDto } from './dtos/create-obligation.dto';
import { UpdateObligationDto } from './dtos/update-obligation.dto';
import { ObligationResponseDto } from './dtos/obligation-response.dto';

@Controller('obligations')
export class ObligationController {
  constructor(
    private readonly createObligationUseCase: CreateObligationUseCase,
    private readonly getObligationUseCase: GetObligationUseCase,
    private readonly updateObligationUseCase: UpdateObligationUseCase,
  ) {}

  @Post()
  async createObligation(@Body() dto: CreateObligationDto): Promise<ObligationResponseDto> {
    try {
      const obligation = await this.createObligationUseCase.execute(dto);
      return new ObligationResponseDto(obligation);
    } catch (error: any) {
      throw new HttpException(error.message, HttpStatus.BAD_REQUEST);
    }
  }

  @Get()
  async getAllObligations(): Promise<ObligationResponseDto[]> {
    try {
      const obligations = await this.getObligationUseCase.executeAll();
      return obligations.map((o) => new ObligationResponseDto(o));
    } catch (error: any) {
      throw new HttpException(error.message, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  @Get(':id')
  async getObligation(@Param('id') id: number): Promise<ObligationResponseDto> {
    try {
      const obligation = await this.getObligationUseCase.execute(id);
      return new ObligationResponseDto(obligation);
    } catch (error: any) {
      throw new HttpException(error.message, HttpStatus.NOT_FOUND);
    }
  }

  @Patch(':id')
  async updateObligation(
    @Param('id') id: number,
    @Body() dto: UpdateObligationDto,
  ): Promise<ObligationResponseDto> {
    try {
      const obligation = await this.updateObligationUseCase.execute({ id, ...dto });
      return new ObligationResponseDto(obligation);
    } catch (error: any) {
      throw new HttpException(error.message, HttpStatus.BAD_REQUEST);
    }
  }
}
