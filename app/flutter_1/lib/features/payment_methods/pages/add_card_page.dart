import 'package:flutter/material.dart';

class AddCardPage extends StatelessWidget {
  const AddCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Add Card"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
          children: [
             Container(
               padding: const EdgeInsets.all(16),
               decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
               child: const Row(children: [
                 Icon(Icons.lock, size: 16, color: Colors.blue),
                 SizedBox(width: 8),
                 Text("Your card details are secure.", style: TextStyle(color: Colors.blue)),
               ]),
             ),
             const SizedBox(height: 24),
             TextField(
               decoration: InputDecoration(
                 labelText: "Card Number",
                 prefixIcon: const Icon(Icons.credit_card),
                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                 filled: true,
                 fillColor: Colors.white,
               ),
             ),
             const SizedBox(height: 16),
             Row(
               children: [
                 Expanded(
                   child: TextField(
                     decoration: InputDecoration(
                       labelText: "Expiry",
                       hintText: "MM/YY",
                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                       filled: true,
                       fillColor: Colors.white,
                     ),
                   ),
                 ),
                 const SizedBox(width: 16),
                 Expanded(
                   child: TextField(
                     decoration: InputDecoration(
                       labelText: "CVV",
                       hintText: "123",
                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                       filled: true,
                       fillColor: Colors.white,
                     ),
                   ),
                 ),
               ],
             ),
             const SizedBox(height: 16),
             TextField(
               decoration: InputDecoration(
                 labelText: "Cardholder Name",
                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                 filled: true,
                 fillColor: Colors.white,
               ),
             ),
             const SizedBox(height: 24),
              const Text(
               "By adding this card, you authorize recurring charges on due dates.",
               style: TextStyle(color: Colors.grey, fontSize: 12),
               textAlign: TextAlign.center,
             ),
             const Spacer(),
             SizedBox(
               width: double.infinity,
               height: 50,
               child: ElevatedButton(
                 onPressed: () => Navigator.pop(context),
                 style: ElevatedButton.styleFrom(
                   backgroundColor: const Color(0xFF2d3561),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                 ),
                 child: const Text("Save Card", style: TextStyle(color: Colors.white, fontSize: 16)),
               ),
             )
          ],
        ),
      ),
      ),
      ),
    );
  }
}
