

import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/Utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:LedgerPro_app/config/apiconfig.dart';

class GeneralLedgerController extends GetxController {
  var accountSummaries = <AccountSummary>[].obs;
  var ledgerEntries = <LedgerEntry>[].obs;
  var isLoading = true.obs;
  var selectedAccount = 'All Accounts'.obs;
  var selectedFilter = 'All'.obs;
  var selectedDateRange = Rx<DateTimeRange?>(null);
  var searchQuery = ''.obs;
  
  // For dropdown accounts
  var accountsForDropdown = <Map<String, dynamic>>[].obs;
  
  // Filter variables
  var showOnlyDebit = false.obs;
  var showOnlyCredit = false.obs;
  
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
  
  // Computed filtered entries
  List<LedgerEntry> get filteredLedgerEntries {
    List<LedgerEntry> filtered = ledgerEntries.toList();
    
    if (showOnlyDebit.value) {
      filtered = filtered.where((e) => e.debit > 0).toList();
    } else if (showOnlyCredit.value) {
      filtered = filtered.where((e) => e.credit > 0).toList();
    }
    
    return filtered;
  }

  void toggleDebitFilter() {
    if (showOnlyDebit.value) {
      showOnlyDebit.value = false;
    } else {
      showOnlyDebit.value = true;
      showOnlyCredit.value = false;
    }
    // Refresh the list
    fetchLedgerEntries();
  }

  void toggleCreditFilter() {
    if (showOnlyCredit.value) {
      showOnlyCredit.value = false;
    } else {
      showOnlyCredit.value = true;
      showOnlyDebit.value = false;
    }
    fetchLedgerEntries();
  }

  void clearFilters() {
    showOnlyDebit.value = false;
    showOnlyCredit.value = false;
    fetchLedgerEntries();
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
    fetchLedgerEntries();
    fetchAccountSummaries();
  }
  
  // Fetch account summaries for cards and dropdown
  Future<void> fetchAccountSummaries() async {
    try {
      isLoading(true);
      
      String url = '$baseUrl/api/general-ledger/accounts';
      List<String> queryParams = [];
      
      if (selectedDateRange.value != null) {
        queryParams.add('startDate=${selectedDateRange.value!.start.toIso8601String()}');
        queryParams.add('endDate=${selectedDateRange.value!.end.toIso8601String()}');
      }
      
      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }
      
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          accountSummaries.value = (data['data'] as List)
              .map((e) => AccountSummary.fromJson(e))
              .toList();
          
          // Update accounts for dropdown
          accountsForDropdown.value = (data['data'] as List).map((e) => {
            'accountId': e['accountId'],
            'accountName': e['accountName'],
            'accountCode': e['accountCode'],
          }).toList();
        }
      } else if (response.statusCode == 401) {
        _handleSessionExpired();
      }
    } catch (e) {
      AppSnackbar.error(Colors.red, 'Error', 'Failed to load account summaries: $e');
    } finally {
      isLoading(false);
    }
  }
  
  // Fetch ledger entries
  Future<void> fetchLedgerEntries() async {
    try {
      isLoading(true);
      
      String url;
      List<String> queryParams = [];
      
      if (selectedAccount.value == 'All Accounts') {
        url = '$baseUrl/api/general-ledger/all-entries';
      } else {
        // Find account ID for selected account name
        final selected = accountSummaries.firstWhere(
          (a) => a.accountName == selectedAccount.value,
          orElse: () => AccountSummary(
            accountId: '', accountCode: '', accountName: '',
            accountType: '', openingBalance: 0, totalDebit: 0,
            totalCredit: 0, closingBalance: 0,
          ),
        );
        
        if (selected.accountId.isEmpty) {
          isLoading(false);
          return;
        }
        
        url = '$baseUrl/api/general-ledger/entries/${selected.accountId}';
      }
      
      // Add date range filter
      if (selectedDateRange.value != null) {
        queryParams.add('startDate=${selectedDateRange.value!.start.toIso8601String()}');
        queryParams.add('endDate=${selectedDateRange.value!.end.toIso8601String()}');
      }
      
      // Add search filter
      if (searchQuery.value.isNotEmpty) {
        queryParams.add('search=${searchQuery.value}');
      }
      
      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }
      
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          ledgerEntries.value = (data['data'] as List)
              .map((e) => LedgerEntry.fromJson(e))
              .toList();
        }
      }
    } catch (e) {
      AppSnackbar.error(Colors.red,'Error', 'Failed to load ledger entries: $e');
    } finally {
      isLoading(false);
    }
  }
  
  // Combined fetch (both summaries and entries)
  Future<void> refreshData() async {
    await fetchAccountSummaries();
    await fetchLedgerEntries();
  }
  
  // Filter methods
  void changeAccount(String account) {
    selectedAccount.value = account;
    fetchLedgerEntries();
  }
  
  void changeFilter(String filter) {
    selectedFilter.value = filter;
    if (filter != 'Custom Range') {
      selectedDateRange.value = null;
      _applyDateFilter(filter);
    }
    fetchLedgerEntries();
    fetchAccountSummaries();
  }
  
  void setDateRange(DateTimeRange? range) {
    selectedDateRange.value = range;
    if (range != null) {
      selectedFilter.value = 'Custom Range';
    }
    fetchLedgerEntries();
    fetchAccountSummaries();
  }
  
  void searchEntries(String query) {
    searchQuery.value = query;
    fetchLedgerEntries();
  }
  
  void _applyDateFilter(String filter) {
    final now = DateTime.now();
    DateTime start;
    
    switch (filter) {
      case 'Today':
        start = DateTime(now.year, now.month, now.day);
        selectedDateRange.value = DateTimeRange(start: start, end: now);
        break;
      case 'This Week':
        start = now.subtract(Duration(days: now.weekday - 1));
        selectedDateRange.value = DateTimeRange(start: start, end: now);
        break;
      case 'This Month':
        start = DateTime(now.year, now.month, 1);
        selectedDateRange.value = DateTimeRange(start: start, end: now);
        break;
      case 'This Quarter':
        int quarter = ((now.month - 1) / 3).floor();
        start = DateTime(now.year, quarter * 3 + 1, 1);
        selectedDateRange.value = DateTimeRange(start: start, end: now);
        break;
      case 'This Year':
        start = DateTime(now.year, 1, 1);
        selectedDateRange.value = DateTimeRange(start: start, end: now);
        break;
      default:
        selectedDateRange.value = null;
    }
  }
  
  void _handleSessionExpired() {
    AppSnackbar.error(
      Colors.red,
      'Session Expired',
      'Please login again',
    
    );
  }
  
  // Export functions
  void exportLedger() {
    AppSnackbar.success(
      kPrimary,
      'Export',
      'Exporting General Ledger to Excel...',
    );
  }
  
  void printLedger() {
    AppSnackbar.success(
      kPrimary,
      'Print',
      'Preparing General Ledger for printing...');
  }
}

class AccountSummary {
  final String accountId;
  final String accountCode;
  final String accountName;
  final String accountType;
  final double openingBalance;
  final double totalDebit;
  final double totalCredit;
  final double closingBalance;
  
  AccountSummary({
    required this.accountId,
    required this.accountCode,
    required this.accountName,
    required this.accountType,
    required this.openingBalance,
    required this.totalDebit,
    required this.totalCredit,
    required this.closingBalance,
  });
  
  factory AccountSummary.fromJson(Map<String, dynamic> json) {
    return AccountSummary(
      accountId: json['accountId'],
      accountCode: json['accountCode'],
      accountName: json['accountName'],
      accountType: json['accountType'],
      openingBalance: (json['openingBalance'] ?? 0).toDouble(),
      totalDebit: (json['totalDebit'] ?? 0).toDouble(),
      totalCredit: (json['totalCredit'] ?? 0).toDouble(),
      closingBalance: (json['closingBalance'] ?? 0).toDouble(),
    );
  }
}

class LedgerEntry {
  final String id;
  final DateTime date;
  final String accountId;
  final String accountName;
  final String accountCode;
  final String description;
  final double debit;
  final double credit;
  final double balance;
  final String reference;
  
  LedgerEntry({
    required this.id,
    required this.date,
    required this.accountId,
    required this.accountName,
    required this.accountCode,
    required this.description,
    required this.debit,
    required this.credit,
    required this.balance,
    required this.reference,
  });
  
  factory LedgerEntry.fromJson(Map<String, dynamic> json) {
    return LedgerEntry(
      id: json['id'],
      date: DateTime.parse(json['date']),
      accountId: json['accountId'],
      accountName: json['accountName'],
      accountCode: json['accountCode'],
      description: json['description'],
      debit: (json['debit'] ?? 0).toDouble(),
      credit: (json['credit'] ?? 0).toDouble(),
      balance: (json['balance'] ?? 0).toDouble(),
      reference: json['reference'] ?? '',
    );
  }
}