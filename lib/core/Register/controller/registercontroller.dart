import 'package:LedgerPro_app/core/dashboard/Screens/dashbaord_screen.dart';
import 'package:LedgerPro_app/core/plans/controllers/subscription_controller.dart';
import 'package:LedgerPro_app/core/plans/views/Subscription_plans.dart';
import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/Utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/apiconfig.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var isLoggedIn = false.obs;
  var user = Rxn<Map<String, dynamic>>();

  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController countryController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  
  // New controllers for address and organization name
  late TextEditingController addressController;
  late TextEditingController organizationNameController;

  var isPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;
  var agreeToTerms = false.obs;
  var currentStep = 0.obs;
  var passwordStrength = 0.0.obs;
  var passwordStrengthText = ''.obs;
  var passwordStrengthColor = Colors.red.obs;

  final List<String> countries = [
    'Pakistan', 'United States', 'United Kingdom', 'Canada',
    'Australia', 'India', 'Bangladesh', 'Sri Lanka', 'Nepal', 'UAE',
    'Saudi Arabia', 'Oman', 'Qatar', 'Kuwait', 'Bahrain',
    'Malaysia', 'Singapore', 'Indonesia', 'Turkey', 'Egypt',
  ];

  final String baseUrl = Apiconfig().baseUrl;

  var firstName = ''.obs;
  var lastName = ''.obs;
  var email = ''.obs;
  var phone = ''.obs;
  var country = ''.obs;
  var password = ''.obs;
  var confirmPassword = ''.obs;
  var address = ''.obs;           // New
  var organizationName = ''.obs;  // New

  @override
  void onInit() {
    super.onInit();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    countryController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    addressController = TextEditingController();              // New
    organizationNameController = TextEditingController();     // New

    firstNameController.addListener(() => firstName.value = firstNameController.text);
    lastNameController.addListener(() => lastName.value = lastNameController.text);
    emailController.addListener(() => email.value = emailController.text);
    phoneController.addListener(() => phone.value = phoneController.text);
    countryController.addListener(() => country.value = countryController.text);
    passwordController.addListener(() {
      password.value = passwordController.text;
      checkPasswordStrength(passwordController.text);
    });
    confirmPasswordController.addListener(() => confirmPassword.value = confirmPasswordController.text);
    addressController.addListener(() => address.value = addressController.text);                 // New
    organizationNameController.addListener(() => organizationName.value = organizationNameController.text); // New

    checkLoginStatus();
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    countryController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    addressController.dispose();           // New
    organizationNameController.dispose();  // New
    super.onClose();
  }

  Future<void> checkLoginStatus() async {
    final token = await _getToken();
    if (token != null && token.isNotEmpty) {
      await getCurrentUser();
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _saveAuthData(String token, Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_data', json.encode(userData));
    user.value = userData;
    isLoggedIn.value = true;
  }

  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    user.value = null;
    isLoggedIn.value = false;
  }

  Future<bool> register() async {
    print("🚀 Register function started at step: ${currentStep.value}");

    if (currentStep.value == 0) {
      if (firstNameController.text.trim().isEmpty) {
        AppSnackbar.error(kDanger, 'Error', 'Please enter first name');
        return false;
      }
      if (lastNameController.text.trim().isEmpty) {
        AppSnackbar.error(kDanger, 'Error', 'Please enter last name');
        return false;
      }
      if (countryController.text.trim().isEmpty) {
        AppSnackbar.error(kDanger, 'Error', 'Please select country');
        return false;
      }
      currentStep.value = 1;
      return true;
    }

    if (currentStep.value == 1) {
      if (phoneController.text.trim().isEmpty) {
        AppSnackbar.error(kDanger, 'Error', 'Please enter phone number');
        return false;
      }
      if (emailController.text.trim().isEmpty || !emailController.text.contains('@')) {
        AppSnackbar.error(kDanger, 'Error', 'Please enter valid email');
        return false;
      }
      
      if (!agreeToTerms.value) {
        AppSnackbar.error(kDanger, 'Error', 'Please agree to terms and conditions');
        return false;
      }
      currentStep.value = 2;
      return true;
    }

    if (currentStep.value == 2) {
      if (passwordController.text.length < 6) {
        AppSnackbar.error(kDanger, 'Error', 'Password must be at least 6 characters');
        return false;
      }
      if (passwordController.text != confirmPasswordController.text) {
        AppSnackbar.error(kDanger, 'Error', 'Passwords do not match');
        return false;
      }

      isLoading.value = true;

      try {
        final response = await http.post(
          Uri.parse('$baseUrl/api/users/register'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'firstName': firstNameController.text.trim(),
            'lastName': lastNameController.text.trim(),
            'email': emailController.text.trim(),
            'password': passwordController.text,
            'country': countryController.text.trim(),
            'phone': phoneController.text.trim(),
            'address': addressController.text.trim(),
            'organizationName': organizationNameController.text.trim(),
          }),
        );

        final data = json.decode(response.body);

        if (response.statusCode == 201) {
          print("✅ Registration successful");

          await _saveAuthData(data['token'], data['user']);

          // Store company name separately in SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          if (data['user']['organizationName'] != null && data['user']['organizationName'].isNotEmpty) {
            print("Company Name in: ${data['user']['organizationName']}");
            await prefs.setString('company_name', data['user']['organizationName']);
            print("Company Name: ${data['user']['organizationName']}");
            print("✅ Company name saved: ${data['user']['organizationName']}");
          }
          
          // Also store address if needed
          if (data['user']['address'] != null && data['user']['address'].isNotEmpty) {
            await prefs.setString('company_address', data['user']['address']);
          }

          final subscriptionController = Get.find<SubscriptionController>();
          subscriptionController.updateFromUserData(data['user']);

          currentStep.value = 3;
          AppSnackbar.success(kSuccess, 'Success', 'Account created successfully!');

          if (subscriptionController.hasAccess) {
            Get.offAll(() => const DashboardScreen());
          } else {
            Get.offAll(() => const SelectPlanScreen());
          }

          return true;
        } else {
          AppSnackbar.error(kDanger, 'Error', data['message'] ?? 'Registration failed');
          return false;
        }
      } catch (e) {
        print('❌ Registration error: $e');
        AppSnackbar.error(kDanger, 'Error', 'Network error. Please try again.');
        return false;
      } finally {
        isLoading.value = false;
      }
    }

    return false;
  }

  Future<bool> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      AppSnackbar.error(kDanger, 'Error', 'Please enter email and password');
      return false;
    }

    isLoading.value = true;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email.trim(),
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        await _saveAuthData(data['token'], data['user']);

        final subscriptionController = Get.find<SubscriptionController>();
        subscriptionController.updateFromUserData(data['user']);

        AppSnackbar.success(kSuccess, 'Success', 'Login successful!');

        if (subscriptionController.hasAccess) {
          Get.offAll(() => const DashboardScreen());
        } else {
          Get.offAll(() => const SelectPlanScreen());
        }

        return true;
      } else {
        AppSnackbar.error(kDanger, 'Error', data['message'] ?? 'Login failed');
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      AppSnackbar.error(kDanger, 'Error', 'Network error. Please try again.');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getCurrentUser() async {
    try {
      final token = await _getToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('$baseUrl/api/users/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        user.value = data['user'];
        isLoggedIn.value = true;

        final subscriptionController = Get.find<SubscriptionController>();
        subscriptionController.updateFromUserData(data['user']);
      } else {
        await _clearAuthData();
      }
    } catch (e) {
      print('Get user error: $e');
    }
  }

  Future<void> logout() async {
    await _clearAuthData();
    Get.offAllNamed('/login');
    AppSnackbar.success(kWarning, 'Logged Out', 'You have been logged out successfully');
  }

  void checkPasswordStrength(String pwd) {
    double strength = 0;
    if (pwd.length >= 8) strength += 0.3;
    if (pwd.contains(RegExp(r'[A-Z]'))) strength += 0.2;
    if (pwd.contains(RegExp(r'[0-9]'))) strength += 0.2;
    if (pwd.contains(RegExp(r'[!@#\$%^&*]'))) strength += 0.3;
    strength = strength.clamp(0.0, 1.0);

    passwordStrength.value = strength;

    if (strength >= 0.7) {
      passwordStrengthText.value = 'Strong';
      passwordStrengthColor.value = Colors.green;
    } else if (strength >= 0.4) {
      passwordStrengthText.value = 'Medium';
      passwordStrengthColor.value = Colors.orange;
    } else {
      passwordStrengthText.value = 'Weak';
      passwordStrengthColor.value = Colors.red;
    }
  }

  void nextStep() {
    if (currentStep.value < 3) register();
  }

  void previousStep() {
    if (currentStep.value > 0) currentStep.value--;
  }

  void goToStep(int step) {
    if (step <= currentStep.value + 1) currentStep.value = step;
  }

  void resetForm() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    phoneController.clear();
    countryController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    addressController.clear();           // ✅ New
    organizationNameController.clear();  // ✅ New
    agreeToTerms.value = false;
    currentStep.value = 0;
    passwordStrength.value = 0;
    passwordStrengthText.value = '';
  }

  bool isStepActive(int step) => currentStep.value >= step;
  bool isStepDone(int step) => currentStep.value > step;

  IconData getStepIcon(int step) {
    if (isStepDone(step)) return Icons.check;
    switch (step) {
      case 0: return Icons.person_outline;
      case 1: return Icons.phone_outlined;
      case 2: return Icons.lock_outline;
      case 3: return Icons.check_circle_outline;
      default: return Icons.circle_outlined;
    }
  }

  Color getStepColor(int step) {
    if (isStepDone(step)) return const Color(0xFF1AB4F5);
    if (isStepActive(step)) return const Color(0xFF1AB4F5);
    return const Color(0xFF7A8FA6);
  }
}