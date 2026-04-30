import 'dart:convert';
import 'package:LedgerPro_app/Utils/toast_utils.dart';
import 'package:LedgerPro_app/core/login/screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/apiconfig.dart';

class ChangePasswordController extends GetxController {
  // Observable variables
  var isLoading = false.obs;
  var isOldPasswordVisible = false.obs;
  var isNewPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;
  
  // Form controllers
  late TextEditingController oldPasswordController;
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;
  
  // Error messages
  var oldPasswordError = ''.obs;
  var newPasswordError = ''.obs;
  var confirmPasswordError = ''.obs;
  
  final String baseUrl = Apiconfig().baseUrl;
  
  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
  }
  
  void _initializeControllers() {
    oldPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }
  
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  
  // Clear errors when typing
  void clearOldPasswordError() {
    if (oldPasswordError.value.isNotEmpty) {
      oldPasswordError.value = '';
    }
  }
  
  void clearNewPasswordError() {
    if (newPasswordError.value.isNotEmpty) {
      newPasswordError.value = '';
    }
  }
  
  void clearConfirmPasswordError() {
    if (confirmPasswordError.value.isNotEmpty) {
      confirmPasswordError.value = '';
    }
  }
  
  // Toggle password visibility
  void toggleOldPasswordVisibility() {
    isOldPasswordVisible.value = !isOldPasswordVisible.value;
  }
  
  void toggleNewPasswordVisibility() {
    isNewPasswordVisible.value = !isNewPasswordVisible.value;
  }
  
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }
  
  // Validate form
  bool _validateForm() {
    bool isValid = true;
    
    // Old password validation
    if (oldPasswordController.text.isEmpty) {
      oldPasswordError.value = 'Please enter current password';
      isValid = false;
    } else if (oldPasswordController.text.length < 6) {
      oldPasswordError.value = 'Password must be at least 6 characters';
      isValid = false;
    } else {
      oldPasswordError.value = '';
    }
    
    // New password validation
    if (newPasswordController.text.isEmpty) {
      newPasswordError.value = 'Please enter new password';
      isValid = false;
    } else if (newPasswordController.text.length < 6) {
      newPasswordError.value = 'Password must be at least 6 characters';
      isValid = false;
    } else if (newPasswordController.text == oldPasswordController.text) {
      newPasswordError.value = 'New password cannot be same as old password';
      isValid = false;
    } else {
      newPasswordError.value = '';
    }
    
    // Confirm password validation
    if (confirmPasswordController.text.isEmpty) {
      confirmPasswordError.value = 'Please confirm new password';
      isValid = false;
    } else if (confirmPasswordController.text != newPasswordController.text) {
      confirmPasswordError.value = 'Passwords do not match';
      isValid = false;
    } else {
      confirmPasswordError.value = '';
    }
    
    return isValid;
  }
  
  // Change password API call
  Future<void> changePassword() async {
    if (!_validateForm()) return;
    
    try {
      isLoading.value = true;
      
      final headers = await _getHeaders();
      final body = json.encode({
        'currentPassword': oldPasswordController.text,
        'newPassword': newPasswordController.text,
      });
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/users/change-password'),
        headers: headers,
        body: body,
      );
      
      print('Change Password Response Status: ${response.statusCode}');
      print('Change Password Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _showSuccess(data['message'] ?? 'Password changed successfully!');
        _clearForm();
        SharedPreferences prefs =await SharedPreferences.getInstance();
        await prefs.remove("auth_token");
      
        Get.offAll(LoginScreen());
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        _showError(data['message'] ?? 'Invalid current password');
      } else if (response.statusCode == 401) {
        _showError('Session expired. Please login again.');
        _redirectToLogin();
      } else {
        _showError('Failed to change password. Please try again.');
      }
    } catch (e) {
      print('Error changing password: $e');
      _showError('Network error. Please check your connection.');
    } finally {
      isLoading.value = false;
    }
  }
  
  void _clearForm() {
    oldPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    oldPasswordError.value = '';
    newPasswordError.value = '';
    confirmPasswordError.value = '';
  }
  
  void _showError(String message) {
    AppSnackbar.error(
      Colors.red,
      'Error',
      message,
      
      duration: const Duration(seconds: 3),
    );
  }
  
  void _showSuccess(String message) {
      AppSnackbar.success(
        Colors.green,
        'Success',
        message,
      duration: const Duration(seconds: 2),
    );
  }
  
  void _redirectToLogin() {
    Future.delayed(const Duration(seconds: 2), () {
      Get.offAllNamed('/login');
    });
  }
  
  @override
  void onClose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}