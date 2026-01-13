import 'package:flutter/material.dart';
import 'widgets/quick_action_card.dart';
import 'widgets/charge_card.dart';
import 'widgets/heading_text.dart';
import 'widgets/bottom_navigation.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: Stack(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      color: const Color(0xFFe8e9ed),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Hi, Nathan!",
                                style: TextStyle(
                                  color: const Color(0xFF2d3561),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Welcome to Gawa",
                                style: TextStyle(
                                  color: const Color(0xFF2d3561),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.notifications_outlined,
                              color:Color(0xFF2d3561),
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Main content
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      color: const Color(0xFFe8e9ed),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Next Charge Section
                          HeadingText(
                            text: 'Next Charge'
                          ),
                          const SizedBox(height: 12),

                          ChargeCard(
                            price: '20,000 ksh',
                            subscription: "Nathan's Allowance",
                            dueDate: 'April  24',
                            status: 'Paid',
                          ),

                          const SizedBox(height: 24),

                          // Action Required Section
                          HeadingText(
                            text: 'Action Required'
                          ),
                          const SizedBox(height: 12),
                          ChargeCard(
                            price: '200 ksh',
                            subscription: 'ICloud family',
                            dueDate: '21 June',
                            status: 'Failed',
                          ),

                          const SizedBox(height: 24),

                          // Quick Actions Section
                          HeadingText(
                            text: 'Quick Actions'
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              QuickActionCard(
                                icon: Icons.group_add_outlined,
                                label: 'Create group',
                                onTap: () {},
                              ),
                              QuickActionCard(
                                icon: Icons.shopping_bag_outlined,
                                label: 'Create New\nSubscription',
                                onTap: () {},
                              ),
                              QuickActionCard(
                                icon: Icons.person_add_outlined,
                                label: 'Invite a Member',
                                onTap: () {},
                              ),
                            ],
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

          // Floating Bottom Navigation
          BottomNavigation(),
        ],
      ),
    );
  }
}


  