import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final void Function()? onTap;
  final String text;

  const MyButton({super.key, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(25),
        decoration: BoxDecoration(
          //color of the button
          color: Theme.of(context).colorScheme.inversePrimary,

          //curve corners
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onPrimary),
          ),
        ),  
      ),
    );
  }
}
