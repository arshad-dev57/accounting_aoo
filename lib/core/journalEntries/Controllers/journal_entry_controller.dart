import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:LedgerPro_app/config/apiconfig.dart';

class JournalEntryController extends GetxController {
  // Observables
  var journalEntries = <JournalEntry>[].obs;
  var isLoading = true.obs;
  var isLoadingMore = false.obs;
  var selectedFilter = 'All'.obs;
  var searchQuery = ''.obs;
  var selectedDateRange = Rxn<DateTimeRange>();

  // Pagination
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var hasMore = true.obs;
  final int pageSize = 10;

  // Summary totals
  var totalDebit = 0.0.obs;
  var totalCredit = 0.0.obs;
  var difference = 0.0.obs;
  var postedCount = 0.obs;
  var draftCount = 0.obs;

  // Accounts for dropdown
  var accounts = <Map<String, dynamic>>[].obs;

  // Scroll controller for lazy loading
  final ScrollController scrollController = ScrollController();

  // Base URL
  final String baseUrl = Apiconfig().baseUrl;
  String? _cachedToken;

  @override
  void onInit() {
    super.onInit();
    fetchJournalEntries();
    fetchAccountsForDropdown();
    _setupScrollListener();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 100) {
        if (hasMore.value && !isLoadingMore.value) {
          loadMoreJournalEntries();
        }
      }
    });
  }

  void _resetAndReload() {
    currentPage.value = 1;
    journalEntries.clear();
    hasMore.value = true;
    fetchJournalEntries();
  }

  // --- Auth Helpers ---
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

  // --- API Methods with Pagination ---



  Future<void> fetchAccountsForDropdown() async {
    final String url = '$baseUrl/api/chart-of-accounts';
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          accounts.value = List<Map<String, dynamic>>.from(data['data']);
        }
      }
    } catch (e) {
      print('Error fetching accounts: $e');
    }
  }

  // Fetch journal entries with pagination
  Future<void> fetchJournalEntries() async {
    try {
      isLoading.value = true;

      Map<String, String> params = {
        'page': currentPage.value.toString(),
        'limit': pageSize.toString(),
      };

      if (selectedFilter.value != 'All' && selectedFilter.value != 'Custom Range') {
        params['status'] = selectedFilter.value;
      }
      if (searchQuery.value.isNotEmpty) {
        params['search'] = searchQuery.value;
      }
      if (selectedDateRange.value != null) {
        params['startDate'] = selectedDateRange.value!.start.toIso8601String();
        params['endDate'] = selectedDateRange.value!.end.toIso8601String();
      }

      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl/api/journal-entries').replace(queryParameters: params);
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          journalEntries.value = (data['data'] as List)
              .map((e) => JournalEntry.fromJson(e))
              .toList();

          totalPages.value = data['pages'] ?? 1;
          hasMore.value = currentPage.value < totalPages.value;

          // Update summary
          totalDebit.value = _toDouble(data['summary']['totalDebit']);
          totalCredit.value = _toDouble(data['summary']['totalCredit']);
          difference.value = _toDouble(data['summary']['difference']);
          postedCount.value = _toDouble(data['summary']['postedCount']).toInt();
          draftCount.value = _toDouble(data['summary']['draftCount']).toInt();
        }
      } else if (response.statusCode == 401) {
        _handleSessionExpired();
      }
    } catch (e) {
      print('Error fetching journal entries: $e');
      Get.snackbar('Error', 'Failed to load journal entries: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Load more journal entries (lazy loading)
  Future<void> loadMoreJournalEntries() async {
    if (!hasMore.value || isLoadingMore.value) return;

    try {
      isLoadingMore.value = true;
      currentPage.value++;

      Map<String, String> params = {
        'page': currentPage.value.toString(),
        'limit': pageSize.toString(),
      };

      if (selectedFilter.value != 'All' && selectedFilter.value != 'Custom Range') {
        params['status'] = selectedFilter.value;
      }
      if (searchQuery.value.isNotEmpty) {
        params['search'] = searchQuery.value;
      }
      if (selectedDateRange.value != null) {
        params['startDate'] = selectedDateRange.value!.start.toIso8601String();
        params['endDate'] = selectedDateRange.value!.end.toIso8601String();
      }

      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl/api/journal-entries').replace(queryParameters: params);
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          List<JournalEntry> newEntries = (data['data'] as List)
              .map((e) => JournalEntry.fromJson(e))
              .toList();
          journalEntries.addAll(newEntries);

          totalPages.value = data['pages'] ?? 1;
          hasMore.value = currentPage.value < totalPages.value;
        }
      }
    } catch (e) {
      print('Error loading more journal entries: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  // Create journal entry
  Future<void> createJournalEntry({
    required DateTime date,
    required String description,
    required String reference,
    required List<Map<String, dynamic>> lines,
    required bool postNow,
  }) async {
    final String url = '$baseUrl/api/journal-entries';
    final body = {
      'date': date.toIso8601String(),
      'description': description,
      'reference': reference,
      'lines': lines,
    };

    try {
      isLoading.value = true;
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          final entryId = data['data']['_id'];
          if (postNow) {
            await postJournalEntry(entryId);
          }
          _resetAndReload();
          Get.snackbar(
            'Success',
            postNow ? 'Journal entry posted successfully' : 'Journal entry saved as draft',
            backgroundColor: const Color(0xFF2ECC71),
            colorText: Colors.white,
          );
        }
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar('Error', data['message'] ?? 'Failed to create entry');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create journal entry: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Post journal entry
  Future<void> postJournalEntry(String id) async {
    final String url = '$baseUrl/api/journal-entries/$id/post';
    try {
      final headers = await _getHeaders();
      final response = await http.post(Uri.parse(url), headers: headers);

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        Get.snackbar('Error', data['message'] ?? 'Failed to post entry');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to post journal entry: $e');
    }
  }

  // Delete journal entry
  Future<void> deleteJournalEntry(String id) async {
    final String url = '$baseUrl/api/journal-entries/$id';
    try {
      final headers = await _getHeaders();
      final response = await http.delete(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        _resetAndReload();
        Get.snackbar('Success', 'Journal entry deleted');
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar('Error', errorData['message'] ?? 'Failed to delete');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete: $e');
    }
  }

  // --- Filtering Methods ---
  void changeFilter(String filter) {
    selectedFilter.value = filter;
    if (filter != 'Custom Range') {
      selectedDateRange.value = null;
    }
    _resetAndReload();
  }

  void setDateRange(DateTimeRange? range) {
    selectedDateRange.value = range;
    if (range != null) {
      selectedFilter.value = 'Custom Range';
    }
    _resetAndReload();
  }

  void searchEntries(String query) {
    searchQuery.value = query;
    _resetAndReload();
  }

  void _handleSessionExpired() {
    Get.snackbar(
      'Session Expired',
      'Please login again',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFE74C3C),
      colorText: Colors.white,
    );
  }
}

// --- Model Classes ---

class JournalEntry {
  final String id;
  final String entryNumber;
  final DateTime date;
  final String description;
  final String reference;
  final List<JournalLine> lines;
  final String status;
  final String createdBy;
  final DateTime createdAt;
  final String? postedBy;
  final DateTime? postedAt;

  JournalEntry({
    required this.id,
    required this.entryNumber,
    required this.date,
    required this.description,
    required this.reference,
    required this.lines,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    this.postedBy,
    this.postedAt,
  });

  double get totalDebit => lines.fold(0, (sum, line) => sum + line.debit);
  double get totalCredit => lines.fold(0, (sum, line) => sum + line.credit);

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['_id'],
      entryNumber: json['entryNumber'],
      date: DateTime.parse(json['date']),
      description: json['description'],
      reference: json['reference'] ?? '',
      lines: (json['lines'] as List)
          .map((e) => JournalLine.fromJson(e))
          .toList(),
      status: json['status'],
      createdBy: json['createdBy'] is Map
          ? '${json['createdBy']['firstName']} ${json['createdBy']['lastName']}'
          : json['createdBy'].toString(),
      createdAt: DateTime.parse(json['createdAt']),
      postedBy: json['postedBy'] is Map
          ? '${json['postedBy']['firstName']} ${json['postedBy']['lastName']}'
          : json['postedBy']?.toString(),
      postedAt: json['postedAt'] != null ? DateTime.parse(json['postedAt']) : null,
    );
  }
}

class JournalLine {
  final String accountId;
  final String accountName;
  final String accountCode;
  final double debit;
  final double credit;

  JournalLine({
    required this.accountId,
    required this.accountName,
    required this.accountCode,
    required this.debit,
    required this.credit,
  });

  factory JournalLine.fromJson(Map<String, dynamic> json) {
    return JournalLine(
      accountId: json['accountId'] ?? '',
      accountName: json['accountName'] ?? '',
      accountCode: json['accountCode'] ?? '',
      debit: (json['debit'] ?? 0).toDouble(),
      credit: (json['credit'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'debit': debit,
      'credit': credit,
    };
  }
}