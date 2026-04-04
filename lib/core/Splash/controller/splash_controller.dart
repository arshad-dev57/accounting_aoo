import 'package:LedgerPro_app/core/Onboarding/views/Onboarding_screen.dart';
import 'package:LedgerPro_app/core/dashboard/Screens/dashbaord_screen.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    checkToken();
  }

  void checkToken() async {
    await Future.delayed(Duration(seconds: 3)); // Splash ka delay
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token != null && token.isNotEmpty) {
      Get.off(() => DashboardScreen()); // Token hai -> Dashboard
    } else {
      Get.off(() => OnboardingScreen()); // Token nahi -> Onboarding
    }
  }
}