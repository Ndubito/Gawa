import 'package:flutter/material.dart';

class AddMpesaPage extends StatelessWidget {
  const AddMpesaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Add M-Pesa"),
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
             TextField(
               keyboardType: TextInputType.phone,
               decoration: InputDecoration(
                 labelText: "Phone Number",
                 hintText: "0712 345 678",
                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                 filled: true,
                 fillColor: Colors.white,
               ),
             ),
             const SizedBox(height: 24),
              const Text(
               "You will receive an STK Push on your phone to verify this payment method.",
               style: TextStyle(color: Colors.grey),
               textAlign: TextAlign.center,
             ),
             const Spacer(),
             SizedBox(
               width: double.infinity,
               height: 50,
               child: ElevatedButton(
                 onPressed: () => Navigator.pop(context),
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.green,
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                 ),
                 child: const Text("Authorize", style: TextStyle(color: Colors.white, fontSize: 16)),
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
