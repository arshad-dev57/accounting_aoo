import 'package:LedgerPro_app/core/BusinessSetup/Views/business_setup_view.dart';
import 'package:LedgerPro_app/core/changepassword/screen/otp_screen.dart';
import 'package:LedgerPro_app/core/plans/controllers/subscription_controller.dart';
import 'package:LedgerPro_app/core/plans/views/Subscription_plans.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/apiconfig.dart';


class LoginController extends GetxController {
  var isLoading = false.obs;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  var isPasswordVisible = false.obs;
  var emailError = ''.obs;
  var passwordError = ''.obs;
  
  final String baseUrl = Apiconfig().baseUrl;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }
  
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
  
  void clearEmailError() {
    if (emailError.value.isNotEmpty) {
      emailError.value = '';
    }
  }

  void clearPasswordError() {
    if (passwordError.value.isNotEmpty) {
      passwordError.value = '';
    }
  }
  
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
  
  bool _validateForm() {
    bool isValid = true;
    
    if (emailController.text.trim().isEmpty) {
      emailError.value = 'Please enter email';
      isValid = false;
    } else if (!_isValidEmail(emailController.text.trim())) {
      emailError.value = 'Please enter a valid email';
      isValid = false;
    } else {
      emailError.value = '';
    }
    
    if (passwordController.text.isEmpty) {
      passwordError.value = 'Please enter password';
      isValid = false;
    } else if (passwordController.text.length < 6) {
      passwordError.value = 'Password must be at least 6 characters';
      isValid = false;
    } else {
      passwordError.value = '';
    }
    
    return isValid;
  }
  
  Future<bool> login() async {
    if (!_validateForm()) {
      return false;
    }
    
    isLoading.value = true;
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': emailController.text.trim(),
          'password': passwordController.text,
        }),
      );
      
      final data = json.decode(response.body);
      print(data);
      
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        
        // ✅ Save token and user data
        await prefs.setString('auth_token', data['token']);
        await prefs.setString('user_data', json.encode(data['user']));
        
        // ✅ Store company name in SharedPreferences
        if (data['user']['organizationName'] != null && data['user']['organizationName'].isNotEmpty) {
          await prefs.setString('company_name', data['user']['organizationName']);
          print("✅ Company name saved: ${data['user']['organizationName']}");
        } else {
          // If no company name, save empty string
          await prefs.setString('company_name', '');
        }
        
        // ✅ Store address if needed
        if (data['user']['address'] != null && data['user']['address'].isNotEmpty) {
          await prefs.setString('company_address', data['user']['address']);
          print("✅ Company address saved: ${data['user']['address']}");
        }
        
        // ✅ Store user full name
        if (data['user']['firstName'] != null && data['user']['lastName'] != null) {
          String fullName = "${data['user']['firstName']} ${data['user']['lastName']}";
          await prefs.setString('user_name', fullName);
        }
        
        // ✅ Store user email
        if (data['user']['email'] != null) {
          await prefs.setString('user_email', data['user']['email']);
        }
        
        final subscriptionController = Get.find<SubscriptionController>();
        await subscriptionController.checkSubscriptionStatus();
        
        Get.snackbar(
          'Success',
          'Login successful!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        
        // ✅ Redirect based on subscription status
        if (subscriptionController.hasAccess) {
          Get.offAll(() => const DashboardScreen());
        } else {
          Get.offAll(() => const SelectPlanScreen());
        }
        return true;
      } else {
        Get.snackbar(
          'Error',
          data['message'] ?? 'Invalid email or password',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      Get.snackbar(
        'Error',
        'Network error. Please check your connection.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  void forgotPassword() {
    Get.to(() => const OtpScreen());
  }
}