import 'dart:convert';
import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/config/apiconfig.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class TransactionController extends GetxController {
  // Observable variables
  var transactions = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var isLoadingMore = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  
  // Filter variables
  var selectedTab = 0.obs; // 0 = All, 1 = Income, 2 = Expense
  var selectedPeriod = 'This Month'.obs;
  var selectedDateRange = Rxn<DateTimeRange>();
  var searchQuery = ''.obs;
  var selectedType = 'All'.obs;  // All, income, expense, receivable, payable, etc.
  
  // Summary data
  var totalIncome = 0.0.obs;
  var totalExpense = 0.0.obs;
  var totalReceivable = 0.0.obs;
  var totalPayable = 0.0.obs;
  var netCashFlow = 0.0.obs;
  
  // Pagination
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var hasMore = true.obs;
  final int pageSize = 10;
  
  // Text editing controller
  TextEditingController searchController = TextEditingController();
  
  // Scroll controller for lazy loading
  final ScrollController scrollController = ScrollController();
  
  // Categories
  var incomeCategories = <String>[].obs;
  var expenseCategories = <String>[].obs;
  var otherCategories = <String>[].obs;
  
  final List<String> periodOptions = [
    'Today',
    'This Week',
    'This Month',
    'This Quarter',
    'This Year',
    'Custom Range'
  ];
  
  final List<String> typeOptions = [
    'All',
    'Income',
    'Expense',
    'Receivable',
    'Payable',
    'Adjustment',
    'Financing',
    'Investment'
  ];
  
  final String baseUrl = Apiconfig().baseUrl;
  
  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    scrollController.addListener(_onScroll);
    loadCategories();
    loadTransactions();
  }
  
  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }
  
  void _onSearchChanged() {
    searchQuery.value = searchController.text;
    _resetAndReload();
  }
  
  void _onScroll() {
    if (scrollController.position.pixels >= 
        scrollController.position.maxScrollExtent - 100) {
      if (hasMore.value && !isLoadingMore.value) {
        loadMoreTransactions();
      }
    }
  }
  void _resetAndReload() {
  print("🔄 Resetting and reloading...");
  currentPage.value = 1;
  transactions.clear();
  hasMore.value = true;
  loadTransactions();
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
  
  Future<void> loadCategories() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/transactions/categories'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          incomeCategories.value = List<String>.from(data['data']['income']);
          expenseCategories.value = List<String>.from(data['data']['expense']);
          otherCategories.value = List<String>.from(data['data']['other'] ?? []);
        }
      }
    } catch (e) {
      print('Error loading categories: $e');
      // Fallback categories
      incomeCategories.value = ['Sales', 'Services', 'Consulting', 'Interest', 'Rental', 'Dividend', 'Other', 'Receipt'];
      expenseCategories.value = ['Rent', 'Salaries', 'Utilities', 'Office Supplies', 'Marketing', 'Travel', 'Meals', 'Software', 'Equipment', 'Payment', 'Other'];
      otherCategories.value = ['Sales', 'Purchase', 'Adjustment', 'Financing', 'Investment', 'Fixed Asset'];
    }
  }
  
  Future<void> loadTransactions() async {
  try {
    isLoading.value = true;
    hasError.value = false;
    
    Map<String, String> params = {
      'page': currentPage.value.toString(),
      'limit': pageSize.toString(),
    };
    
    // Add type filter (All, income, expense, receivable, etc.)
    if (selectedType.value != 'All') {
      params['type'] = selectedType.value.toLowerCase();
    }
    
    // ✅ DEBUG: Print selected period
    print("🔍 ========== LOAD TRANSACTIONS DEBUG ==========");
    print("📅 SELECTED PERIOD: ${selectedPeriod.value}");
    print("📅 SELECTED DATE RANGE: ${selectedDateRange.value}");
    print("📅 SEARCH QUERY: ${searchQuery.value}");
    print("📅 SELECTED TYPE: ${selectedType.value}");
    print("==========================================");
    
    // Add date range filter
    if (selectedDateRange.value != null) {
      params['startDate'] = DateFormat('yyyy-MM-dd').format(selectedDateRange.value!.start);
      params['endDate'] = DateFormat('yyyy-MM-dd').format(selectedDateRange.value!.end);
      print("📅 USING CUSTOM RANGE: ${params['startDate']} to ${params['endDate']}");
    } else {
      // Apply period filter
      final now = DateTime.now();
      print("📅 CURRENT DATE TIME: $now");
      
      switch (selectedPeriod.value) {
        case 'Today':
          params['startDate'] = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month, now.day));
          params['endDate'] = DateFormat('yyyy-MM-dd').format(now);
          print("📅 TODAY: ${params['startDate']} to ${params['endDate']}");
          break;
        case 'This Week':
          final start = now.subtract(Duration(days: now.weekday - 1));
          params['startDate'] = DateFormat('yyyy-MM-dd').format(DateTime(start.year, start.month, start.day));
          params['endDate'] = DateFormat('yyyy-MM-dd').format(now);
          print("📅 THIS WEEK: ${params['startDate']} to ${params['endDate']}");
          break;
        case 'This Month':
          params['startDate'] = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month, 1));
          params['endDate'] = DateFormat('yyyy-MM-dd').format(now);
          print("📅 THIS MONTH: ${params['startDate']} to ${params['endDate']}");
          break;
        case 'This Quarter':
          final quarter = (now.month - 1) ~/ 3;
          final startMonth = quarter * 3 + 1;
          params['startDate'] = DateFormat('yyyy-MM-dd').format(DateTime(now.year, startMonth, 1));
          params['endDate'] = DateFormat('yyyy-MM-dd').format(now);
          print("📅 THIS QUARTER: ${params['startDate']} to ${params['endDate']}");
          break;
        case 'This Year':
          params['startDate'] = DateFormat('yyyy-MM-dd').format(DateTime(now.year, 1, 1));
          params['endDate'] = DateFormat('yyyy-MM-dd').format(now);
          print("📅 THIS YEAR: ${params['startDate']} to ${params['endDate']}");
          break;
        default:
          print("⚠️ DEFAULT CASE - NO PERIOD SELECTED");
      }
    }
    
    // Add search filter
    if (searchQuery.value.isNotEmpty) {
      params['search'] = searchQuery.value;
    }
    
    print("📤 FINAL PARAMS SENT TO API: $params");
    
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl/api/transactions').replace(queryParameters: params);
    final response = await http.get(uri, headers: headers);
    
    print("🌐 FULL API URL: $uri");
    print("📡 Response Status Code: ${response.statusCode}");
    print("📡 Response Body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}");
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        transactions.value = List<Map<String, dynamic>>.from(data['data']);
        totalPages.value = data['pages'];
        hasMore.value = currentPage.value < totalPages.value;
        
        // Update summary
        totalIncome.value = (data['summary']['totalIncome'] ?? 0).toDouble();
        totalExpense.value = (data['summary']['totalExpense'] ?? 0).toDouble();
        totalReceivable.value = (data['summary']['totalReceivable'] ?? 0).toDouble();
        totalPayable.value = (data['summary']['totalPayable'] ?? 0).toDouble();
        netCashFlow.value = (data['summary']['netCashFlow'] ?? 0).toDouble();
        
        print("✅ Transactions loaded: ${transactions.length} records");
        print("✅ Total pages: $totalPages");
      }
    } else if (response.statusCode == 401) {
      hasError.value = true;
      errorMessage.value = 'Session expired. Please login again.';
      print("❌ Session expired");
    } else {
      hasError.value = true;
      errorMessage.value = 'Failed to load transactions';
      print("❌ Failed to load transactions: ${response.statusCode}");
    }
  } catch (e) {
    hasError.value = true;
    errorMessage.value = 'Network error: $e';
    print('🔥 Error loading transactions: $e');
  } finally {
    isLoading.value = false;
    print("🔍 ========== LOAD TRANSACTIONS END ==========\n");
  }
}
Future<void> loadMoreTransactions() async {
  if (!hasMore.value || isLoadingMore.value) return;
  
  try {
    isLoadingMore.value = true;
    currentPage.value++;
    
    print("🔄 Loading more transactions - Page: ${currentPage.value}");
    
    Map<String, String> params = {
      'page': currentPage.value.toString(),
      'limit': pageSize.toString(),
    };
    
    if (selectedType.value != 'All') {
      params['type'] = selectedType.value.toLowerCase();
    }
    
    if (selectedDateRange.value != null) {
      params['startDate'] = DateFormat('yyyy-MM-dd').format(selectedDateRange.value!.start);
      params['endDate'] = DateFormat('yyyy-MM-dd').format(selectedDateRange.value!.end);
    } else {
      final now = DateTime.now();
      switch (selectedPeriod.value) {
        case 'Today':
          params['startDate'] = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month, now.day));
          params['endDate'] = DateFormat('yyyy-MM-dd').format(now);
          break;
        case 'This Week':
          final start = now.subtract(Duration(days: now.weekday - 1));
          params['startDate'] = DateFormat('yyyy-MM-dd').format(DateTime(start.year, start.month, start.day));
          params['endDate'] = DateFormat('yyyy-MM-dd').format(now);
          break;
        case 'This Month':
          params['startDate'] = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month, 1));
          params['endDate'] = DateFormat('yyyy-MM-dd').format(now);
          break;
        case 'This Quarter':
          final quarter = (now.month - 1) ~/ 3;
          final startMonth = quarter * 3 + 1;
          params['startDate'] = DateFormat('yyyy-MM-dd').format(DateTime(now.year, startMonth, 1));
          params['endDate'] = DateFormat('yyyy-MM-dd').format(now);
          break;
        case 'This Year':
          params['startDate'] = DateFormat('yyyy-MM-dd').format(DateTime(now.year, 1, 1));
          params['endDate'] = DateFormat('yyyy-MM-dd').format(now);
          break;
      }
    }
    
    if (searchQuery.value.isNotEmpty) {
      params['search'] = searchQuery.value;
    }
    
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl/api/transactions').replace(queryParameters: params);
    final response = await http.get(uri, headers: headers);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        List<dynamic> newTransactions = data['data'];
        transactions.addAll(newTransactions.map((e) => e as Map<String, dynamic>).toList());
        hasMore.value = currentPage.value < data['pages'];
        print("✅ Loaded ${newTransactions.length} more transactions. Total: ${transactions.length}");
      }
    }
  } catch (e) {
    print('Error loading more transactions: $e');
  } finally {
    isLoadingMore.value = false;
  }
}  
  Future<void> createTransaction({
    required String type,
    required String title,
    required String description,
    required double amount,
    required DateTime date,
    required String category,
    required String paymentMethod,
    required String reference,
  }) async {
    try {
      isLoading.value = true;
      
      final Map<String, dynamic> transactionData = {
        'type': type,
        'title': title,
        'description': description,
        'amount': amount,
        'date': DateFormat('yyyy-MM-dd').format(date),
        'category': category,
        'paymentMethod': paymentMethod,
        'reference': reference,
      };
      
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/transactions'),
        headers: headers,
        body: json.encode(transactionData),
      );
      
      if (response.statusCode == 201) {
        Get.back();
        Get.snackbar(
          'Success',
          '${type == 'income' ? 'Income' : 'Expense'} recorded successfully\nJournal entry created',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: kSuccess,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        _resetAndReload();
      } else {
        final errorData = json.decode(response.body);
        Get.snackbar('Error', errorData['message'] ?? 'Failed to create transaction',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: kDanger, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create transaction: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: kDanger, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
  
  void changeTab(int index) {
    selectedTab.value = index;
    if (index == 0) {
      selectedType.value = 'All';
    } else if (index == 1) {
      selectedType.value = 'Income';
    } else if (index == 2) {
      selectedType.value = 'Expense';
    }
    _resetAndReload();
  }
  
  void changeType(String type) {
    selectedType.value = type;
    // Update tab based on type
    if (type == 'All') {
      selectedTab.value = 0;
    } else if (type == 'Income') {
      selectedTab.value = 1;
    } else if (type == 'Expense') {
      selectedTab.value = 2;
    }
    _resetAndReload();
  }
  void changePeriod(String period) {
  print("🔄 Changing period to: $period");
  selectedPeriod.value = period;
  if (period != 'Custom Range') {
    selectedDateRange.value = null;
    print("🔄 Date range cleared");
  }
  // Force reload with new period
  _resetAndReload();
}
  void setDateRange(DateTimeRange? range) {
    selectedDateRange.value = range;
    if (range != null) {
      selectedPeriod.value = 'Custom Range';
    }
    _resetAndReload();
  }
  
  void clearDateRange() {
    selectedDateRange.value = null;
    selectedPeriod.value = 'This Month';
    _resetAndReload();
  }
  
  void clearFilters() {
    searchController.clear();
    searchQuery.value = '';
    selectedDateRange.value = null;
    selectedPeriod.value = 'This Month';
    selectedType.value = 'All';
    selectedTab.value = 0;
    _resetAndReload();
  }
  
  void refreshData() {
    _resetAndReload();
  }
  
  // Updated icon and color methods to handle all transaction types
  IconData getIconForTransaction(Map<String, dynamic> transaction) {
    final source = transaction['source'] ?? '';
    final type = transaction['type'] ?? '';
    
    switch (source) {
      case 'income':
        return Icons.trending_up;
      case 'expense':
        return Icons.trending_down;
      case 'invoice':
        return Icons.receipt;
      case 'bill':
        return Icons.receipt;
      case 'payment_received':
        return Icons.arrow_downward;
      case 'payment_made':
        return Icons.arrow_upward;
      case 'credit_note':
        return Icons.note;
      case 'journal_entry':
        return Icons.book;
      case 'loan':
        return Icons.credit_card;
      case 'fixed_asset':
        return Icons.business_center;
      default:
        return type == 'income' ? Icons.trending_up : Icons.trending_down;
    }
  }
  
  Color getColorForTransaction(Map<String, dynamic> transaction) {
    final source = transaction['source'] ?? '';
    final type = transaction['type'] ?? '';
    
    if (transaction['color'] != null) {
      final colorStr = transaction['color'] as String;
      return Color(int.parse(colorStr.replaceAll('#', '0xFF')));
    }
    
    switch (source) {
      case 'income':
      case 'payment_received':
        return kSuccess;
      case 'expense':
      case 'payment_made':
        return kDanger;
      case 'invoice':
        return const Color(0xFF3498DB);
      case 'bill':
        return const Color(0xFFE67E22);
      case 'credit_note':
        return const Color(0xFFF1C40F);
      case 'journal_entry':
        return const Color(0xFF9B59B6);
      case 'loan':
        return const Color(0xFF3498DB);
      case 'fixed_asset':
        return const Color(0xFF1ABC9C);
      default:
        return type == 'income' ? kSuccess : kDanger;
    }
  }
  
  String getTransactionTitle(Map<String, dynamic> transaction) {
    final source = transaction['source'] ?? '';
    final title = transaction['title'] ?? '';
    final transactionNumber = transaction['transactionNumber'] ?? '';
    
    switch (source) {
      case 'invoice':
        return 'Invoice: $transactionNumber';
      case 'bill':
        return 'Bill: $transactionNumber';
      case 'payment_received':
        return 'Payment Received';
      case 'payment_made':
        return 'Payment Made';
      case 'credit_note':
        return 'Credit Note: $transactionNumber';
      case 'journal_entry':
        return 'Journal Entry: $transactionNumber';
      case 'loan':
        return 'Loan: $transactionNumber';
      case 'fixed_asset':
        return 'Asset Purchase: $transactionNumber';
      default:
        return title;
    }
  }
  
  String getTransactionSubtitle(Map<String, dynamic> transaction) {
    final source = transaction['source'] ?? '';
    final category = transaction['category'] ?? '';
    final customerName = transaction['customerName'] ?? '';
    final vendorName = transaction['vendorName'] ?? '';
    final dueDate = transaction['dueDate'];
    
    String subtitle = category;
    
    if (customerName.isNotEmpty) {
      subtitle = '$customerName • $subtitle';
    } else if (vendorName.isNotEmpty) {
      subtitle = '$vendorName • $subtitle';
    }
    
    if (dueDate != null) {
      subtitle = '$subtitle • Due: ${DateFormat('dd MMM yyyy').format(DateTime.parse(dueDate))}';
    }
    
    return subtitle;
  }
  
  String formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '₨ ${formatter.format(amount)}';
  }
  
  void exportTransactions() {
    Get.snackbar('Export', 'Exporting transactions to Excel...',
        snackPosition: SnackPosition.BOTTOM, backgroundColor: kPrimary, colorText: Colors.white);
  }
  
  void _showError(String message) {
    Get.snackbar('Error', message,
        snackPosition: SnackPosition.BOTTOM, backgroundColor: kDanger, colorText: Colors.white);
  }
}