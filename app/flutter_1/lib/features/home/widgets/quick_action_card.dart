import 'package:flutter/material.dart';

class QuickActionCard extends StatelessWidget{

    final IconData icon;
    final String label;
    final VoidCallback onTap;
   
  const QuickActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

    @override
    Widget build(BuildContext context){
    return SizedBox(
      width: 105,
      height: 105,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: const Color(0xFF4a9fd8).withValues(alpha:0.12),
          highlightColor: const Color(0xFF4a9fd8).withValues(alpha:0.06),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),

                  child: Icon(icon, color: const Color(0xFF4a9fd8), size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2d3561),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }}