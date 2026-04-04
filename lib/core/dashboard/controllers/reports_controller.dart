import 'dart:convert';
import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/config/apiconfig.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReportsController extends GetxController {
  // Observable variables
  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  
  // Report data
  var profitLossData = <String, dynamic>{}.obs;
  var balanceSheetData = <String, dynamic>{}.obs;
  var cashFlowData = <String, dynamic>{}.obs;
  var journalEntriesData = <String, dynamic>{}.obs;
  
  // Period filter
  var selectedPeriod = 'This Month'.obs;
  var selectedDateRange = Rxn<DateTimeRange>();
  var periodText = ''.obs;
  
  final List<String> periodOptions = [
    'Today',
    'This Week',
    'This Month',
    'This Quarter',
    'This Year',
    'Custom Range'
  ];
  
  final String baseUrl = Apiconfig().baseUrl;
  
  @override
  void onInit() {
    super.onInit();
    // Load all reports when period changes
    ever(selectedPeriod, (_) => loadAllReports());
    ever(selectedDateRange, (_) => loadAllReports());
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
  
  Future<void> loadAllReports() async {
    await Future.wait([
      loadProfitLoss(),
      loadBalanceSheet(),
      loadCashFlow(),
      loadJournalEntries(),
    ]);
  }
  
  // ==================== LOAD PROFIT & LOSS ====================
  Future<void> loadProfitLoss() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      Map<String, String> params = {};
      
      if (selectedPeriod.value == 'Custom Range' && selectedDateRange.value != null) {
        params['startDate'] = DateFormat('yyyy-MM-dd').format(selectedDateRange.value!.start);
        params['endDate'] = DateFormat('yyyy-MM-dd').format(selectedDateRange.value!.end);
      } else {
        params['period'] = selectedPeriod.value;
      }
      
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl/api/reports/profit-loss').replace(queryParameters: params);
      final response = await http.get(uri, headers: headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          profitLossData.value = data['data'];
          periodText.value = profitLossData['period']['displayText'];
        }
      } else {
        print('Error loading profit loss: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading profit loss: $e');
      hasError.value = true;
      errorMessage.value = 'Failed to load Profit & Loss';
    } finally {
      isLoading.value = false;
    }
  }
  
  // ==================== LOAD BALANCE SHEET ====================
  Future<void> loadBalanceSheet() async {
    try {
      Map<String, String> params = {};
      
      if (selectedPeriod.value == 'Custom Range' && selectedDateRange.value != null) {
        params['asOfDate'] = DateFormat('yyyy-MM-dd').format(selectedDateRange.value!.end);
      } else {
        params['period'] = selectedPeriod.value;
      }
      
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl/api/reports/balance-sheet').replace(queryParameters: params);
      final response = await http.get(uri, headers: headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          balanceSheetData.value = data['data'];
        }
      } else {
        print('Error loading balance sheet: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading balance sheet: $e');
    }
  }
  
  // ==================== LOAD CASH FLOW ====================
  Future<void> loadCashFlow() async {
    try {
      Map<String, String> params = {};
      
      if (selectedPeriod.value == 'Custom Range' && selectedDateRange.value != null) {
        params['startDate'] = DateFormat('yyyy-MM-dd').format(selectedDateRange.value!.start);
        params['endDate'] = DateFormat('yyyy-MM-dd').format(selectedDateRange.value!.end);
      } else {
        params['period'] = selectedPeriod.value;
      }
      
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl/api/reports/cash-flow').replace(queryParameters: params);
      final response = await http.get(uri, headers: headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          cashFlowData.value = data['data'];
        }
      } else {
        print('Error loading cash flow: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading cash flow: $e');
    }
  }
  
  // ==================== LOAD JOURNAL ENTRIES ====================
  Future<void> loadJournalEntries() async {
    try {
      Map<String, String> params = {
        'page': '1',
        'limit': '5',
      };
      
      if (selectedPeriod.value == 'Custom Range' && selectedDateRange.value != null) {
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
            params['startDate'] = DateFormat('yyyy-MM-dd').format(DateTime(now.year, quarter * 3 + 1, 1));
            params['endDate'] = DateFormat('yyyy-MM-dd').format(now);
            break;
          case 'This Year':
            params['startDate'] = DateFormat('yyyy-MM-dd').format(DateTime(now.year, 1, 1));
            params['endDate'] = DateFormat('yyyy-MM-dd').format(now);
            break;
        }
      }
      
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl/api/reports/journal-entries').replace(queryParameters: params);
      final response = await http.get(uri, headers: headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          journalEntriesData.value = data;
        }
      } else {
        print('Error loading journal entries: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading journal entries: $e');
    }
  }
  
  void changePeriod(String period) {
    selectedPeriod.value = period;
    if (period != 'Custom Range') {
      selectedDateRange.value = null;
    }
  }
  
  void setDateRange(DateTimeRange? range) {
    selectedDateRange.value = range;
    if (range != null) {
      selectedPeriod.value = 'Custom Range';
    }
  }
  
  void clearDateRange() {
    selectedDateRange.value = null;
    selectedPeriod.value = 'This Month';
  }
  
  String formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '₨ ${formatter.format(amount)}';
  }
  
  void exportReport() {
    Get.snackbar('Export', 'Exporting report to Excel...',
        snackPosition: SnackPosition.BOTTOM, backgroundColor: kPrimary, colorText: Colors.white);
  }
  
  void printReport() {
    Get.snackbar('Print', 'Preparing report for print...',
        snackPosition: SnackPosition.BOTTOM, backgroundColor: kPrimary, colorText: Colors.white);
  }
}