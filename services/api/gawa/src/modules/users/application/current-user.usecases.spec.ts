import { NotFoundException } from '@nestjs/common';
import { GetCurrentUserUseCase } from './get-current-user.usecase';
import { UpdateUserUseCase } from './update-user.usecase';
import { IUserRepository } from '../domain/repos/user.repository';
import { User } from '../domain/entities/user.entity';

describe('Current user use cases', () => {
  let repo: jest.Mocked<IUserRepository>;

  beforeEach(() => {
    repo = {
      findById: jest.fn().mockResolvedValue(
        new User({
          id: 1,
          fullName: '+254700000001',
          phoneNumber: '+254700000001',
        }),
      ),
      findByEmail: jest.fn(),
      findByPhoneNumber: jest.fn(),
      findByFirebaseUid: jest.fn(),
      findAll: jest.fn(),
      save: jest.fn(),
      update: jest.fn().mockImplementation(async (u) => u),
      delete: jest.fn(),
    };
  });

  it('returns the requester’s own profile', async () => {
    const user = await new GetCurrentUserUseCase(repo).execute(1);
    expect(repo.findById).toHaveBeenCalledWith(1);
    expect(user.id).toBe(1);
  });

  it('404s when the user row is gone', async () => {
    repo.findById.mockResolvedValue(null);
    await expect(new GetCurrentUserUseCase(repo).execute(1)).rejects.toThrow(
      NotFoundException,
    );
  });

  it('updates the display name but never the phone number', async () => {
    const user = await new UpdateUserUseCase(repo).execute({
      id: 1,
      fullName: '  Mary Wanjiku ',
    });
    expect(user.fullName).toBe('Mary Wanjiku');
    expect(user.phoneNumber).toBe('+254700000001');
  });
});
