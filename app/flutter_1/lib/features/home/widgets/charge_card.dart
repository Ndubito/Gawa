  import 'package:flutter/material.dart';
  import 'action_button.dart';

  class ChargeCard extends StatelessWidget{
    final String price;
    final String subscription;
    final String dueDate;
    final String status;

    const ChargeCard({
      super.key,
      required this.price,
      required this.subscription,
      required this.dueDate,
      required this.status,
    });

  @override
  Widget build (BuildContext context){
    Color pillColor = status == 'Paid' ? Colors.green : Colors.red;
      return Card(

      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        price,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        subscription,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        dueDate,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
    
                 Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
    
                        decoration: BoxDecoration(
                          color: pillColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: pillColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      )
              ],
            ),
            const SizedBox(height: 12),
    
            if (status == 'Failed')
              ActionButton(text: 'Retry Payment', onPressed: () {}),
          ],
        ),
      ),
    );
  }
  }