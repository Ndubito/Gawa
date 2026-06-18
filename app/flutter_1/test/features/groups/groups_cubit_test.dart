import 'package:flutter_1/features/groups/domain/entities/group_member_model.dart';
import 'package:flutter_1/features/groups/domain/entities/group_model.dart';
import 'package:flutter_1/features/groups/domain/repos/groups_repo.dart';
import 'package:flutter_1/features/groups/presentation/cubits/groups_cubit.dart';
import 'package:flutter_1/features/groups/presentation/cubits/groups_state.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory fake repo; set [failing] to simulate the backend being down.
class FakeGroupsRepo extends GroupsRepo {
  final List<GroupModel> groups = [];
  final Map<int, List<GroupMemberModel>> members = {};
  bool failing = false;
  int _nextId = 1;
  int _nextUserId = 100;

  void _maybeFail() {
    if (failing) throw Exception('backend unreachable');
  }

  @override
  Future<List<GroupMemberModel>> getMembers(int groupId) async {
    _maybeFail();
    return [
      const GroupMemberModel(userId: 1, fullName: 'Owner', role: 'owner'),
      ...?members[groupId],
    ];
  }

  @override
  Future<GroupMemberModel> addMember(int groupId, String phoneNumber) async {
    _maybeFail();
    final existing = members[groupId] ?? [];
    if (existing.any((m) => m.phoneNumber == phoneNumber)) {
      throw Exception('This person is already a member');
    }
    final member = GroupMemberModel(
      userId: _nextUserId++,
      fullName: phoneNumber,
      phoneNumber: phoneNumber,
      role: 'member',
    );
    members[groupId] = [...existing, member];
    return member;
  }

  @override
  Future<void> removeMember(int groupId, int userId) async {
    _maybeFail();
    members[groupId]?.removeWhere((m) => m.userId == userId);
  }

  @override
  Future<GroupModel> createGroup(String name, {String? description}) async {
    _maybeFail();
    final group = GroupModel(
      id: _nextId++,
      name: name,
      description: description,
      ownerId: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    groups.add(group);
    return group;
  }

  @override
  Future<List<GroupModel>> getGroups() async {
    _maybeFail();
    return List.of(groups);
  }

  @override
  Future<GroupModel> getGroup(int groupId) async {
    _maybeFail();
    return groups.firstWhere((g) => g.id == groupId);
  }

  @override
  Future<GroupModel> updateGroup(
    int groupId, {
    String? name,
    String? description,
  }) async {
    _maybeFail();
    return getGroup(groupId);
  }

  @override
  Future<void> deleteGroup(int groupId) async {
    _maybeFail();
    groups.removeWhere((g) => g.id == groupId);
  }
}

void main() {
  group('GroupsCubit', () {
    test('loadGroups emits Loading then Loaded', () async {
      final repo = FakeGroupsRepo();
      await repo.createGroup('Family Netflix');
      final cubit = GroupsCubit(groupsRepo: repo);

      final emitted = <GroupsState>[];
      final sub = cubit.stream.listen(emitted.add);

      await cubit.loadGroups();
      // let the stream deliver the final event to the listener
      await Future<void>.delayed(Duration.zero);

      expect(emitted.first, isA<GroupsLoading>());
      expect(emitted.last, isA<GroupsLoaded>());
      expect((emitted.last as GroupsLoaded).groups, hasLength(1));
      await sub.cancel();
    });

    test('loadGroups emits Error when the repo fails', () async {
      final repo = FakeGroupsRepo()..failing = true;
      final cubit = GroupsCubit(groupsRepo: repo);

      await cubit.loadGroups();

      expect(cubit.state, isA<GroupsError>());
    });

    test('createGroup adds the group and reloads the list', () async {
      final repo = FakeGroupsRepo();
      final cubit = GroupsCubit(groupsRepo: repo);

      await cubit.createGroup('Office Spotify', description: 'music');

      final state = cubit.state as GroupsLoaded;
      expect(state.groups.single.name, 'Office Spotify');
      expect(state.groups.single.description, 'music');
    });

    test('createGroup propagates errors to the caller', () async {
      final repo = FakeGroupsRepo()..failing = true;
      final cubit = GroupsCubit(groupsRepo: repo);

      expect(
        () => cubit.createGroup('Doomed'),
        throwsA(isA<Exception>()),
      );
    });

    test('deleteGroup removes the group and reloads', () async {
      final repo = FakeGroupsRepo();
      final created = await repo.createGroup('Gym');
      final cubit = GroupsCubit(groupsRepo: repo);

      await cubit.deleteGroup(created.id);

      expect((cubit.state as GroupsLoaded).groups, isEmpty);
    });
  });

  group('GroupModel', () {
    test('fromJson parses a backend group response', () {
      final group = GroupModel.fromJson({
        'id': 2,
        'name': 'Smoke Test Group',
        'description': 'temp',
        'ownerId': 5,
        'createdAt': '2026-06-11T19:10:46.284Z',
        'updatedAt': '2026-06-11T19:10:46.284Z',
      });

      expect(group.id, 2);
      expect(group.name, 'Smoke Test Group');
      expect(group.description, 'temp');
      expect(group.ownerId, 5);
      expect(group.createdAt.year, 2026);
    });

    test('fromJson accepts a null description', () {
      final group = GroupModel.fromJson({
        'id': 3,
        'name': 'No Description',
        'description': null,
        'ownerId': 5,
        'createdAt': '2026-06-11T19:10:46.284Z',
        'updatedAt': '2026-06-11T19:10:46.284Z',
      });

      expect(group.description, isNull);
    });
  });
}
