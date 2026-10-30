import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_1/features/obligations/presentation/cubits/obligations_cubit.dart';
import 'package:flutter_1/features/obligations/presentation/cubits/obligations_state.dart';
import 'package:flutter_1/features/obligations/presentation/widgets/home_bills_section.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/heading_text.dart';
import '../../../groups/presentation/pages/create_group_page.dart';
import '../../../groups/presentation/pages/groups_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<ObligationsCubit>();
    if (cubit.state is ObligationsInitial) cubit.loadBills();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hi, Nathan!",
                            style: TextStyle(
                              color: colors.onSurface,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Welcome to Gawa",
                            style: TextStyle(
                              color: colors.primary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.notifications_outlined,
                          color: colors.onSurface,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Owe/owed totals and what needs attention
                      const HomeBillsSection(),

                      const SizedBox(height: 20),

                      // Quick Actions Section
                      const HeadingText(text: 'Quick Actions'),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          QuickActionCard(
                            icon: Icons.group_add_outlined,
                            label: 'Create group',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CreateGroupPage(),
                                ),
                              );
                            },
                          ),
                          QuickActionCard(
                            icon: Icons.person_add_outlined,
                            label: 'Invite a Member',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const GroupsPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
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
