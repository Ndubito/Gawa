// What a pending invitee is allowed to see about a group before accepting.
export interface GroupInviteProps {
  groupId: number;
  groupName: string;
  groupDescription?: string | null;
  invitedByName: string;
}

export class GroupInvite {
  constructor(private readonly props: GroupInviteProps) {}

  get groupId(): number {
    return this.props.groupId;
  }

  get groupName(): string {
    return this.props.groupName;
  }

  get groupDescription(): string | null | undefined {
    return this.props.groupDescription;
  }

  get invitedByName(): string {
    return this.props.invitedByName;
  }
}
