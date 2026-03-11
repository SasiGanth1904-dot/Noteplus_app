import 'package:flutter/material.dart';

// Replace with actual Admin UIDs from Firebase Authentication
const List<String> adminUIDs = [
  "ADMIN_FIREBASE_UID_1",
  "ADMIN_FIREBASE_UID_2"
];

// NotePlus Color Palette
const Color primaryColor = Color(0xFFF79071); // Soft Orange/Peach
const Color accentColor = Color(0xFFFA7D82); // Coral Pink
const Color darkTextColor = Color(0xFF4A4A4A);
const Color lightTextColor = Color(0xFF9E9E9E);
const Color whiteBackground = Color(0xFFFFFFFF);

// Gradients
const LinearGradient mainGradient = LinearGradient(
  colors: [
    Color(0xFFFECCB1), // Light peach
    Color(0xFFFD9487), // Mid coral
    Color(0xFFFA608D), // Deep pinkish
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient fabGradient = LinearGradient(
  colors: [
    Color(0xFFFD9781),
    Color(0xFFFA628D),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const double defaultPadding = 16.0;
const double defaultRadius = 24.0;
