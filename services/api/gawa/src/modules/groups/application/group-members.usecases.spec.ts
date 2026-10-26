import { NotFoundException, ConflictException } from '@nestjs/common';
import { AddGroupMemberUseCase } from './add-group-member.usecase';
import { RemoveGroupMemberUseCase } from './remove-group-member.usecase';
import { ListGroupMembersUseCase } from './list-group-members.usecase';
import { GroupInvitesUseCase } from './group-invites.usecase';
import { GetGroupUseCase } from './get-group.usecase';
import { GroupAccessPolicy } from './group-access.policy';
import { InMemoryGroupRepository } from '../testing/in-memory-group.repository';
import { GroupMemberStatus } from '../domain/types/group.types';
import { IUserRepository } from '../../users/domain/repos/user.repository';
import { User } from '../../users/domain/entities/user.entity';

const OWNER = 1;
const MEMBER = 2;
const INVITEE = 3;
const STRANGER = 99;
const GROUP = 10;

describe('Group membership use cases', () => {
  let repo: InMemoryGroupRepository;
  let access: GroupAccessPolicy;
  let userRepo: jest.Mocked<IUserRepository>;

  beforeEach(() => {
    repo = new InMemoryGroupRepository();
    repo.seedGroup({ id: GROUP, ownerId: OWNER });
    repo.seedMember(GROUP, MEMBER, GroupMemberStatus.ACTIVE);
    repo.seedMember(GROUP, INVITEE, GroupMemberStatus.INVITED);
    access = new GroupAccessPolicy(repo);
    userRepo = {
      findById: jest.fn().mockResolvedValue(null),
      findByEmail: jest.fn(),
      findByPhoneNumber: jest.fn().mockResolvedValue(null),
      findByFirebaseUid: jest.fn(),
      findAll: jest.fn(),
      save: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
    };
  });

  describe('AddGroupMemberUseCase', () => {
    const add = (phone: string, requester: number) =>
      new AddGroupMemberUseCase(repo, userRepo, access).execute(
        { groupId: GROUP, phoneNumber: phone },
        requester,
      );

    it('invites an existing user as pending, not as a member', async () => {
      userRepo.findByPhoneNumber.mockResolvedValue(
        new User({ id: 5, fullName: 'Mary', phoneNumber: '+254700000005' }),
      );

      const member = await add('+254700000005', OWNER);

      expect(member.status).toBe(GroupMemberStatus.INVITED);
      expect((await repo.findMembership(GROUP, 5))!.isActive).toBe(false);
      expect(await new GetGroupUseCase(repo, access).executeForUser(5)).toEqual(
        [],
      );
      expect(userRepo.save).not.toHaveBeenCalled();
    });

    it('creates a placeholder user for an unknown phone number', async () => {
      userRepo.save.mockImplementation(async (u) => {
        u.assignId(7);
        return u;
      });

      const member = await add('+254799999999', OWNER);

      expect(member.userId).toBe(7);
      expect(member.phoneNumber).toBe('+254799999999');
    });

    it.each([MEMBER, INVITEE, STRANGER])(
      '404s user %i (only the owner invites)',
      async (userId) => {
        await expect(add('+254700000005', userId)).rejects.toThrow(
          NotFoundException,
        );
      },
    );

    it('rejects inviting the owner', async () => {
      userRepo.findByPhoneNumber.mockResolvedValue(
        new User({
          id: OWNER,
          fullName: 'Owner',
          phoneNumber: '+254700000001',
        }),
      );
      await expect(add('+254700000001', OWNER)).rejects.toThrow(
        ConflictException,
      );
    });

    it.each([
      [MEMBER, 'already a member'],
      [INVITEE, 'already been invited'],
    ])('rejects re-inviting user %i', async (userId, message) => {
      userRepo.findByPhoneNumber.mockResolvedValue(
        new User({ id: userId, fullName: 'X', phoneNumber: '+254700000009' }),
      );
      await expect(add('+254700000009', OWNER)).rejects.toThrow(message);
    });
  });

  describe('RemoveGroupMemberUseCase', () => {
    const remove = (memberId: number, requester: number) =>
      new RemoveGroupMemberUseCase(repo, access).execute(
        GROUP,
        memberId,
        requester,
      );

    it('lets the owner remove an accepted member', async () => {
      await remove(MEMBER, OWNER);
      expect(await repo.findMembership(GROUP, MEMBER)).toBeNull();
    });

    it('lets the owner revoke a pending invite', async () => {
      await remove(INVITEE, OWNER);
      expect(await repo.findMembership(GROUP, INVITEE)).toBeNull();
    });

    it('lets a member leave', async () => {
      await remove(MEMBER, MEMBER);
      expect(await repo.findMembership(GROUP, MEMBER)).toBeNull();
    });

    it('stops a member removing someone else', async () => {
      await expect(remove(INVITEE, MEMBER)).rejects.toThrow(NotFoundException);
      expect(await repo.findMembership(GROUP, INVITEE)).not.toBeNull();
    });

    it.each([INVITEE, STRANGER])('404s user %i', async (userId) => {
      await expect(remove(MEMBER, userId)).rejects.toThrow(NotFoundException);
      expect(await repo.findMembership(GROUP, MEMBER)).not.toBeNull();
    });

    it('404s when the person is not in the group', async () => {
      await expect(remove(STRANGER, OWNER)).rejects.toThrow(NotFoundException);
    });
  });

  describe('ListGroupMembersUseCase', () => {
    const list = (requester: number) =>
      new ListGroupMembersUseCase(repo, userRepo, access).execute(
        GROUP,
        requester,
      );

    it('shows the owner first, then everyone including pending invites, to the owner', async () => {
      const members = await list(OWNER);
      expect(members.map((m) => [m.userId, m.status])).toEqual([
        [OWNER, GroupMemberStatus.ACTIVE],
        [MEMBER, GroupMemberStatus.ACTIVE],
        [INVITEE, GroupMemberStatus.INVITED],
      ]);
      expect(members[0].role).toBe('owner');
    });

    it('hides pending invitees from members', async () => {
      const members = await list(MEMBER);
      expect(members.map((m) => m.userId)).toEqual([OWNER, MEMBER]);
    });

    it.each([INVITEE, STRANGER])('404s user %i', async (userId) => {
      await expect(list(userId)).rejects.toThrow(NotFoundException);
    });
  });

  describe('GroupInvitesUseCase', () => {
    let invites: GroupInvitesUseCase;

    beforeEach(() => {
      invites = new GroupInvitesUseCase(repo, access);
    });

    it('lists only pending invites for the user', async () => {
      expect(
        (await invites.listForUser(INVITEE)).map((i) => i.groupId),
      ).toEqual([GROUP]);
      expect(await invites.listForUser(MEMBER)).toEqual([]);
    });

    it('does not list invites to deleted groups', async () => {
      await repo.delete(GROUP);
      expect(await invites.listForUser(INVITEE)).toEqual([]);
    });

    it('accepting makes the group visible', async () => {
      await invites.accept(GROUP, INVITEE);

      const group = await new GetGroupUseCase(repo, access).execute(
        GROUP,
        INVITEE,
      );
      expect(group.id).toBe(GROUP);
      expect(await invites.listForUser(INVITEE)).toEqual([]);
    });

    it('declining removes the invite so the owner can re-invite later', async () => {
      await invites.decline(GROUP, INVITEE);
      expect(await repo.findMembership(GROUP, INVITEE)).toBeNull();
    });

    it.each([OWNER, MEMBER, STRANGER])(
      '404s user %i who has no pending invite',
      async (userId) => {
        await expect(invites.accept(GROUP, userId)).rejects.toThrow(
          NotFoundException,
        );
        await expect(invites.decline(GROUP, userId)).rejects.toThrow(
          NotFoundException,
        );
      },
    );
  });
});
