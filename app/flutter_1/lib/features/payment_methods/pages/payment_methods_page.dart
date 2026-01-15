import 'package:flutter/material.dart';
import '../../home/widgets/heading_text.dart';
import 'add_mpesa_page.dart';
import 'add_card_page.dart';

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text("Payment Methods", style: TextStyle(color: Colors.white)),
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
                        const HeadingText(text: "Your Methods"),
                        const SizedBox(height: 20),
                        
                        _buildMethodCard(Icons.credit_card, "Visa ending in 4242", "Expires 12/26", true),
                        _buildMethodCard(Icons.phone_android, "M-Pesa (0712***789)", "Primary Method", false),

                        const SizedBox(height: 32),
                         const HeadingText(text: "Add New Method"),
                         const SizedBox(height: 16),
                         
                         ListTile(
                           leading: const Icon(Icons.phone_android, color: Colors.green),
                           title: const Text("M-Pesa"),
                           trailing: const Icon(Icons.chevron_right),
                           tileColor: Colors.white,
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                           onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (c) => const AddMpesaPage()));
                           },
                         ),
                         const SizedBox(height: 12),
                          ListTile(
                           leading: const Icon(Icons.credit_card, color: Colors.blue),
                           title: const Text("Credit / Debit Card"),
                           trailing: const Icon(Icons.chevron_right),
                           tileColor: Colors.white,
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                           onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (c) => const AddCardPage()));
                           },
                         ),
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

  Widget _buildMethodCard(IconData icon, String title, String subtitle, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isSelected ? Border.all(color: const Color(0xFF6c63ff), width: 2) : null,
      ),
      child: Row(
        children: [
           Icon(icon, size: 32, color: const Color(0xFF2d3561)),
           const SizedBox(width: 16),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                 Text(subtitle, style: const TextStyle(color: Colors.grey)),
               ],
             ),
           ),
           if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF6c63ff)),
           if(!isSelected) PopupMenuButton(itemBuilder: (context) => [
              const PopupMenuItem(child: Text("Set as Primary")),
              const PopupMenuItem(child: Text("Remove")),
           ])
        ],
      ),
    );
  }
}
