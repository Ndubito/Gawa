import 'package:flutter_1/features/groups/domain/entities/group_invite_model.dart';
import 'package:flutter_1/features/groups/domain/entities/group_member_model.dart';
import 'package:flutter_1/features/groups/presentation/cubits/invites_cubit.dart';
import 'package:flutter_1/features/groups/presentation/cubits/invites_state.dart';
import 'package:flutter_test/flutter_test.dart';

import 'groups_cubit_test.dart' show FakeGroupsRepo;

const _netflix = GroupInviteModel(
  groupId: 10,
  groupName: 'Family Netflix',
  invitedByName: 'Nathan',
);
const _spotify = GroupInviteModel(
  groupId: 20,
  groupName: 'Office Spotify',
  invitedByName: 'Mary',
);

void main() {
  group('InvitesCubit', () {
    late FakeGroupsRepo repo;
    late InvitesCubit cubit;

    setUp(() {
      repo = FakeGroupsRepo()..invites.addAll([_netflix, _spotify]);
      cubit = InvitesCubit(groupsRepo: repo);
    });

    test('loadInvites emits Loading then Loaded', () async {
      final emitted = <InvitesState>[];
      final sub = cubit.stream.listen(emitted.add);

      await cubit.loadInvites();
      await Future<void>.delayed(Duration.zero);

      expect(emitted.first, isA<InvitesLoading>());
      expect((emitted.last as InvitesLoaded).invites, hasLength(2));
      await sub.cancel();
    });

    test('loadInvites emits Error when the repo fails', () async {
      repo.failing = true;
      await cubit.loadInvites();
      expect(cubit.state, isA<InvitesError>());
    });

    test('accept calls the API and removes only that invite', () async {
      await cubit.loadInvites();

      await cubit.accept(10);

      expect(repo.accepted, [10]);
      final state = cubit.state as InvitesLoaded;
      expect(state.invites.map((i) => i.groupId), [20]);
      expect(state.responding, isEmpty);
    });

    test(
      'marks the invite as responding while the request is in flight',
      () async {
        await cubit.loadInvites();
        final emitted = <InvitesState>[];
        final sub = cubit.stream.listen(emitted.add);

        await cubit.decline(20);
        await Future<void>.delayed(Duration.zero);

        expect((emitted.first as InvitesLoaded).responding, {20});
        expect((emitted.last as InvitesLoaded).invites.map((i) => i.groupId), [
          10,
        ]);
        await sub.cancel();
      },
    );

    test(
      'a failed response keeps the invite and propagates the error',
      () async {
        await cubit.loadInvites();
        repo.failing = true;

        await expectLater(cubit.accept(10), throwsA(isA<Exception>()));

        final state = cubit.state as InvitesLoaded;
        expect(state.invites, hasLength(2));
        expect(state.responding, isEmpty);
      },
    );
  });

  group('GroupInviteModel', () {
    test('fromJson parses a backend invite', () {
      final invite = GroupInviteModel.fromJson({
        'groupId': 10,
        'groupName': 'Family Netflix',
        'groupDescription': null,
        'invitedByName': 'Nathan',
      });

      expect(invite.groupId, 10);
      expect(invite.groupDescription, isNull);
      expect(invite.invitedByName, 'Nathan');
    });
  });

  group('GroupMemberModel', () {
    test('fromJson reads the invite status', () {
      final member = GroupMemberModel.fromJson({
        'userId': 3,
        'fullName': null,
        'phoneNumber': '+254700000003',
        'role': 'member',
        'status': 'INVITED',
      });

      expect(member.isPending, isTrue);
      expect(member.displayName, '+254700000003');
    });
  });
}
