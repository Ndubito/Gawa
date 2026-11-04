import 'package:flutter/material.dart';
import 'package:flutter_1/features/groups/presentation/widgets/group_card.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _card({int? subscriptionCount}) => MaterialApp(
  home: Scaffold(
    body: GroupCard(
      groupName: 'Family Netflix',
      subscriptionCount: subscriptionCount,
      onTap: () {},
    ),
  ),
);

void main() {
  group('GroupCard', () {
    testWidgets('says there is no subscription only when that is known', (
      tester,
    ) async {
      await tester.pumpWidget(_card(subscriptionCount: 0));

      expect(find.text('No subscription yet'), findsOneWidget);
      expect(find.text('No upcoming charges'), findsOneWidget);
    });

    testWidgets('shows the real subscription count', (tester) async {
      await tester.pumpWidget(_card(subscriptionCount: 2));

      expect(find.text('2 subscriptions'), findsOneWidget);
      expect(find.text('No subscription yet'), findsNothing);
      expect(find.text('No upcoming charges'), findsNothing);
      expect(find.text('All paid ✓'), findsNothing);
    });

    testWidgets('shows no status while counts are still loading', (
      tester,
    ) async {
      await tester.pumpWidget(_card());

      expect(find.text('No subscription yet'), findsNothing);
      expect(find.text('No upcoming charges'), findsNothing);
    });
  });
}
