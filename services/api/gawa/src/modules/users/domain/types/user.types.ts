export enum UserStatus {
  ACTIVE = 'ACTIVE',
  INACTIVE = 'INACTIVE',
  SUSPENDED = 'SUSPENDED',
}

export interface UserProps {
  id?: number;
  firebaseUid?: string | null;
  fullName: string;
  phoneNumber: string;
  email?: string | null;
  status?: UserStatus;
  createdAt?: Date;
  updatedAt?: Date;
  deletedAt?: Date | null;
}
