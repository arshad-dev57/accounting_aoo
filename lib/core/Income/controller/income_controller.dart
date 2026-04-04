import 'dart:convert';
import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/config/apiconfig.dart';
import 'package:LedgerPro_app/core/Income/models/income_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class IncomeController extends GetxController {
  // Observable variables
  var incomes = <Income>[].obs;
  var customers = <Map<String, dynamic>>[].obs;
  var bankAccounts = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var isProcessing = false.obs;
  var selectedFilter = 'All'.obs;
  var selectedType = 'All'.obs;
  var startDate = Rxn<DateTime>();
  var endDate = Rxn<DateTime>();
  var searchQuery = ''.obs;
  
  final List<String> filterOptions = ['All', 'Draft', 'Posted', 'Cancelled'];
  final List<String> incomeTypes = [
    'All', 'Sales', 'Services', 'Interest Income', 
    'Rental Income', 'Dividend Income', 'Other Income'
  ];
  
  var totalIncome = 0.0.obs;
  var totalTax = 0.0.obs;
  var totalCount = 0.obs;
  var thisMonthTotal = 0.0.obs;
  var thisWeekTotal = 0.0.obs;
  var byType = <String, double>{}.obs;
  
  TextEditingController searchController = TextEditingController();
  final String baseUrl = Apiconfig().baseUrl;
  
  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    loadIncomes();
    loadCustomers();
    loadBankAccounts();
    loadSummary();
  }
  
  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }
  
  void _onSearchChanged() {
    searchQuery.value = searchController.text;
    loadIncomes();
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
  
  Future<void> loadIncomes() async {
    try {
      isLoading.value = true;
      
      Map<String, dynamic> params = {};
      if (selectedFilter.value != 'All') {
        params['status'] = selectedFilter.value;
      }
      if (selectedType.value != 'All') {
        params['incomeType'] = selectedType.value;
      }
      if (startDate.value != null && endDate.value != null) {
        params['startDate'] = DateFormat('yyyy-MM-dd').format(startDate.value!);
        params['endDate'] = DateFormat('yyyy-MM-dd').format(endDate.value!);
      }
      if (searchQuery.value.isNotEmpty) {
        params['search'] = searchQuery.value;
      }
      
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl/api/income').replace(queryParameters: params);
      final response = await http.get(uri, headers: headers);
      print("income body");
      print(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          List<dynamic> incomesData = responseData['data'];
          incomes.value = incomesData.map((json) => Income.fromJson(json)).toList();
        } else {
          _showError('Failed to load incomes');
        }
      }
    } catch (e) {
      print('Error loading incomes: $e');
      _showError('Error loading incomes');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> loadCustomers() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/customers'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          customers.value = List<Map<String, dynamic>>.from(responseData['data']);
        }
      }
    } catch (e) {
      print('Error loading customers: $e');
    }
  }
  
  Future<void> loadBankAccounts() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/bank-accounts'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          bankAccounts.value = List<Map<String, dynamic>>.from(responseData['data']);
        }
      }
    } catch (e) {
      print('Error loading bank accounts: $e');
    }
  }
  
  Future<void> loadSummary() async {
    try {
      Map<String, dynamic> params = {};
      if (startDate.value != null && endDate.value != null) {
        params['startDate'] = DateFormat('yyyy-MM-dd').format(startDate.value!);
        params['endDate'] = DateFormat('yyyy-MM-dd').format(endDate.value!);
      }
      
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl/api/income/summary').replace(queryParameters: params);
      final response = await http.get(uri, headers: headers);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final data = responseData['data'];
          totalIncome.value = (data['totalIncome'] ?? 0).toDouble();
          totalTax.value = (data['totalTax'] ?? 0).toDouble();
          totalCount.value = data['totalCount'] ?? 0;
          thisMonthTotal.value = (data['thisMonth'] ?? 0).toDouble();
          thisWeekTotal.value = (data['thisWeek'] ?? 0).toDouble();
          
          if (data['byType'] != null) {
            byType.clear();
            data['byType'].forEach((key, value) {
              byType[key] = (value ?? 0).toDouble();
            });
          }
        }
      }
    } catch (e) {
      print('Error loading summary: $e');
    }
  }
Future<void> createIncome({
  required DateTime date,
  required String incomeType,
  required String? customerId,
  required List<Map<String, dynamic>> items,
  required double? amount,        // ← Simple income ke liye
  required double taxRate,
  required String description,
  required String reference,
  required String paymentMethod,
  required String? bankAccountId,
}) async {
  try {
    isProcessing.value = true;
    
    final Map<String, dynamic> incomeData = {
      'date': DateFormat('yyyy-MM-dd').format(date),
      'incomeType': incomeType,
      'customerId': customerId,
      'items': items,
      'amount': amount ?? 0,         
      'taxRate': taxRate,
      'description': description,
      'reference': reference,
      'paymentMethod': paymentMethod,
      'bankAccountId': bankAccountId,
    };
    
    print("📦 Sending to backend:");
    print(json.encode(incomeData));
    
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/api/income'),
      headers: headers,
      body: json.encode(incomeData),
    );
    
    print("📡 Response Status: ${response.statusCode}");
    print("📨 Response Body: ${response.body}");
    
    if (response.statusCode == 201) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['success'] == true) {
        Get.back();
        Get.snackbar(
          'Success',
          'Income recorded successfully\nJournal entry created',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: kSuccess,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        loadIncomes();
        loadSummary();
      } else {
        _showError(responseData['message'] ?? 'Failed to create income');
      }
    } else {
      final Map<String, dynamic> errorData = json.decode(response.body);
      _showError(errorData['message'] ?? 'Failed to create income');
    }
  } catch (e) {
    print('Error creating income: $e');
    _showError('Error creating income');
  } finally {
    isProcessing.value = false;
  }
}  
  Future<void> deleteIncome(String id, String incomeNumber) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/api/income/$id'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'Income $incomeNumber deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: kSuccess,
          colorText: Colors.white,
        );
        loadIncomes();
        loadSummary();
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        _showError(errorData['message'] ?? 'Failed to delete income');
      }
    } catch (e) {
      print('Error deleting income: $e');
      _showError('Error deleting income');
    }
  }
  
  Future<void> postIncome(String id) async {
    try {
      isProcessing.value = true;
      
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/income/$id/post'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'Income posted successfully\nJournal entry created',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: kSuccess,
          colorText: Colors.white,
        );
        loadIncomes();
        loadSummary();
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        _showError(errorData['message'] ?? 'Failed to post income');
      }
    } catch (e) {
      print('Error posting income: $e');
      _showError('Error posting income');
    } finally {
      isProcessing.value = false;
    }
  }
  
  void applyFilter(String filter) {
    selectedFilter.value = filter;
    loadIncomes();
  }
  
  void applyTypeFilter(String type) {
    selectedType.value = type;
    loadIncomes();
  }
  
  void setDateRange(DateTime? start, DateTime? end) {
    startDate.value = start;
    endDate.value = end;
    loadIncomes();
    loadSummary();
  }
  
  void clearDateRange() {
    startDate.value = null;
    endDate.value = null;
    loadIncomes();
    loadSummary();
  }
  
  void clearFilters() {
    selectedFilter.value = 'All';
    selectedType.value = 'All';
    startDate.value = null;
    endDate.value = null;
    searchController.clear();
    searchQuery.value = '';
    loadIncomes();
    loadSummary();
  }
  
  void exportIncomes() {
    Get.snackbar('Export', 'Exporting incomes to Excel...', 
        snackPosition: SnackPosition.BOTTOM, backgroundColor: kPrimary, colorText: Colors.white);
  }
  
  void printIncomes() {
    Get.snackbar('Print', 'Preparing income report...', 
        snackPosition: SnackPosition.BOTTOM, backgroundColor: kPrimary, colorText: Colors.white);
  }
  
  String formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '₨ ${formatter.format(amount)}';
  }
  
  String getTypeColor(String type) {
    switch (type) {
      case 'Sales': return '#2ECC71';
      case 'Services': return '#3498DB';
      case 'Interest Income': return '#F1C40F';
      case 'Rental Income': return '#E67E22';
      case 'Dividend Income': return '#9B59B6';
      default: return '#7A8FA6';
    }
  }
  
  IconData getTypeIcon(String type) {
    switch (type) {
      case 'Sales': return Icons.shopping_cart;
      case 'Services': return Icons.handshake;
      case 'Interest Income': return Icons.trending_up;
      case 'Rental Income': return Icons.home_work;
      case 'Dividend Income': return Icons.attach_money;
      default: return Icons.receipt;
    }
  }
  
  void _showError(String message) {
    Get.snackbar('Error', message, 
        snackPosition: SnackPosition.BOTTOM, backgroundColor: kWarning, colorText: Colors.white);
  }
}