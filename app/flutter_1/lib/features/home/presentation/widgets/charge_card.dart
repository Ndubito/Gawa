import 'package:flutter/material.dart';
import 'action_button.dart';
import 'status_pill.dart';

class ChargeCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    Color pillColor = status == 'Paid' ? Colors.green : colors.error;
    return Card(
      color: colors.tertiary,
      elevation: 0.85, 
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
                          color: colors.primary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            dueDate,
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    StatusPill(pillColor: pillColor, status: status),

                    SizedBox(height: 25,),

                    if (status == 'Failed')
                      ActionButton(
                        text: 'Retry Payment',
                        onPressed: () {},
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
