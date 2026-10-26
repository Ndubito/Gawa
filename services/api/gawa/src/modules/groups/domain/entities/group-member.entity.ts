import { GroupMemberStatus } from '../types/group.types';

export interface GroupMemberProps {
  groupId: number;
  userId: number;
  role?: string | null;
  status?: GroupMemberStatus;
  // Denormalized user info for display
  fullName?: string;
  phoneNumber?: string;
}

export class GroupMember {
  private props: GroupMemberProps;

  constructor(props: GroupMemberProps) {
    this.props = {
      ...props,
      role: props.role ?? 'member',
      status: props.status ?? GroupMemberStatus.INVITED,
    };
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

  get status(): GroupMemberStatus {
    return this.props.status!;
  }

  get isActive(): boolean {
    return this.props.status === GroupMemberStatus.ACTIVE;
  }

  get fullName(): string | undefined {
    return this.props.fullName;
  }

  get phoneNumber(): string | undefined {
    return this.props.phoneNumber;
  }
}
