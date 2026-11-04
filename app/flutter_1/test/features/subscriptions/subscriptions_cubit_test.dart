import 'package:flutter_1/core/enums.dart';
import 'package:flutter_1/features/subscriptions/domain/entities/subscription_cycle_model.dart';
import 'package:flutter_1/features/subscriptions/domain/entities/subscription_member_model.dart';
import 'package:flutter_1/features/subscriptions/domain/entities/subscription_model.dart';
import 'package:flutter_1/features/subscriptions/domain/repos/subscriptions_repo.dart';
import 'package:flutter_1/features/subscriptions/presentation/cubits/group_subscriptions_cubit.dart';
import 'package:flutter_1/features/subscriptions/presentation/cubits/group_subscriptions_state.dart';
import 'package:flutter_1/features/subscriptions/presentation/cubits/subscriptions_cubit.dart';
import 'package:flutter_1/features/subscriptions/presentation/cubits/subscriptions_state.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory fake; set [failing] to simulate the backend being down.
class FakeSubscriptionsRepo extends SubscriptionsRepo {
  final Map<int, List<SubscriptionModel>> byGroup = {};
  bool failing = false;
  int _nextId = 1;

  void _maybeFail() {
    if (failing) throw Exception('backend unreachable');
  }

  SubscriptionModel _build(int id, SubscriptionModel draft) {
    final now = DateTime.now();
    return SubscriptionModel(
      id: id,
      groupId: draft.groupId,
      recipientId: 1,
      organizerId: 1,
      name: draft.name,
      description: draft.description,
      amountCents: draft.amountCents,
      currency: Currency.kes,
      schedule: draft.schedule,
      graceHours: draft.graceHours,
      status: SubscriptionStatus.active,
      startDate: draft.startDate,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<SubscriptionModel> createSubscription(SubscriptionModel subscription) async {
    _maybeFail();
    final saved = _build(_nextId++, subscription);
    byGroup[subscription.groupId] = [...?byGroup[subscription.groupId], saved];
    return saved;
  }

  @override
  Future<List<SubscriptionModel>> getGroupSubscriptions(int groupId) async {
    _maybeFail();
    return List.of(byGroup[groupId] ?? const []);
  }

  @override
  Future<List<SubscriptionModel>> getMySubscriptions() async {
    _maybeFail();
    return byGroup.values.expand((s) => s).toList();
  }

  @override
  Future<void> deleteSubscription(int subscriptionId) async {
    _maybeFail();
    for (final entry in byGroup.entries) {
      entry.value.removeWhere((s) => s.id == subscriptionId);
    }
  }

  @override
  Future<SubscriptionModel> getSubscription(int subscriptionId) async {
    _maybeFail();
    return byGroup.values.expand((s) => s).firstWhere((s) => s.id == subscriptionId);
  }

  @override
  Future<SubscriptionModel> updateSubscription(int id, SubscriptionModel sub) async {
    _maybeFail();
    return sub;
  }

  @override
  Future<List<SubscriptionMemberModel>> getMembers(int subscriptionId) =>
      throw UnimplementedError();

  @override
  Future<List<SubscriptionCycleModel>> getCycles(int subscriptionId) =>
      throw UnimplementedError();
}

void main() {
  group('GroupSubscriptionsCubit', () {
    test('loadSubscriptions emits Loaded', () async {
      final repo = FakeSubscriptionsRepo();
      final cubit = GroupSubscriptionsCubit(subscriptionsRepo: repo, groupId: 1);

      await cubit.loadSubscriptions();

      expect(cubit.state, isA<GroupSubscriptionsLoaded>());
      expect((cubit.state as GroupSubscriptionsLoaded).subscriptions, isEmpty);
    });

    test('loadSubscriptions emits Error when the repo fails', () async {
      final repo = FakeSubscriptionsRepo()..failing = true;
      final cubit = GroupSubscriptionsCubit(subscriptionsRepo: repo, groupId: 1);

      await cubit.loadSubscriptions();

      expect(cubit.state, isA<GroupSubscriptionsError>());
    });

    test('createSubscription adds and reloads with KES converted to cents', () async {
      final repo = FakeSubscriptionsRepo();
      final cubit = GroupSubscriptionsCubit(subscriptionsRepo: repo, groupId: 1);

      await cubit.createSubscription(
        name: 'Netflix',
        amountCents: 150000, // KES 1,500
        startDate: DateTime(2026, 7, 1),
      );

      final state = cubit.state as GroupSubscriptionsLoaded;
      expect(state.subscriptions, hasLength(1));
      expect(state.subscriptions.first.name, 'Netflix');
      expect(state.subscriptions.first.amountCents, 150000);
      expect(state.subscriptions.first.amountValue, 1500.0);
      expect(state.subscriptions.first.schedule, SubscriptionSchedule.monthly);
    });

    test('createSubscription propagates errors to the caller', () async {
      final repo = FakeSubscriptionsRepo()..failing = true;
      final cubit = GroupSubscriptionsCubit(subscriptionsRepo: repo, groupId: 1);

      expect(
        () => cubit.createSubscription(
          name: 'Doomed',
          amountCents: 1000,
          startDate: DateTime(2026, 7, 1),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('deleteSubscription removes and reloads', () async {
      final repo = FakeSubscriptionsRepo();
      final cubit = GroupSubscriptionsCubit(subscriptionsRepo: repo, groupId: 1);
      await cubit.createSubscription(
        name: 'Spotify',
        amountCents: 30000,
        startDate: DateTime(2026, 7, 1),
      );
      final added = (cubit.state as GroupSubscriptionsLoaded).subscriptions.first;

      await cubit.deleteSubscription(added.id);

      expect((cubit.state as GroupSubscriptionsLoaded).subscriptions, isEmpty);
    });
  });

  group('SubscriptionsCubit (aggregate)', () {
    test('loadMine aggregates across groups', () async {
      final repo = FakeSubscriptionsRepo();
      await repo.createSubscription(
        SubscriptionModel(
          id: 0,
          groupId: 1,
          recipientId: 1,
          organizerId: 1,
          name: 'A',
          amountCents: 1000,
          currency: Currency.kes,
          schedule: SubscriptionSchedule.monthly,
          graceHours: 48,
          status: SubscriptionStatus.active,
          startDate: DateTime(2026, 7, 1),
          createdAt: DateTime(2026, 6, 1),
          updatedAt: DateTime(2026, 6, 1),
        ),
      );
      await repo.createSubscription(
        SubscriptionModel(
          id: 0,
          groupId: 2,
          recipientId: 1,
          organizerId: 1,
          name: 'B',
          amountCents: 2000,
          currency: Currency.kes,
          schedule: SubscriptionSchedule.monthly,
          graceHours: 48,
          status: SubscriptionStatus.active,
          startDate: DateTime(2026, 7, 1),
          createdAt: DateTime(2026, 6, 1),
          updatedAt: DateTime(2026, 6, 1),
        ),
      );
      final cubit = SubscriptionsCubit(subscriptionsRepo: repo);

      await cubit.loadMine();

      final state = cubit.state as SubscriptionsLoaded;
      expect(state.subscriptions, hasLength(2));
    });

    test('loadMine emits Error when the repo fails', () async {
      final repo = FakeSubscriptionsRepo()..failing = true;
      final cubit = SubscriptionsCubit(subscriptionsRepo: repo);

      await cubit.loadMine();

      expect(cubit.state, isA<SubscriptionsError>());
    });
  });

  group('SubscriptionModel', () {
    test('sharePerMember splits equally and falls back to full amount', () {
      final sub = SubscriptionModel(
        id: 1,
        groupId: 1,
        recipientId: 1,
        organizerId: 1,
        name: 'Netflix',
        amountCents: 150000,
        currency: Currency.kes,
        schedule: SubscriptionSchedule.monthly,
        graceHours: 48,
        status: SubscriptionStatus.active,
        startDate: DateTime(2026, 7, 1),
        createdAt: DateTime(2026, 6, 1),
        updatedAt: DateTime(2026, 6, 1),
      );

      expect(sub.sharePerMember(3), closeTo(500.0, 0.001));
      expect(sub.sharePerMember(0), 1500.0);
    });

    test('toCreateJson omits server-derived fields', () {
      final sub = SubscriptionModel(
        id: 0,
        groupId: 7,
        recipientId: 99,
        organizerId: 99,
        name: 'Netflix',
        amountCents: 150000,
        currency: Currency.kes,
        schedule: SubscriptionSchedule.monthly,
        graceHours: 48,
        status: SubscriptionStatus.active,
        startDate: DateTime(2026, 7, 1),
        createdAt: DateTime(2026, 6, 1),
        updatedAt: DateTime(2026, 6, 1),
      );

      final json = sub.toCreateJson();
      expect(json.containsKey('recipientId'), isFalse);
      expect(json.containsKey('organizerId'), isFalse);
      expect(json.containsKey('currency'), isFalse);
      expect(json['groupId'], 7);
      expect(json['amountCents'], 150000);
      expect(json['schedule'], 'MONTHLY');
    });
  });
}
