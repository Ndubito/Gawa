import 'package:flutter/material.dart';
import '../widgets/group_card.dart';
import '../../home/widgets/heading_text.dart';
import './group_details_page.dart';
import './create_group_page.dart';
import '../widgets/long_action_button.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Main content
                Container(
                  padding: const EdgeInsets.all(20),
                  color: const Color(0xFFe8e9ed),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Groups Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          HeadingText(text: 'Groups'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      LongActionButton(
                        buttonLabel: const Text("Create New Group"),
                        icon: const Icon(Icons.add),
                        onClick: () {
                           Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CreateGroupPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      GroupCard(
                        groupName: 'Family Netflix',
                        totalAmount: '1,500 ksh',
                        nextCharge: 'Jan 15',
                        memberCount: 4,
                        paidCount: 3,
                        pendingCount: 1,
                        memberAvatars: const ['N', 'M', 'D', 'S'],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const GroupDetailsPage(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 12),

                      GroupCard(
                        groupName: 'Office Spotify',
                        totalAmount: '800 ksh',
                        nextCharge: 'Jan 20',
                        memberCount: 5,
                        paidCount: 5,
                        pendingCount: 0,
                        memberAvatars: const ['J', 'A', 'K', 'L', 'M'],
                        onTap: () {},
                      ),

                      const SizedBox(height: 12),

                      GroupCard(
                        groupName: 'Gym Membership',
                        totalAmount: '3,200 ksh',
                        nextCharge: 'Jan 18',
                        memberCount: 3,
                        paidCount: 2,
                        pendingCount: 0,
                        failedCount: 1,
                        memberAvatars: const ['T', 'R', 'P'],
                        onTap: () {},
                      ),

                      const SizedBox(
                        height: 100,
                      ), // Space for floating nav bar
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
