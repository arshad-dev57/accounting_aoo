import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:LedgerPro_app/config/apiconfig.dart';

class BankReconciliationController extends GetxController {
  // State variables
  var bankAccounts = <BankAccountForRecon>[].obs;
  var selectedAccountId = ''.obs;
  var selectedAccount = Rx<BankAccountForRecon?>(null);
  var isLoading = true.obs;
  var isReconciling = false.obs;
  
  // Reconciliation data
  var statementBalance = 0.0.obs;
  var serviceCharge = 0.0.obs;
  var interestEarned = 0.0.obs;
  var transactions = <TransactionForRecon>[].obs;
  var clearedTransactionIds = <String>[].obs;
  
  // Calculated values
  var bookBalance = 0.0.obs;
  var adjustedBookBalance = 0.0.obs;
  var reconciledBalance = 0.0.obs;
  var difference = 0.0.obs;
  var isBalanced = false.obs;
  
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
  
  // Fetch bank accounts for dropdown
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
              .map((e) => BankAccountForRecon.fromJson(e))
              .toList();
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load bank accounts: $e');
    } finally {
      isLoading(false);
    }
  }
  
  // Fetch reconciliation data for selected account
  Future<void> fetchReconciliationData(String accountId) async {
    try {
      isLoading(true);
      
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/bank-reconciliation/$accountId'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          final accountData = data['data']['account'];
          selectedAccount.value = BankAccountForRecon(
            id: accountData['id'],
            name: accountData['name'],
            number: accountData['number'],
            balance: _toDouble(accountData['currentBalance']),
            openingBalance: _toDouble(accountData['openingBalance']),
            lastReconciled: accountData['lastReconciled'] != null 
                ? DateTime.parse(accountData['lastReconciled'])
                : null,
          );
          
          bookBalance.value = _toDouble(data['data']['bookBalance']);
          statementBalance.value = selectedAccount.value!.balance;
          
          transactions.value = (data['data']['transactions'] as List)
              .map((e) => TransactionForRecon.fromJson(e))
              .toList();
          
          clearedTransactionIds.clear();
          serviceCharge.value = 0;
          interestEarned.value = 0;
          
          _calculateBalances();
        }
      } else if (response.statusCode == 401) {
        _handleSessionExpired();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load reconciliation data: $e');
    } finally {
      isLoading(false);
    }
  }
  
  // Calculate all balances based on selections
  void _calculateBalances() {
    // Calculate uncleared amounts
    double unclearedDeposits = 0;
    double unclearedPayments = 0;
    
    for (var t in transactions) {
      if (!clearedTransactionIds.contains(t.id)) {
        if (t.type == 'Deposit') {
          unclearedDeposits += t.amount;
        } else {
          unclearedPayments += t.amount;
        }
      }
    }
    
    // Adjusted book balance
    adjustedBookBalance.value = bookBalance.value - serviceCharge.value + interestEarned.value;
    
    // Reconciled balance
    reconciledBalance.value = statementBalance.value - unclearedPayments + unclearedDeposits;
    
    // Difference
    difference.value = (adjustedBookBalance.value - reconciledBalance.value).abs();
    isBalanced.value = difference.value < 0.01;
  }
  
  // Update cleared transactions
  void toggleClearedTransaction(String transactionId) {
    if (clearedTransactionIds.contains(transactionId)) {
      clearedTransactionIds.remove(transactionId);
    } else {
      clearedTransactionIds.add(transactionId);
    }
    _calculateBalances();
  }
  
  // Update service charge
  void updateServiceCharge(double value) {
    serviceCharge.value = value;
    _calculateBalances();
  }
  
  // Update interest earned
  void updateInterestEarned(double value) {
    interestEarned.value = value;
    _calculateBalances();
  }
  
  // Reset reconciliation
  void resetReconciliation() {
    clearedTransactionIds.clear();
    serviceCharge.value = 0;
    interestEarned.value = 0;
    _calculateBalances();
  }
  
  // Complete reconciliation
  Future<void> completeReconciliation() async {
    if (!isBalanced.value) {
      Get.snackbar(
        'Cannot Complete',
        'Reconciliation is not balanced. Please check your entries.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: kDanger,
        colorText: Colors.white,
      );
      return;
    }
    
    try {
      isReconciling(true);
      
      final body = {
        'statementBalance': statementBalance.value,
        'serviceCharge': serviceCharge.value,
        'interestEarned': interestEarned.value,
        'clearedTransactionIds': clearedTransactionIds.toList(),
        'statementDate': DateTime.now().toIso8601String(),
      };
      
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/bank-reconciliation/${selectedAccount.value!.id}/complete'),
        headers: headers,
        body: jsonEncode(body),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Get.snackbar(
          'Success',
          data['message'] ?? 'Bank reconciliation completed successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: kSuccess,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        
        // Reset and go back
        selectedAccount.value = null;
        selectedAccountId.value = '';
        await fetchBankAccounts();
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar(
          'Error',
          errorData['message'] ?? 'Failed to complete reconciliation',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: kDanger,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to complete reconciliation: $e');
    } finally {
      isReconciling(false);
    }
  }
  
  // Select account
  void selectAccount(String accountId) {
    selectedAccountId.value = accountId;
    final account = bankAccounts.firstWhere((a) => a.id == accountId);
    selectedAccount.value = account;
    fetchReconciliationData(accountId);
  }
  
  // Clear selected account
  void clearSelectedAccount() {
    selectedAccount.value = null;
    selectedAccountId.value = '';
    transactions.clear();
    clearedTransactionIds.clear();
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

// Models
class BankAccountForRecon {
  final String id;
  final String name;
  final String number;
  final double balance;
  final double openingBalance;
  final DateTime? lastReconciled;
  
  BankAccountForRecon({
    required this.id,
    required this.name,
    required this.number,
    required this.balance,
    required this.openingBalance,
    this.lastReconciled,
  });
  
  factory BankAccountForRecon.fromJson(Map<String, dynamic> json) {
    return BankAccountForRecon(
      id: json['_id'],
      name: json['accountName'],
      number: json['accountNumber'],
      balance: (json['currentBalance'] ?? 0).toDouble(),
      openingBalance: (json['openingBalance'] ?? 0).toDouble(),
      lastReconciled: json['lastReconciled'] != null 
          ? DateTime.parse(json['lastReconciled'])
          : null,
    );
  }
}

class TransactionForRecon {
  final String id;
  final DateTime date;
  final String description;
  final String reference;
  final double amount;
  final String type;
  final bool isCleared;
  
  TransactionForRecon({
    required this.id,
    required this.date,
    required this.description,
    required this.reference,
    required this.amount,
    required this.type,
    required this.isCleared,
  });
  
  factory TransactionForRecon.fromJson(Map<String, dynamic> json) {
    return TransactionForRecon(
      id: json['id'],
      date: DateTime.parse(json['date']),
      description: json['description'],
      reference: json['reference'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      type: json['type'],
      isCleared: json['isCleared'] ?? false,
    );
  }
}