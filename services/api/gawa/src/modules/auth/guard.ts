import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import * as admin from 'firebase-admin';
import { SyncFirebaseUserUseCase } from '../users/application/sync-firebase-user.usecase';
import { IS_PUBLIC_KEY } from './public.decorator';
import type { AuthenticatedRequest } from './authenticated-request';

// Initialize Firebase Admin SDK if not already initialized
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
  });
}

@Injectable()
export class FirebaseAuthGuard implements CanActivate {
  constructor(
    private readonly reflector: Reflector,
    private readonly syncFirebaseUser: SyncFirebaseUserUseCase,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (isPublic) return true;

    const req = context.switchToHttp().getRequest<AuthenticatedRequest>();
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new UnauthorizedException('Missing bearer token');
    }

    let decoded: admin.auth.DecodedIdToken;
    try {
      decoded = await admin
        .auth()
        .verifyIdToken(authHeader.slice('Bearer '.length));
    } catch {
      throw new UnauthorizedException('Invalid or expired token');
    }

    const user = await this.syncFirebaseUser.execute({
      uid: decoded.uid,
      phoneNumber: decoded.phone_number,
      fullName: typeof decoded.name === 'string' ? decoded.name : undefined,
      email: decoded.email,
    });

    req.user = decoded;
    req.userId = user.id;
    return true;
  }
}
