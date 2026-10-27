import 'package:flutter/material.dart';
import 'package:flutter_1/core/money.dart';
import 'package:flutter_1/features/expenses/domain/entities/expense_model.dart';

/// One expense row, phrased from the signed-in user's point of view:
/// what they're owed if they paid, otherwise what they owe.
class ExpenseTile extends StatelessWidget {
  final ExpenseModel expense;
  final int currentUserId;

  /// Display name for a user id (members who left can't be resolved).
  final String Function(int userId) nameOf;

  /// Shown only to the payer.
  final VoidCallback? onDelete;

  const ExpenseTile({
    super.key,
    required this.expense,
    required this.currentUserId,
    required this.nameOf,
    this.onDelete,
  });

  static String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final local = date.toLocal();
    return '${months[local.month - 1]} ${local.day}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final paidByMe = expense.isPaidBy(currentUserId);
    final myShare = expense.amountOwedBy(currentUserId);
    final due = _formatDate(expense.dueAt);

    final String yourPart;
    final Color yourPartColor;
    if (paidByMe) {
      yourPart =
          "You're owed KES ${formatKesCents(expense.amountOwedToPayer)} • due $due";
      yourPartColor = Colors.green;
    } else if (myShare != null) {
      yourPart = 'You owe KES ${formatKesCents(myShare)} • due $due';
      yourPartColor = colors.inversePrimary;
    } else {
      yourPart = "You're not part of this one";
      yourPartColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.tertiary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  expense.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
              ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Colors.grey,
                  ),
                  tooltip: 'Delete expense',
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'KES ${formatKesCents(expense.totalAmountCents)} • paid by '
            '${paidByMe ? 'you' : nameOf(expense.payerId)} • '
            'split ${expense.splits.length} ways',
            style: TextStyle(fontSize: 14, color: colors.primary),
          ),
          const SizedBox(height: 4),
          Text(
            yourPart,
            style: TextStyle(
              fontSize: 13,
              color: yourPartColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
