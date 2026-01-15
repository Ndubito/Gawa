import 'package:flutter/material.dart';

class TransactionDetailsPage extends StatelessWidget {
  const TransactionDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text("Transaction", style: TextStyle(color: Colors.white)),
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
               const SizedBox(height: 40),
               Container(
                 width: 80,
                 height: 80,
                 decoration: BoxDecoration(
                   color: Colors.green.withValues(alpha: 0.2),
                   shape: BoxShape.circle,
                 ),
                 child: const Icon(Icons.check, color: Colors.green, size: 40),
               ),
               const SizedBox(height: 24),
               const Text("- 1,200 ksh", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
               const Text("Netflix Standard", style: TextStyle(color: Colors.grey, fontSize: 18)),
               
               const SizedBox(height: 40),
               
               const SizedBox(height: 40),
               
               Container(
                 width: double.infinity,
                 padding: const EdgeInsets.all(24),
                 decoration: const BoxDecoration(
                   color: Color(0xFFe8e9ed),
                   borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                 ),
                   child: Column(
                     children: [
                        _buildDetailRow("Status", "Success"),
                        const Divider(),
                        _buildDetailRow("Date", "Jan 15, 2024, 10:30 AM"),
                        const Divider(),
                        _buildDetailRow("Payment Method", "Visa **** 4242"),
                         const Divider(),
                        _buildDetailRow("Reference", "TRX-893020002"),
                        
                         const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(onPressed: (){}, child: const Text("Report Issue")),
                        ),
                        const SizedBox(height: 40),
                     ],
                   ),
                 ),
            ], // outer Column children
          ), // outer Column
        ), // SingleChildScrollView
      ), // ConstrainedBox
    ), // Center
  ); // Scaffold
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2d3561))),
        ],
      ),
    );
  }
}
