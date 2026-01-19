  import 'package:flutter/material.dart';
  import 'action_button.dart';
  import 'status_pill.dart';

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
    final colors = Theme.of(context).colorScheme;
    Color pillColor = status == 'Paid' ? Colors.green : colors.error;
      return Card(

      color: colors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.black,
          width: 0.2,
        )
        ),
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
                          color: colors.primary
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
    
                 StatusPill(pillColor: pillColor, status: status)
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

