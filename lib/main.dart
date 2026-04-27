import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/core/BusinessSetup/Views/business_setup_view.dart';
import 'package:LedgerPro_app/core/Onboarding/views/Onboarding_screen.dart';
import 'package:LedgerPro_app/core/Register/Views/register_screen.dart';
import 'package:LedgerPro_app/core/Splash/screen/splash_screen.dart';
import 'package:LedgerPro_app/core/dashboard/Screens/dashboard_screen_web.dart';
import 'package:LedgerPro_app/core/plans/controllers/subscription_controller.dart';
import 'package:LedgerPro_app/core/plans/views/Subscription_plans.dart';
import 'package:LedgerPro_app/core/plans/views/payment_cancel_screen.dart';
import 'package:LedgerPro_app/core/plans/views/payment_sucess_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class ThemeController extends GetxController {
  var isDarkMode = false.obs;

  void toggleDarkMode() {
    isDarkMode.value = !isDarkMode.value;
    print('Dark mode: ${isDarkMode.value}');
    if (isDarkMode.value) {
      Get.changeThemeMode(ThemeMode.dark);
    } else {
      Get.changeThemeMode(ThemeMode.light);
    }
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(SubscriptionController(), permanent: true);
  Get.put(ThemeController(), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'LedgerPro App',
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          themeMode: Get.find<ThemeController>().isDarkMode.value
              ? ThemeMode.dark
              : ThemeMode.light,

          // ✅ home hata ke initialRoute use karo
          initialRoute: '/',
          getPages: [
            GetPage(
              name: '/',
              page: () => WebDashboardScreen(),
            ),
            GetPage(
              name: '/payment-success',
              page: () => const PaymentSuccessScreen(),
            ),
            GetPage(
              name: '/payment-cancel',
              page: () => const PaymentCancelScreen(),
            ),
          ],
        );
      },
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      fontFamily: 'Poppins',
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1AB4F5),
        primary: const Color(0xFF1AB4F5),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: kBg,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Color(0xFF1AB4F5),
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1AB4F5),
          foregroundColor: Colors.white,
          minimumSize: Size(100.w, 6.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF1AB4F5), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE74C3C)),
        ),
        contentPadding:
            EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: Colors.black87),
        headlineMedium: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black87),
        titleLarge: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87),
        bodyLarge: TextStyle(fontSize: 14.sp, color: Colors.black87),
        bodyMedium: TextStyle(fontSize: 12.sp, color: Colors.black87),
        labelSmall:
            TextStyle(fontSize: 10.sp, color: Colors.black54),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      fontFamily: 'Poppins',
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1AB4F5),
        primary: const Color(0xFF1AB4F5),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Color(0xFF1AB4F5),
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1AB4F5),
          foregroundColor: Colors.white,
          minimumSize: Size(100.w, 6.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF1AB4F5), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE74C3C)),
        ),
        contentPadding:
            EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white),
        headlineMedium: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white),
        titleLarge: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white),
        bodyLarge: TextStyle(fontSize: 14.sp, color: Colors.white70),
        bodyMedium:
            TextStyle(fontSize: 12.sp, color: Colors.white70),
        labelSmall:
            TextStyle(fontSize: 10.sp, color: Colors.white60),
      ),
    );
  }
}