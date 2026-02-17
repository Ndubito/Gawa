import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    primary: Colors.grey.shade500,
    secondary: Colors.grey.shade200,
    tertiary: Colors.white, 
    inversePrimary: Colors.grey.shade900,
  ),
  scaffoldBackgroundColor: const Color.fromARGB(255, 247, 247, 247),
);