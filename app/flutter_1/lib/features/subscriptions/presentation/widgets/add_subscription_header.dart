import 'package:flutter/material.dart';

class AddSubscriptionHeader extends StatelessWidget {
  const AddSubscriptionHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon:  Icon(Icons.arrow_back, color: colors.onSurface),
        ),
        const SizedBox(width: 8),
         Expanded(
          child: Text(
            "Add a Subscription",
            style: TextStyle( 
              color: colors.onSurface,
              fontSize: 24,
            ),  
          ),
        ),
      ],
    );
  }
}