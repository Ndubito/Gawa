import { NotFoundException, ConflictException } from '@nestjs/common';
import { AddGroupMemberUseCase } from './add-group-member.usecase';
import { RemoveGroupMemberUseCase } from './remove-group-member.usecase';
import { ListGroupMembersUseCase } from './list-group-members.usecase';
import { GetGroupUseCase } from './get-group.usecase';
import { IGroupRepository } from '../domain/repos/group.repository';
import { IUserRepository } from '../../users/domain/repos/user.repository';
import { Group } from '../domain/entities/group.entity';
import { GroupMember } from '../domain/entities/group-member.entity';
import { User } from '../../users/domain/entities/user.entity';

describe('Group member use cases', () => {
  let groupRepo: jest.Mocked<IGroupRepository>;
  let userRepo: jest.Mocked<IUserRepository>;

  const group = () => new Group({ id: 10, name: 'Family Netflix', ownerId: 1 });
  const memberUser = () =>
    new User({ id: 2, fullName: 'Mary', phoneNumber: '+254700000002' });

  beforeEach(() => {
    groupRepo = {
      findById: jest.fn(),
      findByOwnerId: jest.fn(),
      findByUser: jest.fn(),
      findAll: jest.fn(),
      save: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
      addMember: jest.fn(),
      removeMember: jest.fn(),
      findMembers: jest.fn(),
      isMember: jest.fn(),
    };
    userRepo = {
      findById: jest.fn(),
      findByEmail: jest.fn(),
      findByPhoneNumber: jest.fn(),
      findByFirebaseUid: jest.fn(),
      findAll: jest.fn(),
      save: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
    };
  });

  describe('AddGroupMemberUseCase', () => {
    it('adds an existing user found by phone number', async () => {
      const useCase = new AddGroupMemberUseCase(groupRepo, userRepo);
      groupRepo.findById.mockResolvedValue(group());
      userRepo.findByPhoneNumber.mockResolvedValue(memberUser());
      groupRepo.isMember.mockResolvedValue(false);

      const member = await useCase.execute(
        { groupId: 10, phoneNumber: '+254700000002' },
        1,
      );

      expect(groupRepo.addMember).toHaveBeenCalledWith(10, 2, undefined);
      expect(member.fullName).toBe('Mary');
      expect(member.role).toBe('member');
      expect(userRepo.save).not.toHaveBeenCalled();
    });

    it('creates a placeholder user for an unknown phone number', async () => {
      const useCase = new AddGroupMemberUseCase(groupRepo, userRepo);
      groupRepo.findById.mockResolvedValue(group());
      userRepo.findByPhoneNumber.mockResolvedValue(null);
      groupRepo.isMember.mockResolvedValue(false);
      userRepo.save.mockImplementation(async (u) => {
        u.assignId(7);
        return u;
      });

      const member = await useCase.execute(
        { groupId: 10, phoneNumber: '+254799999999' },
        1,
      );

      expect(userRepo.save).toHaveBeenCalled();
      expect(member.userId).toBe(7);
      // Placeholder rows have no firebase_uid, so the existing auth sync
      // links them by phone number on their first sign-in.
      expect(member.phoneNumber).toBe('+254799999999');
    });

    it('rejects non-owners with NotFound', async () => {
      const useCase = new AddGroupMemberUseCase(groupRepo, userRepo);
      groupRepo.findById.mockResolvedValue(group());

      await expect(
        useCase.execute({ groupId: 10, phoneNumber: '+254700000002' }, 99),
      ).rejects.toThrow(NotFoundException);
    });

    it('rejects adding the owner as a member', async () => {
      const useCase = new AddGroupMemberUseCase(groupRepo, userRepo);
      groupRepo.findById.mockResolvedValue(group());
      userRepo.findByPhoneNumber.mockResolvedValue(
        new User({ id: 1, fullName: 'Owner', phoneNumber: '+254700000001' }),
      );

      await expect(
        useCase.execute({ groupId: 10, phoneNumber: '+254700000001' }, 1),
      ).rejects.toThrow(ConflictException);
    });

    it('rejects duplicate members', async () => {
      const useCase = new AddGroupMemberUseCase(groupRepo, userRepo);
      groupRepo.findById.mockResolvedValue(group());
      userRepo.findByPhoneNumber.mockResolvedValue(memberUser());
      groupRepo.isMember.mockResolvedValue(true);

      await expect(
        useCase.execute({ groupId: 10, phoneNumber: '+254700000002' }, 1),
      ).rejects.toThrow(ConflictException);
      expect(groupRepo.addMember).not.toHaveBeenCalled();
    });
  });

  describe('RemoveGroupMemberUseCase', () => {
    it('removes a member when requested by the owner', async () => {
      const useCase = new RemoveGroupMemberUseCase(groupRepo);
      groupRepo.findById.mockResolvedValue(group());
      groupRepo.isMember.mockResolvedValue(true);

      await useCase.execute(10, 2, 1);
      expect(groupRepo.removeMember).toHaveBeenCalledWith(10, 2);
    });

    it('rejects non-owners', async () => {
      const useCase = new RemoveGroupMemberUseCase(groupRepo);
      groupRepo.findById.mockResolvedValue(group());

      await expect(useCase.execute(10, 2, 99)).rejects.toThrow(
        NotFoundException,
      );
      expect(groupRepo.removeMember).not.toHaveBeenCalled();
    });

    it('404s when the person is not a member', async () => {
      const useCase = new RemoveGroupMemberUseCase(groupRepo);
      groupRepo.findById.mockResolvedValue(group());
      groupRepo.isMember.mockResolvedValue(false);

      await expect(useCase.execute(10, 5, 1)).rejects.toThrow(
        NotFoundException,
      );
    });
  });

  describe('ListGroupMembersUseCase', () => {
    it('returns the owner first, then members, for the owner', async () => {
      const useCase = new ListGroupMembersUseCase(groupRepo, userRepo);
      groupRepo.findById.mockResolvedValue(group());
      userRepo.findById.mockResolvedValue(
        new User({ id: 1, fullName: 'Owner', phoneNumber: '+254700000001' }),
      );
      groupRepo.findMembers.mockResolvedValue([
        new GroupMember({
          groupId: 10,
          userId: 2,
          role: 'member',
          fullName: 'Mary',
        }),
      ]);

      const members = await useCase.execute(10, 1);

      expect(members).toHaveLength(2);
      expect(members[0].role).toBe('owner');
      expect(members[0].userId).toBe(1);
      expect(members[1].fullName).toBe('Mary');
    });

    it('allows a member to view the list', async () => {
      const useCase = new ListGroupMembersUseCase(groupRepo, userRepo);
      groupRepo.findById.mockResolvedValue(group());
      groupRepo.isMember.mockResolvedValue(true);
      userRepo.findById.mockResolvedValue(null);
      groupRepo.findMembers.mockResolvedValue([]);

      const members = await useCase.execute(10, 2);
      expect(members[0].role).toBe('owner');
    });

    it('404s for outsiders', async () => {
      const useCase = new ListGroupMembersUseCase(groupRepo, userRepo);
      groupRepo.findById.mockResolvedValue(group());
      groupRepo.isMember.mockResolvedValue(false);

      await expect(useCase.execute(10, 99)).rejects.toThrow(NotFoundException);
    });
  });

  describe('GetGroupUseCase with members', () => {
    it('lets a member read the group', async () => {
      const useCase = new GetGroupUseCase(groupRepo);
      groupRepo.findById.mockResolvedValue(group());
      groupRepo.isMember.mockResolvedValue(true);

      const result = await useCase.execute(10, 2);
      expect(result.id).toBe(10);
    });

    it('still 404s for outsiders', async () => {
      const useCase = new GetGroupUseCase(groupRepo);
      groupRepo.findById.mockResolvedValue(group());
      groupRepo.isMember.mockResolvedValue(false);

      await expect(useCase.execute(10, 99)).rejects.toThrow(NotFoundException);
    });

    it('lists owned and member groups together', async () => {
      const useCase = new GetGroupUseCase(groupRepo);
      groupRepo.findByUser.mockResolvedValue([group()]);

      const groups = await useCase.executeForUser(2);
      expect(groupRepo.findByUser).toHaveBeenCalledWith(2);
      expect(groups).toHaveLength(1);
    });
  });
});
