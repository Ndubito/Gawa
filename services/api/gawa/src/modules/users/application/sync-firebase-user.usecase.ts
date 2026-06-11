import { Injectable, Inject } from '@nestjs/common';
import { User } from '../domain/entities/user.entity';
import { type IUserRepository, USER_REPOSITORY_TOKEN } from '../domain/repos/user.repository';

export interface FirebaseUserPayload {
  uid: string;
  phoneNumber?: string;
  fullName?: string;
  email?: string;
}

@Injectable()
export class SyncFirebaseUserUseCase {
  constructor(
    @Inject(USER_REPOSITORY_TOKEN)
    private readonly userRepository: IUserRepository,
  ) {}

  async execute(payload: FirebaseUserPayload): Promise<User> {
    const existing = await this.userRepository.findByFirebaseUid(payload.uid);
    if (existing) {
      // Token claims can grow over time (e.g. phone added later) — backfill gaps
      const newPhone =
        payload.phoneNumber && !existing.phoneNumber
          ? payload.phoneNumber
          : undefined;
      const newEmail =
        payload.email && !existing.email ? payload.email : undefined;
      if (newPhone || newEmail) {
        existing.updateProfile(undefined, newEmail, newPhone);
        return this.userRepository.update(existing);
      }
      return existing;
    }

    // A user row may pre-date Firebase sign-in (e.g. added by phone) — link it
    if (payload.phoneNumber) {
      const byPhone = await this.userRepository.findByPhoneNumber(
        payload.phoneNumber,
      );
      if (byPhone) {
        byPhone.linkFirebaseUid(payload.uid);
        return this.userRepository.update(byPhone);
      }
    }

    const user = new User({
      firebaseUid: payload.uid,
      fullName: payload.fullName ?? payload.phoneNumber ?? 'Gawa User',
      phoneNumber: payload.phoneNumber ?? '',
      email: payload.email,
    });
    return this.userRepository.save(user);
  }
}
