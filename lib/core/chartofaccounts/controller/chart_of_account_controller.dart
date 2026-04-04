  import 'dart:ui';

  import 'package:LedgerPro_app/config/apiconfig.dart';
  import 'package:flutter/material.dart';
  import 'package:get/get.dart';
  import 'package:http/http.dart' as http;
  import 'dart:convert';
  import 'package:shared_preferences/shared_preferences.dart';

  class ChartOfAccountController extends GetxController {
    var accounts = <Map<String, dynamic>>[].obs;
    var isLoading = true.obs;
    var selectedFilter = 'All'.obs;
    var searchQuery = ''.obs;
    
    // Summary totals
    var totalAssets = 0.0.obs;
    var totalLiabilities = 0.0.obs;
    var totalEquity = 0.0.obs;
    var totalIncome = 0.0.obs;
    var totalExpenses = 0.0.obs;
    
    // Base URL
    final String baseUrl = Apiconfig().baseUrl;
    
    // Token getter from shared_preferences
    String? _cachedToken;
    
    Future<String?> _getToken() async {
      try {
        if (_cachedToken != null) {
          return _cachedToken;
        }
        
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        _cachedToken = token;
        return token;
      } catch (e) {
        print('Error getting token: $e');
        return null;
      }
    }
    
    // Headers with token
    Future<Map<String, String>> _getHeaders() async {
      final token = await _getToken();
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    }
    
    @override
    void onInit() {
      super.onInit();
      fetchAccounts();
    }
    
    // Refresh token cache (call after login)
    Future<void> refreshToken() async {
      _cachedToken = null;
      await _getToken();
    }
    
    // Helper function to convert to double safely
    double _toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }
    
    // Fetch all accounts with filters
    Future<void> fetchAccounts() async {
      try {
        isLoading(true);
        
        String url = '$baseUrl/api/chart-of-accounts';
        List<String> queryParams = [];
        
        if (selectedFilter.value != 'All') {
          queryParams.add('type=${selectedFilter.value}');
        }
        
        if (searchQuery.value.isNotEmpty) {
          queryParams.add('search=${searchQuery.value}');
        }
        
        if (queryParams.isNotEmpty) {
          url += '?${queryParams.join('&')}';
        }
        
        final headers = await _getHeaders();
        final token = await _getToken();
        
        if (token == null || token.isEmpty) {
          Get.snackbar(
            'Authentication Error',
            'Please login again',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFE74C3C),
            colorText: Colors.white,
          );
          isLoading(false);
          return;
        }
        
        final response = await http.get(
          Uri.parse(url),
          headers: headers,
        );
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          
          if (data['success']) {
            accounts.value = List<Map<String, dynamic>>.from(data['data']);
            
            // Update summary totals with safe conversion
            if (data['summary'] != null) {
              totalAssets.value = _toDouble(data['summary']['Assets']);
              totalLiabilities.value = _toDouble(data['summary']['Liabilities']);
              totalEquity.value = _toDouble(data['summary']['Equity']);
              totalIncome.value = _toDouble(data['summary']['Income']);
              totalExpenses.value = _toDouble(data['summary']['Expenses']);
            } else {
              _calculateSummary();
            }
          }
        } else if (response.statusCode == 401) {
          Get.snackbar(
            'Session Expired',
            'Please login again',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFE74C3C),
            colorText: Colors.white,
          );
        } else {
          _handleError(response);
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to load accounts: $e');
      } finally {
        isLoading(false);
      }
    }
    
    // Create new account
    Future<void> createAccount(Map<String, dynamic> accountData) async {
      try {
        isLoading(true);
        
        final headers = await _getHeaders();
        final token = await _getToken();
        
        if (token == null || token.isEmpty) {
          Get.snackbar(
            'Authentication Error',
            'Please login again',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFE74C3C),
            colorText: Colors.white,
          );
          isLoading(false);
          return;
        }
        
        final response = await http.post(
          Uri.parse('$baseUrl/api/chart-of-accounts'),
          headers: headers,
          body: jsonEncode(accountData),
        );
        
        if (response.statusCode == 201) {
          final data = jsonDecode(response.body);
          if (data['success']) {
            Get.snackbar(
              'Success',
              'Account "${accountData['name']}" added successfully',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFF2ECC71),
              colorText: Colors.white,
            );
            await fetchAccounts(); // Refresh list
          }
        } else if (response.statusCode == 401) {
          Get.snackbar(
            'Session Expired',
            'Please login again',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFE74C3C),
            colorText: Colors.white,
          );
        } else {
          final data = jsonDecode(response.body);
          Get.snackbar(
            'Error',
            data['message'] ?? 'Failed to create account',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFE74C3C),
            colorText: Colors.white,
          );
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to create account: $e');
      } finally {
        isLoading(false);
      }
    }
    
    // Update account
    Future<void> updateAccount(String id, Map<String, dynamic> accountData) async {
      try {
        isLoading(true);
        
        final headers = await _getHeaders();
        final token = await _getToken();
        
        if (token == null || token.isEmpty) {
          Get.snackbar(
            'Authentication Error',
            'Please login again',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFE74C3C),
            colorText: Colors.white,
          );
          isLoading(false);
          return;
        }
        
        final response = await http.put(
          Uri.parse('$baseUrl/api/chart-of-accounts/$id'),
          headers: headers,
          body: jsonEncode(accountData),
        );
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success']) {
            Get.snackbar(
              'Success',
              'Account updated successfully',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFF2ECC71),
              colorText: Colors.white,
            );
            await fetchAccounts();
          }
        } else if (response.statusCode == 401) {
          Get.snackbar(
            'Session Expired',
            'Please login again',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFE74C3C),
            colorText: Colors.white,
          );
        } else {
          final data = jsonDecode(response.body);
          Get.snackbar(
            'Error',
            data['message'] ?? 'Failed to update account',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFE74C3C),
            colorText: Colors.white,
          );
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to update account: $e');
      } finally {
        isLoading(false);
      }
    }
    
    // Delete account
    Future<void> deleteAccount(String id, String accountName) async {
      try {
        final headers = await _getHeaders();
        final token = await _getToken();
        
        if (token == null || token.isEmpty) {
          Get.snackbar(
            'Authentication Error',
            'Please login again',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFE74C3C),
            colorText: Colors.white,
          );
          return;
        }
        
        final response = await http.delete(
          Uri.parse('$baseUrl/api/chart-of-accounts/$id'),
          headers: headers,
        );
        
        if (response.statusCode == 200) {
          Get.snackbar(
            'Success',
            'Account "$accountName" deleted successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF2ECC71),
            colorText: Colors.white,
          );
          await fetchAccounts();
        } else if (response.statusCode == 401) {
          Get.snackbar(
            'Session Expired',
            'Please login again',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFE74C3C),
            colorText: Colors.white,
          );
        } else {
          final data = jsonDecode(response.body);
          Get.snackbar(
            'Error',
            data['message'] ?? 'Failed to delete account',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFE74C3C),
            colorText: Colors.white,
          );
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to delete account: $e');
      }
    }
    
    // Create default accounts
    Future<void> createDefaultAccounts() async {
      try {
        isLoading(true);
        
        final headers = await _getHeaders();
        final token = await _getToken();
        
        if (token == null || token.isEmpty) {
          Get.snackbar(
            'Authentication Error',
            'Please login again',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFE74C3C),
            colorText: Colors.white,
          );
          isLoading(false);
          return;
        }
        
        final response = await http.post(
          Uri.parse('$baseUrl/api/chart-of-accounts/default'),
          headers: headers,
        );
        
        if (response.statusCode == 201) {
          final data = jsonDecode(response.body);
          if (data['success']) {
            Get.snackbar(
              'Success',
              data['message'] ?? 'Default accounts created',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFF2ECC71),
              colorText: Colors.white,
            );
            await fetchAccounts();
          }
        } else if (response.statusCode == 401) {
          Get.snackbar(
            'Session Expired',
            'Please login again',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFE74C3C),
            colorText: Colors.white,
          );
        } else {
          final data = jsonDecode(response.body);
          Get.snackbar(
            'Error',
            data['message'] ?? 'Failed to create default accounts',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFE74C3C),
            colorText: Colors.white,
          );
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to create default accounts: $e');
      } finally {
        isLoading(false);
      }
    }
    
    // Change filter
    void changeFilter(String filter) {
      selectedFilter.value = filter;
      fetchAccounts();
    }
    
    // Search accounts
    void searchAccounts(String query) {
      searchQuery.value = query;
      fetchAccounts();
    }
    
    // Calculate summary from local data (fallback) with safe conversion
    void _calculateSummary() {
      totalAssets.value = accounts
          .where((a) => a['type'] == 'Assets')
          .fold(0.0, (sum, a) => sum + _toDouble(a['currentBalance'] ?? a['balance']));
      
      totalLiabilities.value = accounts
          .where((a) => a['type'] == 'Liabilities')
          .fold(0.0, (sum, a) => sum + _toDouble(a['currentBalance'] ?? a['balance']));
      
      totalEquity.value = accounts
          .where((a) => a['type'] == 'Equity')
          .fold(0.0, (sum, a) => sum + _toDouble(a['currentBalance'] ?? a['balance']));
      
      totalIncome.value = accounts
          .where((a) => a['type'] == 'Income')
          .fold(0.0, (sum, a) => sum + _toDouble(a['currentBalance'] ?? a['balance']));
      
      totalExpenses.value = accounts
          .where((a) => a['type'] == 'Expenses')
          .fold(0.0, (sum, a) => sum + _toDouble(a['currentBalance'] ?? a['balance']));
    }
    
    void _handleError(http.Response response) {
      try {
        final data = jsonDecode(response.body);
        Get.snackbar(
          'Error',
          data['message'] ?? 'Something went wrong',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE74C3C),
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Server error: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE74C3C),
          colorText: Colors.white,
        );
      }
    }
    
    // Helper: Map API account to UI format with safe conversion
    Map<String, dynamic> mapAccountToUI(Map<String, dynamic> apiAccount) {
      return {
        'id': apiAccount['_id'],
        'code': apiAccount['code'],
        'name': apiAccount['name'],
        'type': apiAccount['type'],
        'typeIcon': _getTypeIcon(apiAccount['type']),
        'typeColor': _getTypeColor(apiAccount['type']),
        'balance': _toDouble(apiAccount['currentBalance'] ?? apiAccount['openingBalance']),
        'balanceType': apiAccount['balanceType'] ?? 
            (apiAccount['type'] == 'Assets' || apiAccount['type'] == 'Expenses' ? 'Debit' : 'Credit'),
        'description': apiAccount['description'] ?? '',
        'isActive': apiAccount['isActive'] ?? true,
        'parentAccount': apiAccount['parentAccount'] ?? '',
        'taxCode': apiAccount['taxCode'] ?? 'N/A',
      };
    }
    
    IconData _getTypeIcon(String type) {
      switch (type) {
        case 'Assets': return Icons.account_balance;
        case 'Liabilities': return Icons.payment;
        case 'Equity': return Icons.account_balance_wallet;
        case 'Income': return Icons.trending_up;
        case 'Expenses': return Icons.trending_down;
        default: return Icons.account_balance;
      }
    }
    
    Color _getTypeColor(String type) {
      switch (type) {
        case 'Assets': return const Color(0xFF2ECC71);
        case 'Liabilities': return const Color(0xFFE74C3C);
        case 'Equity': return const Color(0xFF3498DB);
        case 'Income': return const Color(0xFF2ECC71);
        case 'Expenses': return const Color(0xFFE74C3C);
        default: return const Color(0xFF7A8FA6);
      }
    }
  }