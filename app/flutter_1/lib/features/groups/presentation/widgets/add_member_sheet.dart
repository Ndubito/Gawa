import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_1/core/phone_number.dart';
import 'package:flutter_1/features/groups/presentation/cubits/group_members_cubit.dart';

/// Bottom sheet for adding a member by phone number.
/// Returns true through the Navigator when a member was added.
class AddMemberSheet extends StatefulWidget {
  const AddMemberSheet({super.key});

  @override
  State<AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends State<AddMemberSheet> {
  final _controller = TextEditingController();
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final phone = normalizeKenyanPhone(_controller.text);
    if (phone == null) {
      setState(() => _error = 'Enter a valid Kenyan number, e.g. 0712 345 678');
      return;
    }

    setState(() {
      _error = null;
      _saving = true;
    });

    try {
      await context.read<GroupMembersCubit>().addMember(phone);
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
      // keep the sheet above the keyboard
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add a member',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "They join right away — even before installing Gawa. "
            "Their account links up when they sign in with this number.",
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.phone,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: '0712 345 678',
              prefixIcon: const Icon(Icons.phone_outlined),
              errorText: _error,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
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
                  : const Icon(Icons.person_add_outlined),
              label: Text(_saving ? 'Adding...' : 'Add Member'),
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
    );
  }
}
