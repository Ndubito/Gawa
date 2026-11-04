import { Matches } from 'class-validator';

export class AddMemberDto {
  constructor(phoneNumber: string) {
    this.phoneNumber = phoneNumber;
  }

  // E.164 format, e.g. +254708194459 — matches what Firebase stores
  @Matches(/^\+\d{10,15}$/, {
    message: 'phoneNumber must be in international format, e.g. +254712345678',
  })
  phoneNumber: string;
}
