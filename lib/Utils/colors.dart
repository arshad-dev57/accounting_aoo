import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Sab kuch CONSTANT hi rahega - Koi error nahi aayega
const Color kPrimary = Color(0xFF1AB4F5);
const Color kPrimaryDark = Color(0xFF0FA3E0);
const Color kSuccess = Color(0xFF2ECC71);
const Color kDanger = Color(0xFFE74C3C);
const Color kWarning = Color(0xFFF39C12);

// Light mode colors (CONSTANT)
const Color kBgLight = Color(0xFFF0F4F8);
const Color kCardBgLight = Colors.white;
const Color kTextLight = Color(0xFF1A1A2E);
const Color kSubTextLight = Color(0xFF7A8FA6);
const Color kBorderLight = Color(0xFFDDE4EE);

// Dark mode colors (CONSTANT)
const Color kBgDark = Color(0xFF121212);
const Color kCardBgDark = Color(0xFF1E1E1E);
const Color kTextDark = Colors.white;
const Color kSubTextDark = Colors.grey;
const Color kBorderDark = Color(0xFF424242);

// IMPORTANT: Ye getters hain, but screens mein kuch change nahi karna
// Sirf dark mode toggle karne par ye automatically change ho jayenge
Color get kBg => Get.isDarkMode ? kBgDark : kBgLight;
Color get kCardBg => Get.isDarkMode ? kCardBgDark : kCardBgLight;
Color get kText => Get.isDarkMode ? kTextDark : kTextLight;
Color get kSubText => Get.isDarkMode ? kSubTextDark : kSubTextLight;
Color get kBorder => Get.isDarkMode ? kBorderDark : kBorderLight;