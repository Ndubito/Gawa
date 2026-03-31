import { CanActivate, ExecutionContext } from "@nestjs/common";
import { Injectable } from '@nestjs/common';
import * as admin from 'firebase-admin';

// Initialize Firebase Admin SDK if not already initialized
if (!admin.apps.length) {
    admin.initializeApp({
        credential: admin.credential.applicationDefault(),
    });
}


@Injectable()
export class FirebaseAuthGuard implements CanActivate{
    async canActivate(context: ExecutionContext) : Promise<boolean> {
        const req = context.switchToHttp().getRequest();
        const token = req.headers.authorization?.split(" ")[1];

        const decoded = await admin.auth().verifyIdToken(token);;
        req.user = decoded;

        return true;
    }
}
    