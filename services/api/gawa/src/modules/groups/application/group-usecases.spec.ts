import { NotFoundException } from '@nestjs/common';
import { CreateGroupUseCase } from './create-group.usecase';
import { GetGroupUseCase } from './get-group.usecase';
import { UpdateGroupUseCase } from './update-group.usecase';
import { DeleteGroupUseCase } from './delete-group.usecase';
import { IGroupRepository } from '../domain/repos/group.repository';
import { Group } from '../domain/entities/group.entity';

describe('Group use cases (ownership)', () => {
  let repo: jest.Mocked<IGroupRepository>;

  const ownedGroup = () =>
    new Group({ id: 10, name: 'Family Netflix', ownerId: 1 });

  beforeEach(() => {
    repo = {
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

  describe('CreateGroupUseCase', () => {
    it('assigns the owner from the authenticated requester, not the dto', async () => {
      const useCase = new CreateGroupUseCase(repo);
      repo.save.mockImplementation(async (g) => g);

      const group = await useCase.execute(
        { name: 'Office Spotify', description: 'music' },
        42,
      );

      expect(group.ownerId).toBe(42);
      expect(group.name).toBe('Office Spotify');
      expect(repo.save).toHaveBeenCalled();
    });
  });

  describe('GetGroupUseCase', () => {
    it('returns the group to its owner', async () => {
      const useCase = new GetGroupUseCase(repo);
      repo.findById.mockResolvedValue(ownedGroup());

      const group = await useCase.execute(10, 1);
      expect(group.id).toBe(10);
    });

    it('throws NotFound for a non-owner (no existence leak)', async () => {
      const useCase = new GetGroupUseCase(repo);
      repo.findById.mockResolvedValue(ownedGroup());

      await expect(useCase.execute(10, 99)).rejects.toThrow(NotFoundException);
    });

    it('lists only the owner groups via the repository', async () => {
      const useCase = new GetGroupUseCase(repo);
      repo.findByOwnerId.mockResolvedValue([ownedGroup()]);

      const groups = await useCase.executeByOwner(1);
      expect(repo.findByOwnerId).toHaveBeenCalledWith(1);
      expect(groups).toHaveLength(1);
    });
  });

  describe('UpdateGroupUseCase', () => {
    it('updates when the requester owns the group', async () => {
      const useCase = new UpdateGroupUseCase(repo);
      repo.findById.mockResolvedValue(ownedGroup());
      repo.update.mockImplementation(async (g) => g);

      const group = await useCase.execute({ id: 10, name: 'Renamed' }, 1);
      expect(group.name).toBe('Renamed');
    });

    it('throws NotFound for a non-owner', async () => {
      const useCase = new UpdateGroupUseCase(repo);
      repo.findById.mockResolvedValue(ownedGroup());

      await expect(
        useCase.execute({ id: 10, name: 'Hijack' }, 99),
      ).rejects.toThrow(NotFoundException);
      expect(repo.update).not.toHaveBeenCalled();
    });
  });

  describe('DeleteGroupUseCase', () => {
    it('deletes when the requester owns the group', async () => {
      const useCase = new DeleteGroupUseCase(repo);
      repo.findById.mockResolvedValue(ownedGroup());

      await useCase.execute(10, 1);
      expect(repo.delete).toHaveBeenCalledWith(10);
    });

    it('throws NotFound for a non-owner', async () => {
      const useCase = new DeleteGroupUseCase(repo);
      repo.findById.mockResolvedValue(ownedGroup());

      await expect(useCase.execute(10, 99)).rejects.toThrow(NotFoundException);
      expect(repo.delete).not.toHaveBeenCalled();
    });
  });
});
