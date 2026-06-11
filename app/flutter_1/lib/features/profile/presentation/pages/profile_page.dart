import 'package:flutter/material.dart';
import '../../../home/presentation/widgets/heading_text.dart';
import '../../../payment_methods/presentation/pages/payment_methods_page.dart';
import 'payout_destinations_page.dart';
import 'package:flutter_1/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final authCubit = context.read<AuthCubit>();

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
                  padding: const EdgeInsets.all(20),
                  decoration:  BoxDecoration(color: colors.surface),
                  constraints: const BoxConstraints(minHeight: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: colors.tertiary,
                            shape: BoxShape.circle,
                            border: Border.all(color: colors.tertiary, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child:  Center(
                            child: Text(
                              "N",
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: colors.inversePrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child:  Text(
                          "Nathan",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: colors.inversePrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "KYC Verified",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Settings List
                      const HeadingText(text: "Account Settings"),
                      const SizedBox(height: 20),

                      _buildSettingItem(
                        context,
                        Icons.credit_card,
                        "Payment Methods",
                        const PaymentMethodsPage(),
                      ),
                      _buildSettingItem(
                        context,
                        Icons.account_balance,
                        "Payout Destinations",
                        const PayoutDestinationsPage(),
                      ),
                      _buildSettingItem(
                        context,
                        Icons.notifications,
                        "Notifications",
                        null,
                      ),
                      _buildSettingItem(
                        context,
                        Icons.security,
                        "Security",
                        null,
                      ),

                      const SizedBox(height: 32),
                      const HeadingText(text: "Support"),
                      const SizedBox(height: 20),

                      _buildSettingItem(
                        context,
                        Icons.privacy_tip,
                        "Privacy Policy",
                        null,
                      ),
                      _buildSettingItem(
                        context,
                        Icons.help,
                        "Help & Support",
                        null,
                      ),

                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {authCubit.logout();},
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Log Out",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
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

  Widget _buildSettingItem(
    BuildContext context,
    IconData icon,
    String title,
    Widget? page,
  ) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colors.tertiary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: colors.inversePrimary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      contentPadding: EdgeInsets.zero,
      onTap: () {
        if (page != null) {
          Navigator.push(context, MaterialPageRoute(builder: (c) => page));
        }
      },
    );
  }
}
