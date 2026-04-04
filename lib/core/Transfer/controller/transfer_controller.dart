import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:LedgerPro_app/config/apiconfig.dart';

class TransferController extends GetxController {
  var bankAccounts = <BankAccountForTransfer>[].obs;
  var fromAccountId = ''.obs;
  var toAccountId = ''.obs;
  var amount = 0.0.obs;
  var isLoading = true.obs;
  var isTransferring = false.obs;
  var selectedDate = DateTime.now().obs;
  var reference = ''.obs;
  var description = ''.obs;
  
  final String baseUrl = Apiconfig().baseUrl;
  String? _cachedToken;
  
  Future<String?> _getToken() async {
    try {
      if (_cachedToken != null) return _cachedToken;
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      _cachedToken = token;
      return token;
    } catch (e) {
      return null;
    }
  }
  
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
  
  @override
  void onInit() {
    super.onInit();
    fetchBankAccounts();
  }
  
  Future<void> fetchBankAccounts() async {
    try {
      isLoading(true);
      
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/bank-accounts'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          bankAccounts.value = (data['data'] as List)
              .map((e) => BankAccountForTransfer.fromJson(e))
              .toList();
        }
      } else if (response.statusCode == 401) {
        _handleSessionExpired();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load bank accounts: $e');
    } finally {
      isLoading(false);
    }
  }
  
  void setFromAccount(String accountId) {
    fromAccountId.value = accountId;
  }
  
  void setToAccount(String accountId) {
    toAccountId.value = accountId;
  }
  
  void setAmount(String value) {
    amount.value = double.tryParse(value) ?? 0.0;
  }
  
  void setDate(DateTime date) {
    selectedDate.value = date;
  }
  
  void setReference(String value) {
    reference.value = value;
  }
  
  void setDescription(String value) {
    description.value = value;
  }
  
  BankAccountForTransfer? getFromAccount() {
    try {
      return bankAccounts.firstWhere((a) => a.id == fromAccountId.value);
    } catch (e) {
      return null;
    }
  }
  
  BankAccountForTransfer? getToAccount() {
    try {
      return bankAccounts.firstWhere((a) => a.id == toAccountId.value);
    } catch (e) {
      return null;
    }
  }
  
  bool get isAmountValid {
    final fromAccount = getFromAccount();
    if (fromAccount == null) return false;
    return amount.value > 0 && amount.value <= fromAccount.balance;
  }
  
  bool get canTransfer {
    return fromAccountId.value.isNotEmpty &&
           toAccountId.value.isNotEmpty &&
           fromAccountId.value != toAccountId.value &&
           isAmountValid;
  }
  
  Future<void> transfer() async {
    if (!canTransfer) {
      Get.snackbar(
        'Cannot Transfer',
        'Please check: From Account, To Account, and Amount',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: kDanger,
        colorText: Colors.white,
      );
      return;
    }
    
    try {
      isTransferring(true);
      
      final body = {
        'fromAccountId': fromAccountId.value,
        'toAccountId': toAccountId.value,
        'amount': amount.value,
        'date': selectedDate.value.toIso8601String(),
        'reference': reference.value,
        'description': description.value.isEmpty 
            ? 'Transfer from ${getFromAccount()?.name} to ${getToAccount()?.name}'
            : description.value,
      };
      
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/transfers'),
        headers: headers,
        body: jsonEncode(body),
      );
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        Get.snackbar(
          'Success',
          data['message'] ?? 'Transfer completed successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: kSuccess,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        
        // Reset form
        fromAccountId.value = '';
        toAccountId.value = '';
        amount.value = 0;
        reference.value = '';
        description.value = '';
        
        // Refresh accounts
        await fetchBankAccounts();
        
        // Go back
        Get.back();
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar(
          'Error',
          errorData['message'] ?? 'Transfer failed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: kDanger,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Transfer failed: $e');
    } finally {
      isTransferring(false);
    }
  }
  
  void resetForm() {
    fromAccountId.value = '';
    toAccountId.value = '';
    amount.value = 0;
    selectedDate.value = DateTime.now();
    reference.value = '';
    description.value = '';
  }
  
  void _handleSessionExpired() {
    Get.snackbar(
      'Session Expired',
      'Please login again',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: kDanger,
      colorText: Colors.white,
    );
  }
}

class BankAccountForTransfer {
  final String id;
  final String name;
  final String number;
  final double balance;
  final String currency;
  final String color;
  
  BankAccountForTransfer({
    required this.id,
    required this.name,
    required this.number,
    required this.balance,
    required this.currency,
    required this.color,
  });
  
  factory BankAccountForTransfer.fromJson(Map<String, dynamic> json) {
    return BankAccountForTransfer(
      id: json['_id'],
      name: json['accountName'],
      number: json['accountNumber'],
      balance: (json['currentBalance'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'PKR',
      color: json['color'] ?? '#1AB4F5',
    );
  }
}