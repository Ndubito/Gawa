import { NotFoundException } from '@nestjs/common';
import { CreateGroupUseCase } from './create-group.usecase';
import { GetGroupUseCase } from './get-group.usecase';
import { UpdateGroupUseCase } from './update-group.usecase';
import { DeleteGroupUseCase } from './delete-group.usecase';
import { GroupAccessPolicy } from './group-access.policy';
import { InMemoryGroupRepository } from '../testing/in-memory-group.repository';
import { GroupMemberStatus } from '../domain/types/group.types';
import { CancelUpcomingObligationsUseCase } from '../../obligations/application/cancel-upcoming-obligations.usecase';

const OWNER = 1;
const MEMBER = 2;
const INVITEE = 3;
const STRANGER = 99;
const GROUP = 10;

describe('Group use cases', () => {
  let repo: InMemoryGroupRepository;
  let access: GroupAccessPolicy;

  beforeEach(() => {
    repo = new InMemoryGroupRepository();
    repo.seedGroup({ id: GROUP, ownerId: OWNER, name: 'Family Netflix' });
    repo.seedMember(GROUP, MEMBER, GroupMemberStatus.ACTIVE);
    repo.seedMember(GROUP, INVITEE, GroupMemberStatus.INVITED);
    access = new GroupAccessPolicy(repo);
  });

  describe('CreateGroupUseCase', () => {
    it('assigns the owner from the authenticated requester, not the dto', async () => {
      const group = await new CreateGroupUseCase(repo).execute(
        { name: 'Office Spotify', description: 'music' },
        42,
      );

      expect(group.ownerId).toBe(42);
      expect(group.name).toBe('Office Spotify');
    });
  });

  describe('GetGroupUseCase', () => {
    it.each([OWNER, MEMBER])('returns the group to user %i', async (userId) => {
      const group = await new GetGroupUseCase(repo, access).execute(
        GROUP,
        userId,
      );
      expect(group.id).toBe(GROUP);
    });

    it.each([INVITEE, STRANGER])(
      '404s user %i (no existence leak)',
      async (userId) => {
        await expect(
          new GetGroupUseCase(repo, access).execute(GROUP, userId),
        ).rejects.toThrow(NotFoundException);
      },
    );

    it('lists owned and joined groups but not pending invites', async () => {
      repo.seedGroup({ id: 20, ownerId: STRANGER });
      repo.seedMember(20, MEMBER, GroupMemberStatus.INVITED);
      const useCase = new GetGroupUseCase(repo, access);

      expect((await useCase.executeForUser(OWNER)).map((g) => g.id)).toEqual([
        GROUP,
      ]);
      expect((await useCase.executeForUser(MEMBER)).map((g) => g.id)).toEqual([
        GROUP,
      ]);
      expect(await useCase.executeForUser(INVITEE)).toEqual([]);
    });
  });

  describe('UpdateGroupUseCase', () => {
    it('updates when the requester owns the group', async () => {
      const group = await new UpdateGroupUseCase(repo, access).execute(
        { id: GROUP, name: 'Renamed' },
        OWNER,
      );
      expect(group.name).toBe('Renamed');
    });

    it.each([MEMBER, INVITEE, STRANGER])('404s user %i', async (userId) => {
      await expect(
        new UpdateGroupUseCase(repo, access).execute(
          { id: GROUP, name: 'Hijack' },
          userId,
        ),
      ).rejects.toThrow(NotFoundException);
      expect((await repo.findById(GROUP))!.name).toBe('Family Netflix');
    });
  });

  describe('DeleteGroupUseCase', () => {
    let cancelUpcoming: jest.Mocked<CancelUpcomingObligationsUseCase>;

    beforeEach(() => {
      cancelUpcoming = {
        forDeletedGroup: jest.fn().mockResolvedValue(0),
      } as unknown as jest.Mocked<CancelUpcomingObligationsUseCase>;
    });

    it('soft-deletes and withdraws not-yet-due bills when the requester owns the group', async () => {
      await new DeleteGroupUseCase(repo, access, cancelUpcoming).execute(
        GROUP,
        OWNER,
      );
      expect(await repo.findById(GROUP)).toBeNull();
      expect(cancelUpcoming.forDeletedGroup).toHaveBeenCalledWith(GROUP);
    });

    it.each([MEMBER, INVITEE, STRANGER])('404s user %i', async (userId) => {
      await expect(
        new DeleteGroupUseCase(repo, access, cancelUpcoming).execute(
          GROUP,
          userId,
        ),
      ).rejects.toThrow(NotFoundException);
      expect(await repo.findById(GROUP)).not.toBeNull();
      expect(cancelUpcoming.forDeletedGroup).not.toHaveBeenCalled();
    });
  });
});
