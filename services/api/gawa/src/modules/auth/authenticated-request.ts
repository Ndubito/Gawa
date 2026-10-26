import type { Request } from 'express';
import type { auth } from 'firebase-admin';

export interface AuthenticatedRequest extends Request {
  user?: auth.DecodedIdToken;
  userId?: number;
}
