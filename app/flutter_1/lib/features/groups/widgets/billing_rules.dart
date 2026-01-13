import 'package:flutter/material.dart';
import './rule_item.dart';

class BillingRules extends StatelessWidget {
  final bool rulesExpanded;
  final VoidCallback onToggle;

  const BillingRules({
    super.key,
    required this.rulesExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Billing Rules',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1a1a2e),
                  ),
                ),
                Icon(
                  rulesExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.grey,
                ),
              ],
            ),
            if (rulesExpanded) ...[
              const SizedBox(height: 16),
              const RuleItem(label: 'Split Type', value: 'Equal Split'),
              const SizedBox(height: 12),
              const RuleItem(label: 'Billing Cycle', value: 'Monthly (15th)'),
              const SizedBox(height: 12),
              const RuleItem(label: 'Auto-collect', value: 'Enabled'),
            ],
          ],
        ),
      ),
    );
  }
}
