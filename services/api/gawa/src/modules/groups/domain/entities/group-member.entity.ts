export interface GroupMemberProps {
  groupId: number;
  userId: number;
  role?: string | null;
  // Denormalized user info for display
  fullName?: string;
  phoneNumber?: string;
}

export class GroupMember {
  private props: GroupMemberProps;

  constructor(props: GroupMemberProps) {
    this.props = { ...props, role: props.role ?? 'member' };
  }

  get groupId(): number {
    return this.props.groupId;
  }

  get userId(): number {
    return this.props.userId;
  }

  get role(): string {
    return this.props.role!;
  }

  get fullName(): string | undefined {
    return this.props.fullName;
  }

  get phoneNumber(): string | undefined {
    return this.props.phoneNumber;
  }
}
