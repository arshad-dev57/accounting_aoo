import 'package:accounting_app/core/BusinessSetup/Views/business_setup_view.dart';
import 'package:accounting_app/core/Onboarding/views/Onboarding_screen.dart';
import 'package:accounting_app/core/Register/Views/register_screen.dart';
import 'package:accounting_app/core/plans/views/Subscription_plans.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
       debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
       
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const OnboardingScreen(),
    );
  }
}
