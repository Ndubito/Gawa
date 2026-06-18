import {
  Injectable,
  Inject,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import { GroupMember } from '../domain/entities/group-member.entity';
import { type IGroupRepository, GROUP_REPOSITORY_TOKEN } from '../domain/repos/group.repository';
import { type IUserRepository, USER_REPOSITORY_TOKEN } from '../../users/domain/repos/user.repository';
import { User } from '../../users/domain/entities/user.entity';

export interface AddGroupMemberInput {
  groupId: number;
  phoneNumber: string;
  role?: string;
}

@Injectable()
export class AddGroupMemberUseCase {
  constructor(
    @Inject(GROUP_REPOSITORY_TOKEN)
    private readonly groupRepository: IGroupRepository,
    @Inject(USER_REPOSITORY_TOKEN)
    private readonly userRepository: IUserRepository,
  ) {}

  async execute(
    input: AddGroupMemberInput,
    requesterId: number,
  ): Promise<GroupMember> {
    const group = await this.groupRepository.findById(input.groupId);
    if (!group || group.ownerId !== requesterId) {
      throw new NotFoundException(`Group with ID ${input.groupId} not found`);
    }

    // Find the invitee; unknown phones get a placeholder user that the
    // auth sync links automatically when that person signs up.
    let member = await this.userRepository.findByPhoneNumber(
      input.phoneNumber,
    );
    member ??= await this.userRepository.save(
      new User({
        fullName: input.phoneNumber,
        phoneNumber: input.phoneNumber,
      }),
    );

    if (member.id === group.ownerId) {
      throw new ConflictException('The owner is already part of the group');
    }
    if (await this.groupRepository.isMember(input.groupId, member.id!)) {
      throw new ConflictException('This person is already a member');
    }

    await this.groupRepository.addMember(input.groupId, member.id!, input.role);

    return new GroupMember({
      groupId: input.groupId,
      userId: member.id!,
      role: input.role ?? 'member',
      fullName: member.fullName,
      phoneNumber: member.phoneNumber,
    });
  }
}
