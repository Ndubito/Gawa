import 'package:flutter/material.dart';
import '../../home/widgets/heading_text.dart';
import 'transaction_details_page.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                   constraints: const BoxConstraints(minHeight: 800),
                   decoration: const BoxDecoration(
                     color: Color(0xFFe8e9ed),
                   ),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                        HeadingText(text: "Activity"),
                        const SizedBox(height: 20),

                        _buildDateHeader("Today"),
                        _buildTransactionItem(context, "Netflix", "Paid", "- 1,200 ksh", Icons.check_circle, Colors.green),
                        _buildTransactionItem(context, "Gym Membership", "Failed", "- 3,200 ksh", Icons.error, Colors.red),
                        
                        _buildDateHeader("Yesterday"),
                         _buildTransactionItem(context, "Group Payout", "Received", "+ 15,000 ksh", Icons.arrow_downward, Colors.blue),

                        _buildDateHeader("Jan 10"),
                        _buildTransactionItem(context, "Spotify", "Paid", "- 300 ksh", Icons.check_circle, Colors.green),
                         _buildTransactionItem(context, "ICloud", "Paid", "- 250 ksh", Icons.check_circle, Colors.green),

                         const SizedBox(height: 100),
                     ],
                   ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, String title, String subtitle, String amount, IconData icon, Color iconColor) {
    return GestureDetector(
      onTap: () {
         Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const TransactionDetailsPage(),
            ),
          );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
           boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2d3561))),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
            Text(amount, style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 16,
              color: amount.startsWith('+') ? Colors.green : const Color(0xFF2d3561),
              )),
          ],
        ),
      ),
    );
  }
}
