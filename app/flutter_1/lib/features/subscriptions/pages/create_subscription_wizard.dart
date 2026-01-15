import 'package:flutter/material.dart';

class CreateSubscriptionWizard extends StatefulWidget {
  const CreateSubscriptionWizard({super.key});

  @override
  State<CreateSubscriptionWizard> createState() =>
      _CreateSubscriptionWizardState();
}

class _CreateSubscriptionWizardState extends State<CreateSubscriptionWizard> {
  int _currentStep = 0;
  final int _totalSteps = 5;

  final TextEditingController _payeeController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _frequency = 'Monthly';
  String _gracePeriod = '3 Days';

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      // Finish
      Navigator.pop(context);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildPayeeStep();
      case 1:
        return _buildAmountStep();
      case 2:
        return _buildScheduleStep();
      case 3:
        return _buildGracePeriodStep();
      case 4:
        return _buildConfirmStep();
      default:
        return Container();
    }
  }

  Widget _buildPayeeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Who are you paying?",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _payeeController,
          decoration: InputDecoration(
            hintText: "Search name, business or group...",
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        const Text("Suggested",
            style: TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 12),
        ListTile(
          leading: CircleAvatar(backgroundColor: Colors.red[100], child: const Text("N")),
          title: const Text("Netflix"),
          subtitle: const Text("Entertainment"),
          onTap: () {
            _payeeController.text = "Netflix";
          },
        ),
        ListTile(
          leading: CircleAvatar(backgroundColor: Colors.green[100], child: const Text("S")),
          title: const Text("Spotify"),
          subtitle: const Text("Music"),
          onTap: () {
            _payeeController.text = "Spotify";
          },
        ),
      ],
    );
  }

  Widget _buildAmountStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "How much?",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 32),
          decoration: const InputDecoration(
            prefixText: "KSH ",
            hintText: "0.00",
            border: InputBorder.none,
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "How often?",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: ['Weekly', 'Monthly', 'Yearly', 'Custom'].map((freq) {
            final isSelected = _frequency == freq;
            return ChoiceChip(
              label: Text(freq),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _frequency = freq;
                });
              },
              selectedColor: const Color(0xFF6c63ff),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

    Widget _buildGracePeriodStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Grace Period",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text("Time before retrying if payment fails.")
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _gracePeriod,
          items: ['None', '1 Day', '3 Days', '7 Days']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (val) {
             setState(() {
               _gracePeriod = val!;
             });
          },
          decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Confirm Subscription",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildSummaryRow("Payee", _payeeController.text),
              const Divider(),
              _buildSummaryRow("Amount", "KSH ${_amountController.text}"),
              const Divider(),
              _buildSummaryRow("Frequency", _frequency),
              const Divider(),
              _buildSummaryRow("Grace Period", _gracePeriod),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _prevStep,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
             mainAxisAlignment: MainAxisAlignment.center,
             children: List.generate(_totalSteps, (index) {
               return Container(
                 width: 8,
                 height: 8,
                 margin: const EdgeInsets.symmetric(horizontal: 4),
                 decoration: BoxDecoration(
                   shape: BoxShape.circle,
                   color: index <= _currentStep ? const Color(0xFF6c63ff) : Colors.grey[300],
                 ),
               );
             }),
        ),
        centerTitle: true,
        actions: [
            const SizedBox(width: 48), // Balance centering
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: SafeArea(
            child: Container(
              color: Color(0xFFe8e9ed),
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: SingleChildScrollView(child: _buildStepContent()),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                     child: SizedBox(
                         width: double.infinity,
                         height: 50,
                         child: ElevatedButton(
                             onPressed: _nextStep,
                             style: ElevatedButton.styleFrom(
                                 backgroundColor: const Color(0xFF6c63ff),
                                 shape: RoundedRectangleBorder(
                                     borderRadius: BorderRadius.circular(12)
                                 )
                             ),
                             child: Text(
                                 _currentStep == _totalSteps - 1 ? "Confirm" : "Next",
                                 style: const TextStyle(color: Colors.white, fontSize: 16),
                             ),
                         ),
                     ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
