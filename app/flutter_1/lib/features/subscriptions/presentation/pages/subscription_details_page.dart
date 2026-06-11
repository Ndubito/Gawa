import 'package:flutter/material.dart';
import '../widgets/subscription_detail_header.dart';

class SubscriptionDetailsPage extends StatelessWidget {
  const SubscriptionDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: SingleChildScrollView(
            child: Column(
              children: [
            // Header
            const SizedBox(height: 20),
            SubscriptionDetailHeader(),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
              ),
              child:  Center(
                  child: Text("N",
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: colors.onPrimary))),
            ),
            const SizedBox(height: 16),
             Text(
              "Netflix Standard",
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: colors.onSurface),
            ),
            const SizedBox(height: 8),
            const Text(
              "1,200 ksh / month",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20)),
              child: const Text("Active",
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 40),

            // Content
            Container(
              padding: const EdgeInsets.all(24),
              decoration:  BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              constraints: const BoxConstraints(minHeight: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Text("Payment Method", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                   const SizedBox(height: 12),
                   Container(
                     padding: const EdgeInsets.all(16),
                     decoration: BoxDecoration(
                       color: Colors.white,
                       borderRadius: BorderRadius.circular(12),
                     ),
                     child: Row(
                       children:  [
                         Icon(Icons.credit_card, color: colors.primary),
                         SizedBox(width: 12),
                         Text("Visa ending in 4242"),
                         Spacer(),
                         Icon(Icons.chevron_right, color: Colors.grey),
                       ],
                     ),
                   ),

                   const SizedBox(height: 24),
                   const Text("Recent Charges", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                   _buildHistoryItem("Jan 15, 2024", "1,200 ksh", "Success"),
                   _buildHistoryItem("Dec 15, 2023", "1,200 ksh", "Success"),
                   _buildHistoryItem("Nov 15, 2023", "1,200 ksh", "Success"),

                   const SizedBox(height: 40),

                   Row(
                     children: [
                       Expanded(
                         child: OutlinedButton(
                           onPressed: (){},
                           style: OutlinedButton.styleFrom(
                             side: const BorderSide(color: Colors.red),
                             padding: const EdgeInsets.symmetric(vertical: 16),
                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                           ),
                           child: const Text("Cancel Plan", style: TextStyle(color: Colors.red)),
                         ),
                       ),
                       const SizedBox(width: 16),
                       Expanded(
                         child: ElevatedButton(
                           onPressed: (){},
                           style: ElevatedButton.styleFrom(
                             backgroundColor: Colors.orange,
                             padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                           ),
                           child: const Text("Pause", style: TextStyle(color: Colors.white)),
                         ),
                       ),
                     ],
                   )
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

  Widget _buildHistoryItem(String date, String amount, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
           Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
               Text(status, style: const TextStyle(color: Colors.green, fontSize: 12)),
             ],
           ),
           Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
