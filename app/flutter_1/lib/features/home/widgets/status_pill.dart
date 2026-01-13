import 'package:flutter/material.dart';

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.pillColor,
    required this.status,
  });

  final Color pillColor;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
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
         );
  }
}