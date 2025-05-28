import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Colors.grey.shade900,
    primary: Colors.grey.shade800,
    onPrimary: Colors.white,
    secondary: Colors.grey.shade900,
    inversePrimary: Colors.grey.shade100,
  ),
  textTheme: ThemeData.light().textTheme.apply(
    bodyColor: Colors.grey[300],
    displayColor: Colors.white,
  ),
  inputDecorationTheme: InputDecorationTheme(
    hintStyle: TextStyle(color: Colors.grey[500]),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey[600]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white),
    ),
    labelStyle: TextStyle(color: Colors.grey[300]),
  ),
);