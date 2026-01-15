import 'package:flutter/material.dart';
import '../../home/widgets/heading_text.dart';
import '../widgets/subscription_card.dart';
import '../../groups/widgets/long_action_button.dart';
import 'create_subscription_wizard.dart'; // Will create this next
import 'subscription_details_page.dart'; // Will create this too

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Active', 'Paused', 'Failed'];

  // Mock data
  final List<Map<String, String>> _subscriptions = [
    {
      'title': 'Netflix Standard',
      'amount': '1,200 ksh',
      'frequency': 'Monthly',
      'nextDate': 'Feb 15',
      'status': 'Active',
    },
    {
      'title': 'Spotify Premium',
      'amount': '300 ksh',
      'frequency': 'Monthly',
      'nextDate': 'Feb 20',
      'status': 'Active',
    },
    {
      'title': 'Gym Membership',
      'amount': '5,000 ksh',
      'frequency': 'Monthly',
      'nextDate': 'Feb 01',
      'status': 'Paused',
    },
    {
      'title': 'iCloud Storage',
      'amount': '250 ksh',
      'frequency': 'Monthly',
      'nextDate': 'Jan 28',
      'status': 'Failed',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredSubs = _selectedFilter == 'All'
        ? _subscriptions
        : _subscriptions
            .where((s) => s['status'] == _selectedFilter)
            .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  color: const Color(0xFFe8e9ed),
                  constraints: const BoxConstraints(minHeight: 800), // Fill screen roughly
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          HeadingText(text: 'Subscriptions'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                       LongActionButton(
                        buttonLabel: const Text("New Subscription"),
                        icon: const Icon(Icons.add),
                        onClick: () {
                           Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CreateSubscriptionWizard(),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 20),

                      // Filters
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _filters.map((filter) {
                            final isSelected = _selectedFilter == filter;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(filter),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedFilter = filter;
                                    });
                                  }
                                },
                                selectedColor: const Color(0xFF6c63ff),
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black,
                                ),
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide.none,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // List
                      if (filteredSubs.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Column(
                              children: [
                                Icon(Icons.search_off,
                                    size: 48, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'No subscriptions found',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...filteredSubs.map((sub) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: SubscriptionCard(
                                title: sub['title']!,
                                amount: sub['amount']!,
                                frequency: sub['frequency']!,
                                nextDate: sub['nextDate']!,
                                status: sub['status']!,
                                onTap: () {
                                    Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SubscriptionDetailsPage(),
                                    ),
                                  );
                                },
                              ),
                            )),
                            
                      const SizedBox(height: 100),
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
