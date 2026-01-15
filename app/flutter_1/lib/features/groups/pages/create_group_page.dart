import 'package:flutter/material.dart';
import 'package:flutter_1/features/groups/widgets/create_group_header.dart';
import '../widgets/long_action_button.dart';


class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _splitType = 'Equal';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Container(
            color: const Color(0xFFe8e9ed),
            child: Column(
              children: [
                CreateGroupHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Group Name
                        const Text(
                          'Group Name',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2d3561),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'e.g., Family Netflix',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Amount
                        const Text(
                          'Default Amount (ksh)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2d3561),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '0.00',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Split Type
                        const Text(
                          'Split Type',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2d3561),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _splitType,
                              isExpanded: true,
                              items: ['Equal', 'Percentage', 'Fixed Amount']
                                  .map((type) => DropdownMenuItem(
                                        value: type,
                                        child: Text(type),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _splitType = value!;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Invite Members (Placeholder)
                        const Text(
                          'Invite Members',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2d3561),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.withValues(alpha:0.3)),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.people_outline,
                                  size: 48, color: Colors.grey),
                              const SizedBox(height: 8),
                              const Text('No members added yet'),
                              TextButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.add),
                                label: const Text('Add Member'),
                              ),
                            ],
                          ),
                        ),
                         const SizedBox(height: 40),
                        
                         LongActionButton(
                          buttonLabel: const Text('Create Group'),
                          icon: const Icon(Icons.check),
                          onClick: () => Navigator.pop(context), // Placeholder action
                         ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
