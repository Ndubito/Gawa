import 'package:flutter/material.dart';

class SubscriptionDetailsPage extends StatelessWidget {
  const SubscriptionDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text("Detail", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: SingleChildScrollView(
            child: Column(
              children: [
            // Header
            const SizedBox(height: 20),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red[100],
                shape: BoxShape.circle,
              ),
              child: const Center(
                  child: Text("N",
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.red))),
            ),
            const SizedBox(height: 16),
            const Text(
              "Netflix Standard",
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
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
              decoration: const BoxDecoration(
                color: Color(0xFFe8e9ed),
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
                       children: const [
                         Icon(Icons.credit_card, color: Colors.blue),
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
