import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import type { AuthenticatedRequest } from './authenticated-request';

// Backend user id resolved from the verified Firebase token by FirebaseAuthGuard.
export const CurrentUserId = createParamDecorator(
  (_data: unknown, context: ExecutionContext): number =>
    context.switchToHttp().getRequest<AuthenticatedRequest>().userId!,
);
