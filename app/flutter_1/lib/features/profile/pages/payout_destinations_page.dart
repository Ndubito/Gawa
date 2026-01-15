import 'package:flutter/material.dart';
import '../../home/widgets/heading_text.dart';

class PayoutDestinationsPage extends StatelessWidget {
  const PayoutDestinationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text("Payout Destinations", style: TextStyle(color: Colors.white)),
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
          child: Column(
            children: [
               Expanded(
                 child: Container(
                   width: double.infinity,
                   margin: const EdgeInsets.only(top: 20),
                   padding: const EdgeInsets.all(20),
                   decoration: const BoxDecoration(
                     color: Color(0xFFe8e9ed),
                     borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                   ),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                        const HeadingText(text: "Where you receive money"),
                        const SizedBox(height: 20),
                        
                        _buildDestinationCard("M-Pesa (0712***789)", "Verified", true),
                        _buildDestinationCard("KCB Bank (123***123)", "Verified", false),

                        const SizedBox(height: 32),
                         SizedBox(
                           width: double.infinity,
                           height: 50,
                           child: ElevatedButton.icon(
                             onPressed: (){},
                             icon: const Icon(Icons.add),
                             label: const Text("Add New Destination"),
                             style: ElevatedButton.styleFrom(
                               backgroundColor: const Color(0xFF2d3561),
                               foregroundColor: Colors.white,
                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                             ),
                           ),
                         )
                     ],
                   ),
                 ),
               )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDestinationCard(String title, String status, bool isPrimary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
           const Icon(Icons.account_balance_wallet, size: 32, color: Color(0xFF2d3561)),
           const SizedBox(width: 16),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                 Text(status, style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
               ],
             ),
           ),
           if (isPrimary) Container(
             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
             decoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.circular(8)),
             child: const Text("Primary", style: TextStyle(color: Colors.blue, fontSize: 12)),
           )
        ],
      ),
    );
  }
}
