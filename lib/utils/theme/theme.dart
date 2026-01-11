import 'package:flutter/material.dart';

/// Global dark theme for the app
final ThemeData theme = ThemeData(
  useMaterial3: true, // Enable Material 3 styling

  // ---------------- APP BAR ----------------
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    elevation: 0.0,
    surfaceTintColor: Colors.black,
  ),

  // ---------------- GENERAL BRIGHTNESS ----------------
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    brightness: Brightness.dark,
    surface: Colors.black,
    onSurface: Colors.white,
    surfaceTint: Colors.black12,
    primary: Colors.white,
    onPrimary: Colors.black,
  ),

  // ---------------- NAVIGATION BAR ----------------
  navigationBarTheme: const NavigationBarThemeData(
    height: 55,
    indicatorColor: Colors.transparent,
    elevation: 5.0,
    labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
    backgroundColor: Colors.black,
    iconTheme: WidgetStatePropertyAll<IconThemeData>(
      IconThemeData(color: Colors.white, size: 30),
    ),
  ),

  // ---------------- ELEVATED BUTTON ----------------
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStatePropertyAll<Color>(Colors.white),
      foregroundColor: WidgetStatePropertyAll<Color>(Colors.black),
    ),
  ),

  // ---------------- OUTLINED BUTTON ----------------
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: BorderSide(color: Colors.transparent),
        ),
      ),
      backgroundColor: WidgetStatePropertyAll<Color>(const Color(0xff242424)),
      minimumSize: WidgetStatePropertyAll<Size>(Size.zero),
      padding: WidgetStatePropertyAll<EdgeInsets>(
        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      ),
    ),
  ),
);
