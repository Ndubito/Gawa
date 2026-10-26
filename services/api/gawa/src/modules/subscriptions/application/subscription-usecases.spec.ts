import { NotFoundException } from '@nestjs/common';
import { CreateSubscriptionUseCase } from './create-subscription.usecase';
import { GetSubscriptionUseCase } from './get-subscription.usecase';
import { UpdateSubscriptionUseCase } from './update-subscription.usecase';
import { DeleteSubscriptionUseCase } from './delete-subscription.usecase';
import { ISubscriptionRepository } from '../domain/repos/subscription.repository';
import { Subscription } from '../domain/entities/subscription.entity';
import { SubscriptionSchedule } from '../domain/types/subscription.types';
import { GroupAccessPolicy } from '../../groups/application/group-access.policy';
import { InMemoryGroupRepository } from '../../groups/testing/in-memory-group.repository';
import { GroupMemberStatus } from '../../groups/domain/types/group.types';

const OWNER = 1;
const MEMBER = 2;
const INVITEE = 3;
const STRANGER = 99;
const GROUP = 10;
const SUB_ID = 5;

const makeSub = () =>
  new Subscription({
    id: SUB_ID,
    groupId: GROUP,
    recipientId: OWNER,
    organizerId: OWNER,
    name: 'Netflix',
    amountCents: 150000,
    schedule: SubscriptionSchedule.MONTHLY,
    graceHours: 24,
    startDate: new Date('2026-07-01'),
  });

const createInput = (groupId = GROUP) => ({
  groupId,
  name: 'Netflix',
  amountCents: 150000,
  schedule: SubscriptionSchedule.MONTHLY,
  graceHours: 24,
  startDate: new Date('2026-07-01'),
});

describe('Subscription use cases', () => {
  let subRepo: jest.Mocked<ISubscriptionRepository>;
  let groupRepo: InMemoryGroupRepository;
  let access: GroupAccessPolicy;

  beforeEach(() => {
    subRepo = {
      findById: jest.fn().mockResolvedValue(makeSub()),
      findByGroupId: jest.fn().mockResolvedValue([makeSub()]),
      findByGroupIds: jest.fn().mockResolvedValue([makeSub()]),
      save: jest.fn().mockImplementation(async (s) => s),
      update: jest.fn().mockImplementation(async (s) => s),
      delete: jest.fn(),
    };
    groupRepo = new InMemoryGroupRepository();
    groupRepo.seedGroup({ id: GROUP, ownerId: OWNER });
    groupRepo.seedMember(GROUP, MEMBER, GroupMemberStatus.ACTIVE);
    groupRepo.seedMember(GROUP, INVITEE, GroupMemberStatus.INVITED);
    access = new GroupAccessPolicy(groupRepo);
  });

  describe('CreateSubscriptionUseCase', () => {
    it('creates a subscription organized by and paid to the group owner', async () => {
      const sub = await new CreateSubscriptionUseCase(subRepo, access).execute(
        createInput(),
        OWNER,
      );

      expect(sub.organizerId).toBe(OWNER);
      expect(sub.recipientId).toBe(OWNER);
      expect(subRepo.save).toHaveBeenCalled();
    });

    it.each([MEMBER, INVITEE, STRANGER])('404s user %i', async (userId) => {
      await expect(
        new CreateSubscriptionUseCase(subRepo, access).execute(
          createInput(),
          userId,
        ),
      ).rejects.toThrow(NotFoundException);
      expect(subRepo.save).not.toHaveBeenCalled();
    });

    it('404s when the group does not exist', async () => {
      await expect(
        new CreateSubscriptionUseCase(subRepo, access).execute(
          createInput(999),
          OWNER,
        ),
      ).rejects.toThrow(NotFoundException);
    });
  });

  describe('GetSubscriptionUseCase', () => {
    const useCase = () =>
      new GetSubscriptionUseCase(subRepo, groupRepo, access);

    // Regression: the owner has no GroupMember row and used to be 404'd here.
    it.each([OWNER, MEMBER])(
      'returns a subscription to user %i',
      async (userId) => {
        expect((await useCase().execute(SUB_ID, userId)).id).toBe(SUB_ID);
      },
    );

    it.each([INVITEE, STRANGER])('404s user %i', async (userId) => {
      await expect(useCase().execute(SUB_ID, userId)).rejects.toThrow(
        NotFoundException,
      );
    });

    it('404s a missing subscription', async () => {
      subRepo.findById.mockResolvedValue(null);
      await expect(useCase().execute(SUB_ID, OWNER)).rejects.toThrow(
        NotFoundException,
      );
    });

    it.each([OWNER, MEMBER])(
      'lists a group’s subscriptions for user %i',
      async (userId) => {
        expect(await useCase().executeByGroupId(GROUP, userId)).toHaveLength(1);
      },
    );

    it.each([INVITEE, STRANGER])(
      '404s user %i listing a group’s subscriptions',
      async (userId) => {
        await expect(useCase().executeByGroupId(GROUP, userId)).rejects.toThrow(
          NotFoundException,
        );
        expect(subRepo.findByGroupId).not.toHaveBeenCalled();
      },
    );

    it('aggregates across owned and joined groups, excluding pending invites', async () => {
      groupRepo.seedGroup({ id: 20, ownerId: STRANGER });
      groupRepo.seedMember(20, OWNER, GroupMemberStatus.ACTIVE);
      groupRepo.seedGroup({ id: 30, ownerId: STRANGER });
      groupRepo.seedMember(30, OWNER, GroupMemberStatus.INVITED);

      await useCase().executeForUser(OWNER);

      expect(subRepo.findByGroupIds).toHaveBeenCalledWith([GROUP, 20]);
    });
  });

  describe('UpdateSubscriptionUseCase', () => {
    it('updates when the requester is the group owner', async () => {
      const sub = await new UpdateSubscriptionUseCase(subRepo, access).execute(
        { id: SUB_ID, name: 'Netflix HD' },
        OWNER,
      );
      expect(sub.name).toBe('Netflix HD');
    });

    it.each([MEMBER, INVITEE, STRANGER])('404s user %i', async (userId) => {
      await expect(
        new UpdateSubscriptionUseCase(subRepo, access).execute(
          { id: SUB_ID, name: 'Hijack' },
          userId,
        ),
      ).rejects.toThrow(NotFoundException);
      expect(subRepo.update).not.toHaveBeenCalled();
    });
  });

  describe('DeleteSubscriptionUseCase', () => {
    it('deletes when the requester is the group owner', async () => {
      await new DeleteSubscriptionUseCase(subRepo, access).execute(
        SUB_ID,
        OWNER,
      );
      expect(subRepo.delete).toHaveBeenCalledWith(SUB_ID);
    });

    it.each([MEMBER, INVITEE, STRANGER])('404s user %i', async (userId) => {
      await expect(
        new DeleteSubscriptionUseCase(subRepo, access).execute(SUB_ID, userId),
      ).rejects.toThrow(NotFoundException);
      expect(subRepo.delete).not.toHaveBeenCalled();
    });
  });
});
