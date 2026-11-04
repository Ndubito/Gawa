import { Injectable, Inject, ConflictException } from '@nestjs/common';
import { GroupMember } from '../domain/entities/group-member.entity';
import { GroupMemberStatus } from '../domain/types/group.types';
import {
  type IGroupRepository,
  GROUP_REPOSITORY_TOKEN,
} from '../domain/repos/group.repository';
import {
  type IUserRepository,
  USER_REPOSITORY_TOKEN,
} from '../../users/domain/repos/user.repository';
import { User } from '../../users/domain/entities/user.entity';
import { GroupAccessPolicy, OWNER_ONLY } from './group-access.policy';

export interface AddGroupMemberInput {
  groupId: number;
  phoneNumber: string;
}

@Injectable()
export class AddGroupMemberUseCase {
  constructor(
    @Inject(GROUP_REPOSITORY_TOKEN)
    private readonly groupRepository: IGroupRepository,
    @Inject(USER_REPOSITORY_TOKEN)
    private readonly userRepository: IUserRepository,
    private readonly access: GroupAccessPolicy,
  ) {}

  // Creates a pending invite; the invitee must accept before seeing the group.
  async execute(
    input: AddGroupMemberInput,
    requesterId: number,
  ): Promise<GroupMember> {
    const { group } = await this.access.require(
      input.groupId,
      requesterId,
      OWNER_ONLY,
    );

    // Unknown phones get a placeholder user that the auth sync links
    // automatically when that person signs up.
    let invitee = await this.userRepository.findByPhoneNumber(
      input.phoneNumber,
    );
    invitee ??= await this.userRepository.save(
      new User({
        fullName: input.phoneNumber,
        phoneNumber: input.phoneNumber,
      }),
    );

    if (invitee.id === group.ownerId) {
      throw new ConflictException('The owner is already part of the group');
    }
    const existing = await this.groupRepository.findMembership(
      input.groupId,
      invitee.id!,
    );
    if (existing) {
      throw new ConflictException(
        existing.isActive
          ? 'This person is already a member'
          : 'This person has already been invited',
      );
    }

    await this.groupRepository.addMember(input.groupId, invitee.id!);

    return new GroupMember({
      groupId: input.groupId,
      userId: invitee.id!,
      status: GroupMemberStatus.INVITED,
      fullName: invitee.fullName,
      phoneNumber: invitee.phoneNumber,
    });
  }
}
