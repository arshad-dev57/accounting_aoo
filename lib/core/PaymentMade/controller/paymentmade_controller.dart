import 'dart:convert';
import 'dart:io';
import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/Utils/toast_utils.dart';
import 'package:LedgerPro_app/config/apiconfig.dart';
import 'package:LedgerPro_app/core/Bills/Screen/bill_Screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';

class PaymentMadeController extends GetxController {
  // Observable variables
  var payments = <PaymentMade>[].obs;
  var vendors = <VendorForPayment>[].obs;
  var isLoading = true.obs;
  var selectedFilter = 'All'.obs;
  var selectedDateRange = Rxn<DateTimeRange>();
  var searchQuery = ''.obs;
  
  // Filter options
  final List<String> filterOptions = [
    'All', 
    'Today', 
    'This Week', 
    'This Month', 
    'Custom Range'
  ];
  
  // Summary data
  var totalPaid = 0.0.obs;
  var thisMonthTotal = 0.0.obs;
  var thisWeekTotal = 0.0.obs;
  var todayTotal = 0.0.obs;
  var pendingCount = 0.obs;
  
  // Debug variable to track bills loading
  var isLoadingBills = false.obs;
  var currentVendorId = ''.obs;
  var currentBills = <BillForPayment>[].obs;
  
  TextEditingController searchController = TextEditingController();
  final String baseUrl = Apiconfig().baseUrl;
  
  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    loadPaymentsData();
    loadVendors();
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
    filterPayments();
  }
  
  // ==================== HELPER: GET TOKEN ====================
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    print('🔑 Token retrieved: ${token != null ? 'Yes (${token.substring(0, min(20, token.length))}...)' : 'No'}');
    return token;
  }
  
  // ==================== HELPER: GET HEADERS ====================
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    print('📋 Headers: $headers');
    return headers;
  }
  
  // ==================== HELPER: FORMAT AMOUNT ====================
  String _formatAmount(double amount) {
    return '\$. ${amount.toStringAsFixed(2)}';
  }
  
  // ==================== LOAD PAYMENTS FROM API ====================
  Future<void> loadPaymentsData() async {
    try {
      isLoading.value = true;
      print('🔄 Loading payments data...');
      
      // Build query parameters
      Map<String, dynamic> params = {};
      
      if (selectedFilter.value != 'All' && selectedFilter.value != 'Custom Range') {
        final now = DateTime.now();
        switch (selectedFilter.value) {
          case 'Today':
            params['startDate'] = DateFormat('yyyy-MM-dd').format(now);
            params['endDate'] = DateFormat('yyyy-MM-dd').format(now);
            break;
          case 'This Week':
            final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
            params['startDate'] = DateFormat('yyyy-MM-dd').format(startOfWeek);
            params['endDate'] = DateFormat('yyyy-MM-dd').format(now);
            break;
          case 'This Month':
            final startOfMonth = DateTime(now.year, now.month, 1);
            params['startDate'] = DateFormat('yyyy-MM-dd').format(startOfMonth);
            params['endDate'] = DateFormat('yyyy-MM-dd').format(now);
            break;
        }
      } else if (selectedDateRange.value != null) {
        params['startDate'] = DateFormat('yyyy-MM-dd').format(selectedDateRange.value!.start);
        params['endDate'] = DateFormat('yyyy-MM-dd').format(selectedDateRange.value!.end);
      }
      
      if (searchQuery.value.isNotEmpty) {
        params['search'] = searchQuery.value;
      }
      
      print('📊 Query params: $params');
      
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl/api/payments-made').replace(queryParameters: params);
      print('🌐 Request URL: $uri');
      
      final response = await http.get(uri, headers: headers);
      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body.substring(0, min(500, response.body.length))}...');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          List<dynamic> paymentsData = responseData['data'];
          payments.value = paymentsData.map((json) => PaymentMade.fromJson(json)).toList();
          print('✅ Loaded ${payments.length} payments');
        } else {
          print('❌ API returned success=false: ${responseData['message']}');
          _showError('Failed to load payments');
        }
      } else {
        print('❌ HTTP error: ${response.statusCode}');
        _showError('Failed to load payments: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error loading payments: $e');
      _showError('Error loading payments');
    } finally {
      isLoading.value = false;
    }
  }
  
  // ==================== LOAD VENDORS FROM API ====================
  Future<void> loadVendors() async {
    try {
      print('🔄 Loading vendors...');
      final headers = await _getHeaders();
      final url = '$baseUrl/api/accounts-payable/vendors';
      print('🌐 Vendor URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      
      print('📡 Vendor response status: ${response.statusCode}');
      print('📡 Vendor response body: ${response.body.substring(0, min(500, response.body.length))}...');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          List<dynamic> vendorsData = responseData['data'];
          vendors.value = vendorsData.map((json) => VendorForPayment.fromJson(json)).toList();
          print('✅ Loaded ${vendors.length} vendors');
          vendors.forEach((vendor) {
            print('   Vendor: ${vendor.name} (ID: ${vendor.id})');
          });
        } else {
          print('❌ Vendor API returned success=false: ${responseData['message']}');
        }
      } else {
        print('❌ Vendor HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error loading vendors: $e');
    }
  }
  
  // ==================== LOAD SUMMARY FROM API ====================
  Future<void> loadSummary() async {
    try {
      print('🔄 Loading summary...');
      Map<String, dynamic> params = {};
      
      if (selectedDateRange.value != null) {
        params['startDate'] = DateFormat('yyyy-MM-dd').format(selectedDateRange.value!.start);
        params['endDate'] = DateFormat('yyyy-MM-dd').format(selectedDateRange.value!.end);
      }
      
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl/api/payments-made/summary').replace(queryParameters: params);
      print('🌐 Summary URL: $uri');
      
      final response = await http.get(uri, headers: headers);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final data = responseData['data'];
          totalPaid.value = (data['totalPaid'] ?? 0).toDouble();
          thisWeekTotal.value = (data['thisWeek'] ?? 0).toDouble();
          thisMonthTotal.value = (data['thisMonth'] ?? 0).toDouble();
          todayTotal.value = (data['today'] ?? 0).toDouble();
          pendingCount.value = data['pending'] ?? 0;
          print('✅ Summary loaded: Total Paid: ${totalPaid.value}, Pending: ${pendingCount.value}');
        }
      }
    } catch (e) {
      print('❌ Error loading summary: $e');
    }
  }
  
  void applyDateFilter(String filter) {
    selectedFilter.value = filter;
    
    if (filter == 'Custom Range') {
      selectDateRange();
    } else {
      selectedDateRange.value = null;
      loadPaymentsData();
      loadSummary();
    }
  }
  
  Future<void> selectDateRange() async {
    final picked = await Get.dialog<DateTimeRange>(
      DateRangePickerDialog(
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
        initialDateRange: selectedDateRange.value,
      ),
    );
    
    if (picked != null) {
      selectedDateRange.value = picked;
      selectedFilter.value = 'Custom Range';
      loadPaymentsData();
      loadSummary();
    }
  }
  
  void clearDateRange() {
    selectedDateRange.value = null;
    selectedFilter.value = 'All';
    loadPaymentsData();
    loadSummary();
  }
  
  void filterPayments() {
    loadPaymentsData();
  }
  
  Future<void> recordPayment({
    required String vendorId,
    required String billId,
    required double amount,
    required DateTime paymentDate,
    required String paymentMethod,
    String? reference,
    String? bankAccountId,
    String? notes,
  }) async {
    try {
      isLoading.value = true;
      
      final Map<String, dynamic> paymentData = {
        'vendorId': vendorId,
        'billId': billId,
        'amount': amount,
        'paymentDate': DateFormat('yyyy-MM-dd').format(paymentDate),
        'paymentMethod': paymentMethod,
        'reference': reference ?? '',
        'notes': notes ?? '',
      };
      
      if (bankAccountId != null && bankAccountId.isNotEmpty && paymentMethod == 'Bank Transfer') {
        paymentData['bankAccountId'] = bankAccountId;
      }
      
      print('📤 Recording payment: $paymentData');
      
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/payments-made'),
        headers: headers,
        body: json.encode(paymentData),
      );
      
      print('📡 Record payment response status: ${response.statusCode}');
      print('📡 Response: ${response.body}');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          AppSnackbar.success(kSuccess, 'Success', 'Payment recorded successfully\nJournal entry created');
          Get.back(); 
          loadPaymentsData();
          loadSummary();
        } else {
          _showError(responseData['message'] ?? 'Failed to record payment');
        }
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        _showError(errorData['message'] ?? 'Failed to record payment');
      }
    } catch (e) {
      print('❌ Error recording payment: $e');
      _showError('Error recording payment');
    } finally {
      isLoading.value = false;
    }
  }
  
  // ==================== GET UNPAID BILLS WITH DEBUG ====================
  Future<List<BillForPayment>> getUnpaidBills(String vendorId) async {
    print('\n🔍 ========== GET UNPAID BILLS DEBUG ==========');
    print('📌 Vendor ID: $vendorId');
    
    if (vendorId.isEmpty) {
      print('⚠️ Vendor ID is empty, returning empty list');
      return [];
    }
    
    try {
      currentVendorId.value = vendorId;
      isLoadingBills.value = true;
      
      final headers = await _getHeaders();
      final url = '$baseUrl/api/payments-made/bills/unpaid/$vendorId';
      print('🌐 Request URL: $url');
      print('📋 Headers: $headers');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      
      print('📡 Response Status Code: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('📦 Parsed Response Data: $responseData');
        
        if (responseData['success'] == true) {
          List<dynamic> billsData = responseData['data'];
          print('📊 Bills Data Length: ${billsData.length}');
          
          if (billsData.isEmpty) {
            print('⚠️ No unpaid bills found for this vendor');
            AppSnackbar.info('Info', 'No unpaid bills found for this vendor');
            currentBills.value = [];
            return [];
          }
          
          final bills = billsData.map((json) {
            print('   Processing bill JSON: $json');
            return BillForPayment.fromJson(json);
          }).toList();
          
          print('✅ Successfully parsed ${bills.length} bills:');
          bills.forEach((bill) {
            print('   - Bill: ${bill.billNumber} | Amount: ${bill.totalAmount} | Outstanding: ${bill.outstanding} | Due: ${bill.dueDate}');
          });
          
          currentBills.value = bills;
          return bills;
        } else {
          print('❌ API returned success=false: ${responseData['message']}');
          _showError(responseData['message'] ?? 'Failed to load bills');
          return [];
        }
      } else if (response.statusCode == 404) {
        print('❌ API endpoint not found (404)');
        _showError('Bills API endpoint not found');
        return [];
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        try {
          final errorData = json.decode(response.body);
          print('❌ Error details: $errorData');
          _showError(errorData['message'] ?? 'Failed to load bills');
        } catch (e) {
          print('❌ Could not parse error response: $e');
          _showError('Failed to load bills: ${response.statusCode}');
        }
        return [];
      }
    } catch (e) {
      print('❌ Exception in getUnpaidBills: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      _showError('Error loading bills: $e');
      return [];
    } finally {
      isLoadingBills.value = false;
      print('========== END DEBUG ==========\n');
    }
  }
  
  // ==================== ACTION HANDLERS ====================
  void viewBill(PaymentMade payment) {
    Get.to(() => BillsScreen(vendorId: payment.vendorId));
  }
  
  void printVoucher(PaymentMade payment) {
    AppSnackbar.info('Print', 'Printing payment voucher for ${payment.paymentNumber}');
  }
  
  // ─────────────────────── EXPORT FUNCTIONS ───────────────────────
  
  void exportPayments() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Export Payments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Choose export format',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.picture_as_pdf, color: Color(0xFFE53935)),
              title: Text('Export as PDF'),
              onTap: () {
                Get.back();
                exportToPdf();
              },
            ),
            ListTile(
              leading: Icon(Icons.table_chart, color: Color(0xFF2E7D32)),
              title: Text('Export as Excel'),
              onTap: () {
                Get.back();
                exportToExcel();
              },
            ),
          ],
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }
  
  Future<void> exportToPdf() async {
    try {
      // Show loading only on mobile
      if (!kIsWeb) {
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('Generating PDF...', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
          barrierDismissible: false,
        );
      }
      
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          header: (ctx) => _pdfHeader(),
          footer: (ctx) => _pdfFooter(ctx),
          build: (ctx) => [
            _pdfSummarySection(),
            pw.SizedBox(height: 16),
            _pdfPaymentsSection(),
          ],
        ),
      );
      
      final bytes = await pdf.save();
      final fileName = 'payments_made_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
      
      if (kIsWeb) {
        // WEB: Download using HTML anchor tag
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
        
        if (Get.isDialogOpen ?? false) Get.back();
        
        AppSnackbar.success(kSuccess, 'Success', '${payments.length} payments exported to PDF');
      } else {
        // MOBILE: Save to file and open
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(bytes);
        
        if (Get.isDialogOpen ?? false) Get.back();
        
        AppSnackbar.success(kSuccess, 'Success', '${payments.length} payments exported to PDF');
        
        await OpenFile.open(file.path);
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      AppSnackbar.error(kDanger, 'Error', 'Failed to export PDF: $e');
    }
  }
  
  pw.Widget _pdfHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
          border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.grey300, width: 1))),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text('Payments Made Report',
                style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.indigo800)),
            pw.Text(
                'Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
                style: pw.TextStyle(
                    fontSize: 9, color: PdfColors.grey600)),
          ]),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: pw.BoxDecoration(
                color: PdfColors.indigo800,
                borderRadius: pw.BorderRadius.circular(6)),
            child: pw.Text('LedgerPro',
                style: pw.TextStyle(
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10)),
          ),
        ],
      ),
    );
  }
  
  pw.Widget _pdfFooter(pw.Context ctx) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
          border: pw.Border(
              top: pw.BorderSide(color: PdfColors.grey300, width: 1))),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Confidential - For Internal Use Only',
              style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
          pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}',
              style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
        ],
      ),
    );
  }
  
  pw.Widget _pdfSummarySection() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
          color: PdfColors.indigo50,
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: PdfColors.indigo200)),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _pdfSummaryItem('Total Paid', _formatAmount(totalPaid.value), PdfColors.green700),
              _pdfSummaryItem('This Month', _formatAmount(thisMonthTotal.value), PdfColors.indigo700),
              _pdfSummaryItem('This Week', _formatAmount(thisWeekTotal.value), PdfColors.indigo700),
              _pdfSummaryItem('Today', _formatAmount(todayTotal.value), PdfColors.indigo700),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _pdfSummaryItem('Total Payments', payments.length.toString(), PdfColors.grey700),
              _pdfSummaryItem('Pending Bills', pendingCount.value.toString(), PdfColors.orange700),
              _pdfSummaryItem('Filter', selectedFilter.value, PdfColors.grey700),
            ],
          ),
        ],
      ),
    );
  }
  
  pw.Widget _pdfSummaryItem(String label, String value, PdfColor color) {
    return pw.Column(children: [
      pw.Text(label,
          style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
      pw.SizedBox(height: 4),
      pw.Text(value,
          style: pw.TextStyle(
              fontSize: 11, fontWeight: pw.FontWeight.bold, color: color)),
    ]);
  }
  
  pw.Widget _pdfPaymentsSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Payment Details',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 8),
          decoration: const pw.BoxDecoration(
              border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: 1))),
          child: pw.Row(children: [
            pw.Expanded(flex: 2, child: pw.Text('Payment #', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 3, child: pw.Text('Vendor', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text('Bill #', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text('Method', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text('Amount', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          ]),
        ),
        ...payments.map((payment) => pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 6),
          decoration: const pw.BoxDecoration(
              border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5))),
          child: pw.Row(children: [
            pw.Expanded(flex: 2, child: pw.Text(payment.paymentNumber, style: pw.TextStyle(fontSize: 9))),
            pw.Expanded(flex: 2, child: pw.Text(DateFormat('dd/MM/yyyy').format(payment.paymentDate), style: pw.TextStyle(fontSize: 9))),
            pw.Expanded(flex: 3, child: pw.Text(payment.vendorName, style: pw.TextStyle(fontSize: 9))),
            pw.Expanded(flex: 2, child: pw.Text(payment.billNumber, style: pw.TextStyle(fontSize: 9))),
            pw.Expanded(flex: 2, child: pw.Text(payment.paymentMethod, style: pw.TextStyle(fontSize: 9))),
            pw.Expanded(flex: 2, child: pw.Text(_formatAmount(payment.amount), textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9, color: PdfColors.green700))),
          ]),
        )).toList(),
        pw.Divider(),
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 8),
          child: pw.Row(children: [
            pw.Expanded(flex: 11, child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text(_formatAmount(payments.fold(0.0, (sum, p) => sum + p.amount)),
                textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.green700))),
          ]),
        ),
      ],
    );
  }
  
  Future<void> exportToExcel() async {
    try {
      // Show loading only on mobile
      if (!kIsWeb) {
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('Building Excel...', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
          barrierDismissible: false,
        );
      }
      
      final excel = Excel.createExcel();
      
      // Summary Sheet
      final summarySheet = excel['Summary'];
      excel.setDefaultSheet('Summary');
      
      _excelSetCell(summarySheet, 0, 0, 'Payments Made Report',
          bold: true, fontSize: 14, bgColor: '1A237E', fontColor: 'FFFFFF');
      _excelSetCell(summarySheet, 1, 0,
          'Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
          fontSize: 9, fontColor: '757575');
      _excelSetCell(summarySheet, 2, 0,
          'Filter: ${selectedFilter.value}',
          fontSize: 10, fontColor: '1A237E');
      if (selectedDateRange.value != null) {
        _excelSetCell(summarySheet, 3, 0,
          'Period: ${DateFormat('dd MMM yyyy').format(selectedDateRange.value!.start)} - ${DateFormat('dd MMM yyyy').format(selectedDateRange.value!.end)}',
          fontSize: 10, fontColor: '1A237E');
      }
      if (searchQuery.value.isNotEmpty) {
        _excelSetCell(summarySheet, 4, 0,
          'Search: ${searchQuery.value}',
          fontSize: 10, fontColor: '1A237E');
      }
      
      _excelSetCell(summarySheet, 6, 0, 'SUMMARY', bold: true, fontSize: 11, bgColor: 'E8EAF6');
      
      final summaryRows = [
        ['Total Paid', _formatAmount(totalPaid.value)],
        ['This Month', _formatAmount(thisMonthTotal.value)],
        ['This Week', _formatAmount(thisWeekTotal.value)],
        ['Today', _formatAmount(todayTotal.value)],
        ['Total Payments', payments.length.toString()],
        ['Pending Bills', pendingCount.value.toString()],
        ['Total Amount Paid', _formatAmount(payments.fold(0.0, (sum, p) => sum + p.amount))],
      ];
      
      for (int r = 0; r < summaryRows.length; r++) {
        for (int c = 0; c < 2; c++) {
          _excelSetCell(summarySheet, 7 + r, c, summaryRows[r][c],
              bgColor: r.isEven ? 'FFFFFF' : 'F5F5F5');
        }
      }
      summarySheet.setColumnWidth(0, 25);
      summarySheet.setColumnWidth(1, 20);
      
      // Payments Sheet
      final paymentsSheet = excel['Payments'];
      final headers = [
        'Payment #', 'Date', 'Vendor', 'Bill #', 'Bill Amount', 
        'Amount Paid', 'Payment Method', 'Reference', 'Notes', 'Status'
      ];
      
      for (int i = 0; i < headers.length; i++) {
        _excelSetCell(paymentsSheet, 0, i, headers[i],
            bold: true, bgColor: '1A237E', fontColor: 'FFFFFF', fontSize: 10);
      }
      
      int row = 1;
      for (final payment in payments) {
        final bg = row.isEven ? 'F5F5F5' : 'FFFFFF';
        _excelSetCell(paymentsSheet, row, 0, payment.paymentNumber, bgColor: bg);
        _excelSetCell(paymentsSheet, row, 1, DateFormat('dd MMM yyyy').format(payment.paymentDate), bgColor: bg);
        _excelSetCell(paymentsSheet, row, 2, payment.vendorName, bgColor: bg);
        _excelSetCell(paymentsSheet, row, 3, payment.billNumber, bgColor: bg);
        _excelSetCell(paymentsSheet, row, 4, payment.billAmount, bgColor: bg);
        _excelSetCell(paymentsSheet, row, 5, payment.amount, bgColor: bg, fontColor: '2E7D32');
        _excelSetCell(paymentsSheet, row, 6, payment.paymentMethod, bgColor: bg);
        _excelSetCell(paymentsSheet, row, 7, payment.reference.isEmpty ? '-' : payment.reference, bgColor: bg);
        _excelSetCell(paymentsSheet, row, 8, payment.notes.isEmpty ? '-' : payment.notes, bgColor: bg);
        _excelSetCell(paymentsSheet, row, 9, payment.status, 
            bgColor: payment.status == 'Completed' ? 'E8F5E9' : 'FFF8E1',
            fontColor: payment.status == 'Completed' ? '2E7D32' : 'F39C12');
        row++;
      }
      
      // Totals row
      _excelSetCell(paymentsSheet, row, 4, 'TOTAL', bold: true, bgColor: 'E8EAF6');
      _excelSetCell(paymentsSheet, row, 5, payments.fold(0.0, (sum, p) => sum + p.amount), 
          bold: true, bgColor: 'E8EAF6', fontColor: '2E7D32');
      
      final colWidths = [15.0, 12.0, 25.0, 15.0, 15.0, 15.0, 15.0, 15.0, 30.0, 12.0];
      for (int i = 0; i < colWidths.length; i++) {
        paymentsSheet.setColumnWidth(i, colWidths[i]);
      }
      
      excel.delete('Sheet1');
      
      final bytes = excel.save();
      if (bytes == null) throw Exception('Excel save failed');
      
      final fileName = 'payments_made_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
      
      if (kIsWeb) {
        // WEB: Download Excel
        final blob = html.Blob([bytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
        
        if (Get.isDialogOpen ?? false) Get.back();
        
        AppSnackbar.success(kSuccess, 'Success', '${payments.length} payments exported to Excel');
      } else {
        // MOBILE: Save and open
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(bytes);
        
        if (Get.isDialogOpen ?? false) Get.back();
        
        AppSnackbar.success(kSuccess, 'Success', '${payments.length} payments exported to Excel');
        
        await OpenFile.open(file.path);
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      AppSnackbar.error(kDanger, 'Error', 'Failed to export Excel: $e');
    }
  }
  
  void _excelSetCell(
    Sheet sheet,
    int row,
    int col,
    dynamic value, {
    bool bold = false,
    double fontSize = 10,
    String? bgColor,
    String fontColor = '000000',
  }) {
    final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
    cell.value = value is double
        ? DoubleCellValue(value)
        : value is int
            ? IntCellValue(value)
            : TextCellValue(value.toString());

    cell.cellStyle = CellStyle(
      bold: bold,
      fontSize: fontSize.toInt(),
      fontColorHex: ExcelColor.fromHexString('#$fontColor'),
      backgroundColorHex: bgColor != null
          ? ExcelColor.fromHexString('#$bgColor')
          : ExcelColor.fromHexString('#FFFFFF'),
    );
  }
  
  void printPayments() {
    AppSnackbar.info('Print', 'Preparing payments report...');
  }
  
  // ==================== HELPER METHODS ====================
  String formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '\$ ${formatter.format(amount)}';
  }
  
  void _showError(String message) {
    print('❌ Error showing: $message');
    AppSnackbar.error(kDanger, 'Error', message);
  }
}

// Helper function for min
int min(int a, int b) => a < b ? a : b;

// ==================== DATA MODELS ====================

class PaymentMade {
  final String id;
  final String paymentNumber;
  final DateTime paymentDate;
  final String vendorId;
  final String vendorName;
  final String billId;
  final String billNumber;
  final double billAmount;
  final double amount;
  final String paymentMethod;
  final String reference;
  final String bankAccountId;
  final String bankAccountName;
  final String notes;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentMade({
    required this.id,
    required this.paymentNumber,
    required this.paymentDate,
    required this.vendorId,
    required this.vendorName,
    required this.billId,
    required this.billNumber,
    required this.billAmount,
    required this.amount,
    required this.paymentMethod,
    required this.reference,
    required this.bankAccountId,
    required this.bankAccountName,
    required this.notes,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentMade.fromJson(Map<String, dynamic> json) {
    return PaymentMade(
      id: json['_id'] ?? json['id'] ?? '',
      paymentNumber: json['paymentNumber'] ?? '',
      paymentDate: json['paymentDate'] != null 
          ? DateTime.parse(json['paymentDate']) 
          : DateTime.now(),
      vendorId: json['vendorId'] is Map ? json['vendorId']['_id'] : json['vendorId'] ?? '',
      vendorName: json['vendorName'] ?? '',
      billId: json['billId'] is Map ? json['billId']['_id'] : json['billId'] ?? '',
      billNumber: json['billNumber'] ?? '',
      billAmount: (json['billAmount'] ?? 0).toDouble(),
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? '',
      reference: json['reference'] ?? '',
      bankAccountId: json['bankAccountId'] ?? '',
      bankAccountName: json['bankAccountName'] ?? '',
      notes: json['notes'] ?? '',
      status: json['status'] ?? 'Pending',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
    );
  }
}

class VendorForPayment {
  final String id;
  final String name;
  final String email;
  final String phone;

  VendorForPayment({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory VendorForPayment.fromJson(Map<String, dynamic> json) {
    return VendorForPayment(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}

class BillForPayment {
  final String id;
  final String billNumber;
  final double totalAmount;
  final double paidAmount;
  final double outstanding;
  final DateTime dueDate;
  final String status;

  BillForPayment({
    required this.id,
    required this.billNumber,
    required this.totalAmount,
    required this.paidAmount,
    required this.outstanding,
    required this.dueDate,
    required this.status,
  });

  factory BillForPayment.fromJson(Map<String, dynamic> json) {
    print('🔧 BillForPayment.fromJson: $json');
    return BillForPayment(
      id: json['id'] ?? json['_id'] ?? '',
      billNumber: json['billNumber'] ?? json['billNo'] ?? json['invoiceNo'] ?? '',
      totalAmount: (json['totalAmount'] ?? json['amount'] ?? 0).toDouble(),
      paidAmount: (json['paidAmount'] ?? 0).toDouble(),
      outstanding: (json['outstanding'] ?? json['remainingAmount'] ?? 0).toDouble(),
      dueDate: json['dueDate'] != null 
          ? DateTime.parse(json['dueDate']) 
          : DateTime.now(),
      status: json['status'] ?? '',
    );
  }
}

// Placeholder for BillDetailsScreen - you need to create this
class BillDetailsScreen extends StatelessWidget {
  const BillDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bill Details')),
      body: Center(
        child: Text('Bill Details Screen'),
      ),
    );
  }
}