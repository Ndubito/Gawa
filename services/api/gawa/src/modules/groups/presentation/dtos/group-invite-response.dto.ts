import { GroupInvite } from '../../domain/entities/group-invite.entity';

export class GroupInviteResponseDto {
  groupId: number;
  groupName: string;
  groupDescription: string | null;
  invitedByName: string;

  constructor(invite: GroupInvite) {
    this.groupId = invite.groupId;
    this.groupName = invite.groupName;
    this.groupDescription = invite.groupDescription ?? null;
    this.invitedByName = invite.invitedByName;
  }
}
