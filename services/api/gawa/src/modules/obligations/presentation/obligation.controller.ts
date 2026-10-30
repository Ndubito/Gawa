import { Controller, Get, Param, ParseIntPipe } from '@nestjs/common';
import { CurrentUserId } from '../../auth/current-user.decorator';
import { GetObligationUseCase } from '../application/get-obligation.usecase';
import { ObligationResponseDto } from './dtos/obligation-response.dto';

// Read-only: obligations are created by the billing cycle engine, and paid
// through the payment flow — never written directly by clients.
@Controller('obligations')
export class ObligationController {
  constructor(private readonly getObligationUseCase: GetObligationUseCase) {}

  @Get()
  async getMyObligations(
    @CurrentUserId() userId: number,
  ): Promise<ObligationResponseDto[]> {
    const obligations = await this.getObligationUseCase.executeForUser(userId);
    return obligations.map((o) => new ObligationResponseDto(o, userId));
  }

  @Get(':id')
  async getObligation(
    @CurrentUserId() userId: number,
    @Param('id', ParseIntPipe) id: number,
  ): Promise<ObligationResponseDto> {
    const obligation = await this.getObligationUseCase.execute(id, userId);
    return new ObligationResponseDto(obligation, userId);
  }
}
