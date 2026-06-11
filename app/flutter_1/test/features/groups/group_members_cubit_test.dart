import 'package:flutter_1/core/phone_number.dart';
import 'package:flutter_1/features/groups/presentation/cubits/group_members_cubit.dart';
import 'package:flutter_1/features/groups/presentation/cubits/group_members_state.dart';
import 'package:flutter_test/flutter_test.dart';

import 'groups_cubit_test.dart' show FakeGroupsRepo;

void main() {
  group('GroupMembersCubit', () {
    test('loadMembers emits Loaded with the owner first', () async {
      final repo = FakeGroupsRepo();
      final cubit = GroupMembersCubit(groupsRepo: repo, groupId: 1);

      await cubit.loadMembers();

      final state = cubit.state as GroupMembersLoaded;
      expect(state.members.first.role, 'owner');
    });

    test('loadMembers emits Error when the repo fails', () async {
      final repo = FakeGroupsRepo()..failing = true;
      final cubit = GroupMembersCubit(groupsRepo: repo, groupId: 1);

      await cubit.loadMembers();

      expect(cubit.state, isA<GroupMembersError>());
    });

    test('addMember adds and reloads', () async {
      final repo = FakeGroupsRepo();
      final cubit = GroupMembersCubit(groupsRepo: repo, groupId: 1);

      await cubit.addMember('+254712345678');

      final state = cubit.state as GroupMembersLoaded;
      expect(state.members, hasLength(2));
      expect(state.members.last.phoneNumber, '+254712345678');
    });

    test('addMember propagates duplicate errors', () async {
      final repo = FakeGroupsRepo();
      final cubit = GroupMembersCubit(groupsRepo: repo, groupId: 1);
      await cubit.addMember('+254712345678');

      expect(
        () => cubit.addMember('+254712345678'),
        throwsA(isA<Exception>()),
      );
    });

    test('removeMember removes and reloads', () async {
      final repo = FakeGroupsRepo();
      final cubit = GroupMembersCubit(groupsRepo: repo, groupId: 1);
      await cubit.addMember('+254712345678');
      final added = (cubit.state as GroupMembersLoaded).members.last;

      await cubit.removeMember(added.userId);

      expect((cubit.state as GroupMembersLoaded).members, hasLength(1));
    });
  });

  group('normalizeKenyanPhone', () {
    test('accepts the common Kenyan formats', () {
      expect(normalizeKenyanPhone('0712345678'), '+254712345678');
      expect(normalizeKenyanPhone('712345678'), '+254712345678');
      expect(normalizeKenyanPhone('254712345678'), '+254712345678');
      expect(normalizeKenyanPhone('+254712345678'), '+254712345678');
      expect(normalizeKenyanPhone('0712 345 678'), '+254712345678');
      expect(normalizeKenyanPhone('0110123456'), '+254110123456');
    });

    test('rejects invalid input', () {
      expect(normalizeKenyanPhone(''), isNull);
      expect(normalizeKenyanPhone('12345'), isNull);
      expect(normalizeKenyanPhone('0812345678'), isNull);
      expect(normalizeKenyanPhone('not a phone'), isNull);
      expect(normalizeKenyanPhone('07123456789999'), isNull);
    });
  });
}
