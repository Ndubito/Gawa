import { SyncFirebaseUserUseCase } from './sync-firebase-user.usecase';
import { IUserRepository } from '../domain/repos/user.repository';
import { User } from '../domain/entities/user.entity';

describe('SyncFirebaseUserUseCase', () => {
  let repo: jest.Mocked<IUserRepository>;
  let useCase: SyncFirebaseUserUseCase;

  beforeEach(() => {
    repo = {
      findById: jest.fn(),
      findByEmail: jest.fn(),
      findByPhoneNumber: jest.fn(),
      findByFirebaseUid: jest.fn(),
      findAll: jest.fn(),
      save: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
    };
    useCase = new SyncFirebaseUserUseCase(repo);
  });

  it('returns the existing user when the firebase uid is already linked', async () => {
    const existing = new User({
      id: 1,
      firebaseUid: 'uid-1',
      fullName: 'Nathan',
      phoneNumber: '+254700000001',
    });
    repo.findByFirebaseUid.mockResolvedValue(existing);

    const result = await useCase.execute({ uid: 'uid-1' });

    expect(result).toBe(existing);
    expect(repo.save).not.toHaveBeenCalled();
    expect(repo.update).not.toHaveBeenCalled();
  });

  it('links the firebase uid to an existing user found by phone number', async () => {
    const byPhone = new User({
      id: 2,
      fullName: 'Mary',
      phoneNumber: '+254700000002',
    });
    repo.findByFirebaseUid.mockResolvedValue(null);
    repo.findByPhoneNumber.mockResolvedValue(byPhone);
    repo.update.mockImplementation(async (u) => u);

    const result = await useCase.execute({
      uid: 'uid-2',
      phoneNumber: '+254700000002',
    });

    expect(repo.findByPhoneNumber).toHaveBeenCalledWith('+254700000002');
    expect(result.firebaseUid).toBe('uid-2');
    expect(repo.update).toHaveBeenCalledWith(byPhone);
    expect(repo.save).not.toHaveBeenCalled();
  });

  it('creates a new user when no match exists', async () => {
    repo.findByFirebaseUid.mockResolvedValue(null);
    repo.findByPhoneNumber.mockResolvedValue(null);
    repo.save.mockImplementation(async (u) => u);

    const result = await useCase.execute({
      uid: 'uid-3',
      phoneNumber: '+254700000003',
    });

    expect(repo.save).toHaveBeenCalled();
    expect(result.firebaseUid).toBe('uid-3');
    expect(result.phoneNumber).toBe('+254700000003');
    // No display name in a phone-auth token — falls back to the phone number
    expect(result.fullName).toBe('+254700000003');
  });

  it('rejects relinking a user already bound to a different firebase account', async () => {
    const byPhone = new User({
      id: 4,
      firebaseUid: 'uid-original',
      fullName: 'Sam',
      phoneNumber: '+254700000004',
    });
    repo.findByFirebaseUid.mockResolvedValue(null);
    repo.findByPhoneNumber.mockResolvedValue(byPhone);

    await expect(
      useCase.execute({ uid: 'uid-imposter', phoneNumber: '+254700000004' }),
    ).rejects.toThrow('already linked');
  });
});
