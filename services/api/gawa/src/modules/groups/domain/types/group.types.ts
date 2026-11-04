export interface GroupProps {
  id?: number;
  name: string;
  description?: string | null;
  ownerId: number;
  createdAt?: Date;
  updatedAt?: Date;
  deletedAt?: Date | null;
}

export enum GroupMemberStatus {
  INVITED = 'INVITED',
  ACTIVE = 'ACTIVE',
}

// A user's relationship to a group. The owner is implicit (Group.ownerId),
// never a GroupMember row.
export enum GroupRole {
  OWNER = 'OWNER',
  MEMBER = 'MEMBER',
  INVITED = 'INVITED',
}
