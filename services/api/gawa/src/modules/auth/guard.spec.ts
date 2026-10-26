import { ExecutionContext, UnauthorizedException } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { FirebaseAuthGuard } from './guard';
import { SyncFirebaseUserUseCase } from '../users/application/sync-firebase-user.usecase';
import { User } from '../users/domain/entities/user.entity';

const mockVerifyIdToken = jest.fn();
jest.mock('firebase-admin', () => ({
  apps: [{}],
  auth: () => ({ verifyIdToken: mockVerifyIdToken }),
}));

describe('FirebaseAuthGuard', () => {
  let reflector: jest.Mocked<Reflector>;
  let sync: jest.Mocked<SyncFirebaseUserUseCase>;
  let guard: FirebaseAuthGuard;

  const contextFor = (req: any) =>
    ({
      getHandler: () => undefined,
      getClass: () => undefined,
      switchToHttp: () => ({ getRequest: () => req }),
    }) as unknown as ExecutionContext;

  beforeEach(() => {
    mockVerifyIdToken.mockReset();
    reflector = { getAllAndOverride: jest.fn().mockReturnValue(false) } as any;
    sync = {
      execute: jest
        .fn()
        .mockResolvedValue(
          new User({ id: 42, fullName: 'Mary', phoneNumber: '+254700000002' }),
        ),
    } as any;
    guard = new FirebaseAuthGuard(reflector, sync);
  });

  it('lets public routes through without a token', async () => {
    reflector.getAllAndOverride.mockReturnValue(true);
    await expect(guard.canActivate(contextFor({ headers: {} }))).resolves.toBe(
      true,
    );
    expect(mockVerifyIdToken).not.toHaveBeenCalled();
  });

  it('rejects requests without a bearer token', async () => {
    await expect(
      guard.canActivate(contextFor({ headers: {} })),
    ).rejects.toThrow(UnauthorizedException);
  });

  it('rejects invalid tokens without resolving a user', async () => {
    mockVerifyIdToken.mockRejectedValue(new Error('expired'));
    await expect(
      guard.canActivate(
        contextFor({ headers: { authorization: 'Bearer bad' } }),
      ),
    ).rejects.toThrow(UnauthorizedException);
    expect(sync.execute).not.toHaveBeenCalled();
  });

  it('resolves the backend user id from a verified token', async () => {
    mockVerifyIdToken.mockResolvedValue({
      uid: 'fb-1',
      phone_number: '+254700000002',
    });
    const req: any = { headers: { authorization: 'Bearer good' } };

    await expect(guard.canActivate(contextFor(req))).resolves.toBe(true);

    expect(mockVerifyIdToken).toHaveBeenCalledWith('good');
    expect(sync.execute).toHaveBeenCalledWith(
      expect.objectContaining({ uid: 'fb-1', phoneNumber: '+254700000002' }),
    );
    expect(req.userId).toBe(42);
  });
});
