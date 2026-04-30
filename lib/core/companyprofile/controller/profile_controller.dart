import 'dart:convert';
import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/Utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/apiconfig.dart';

class ProfileController extends GetxController {
  // Observable variables
  var isLoading = false.obs;
  var isSaving = false.obs;
  var isEditing = false.obs;
  
  // Profile data
  var organizationName = ''.obs;
  var personName = ''.obs;
  var address = ''.obs;
  var email = ''.obs;
  var contactNo = ''.obs;
  var websiteLink = ''.obs;
  
  // Form controllers
  late TextEditingController orgNameController;
  late TextEditingController personNameController;
  late TextEditingController addressController;
  late TextEditingController emailController;
  late TextEditingController contactNoController;
  late TextEditingController websiteController;
  
  final String baseUrl = Apiconfig().baseUrl;
  
  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    loadProfile();
  }
  
  void _initializeControllers() {
    orgNameController = TextEditingController();
    personNameController = TextEditingController();
    addressController = TextEditingController();
    emailController = TextEditingController();
    contactNoController = TextEditingController();
    websiteController = TextEditingController();
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
  
  // Load profile from API
  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/profile'),
        headers: headers,
      );
      
      print('Profile API Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final profile = data['data'];
          
          organizationName.value = profile['organizationName'] ?? '';
          personName.value = profile['personName'] ?? '';
          address.value = profile['address'] ?? '';
          email.value = profile['email'] ?? '';
          contactNo.value = profile['contactNo'] ?? '';
          websiteLink.value = profile['websiteLink'] ?? '';
          
          // Update controllers
          orgNameController.text = organizationName.value;
          personNameController.text = personName.value;
          addressController.text = address.value;
          emailController.text = email.value;
          contactNoController.text = contactNo.value;
          websiteController.text = websiteLink.value;
        } else {
          _showError(data['message'] ?? 'Failed to load profile');
        }
      } else if (response.statusCode == 401) {
        _showError('Session expired. Please login again.');
        _redirectToLogin();
      } else if (response.statusCode == 403) {
        final data = json.decode(response.body);
        _showError(data['message'] ?? 'Subscription required');
      } else {
        _showError('Failed to load profile. Please try again.');
      }
    } catch (e) {
      print('Error loading profile: $e');
      _showError('Network error. Please check your connection.');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Save profile to API
  Future<void> saveProfile() async {
    try {
      isSaving.value = true;
      
      final headers = await _getHeaders();
      final body = json.encode({
        'organizationName': orgNameController.text.trim(),
        'personName': personNameController.text.trim(),
        'address': addressController.text.trim(),
        'email': emailController.text.trim(),
        'contactNo': contactNoController.text.trim(),
        'websiteLink': websiteController.text.trim(),
      });
      
      final response = await http.put(
        Uri.parse('$baseUrl/api/profile'),
        headers: headers,
        body: body,
      );
      
      print('Update Profile Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Update observable values
        organizationName.value = orgNameController.text.trim();
        personName.value = personNameController.text.trim();
        address.value = addressController.text.trim();
        email.value = emailController.text.trim();
        contactNo.value = contactNoController.text.trim();
        websiteLink.value = websiteController.text.trim();
        
        _showSuccess(data['message'] ?? 'Profile updated successfully!');
        toggleEdit(); // Exit edit mode
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        _showError(data['message'] ?? 'Invalid data');
      } else if (response.statusCode == 401) {
        _showError('Session expired. Please login again.');
        _redirectToLogin();
      } else if (response.statusCode == 403) {
        final data = json.decode(response.body);
        _showError(data['message'] ?? 'Subscription required');
      } else {
        _showError('Failed to update profile. Please try again.');
      }
    } catch (e) {
      print('Error saving profile: $e');
      _showError('Network error. Please check your connection.');
    } finally {
      isSaving.value = false;
    }
  }
  
  // Toggle edit mode
  void toggleEdit() {
    isEditing.value = !isEditing.value;
    if (!isEditing.value) {
      // Reset controllers to original values when canceling
      orgNameController.text = organizationName.value;
      personNameController.text = personName.value;
      addressController.text = address.value;
      emailController.text = email.value;
      contactNoController.text = contactNo.value;
      websiteController.text = websiteLink.value;
    }
  }
  
  // Validate form
  bool validateForm() {
    if (orgNameController.text.trim().isEmpty) {
      _showError('Please enter organization name');
      return false;
    }
    if (personNameController.text.trim().isEmpty) {
      _showError('Please enter person name');
      return false;
    }
    if (addressController.text.trim().isEmpty) {
      _showError('Please enter address');
      return false;
    }
    if (emailController.text.trim().isEmpty) {
      _showError('Please enter email');
      return false;
    }
    if (!emailController.text.contains('@') || !emailController.text.contains('.')) {
      _showError('Please enter a valid email');
      return false;
    }
    if (contactNoController.text.trim().isEmpty) {
      _showError('Please enter contact number');
      return false;
    }
    if (contactNoController.text.trim().length < 10) {
      _showError('Please enter a valid contact number');
      return false;
    }
    return true;
  }
  
  void _showError(String message) {
    AppSnackbar.error(
      kDanger,
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
    orgNameController.dispose();
    personNameController.dispose();
    addressController.dispose();
    emailController.dispose();
    contactNoController.dispose();
    websiteController.dispose();
    super.onClose();
  }
}