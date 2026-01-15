import 'package:flutter/material.dart';
import '../widgets/members_section.dart';
import '../../home/widgets/bottom_navigation.dart';
import '../widgets/group_details_header.dart';
import '../widgets/total_amount_card.dart';
import '../widgets/payout_destination.dart';
import '../widgets/billing_rules.dart';
import '../widgets/long_action_button.dart';

class GroupDetailsPage extends StatefulWidget {
  const GroupDetailsPage({super.key});

  @override
  State<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  bool rulesExpanded = false;
  bool memebersExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: SafeArea(
            child: Container(
              color: const Color(0xFFe8e9ed),
              child: Column(
                children: [
                  // Header
                  GroupDetailsHeader(),
      
                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
      
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Total Amount Card
                          TotalAmountCard(),
                          const SizedBox(height: 24),
      
                          // Members Section (Collapsible)
                          MembersSection(
                            membersExpanded: memebersExpanded,
                            onToggle: () {
                              setState(() {
                                memebersExpanded = !memebersExpanded;
                              });
                            },
                          ),
      
                          const SizedBox(height: 12),
      
                          // Payout Destination (Organizer View)
                          PayoutDestination(),
      
                          const SizedBox(height: 12),
      
                          // Billing Rules (Collapsible)
                          BillingRules(
                            rulesExpanded: rulesExpanded,
                            onToggle: () {
                              setState(() {
                                rulesExpanded = !rulesExpanded;
                              });
                            },
                          ),
                          const SizedBox(height: 24),
      
                          // Invite Member Button
                          LongActionButton(
                            icon: const Icon(Icons.person_add_outlined),
                            buttonLabel: Text('Invite Member'),
                            onClick: () {},
                          ),

                          SizedBox(height: 80,)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
