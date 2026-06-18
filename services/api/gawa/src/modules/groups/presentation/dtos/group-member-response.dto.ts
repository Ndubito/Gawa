import { GroupMember } from '../../domain/entities/group-member.entity';

export class GroupMemberResponseDto {
  userId: number;
  fullName: string | null;
  phoneNumber: string | null;
  role: string;

  constructor(member: GroupMember) {
    this.userId = member.userId;
    this.fullName = member.fullName ?? null;
    this.phoneNumber = member.phoneNumber ?? null;
    this.role = member.role;
  }
}
