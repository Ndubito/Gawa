import { NotFoundException } from '@nestjs/common';
import {
  GroupAccessPolicy,
  GROUP_VIEWERS,
  OWNER_ONLY,
} from './group-access.policy';
import { InMemoryGroupRepository } from '../testing/in-memory-group.repository';
import { GroupMemberStatus, GroupRole } from '../domain/types/group.types';

const OWNER = 1;
const MEMBER = 2;
const INVITEE = 3;
const STRANGER = 99;
const GROUP = 10;

describe('GroupAccessPolicy', () => {
  let repo: InMemoryGroupRepository;
  let policy: GroupAccessPolicy;

  beforeEach(() => {
    repo = new InMemoryGroupRepository();
    repo.seedGroup({ id: GROUP, ownerId: OWNER });
    repo.seedMember(GROUP, MEMBER, GroupMemberStatus.ACTIVE);
    repo.seedMember(GROUP, INVITEE, GroupMemberStatus.INVITED);
    policy = new GroupAccessPolicy(repo);
  });

  it.each([
    [OWNER, GroupRole.OWNER],
    [MEMBER, GroupRole.MEMBER],
    [INVITEE, GroupRole.INVITED],
    [STRANGER, null],
  ])('resolves user %i to role %s', async (userId, expected) => {
    const group = (await repo.findById(GROUP))!;
    expect(await policy.roleOf(group, userId)).toBe(expected);
  });

  it('treats the owner as the owner even though they have no member row', async () => {
    const { role } = await policy.require(GROUP, OWNER, GROUP_VIEWERS);
    expect(role).toBe(GroupRole.OWNER);
  });

  it('lets accepted members view', async () => {
    const { group, role } = await policy.require(GROUP, MEMBER, GROUP_VIEWERS);
    expect(group.id).toBe(GROUP);
    expect(role).toBe(GroupRole.MEMBER);
  });

  it.each([INVITEE, STRANGER])(
    '404s user %i who may not view',
    async (userId) => {
      await expect(
        policy.require(GROUP, userId, GROUP_VIEWERS),
      ).rejects.toThrow(NotFoundException);
    },
  );

  it('404s members on owner-only actions', async () => {
    await expect(policy.require(GROUP, MEMBER, OWNER_ONLY)).rejects.toThrow(
      NotFoundException,
    );
  });

  it('404s for a missing group', async () => {
    await expect(policy.require(404, OWNER, GROUP_VIEWERS)).rejects.toThrow(
      NotFoundException,
    );
  });

  it('404s for a soft-deleted group, even for its owner', async () => {
    await repo.delete(GROUP);
    await expect(policy.require(GROUP, OWNER, OWNER_ONLY)).rejects.toThrow(
      NotFoundException,
    );
  });

  it('uses the caller-supplied message so resource ids are reported consistently', async () => {
    await expect(
      policy.require(
        GROUP,
        STRANGER,
        GROUP_VIEWERS,
        'Subscription 5 not found',
      ),
    ).rejects.toThrow('Subscription 5 not found');
  });
});
