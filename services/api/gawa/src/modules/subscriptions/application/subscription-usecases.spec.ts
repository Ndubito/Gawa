import { NotFoundException } from '@nestjs/common';
import { CreateSubscriptionUseCase } from './create-subscription.usecase';
import { GetSubscriptionUseCase } from './get-subscription.usecase';
import { UpdateSubscriptionUseCase } from './update-subscription.usecase';
import { DeleteSubscriptionUseCase } from './delete-subscription.usecase';
import { ISubscriptionRepository } from '../domain/repos/subscription.repository';
import { IGroupRepository } from '../../groups/domain/repos/group.repository';
import { Subscription } from '../domain/entities/subscription.entity';
import { Group } from '../../groups/domain/entities/group.entity';
import { SubscriptionSchedule, SubscriptionStatus } from '../domain/types/subscription.types';

const OWNER_ID = 1;
const OTHER_ID = 99;
const GROUP_ID = 10;
const SUB_ID = 5;

const makeGroup = () => new Group({ id: GROUP_ID, name: 'Netflix Split', ownerId: OWNER_ID });

const makeSub = () =>
  new Subscription({
    id: SUB_ID,
    groupId: GROUP_ID,
    recipientId: OWNER_ID,
    organizerId: OWNER_ID,
    name: 'Netflix',
    amountCents: 150000,
    schedule: SubscriptionSchedule.MONTHLY,
    graceHours: 24,
    startDate: new Date('2026-07-01'),
  });

describe('Subscription use cases', () => {
  let subRepo: jest.Mocked<ISubscriptionRepository>;
  let groupRepo: jest.Mocked<IGroupRepository>;

  beforeEach(() => {
    subRepo = {
      findById: jest.fn(),
      findByGroupId: jest.fn(),
      save: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
    };

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
      isMember: jest.fn().mockResolvedValue(false),
    };
  });

  describe('CreateSubscriptionUseCase', () => {
    it('creates a subscription for the group owner', async () => {
      const useCase = new CreateSubscriptionUseCase(subRepo, groupRepo);
      groupRepo.findById.mockResolvedValue(makeGroup());
      subRepo.save.mockImplementation(async (s) => s);

      const sub = await useCase.execute(
        {
          groupId: GROUP_ID,
          name: 'Netflix',
          amountCents: 150000,
          schedule: SubscriptionSchedule.MONTHLY,
          graceHours: 24,
          startDate: new Date('2026-07-01'),
        },
        OWNER_ID,
      );

      expect(sub.organizerId).toBe(OWNER_ID);
      expect(sub.recipientId).toBe(OWNER_ID);
      expect(sub.name).toBe('Netflix');
      expect(subRepo.save).toHaveBeenCalled();
    });

    it('throws NotFound when a non-owner tries to create', async () => {
      const useCase = new CreateSubscriptionUseCase(subRepo, groupRepo);
      groupRepo.findById.mockResolvedValue(makeGroup());

      await expect(
        useCase.execute(
          { groupId: GROUP_ID, name: 'Netflix', amountCents: 150000, schedule: SubscriptionSchedule.MONTHLY, graceHours: 24, startDate: new Date() },
          OTHER_ID,
        ),
      ).rejects.toThrow(NotFoundException);
      expect(subRepo.save).not.toHaveBeenCalled();
    });

    it('throws NotFound when group does not exist', async () => {
      const useCase = new CreateSubscriptionUseCase(subRepo, groupRepo);
      groupRepo.findById.mockResolvedValue(null);

      await expect(
        useCase.execute(
          { groupId: 999, name: 'Netflix', amountCents: 150000, schedule: SubscriptionSchedule.MONTHLY, graceHours: 24, startDate: new Date() },
          OWNER_ID,
        ),
      ).rejects.toThrow(NotFoundException);
    });
  });

  describe('GetSubscriptionUseCase', () => {
    it('returns a subscription to a group member', async () => {
      const useCase = new GetSubscriptionUseCase(subRepo, groupRepo);
      subRepo.findById.mockResolvedValue(makeSub());
      groupRepo.isMember.mockResolvedValue(true);

      const sub = await useCase.execute(SUB_ID, OWNER_ID);
      expect(sub.id).toBe(SUB_ID);
    });

    it('throws NotFound for a non-member', async () => {
      const useCase = new GetSubscriptionUseCase(subRepo, groupRepo);
      subRepo.findById.mockResolvedValue(makeSub());
      groupRepo.isMember.mockResolvedValue(false);

      await expect(useCase.execute(SUB_ID, OTHER_ID)).rejects.toThrow(NotFoundException);
    });

    it('returns subscriptions by group for a member', async () => {
      const useCase = new GetSubscriptionUseCase(subRepo, groupRepo);
      groupRepo.isMember.mockResolvedValue(true);
      subRepo.findByGroupId.mockResolvedValue([makeSub()]);

      const subs = await useCase.executeByGroupId(GROUP_ID, OWNER_ID);
      expect(subs).toHaveLength(1);
      expect(groupRepo.isMember).toHaveBeenCalledWith(GROUP_ID, OWNER_ID);
    });

    it('throws NotFound for a non-member accessing group subscriptions', async () => {
      const useCase = new GetSubscriptionUseCase(subRepo, groupRepo);
      groupRepo.isMember.mockResolvedValue(false);

      await expect(useCase.executeByGroupId(GROUP_ID, OTHER_ID)).rejects.toThrow(NotFoundException);
    });
  });

  describe('UpdateSubscriptionUseCase', () => {
    it('updates when the requester is the group owner', async () => {
      const useCase = new UpdateSubscriptionUseCase(subRepo, groupRepo);
      subRepo.findById.mockResolvedValue(makeSub());
      groupRepo.findById.mockResolvedValue(makeGroup());
      subRepo.update.mockImplementation(async (s) => s);

      const sub = await useCase.execute({ id: SUB_ID, name: 'Netflix HD' }, OWNER_ID);
      expect(sub.name).toBe('Netflix HD');
    });

    it('throws NotFound for a non-owner', async () => {
      const useCase = new UpdateSubscriptionUseCase(subRepo, groupRepo);
      subRepo.findById.mockResolvedValue(makeSub());
      groupRepo.findById.mockResolvedValue(makeGroup());

      await expect(useCase.execute({ id: SUB_ID, name: 'Hijack' }, OTHER_ID)).rejects.toThrow(NotFoundException);
      expect(subRepo.update).not.toHaveBeenCalled();
    });
  });

  describe('DeleteSubscriptionUseCase', () => {
    it('deletes when the requester is the group owner', async () => {
      const useCase = new DeleteSubscriptionUseCase(subRepo, groupRepo);
      subRepo.findById.mockResolvedValue(makeSub());
      groupRepo.findById.mockResolvedValue(makeGroup());

      await useCase.execute(SUB_ID, OWNER_ID);
      expect(subRepo.delete).toHaveBeenCalledWith(SUB_ID);
    });

    it('throws NotFound for a non-owner', async () => {
      const useCase = new DeleteSubscriptionUseCase(subRepo, groupRepo);
      subRepo.findById.mockResolvedValue(makeSub());
      groupRepo.findById.mockResolvedValue(makeGroup());

      await expect(useCase.execute(SUB_ID, OTHER_ID)).rejects.toThrow(NotFoundException);
      expect(subRepo.delete).not.toHaveBeenCalled();
    });
  });
});
