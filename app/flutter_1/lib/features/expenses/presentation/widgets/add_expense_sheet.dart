import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_1/features/expenses/presentation/cubits/group_expenses_cubit.dart';
import 'package:flutter_1/features/groups/domain/entities/group_member_model.dart';

/// Bottom sheet for logging something the signed-in user paid for and
/// splitting it equally. Returns true through the Navigator when saved.
class AddExpenseSheet extends StatefulWidget {
  /// Accepted members, including the owner and the signed-in user.
  final List<GroupMemberModel> members;
  final int currentUserId;

  const AddExpenseSheet({
    super.key,
    required this.members,
    required this.currentUserId,
  });

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  static const _dueOptions = [1, 3, 7, 14];

  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  late final Set<int> _participants = widget.members
      .map((m) => m.userId)
      .toSet();
  int _dueInDays = 3;
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());

    if (name.isEmpty) {
      setState(() => _error = 'What was it for?');
      return;
    }
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter an amount greater than 0');
      return;
    }
    if (!_participants.any((id) => id != widget.currentUserId)) {
      setState(() => _error = 'Pick at least one other person to split with');
      return;
    }

    setState(() {
      _error = null;
      _saving = true;
    });

    try {
      await context.read<GroupExpensesCubit>().createExpense(
        name: name,
        totalAmountCents: (amount * 100).round(),
        dueInDays: _dueInDays,
        participantIds: _participants.toList(),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add an expense',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Something you paid for. It's split equally and everyone "
              'else is reminded to pay you back.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.sentences,
              decoration: _fieldDecoration(
                hint: 'e.g. Dinner at Java',
                icon: Icons.receipt_long_outlined,
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: _fieldDecoration(
                hint: 'Total you paid',
                icon: Icons.payments_outlined,
                prefix: 'KES ',
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Pay me back within',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final days in _dueOptions)
                  ChoiceChip(
                    label: Text(days == 1 ? '1 day' : '$days days'),
                    selected: _dueInDays == days,
                    onSelected: (_) => setState(() => _dueInDays = days),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              'Split between',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            for (final member in widget.members)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                value: _participants.contains(member.userId),
                title: Text(
                  member.userId == widget.currentUserId
                      ? '${member.displayName} (you)'
                      : member.displayName,
                ),
                onChanged: (checked) => setState(() {
                  if (checked == true) {
                    _participants.add(member.userId);
                  } else {
                    _participants.remove(member.userId);
                  }
                }),
              ),

            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ],
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _submit,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(_saving ? 'Saving...' : 'Add expense'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.inversePrimary,
                  foregroundColor: colors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    String? prefix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      prefixText: prefix,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
