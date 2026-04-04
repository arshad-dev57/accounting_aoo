import 'dart:convert';
import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/config/apiconfig.dart';
import 'package:LedgerPro_app/core/Expense/model/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class ExpenseController extends GetxController {
  // Observable variables
  var expenses = <Expense>[].obs;
  var vendors = <Map<String, dynamic>>[].obs;
  var bankAccounts = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var isLoadingMore = false.obs;
  var isProcessing = false.obs;
  var selectedFilter = 'All'.obs;
  var selectedType = 'All'.obs;
  var startDate = Rxn<DateTime>();
  var endDate = Rxn<DateTime>();
  var searchQuery = ''.obs;
  
  // Pagination
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var hasMore = true.obs;
  final int pageSize = 20;
  
  // Filter options
  final List<String> filterOptions = ['All', 'Draft', 'Posted', 'Cancelled'];
  final List<String> expenseTypes = [
    'All', 'Rent', 'Utilities', 'Salaries', 'Marketing', 
    'Office Supplies', 'Travel', 'Meals', 'Insurance',
    'Maintenance', 'Software', 'Taxes', 'Other'
  ];
  
  // Summary data
  var totalExpense = 0.0.obs;
  var totalTax = 0.0.obs;
  var totalCount = 0.obs;
  var thisMonthTotal = 0.0.obs;
  var thisWeekTotal = 0.0.obs;
  var byType = <String, double>{}.obs;
  
  // Text editing controller
  TextEditingController searchController = TextEditingController();
  final String baseUrl = Apiconfig().baseUrl;
  
  // Scroll controller for lazy loading
  final ScrollController scrollController = ScrollController();
  
  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    loadVendors();
    loadBankAccounts();
    loadExpenses();
    loadSummary();
    _setupScrollListener();
  }
  
  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }
  
  void _setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 100) {
        if (hasMore.value && !isLoadingMore.value) {
          loadMoreExpenses();
        }
      }
    });
  }
  
  void _onSearchChanged() {
    searchQuery.value = searchController.text;
    _resetAndReload();
  }
  
  void _resetAndReload() {
    currentPage.value = 1;
    expenses.clear();
    hasMore.value = true;
    loadExpenses();
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
  // ==================== LOAD EXPENSES WITH PAGINATION ====================
// ==================== LOAD EXPENSES WITH PAGINATION ====================
Future<void> loadExpenses() async {
  try {
    isLoading.value = true;
    
    // ✅ FIX: Convert all values to String
    Map<String, String> params = {};  // ← Change to String, String
    
    params['page'] = currentPage.value.toString();  // ← toString()
    params['limit'] = pageSize.toString();          // ← toString()
    
    if (selectedFilter.value != 'All') {
      params['status'] = selectedFilter.value;
    }
    if (selectedType.value != 'All') {
      params['expenseType'] = selectedType.value;
    }
    if (startDate.value != null && endDate.value != null) {
      params['startDate'] = DateFormat('yyyy-MM-dd').format(startDate.value!);
      params['endDate'] = DateFormat('yyyy-MM-dd').format(endDate.value!);
    }
    if (searchQuery.value.isNotEmpty) {
      params['search'] = searchQuery.value;
    }
    
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl/api/expenses').replace(queryParameters: params);
    final response = await http.get(uri, headers: headers);
    
    print("load expenses");
    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['success'] == true) {
        
        // ✅ Check if data is List
        if (responseData['data'] is List) {
          List<dynamic> expensesData = responseData['data'];
          expenses.value = expensesData.map((json) => Expense.fromJson(json)).toList();
          totalPages.value = responseData['pages'] ?? 1;
          hasMore.value = currentPage.value < totalPages.value;
        } else {
          // No data or empty
          expenses.clear();
          totalPages.value = 1;
          hasMore.value = false;
        }
      } else {
        _showError('Failed to load expenses');
      }
    }
  } catch (e, stackTrace) {
    print('Error loading expenses: $e');
    print('StackTrace: $stackTrace');
    _showError('Error loading expenses');
  } finally {
    isLoading.value = false;
  }
}  // ==================== LOAD MORE EXPENSES (LAZY LOADING) ====================
  // ==================== LOAD MORE EXPENSES (LAZY LOADING) ====================
Future<void> loadMoreExpenses() async {
  if (!hasMore.value || isLoadingMore.value) return;
  
  try {
    isLoadingMore.value = true;
    currentPage.value++;
    
    // ✅ FIX: Convert all values to String
    Map<String, String> params = {};  // ← Change to String, String
    
    params['page'] = currentPage.value.toString();  // ← toString()
    params['limit'] = pageSize.toString();          // ← toString()
    
    if (selectedFilter.value != 'All') {
      params['status'] = selectedFilter.value;
    }
    if (selectedType.value != 'All') {
      params['expenseType'] = selectedType.value;
    }
    if (startDate.value != null && endDate.value != null) {
      params['startDate'] = DateFormat('yyyy-MM-dd').format(startDate.value!);
      params['endDate'] = DateFormat('yyyy-MM-dd').format(endDate.value!);
    }
    if (searchQuery.value.isNotEmpty) {
      params['search'] = searchQuery.value;
    }
    
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl/api/expenses').replace(queryParameters: params);
    final response = await http.get(uri, headers: headers);
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['success'] == true) {
        if (responseData['data'] is List) {
          List<dynamic> expensesData = responseData['data'];
          List<Expense> newExpenses = expensesData.map((json) => Expense.fromJson(json)).toList();
          expenses.addAll(newExpenses);
          totalPages.value = responseData['pages'] ?? 1;
          hasMore.value = currentPage.value < totalPages.value;
        }
      }
    }
  } catch (e) {
    print('Error loading more expenses: $e');
  } finally {
    isLoadingMore.value = false;
  }
}
  // ==================== LOAD VENDORS ====================
  Future<void> loadVendors() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/accounts-payable/vendors'),
        headers: headers,
      );
      print("load vendors");
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          vendors.value = List<Map<String, dynamic>>.from(responseData['data']);
        }
      }
    } catch (e) {
      print('Error loading vendors: $e');
    }
  }
  
  // ==================== LOAD BANK ACCOUNTS ====================
  Future<void> loadBankAccounts() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/bank-accounts'),
        headers: headers,
      );
      print("load bank accounts");
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
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
  
  // ==================== LOAD SUMMARY ====================
  Future<void> loadSummary() async {
    try {
      Map<String, dynamic> params = {};
      if (startDate.value != null && endDate.value != null) {
        params['startDate'] = DateFormat('yyyy-MM-dd').format(startDate.value!);
        params['endDate'] = DateFormat('yyyy-MM-dd').format(endDate.value!);
      }
      
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl/api/expenses/summary').replace(queryParameters: params);
      final response = await http.get(uri, headers: headers);
      print("load summary");
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final data = responseData['data'];
          totalExpense.value = (data['totalExpense'] ?? 0).toDouble();
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
  
  // ==================== CREATE EXPENSE ====================
  Future<void> createExpense({
    required DateTime date,
    required String expenseType,
    required String? vendorId,
    required List<Map<String, dynamic>> items,
    required double? amount,
    required double taxRate,
    required String description,
    required String reference,
    required String paymentMethod,
    required String? bankAccountId,
  }) async {
    try {
      isProcessing.value = true;
      
      final Map<String, dynamic> expenseData = {
        'date': DateFormat('yyyy-MM-dd').format(date),
        'expenseType': expenseType,
        'vendorId': vendorId,
        'items': items,
        'amount': amount ?? 0,
        'taxRate': taxRate,
        'description': description,
        'reference': reference,
        'paymentMethod': paymentMethod,
        'bankAccountId': bankAccountId,
      };
      print(expenseData);
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/expenses'),
        headers: headers,
        body: json.encode(expenseData),
      );
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          Get.back();
          Get.snackbar(
            'Success',
            'Expense recorded successfully\nJournal entry created',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: kSuccess,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
          _resetAndReload();
          loadSummary();
        } else {
          _showError(responseData['message'] ?? 'Failed to create expense');
        }
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        _showError(errorData['message'] ?? 'Failed to create expense');
      }
    } catch (e) {
      print('Error creating expense: $e');
      _showError('Error creating expense');
    } finally {
      isProcessing.value = false;
    }
  }
  
  // ==================== DELETE EXPENSE ====================
  Future<void> deleteExpense(String id, String expenseNumber) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/api/expenses/$id'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'Expense $expenseNumber deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: kSuccess,
          colorText: Colors.white,
        );
        _resetAndReload();
        loadSummary();
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        _showError(errorData['message'] ?? 'Failed to delete expense');
      }
    } catch (e) {
      print('Error deleting expense: $e');
      _showError('Error deleting expense');
    }
  }
  
  // ==================== POST EXPENSE ====================
  Future<void> postExpense(String id) async {
    try {
      isProcessing.value = true;
      
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/expenses/$id/post'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'Expense posted successfully\nJournal entry created',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: kSuccess,
          colorText: Colors.white,
        );
        _resetAndReload();
        loadSummary();
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        _showError(errorData['message'] ?? 'Failed to post expense');
      }
    } catch (e) {
      print('Error posting expense: $e');
      _showError('Error posting expense');
    } finally {
      isProcessing.value = false;
    }
  }
  
  // ==================== FILTER METHODS ====================
  void applyFilter(String filter) {
    selectedFilter.value = filter;
    _resetAndReload();
  }
  
  void applyTypeFilter(String type) {
    selectedType.value = type;
    _resetAndReload();
  }
  
  void setDateRange(DateTime? start, DateTime? end) {
    startDate.value = start;
    endDate.value = end;
    _resetAndReload();
    loadSummary();
  }
  
  void clearDateRange() {
    startDate.value = null;
    endDate.value = null;
    _resetAndReload();
    loadSummary();
  }
  
  void clearFilters() {
    selectedFilter.value = 'All';
    selectedType.value = 'All';
    startDate.value = null;
    endDate.value = null;
    searchController.clear();
    searchQuery.value = '';
    _resetAndReload();
    loadSummary();
  }
  
  // ==================== EXPORT & PRINT ====================
  void exportExpenses() {
    Get.snackbar('Export', 'Exporting expenses to Excel...', 
        snackPosition: SnackPosition.BOTTOM, backgroundColor: kPrimary, colorText: Colors.white);
  }
  
  void printExpenses() {
    Get.snackbar('Print', 'Preparing expense report...', 
        snackPosition: SnackPosition.BOTTOM, backgroundColor: kPrimary, colorText: Colors.white);
  }
  
  // ==================== HELPER METHODS ====================
  String formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '₨ ${formatter.format(amount)}';
  }
  
  String getTypeColor(String type) {
    switch (type) {
      case 'Rent': return '#E74C3C';
      case 'Utilities': return '#3498DB';
      case 'Salaries': return '#2ECC71';
      case 'Marketing': return '#F1C40F';
      case 'Office Supplies': return '#9B59B6';
      case 'Travel': return '#E67E22';
      case 'Meals': return '#1ABC9C';
      case 'Insurance': return '#16A085';
      case 'Maintenance': return '#27AE60';
      case 'Software': return '#2980B9';
      case 'Taxes': return '#8E44AD';
      default: return '#7A8FA6';
    }
  }
  
  IconData getTypeIcon(String type) {
    switch (type) {
      case 'Rent': return Icons.home;
      case 'Utilities': return Icons.bolt;
      case 'Salaries': return Icons.people;
      case 'Marketing': return Icons.campaign;
      case 'Office Supplies': return Icons.inventory;
      case 'Travel': return Icons.flight;
      case 'Meals': return Icons.restaurant;
      case 'Insurance': return Icons.security;
      case 'Maintenance': return Icons.build;
      case 'Software': return Icons.computer;
      case 'Taxes': return Icons.receipt;
      default: return Icons.money_off;
    }
  }
  
  bool requiresItems(String expenseType) {
    return expenseType == 'Office Supplies' || expenseType == 'Travel' || expenseType == 'Meals';
  }
  
  void _showError(String message) {
    Get.snackbar('Error', message, 
        snackPosition: SnackPosition.BOTTOM, backgroundColor: kWarning, colorText: Colors.white);
  }
}