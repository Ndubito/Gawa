import { UserProps, UserStatus } from '../types/user.types';

export class User {
  private props: UserProps;

  constructor(props: UserProps) {
    this.props = {
      ...props,
      status: props.status ?? UserStatus.ACTIVE,
      createdAt: props.createdAt ?? new Date(),
      updatedAt: props.updatedAt ?? new Date(),
      deletedAt: props.deletedAt ?? null,
    };
  }

  get id(): number | undefined {
    return this.props.id;
  }

  get fullName(): string {
    return this.props.fullName;
  }

  get phoneNumber(): string {
    return this.props.phoneNumber;
  }

  get email(): string | null | undefined {
    return this.props.email;
  }

  get status(): UserStatus {
    return this.props.status!;
  }

  get createdAt(): Date {
    return this.props.createdAt!;
  }

  get updatedAt(): Date {
    return this.props.updatedAt!;
  }

  get deletedAt(): Date | null | undefined {
    return this.props.deletedAt;
  }

  // Domain Logic
  public updateProfile(fullName?: string, email?: string, phoneNumber?: string): void {
    if (fullName) this.props.fullName = fullName;
    if (email) this.props.email = email;
    if (phoneNumber) this.props.phoneNumber = phoneNumber;
    this.props.updatedAt = new Date();
  }

  public delete(): void {
    this.props.deletedAt = new Date();
    this.props.status = UserStatus.INACTIVE;
    this.props.updatedAt = new Date();
  }

  public assignId(id: number): void {
    if (this.props.id) throw new Error('ID is already assigned');
    this.props.id = id;
  }
}
