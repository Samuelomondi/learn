import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
      background: Colors.grey.shade300,
      primary: Colors.grey.shade200,
      onPrimary: Colors.black,
      secondary: Colors.grey.shade700,
      inversePrimary: Colors.grey.shade700,
      ),
  textTheme: ThemeData.light().textTheme.apply(
    bodyColor: Colors.grey[900],
    displayColor: Colors.black,
  ),
  inputDecorationTheme: InputDecorationTheme(
    hintStyle: TextStyle(color: Colors.grey[600]), // Hint text color
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey[500]!), // Default border color
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey.shade800), // On focus
    ),
    labelStyle: TextStyle(color: Colors.grey[700]), // Floating label color
  ),
);