import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/core/Invoice/Screens/Invoice_Screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:LedgerPro_app/config/apiconfig.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';

class PaymentReceivedController extends GetxController {
  var payments = <Payment>[].obs;
  var customers = <Customer>[].obs;
  var bankAccounts = <BankAccount>[].obs;
  var unpaidInvoices = <InvoiceForPayment>[].obs;
  
  var isLoading = true.obs;
  var isRecording = false.obs;
  var selectedFilter = 'All'.obs;
  var selectedDateRange = Rx<DateTimeRange?>(null);
  var searchQuery = ''.obs;
  
  // Summary totals
  var totalReceived = 0.0.obs;
  var thisMonth = 0.0.obs;
  var thisWeek = 0.0.obs;
  var today = 0.0.obs;
  var pendingCount = 0.obs;
  
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
  
  String _formatAmount(double amount) {
    return 'Rs. ${amount.toStringAsFixed(2)}';
  }
  
  @override
  void onInit() {
    super.onInit();
    fetchCustomers();
    fetchBankAccounts();
    fetchPayments();
    fetchSummary();
  }
  
  Future<void> fetchCustomers() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/accounts-receivable/customers'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          customers.value = (data['data'] as List)
              .map((e) => Customer.fromJson(e))
              .toList();
        }
      }
    } catch (e) {
      print('Error fetching customers: $e');
    }
  }
  
  Future<void> fetchBankAccounts() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/bank-accounts'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          bankAccounts.value = (data['data'] as List)
              .map((e) => BankAccount.fromJson(e))
              .toList();
        }
      }
    } catch (e) {
      print('Error fetching bank accounts: $e');
    }
  }
  
  Future<void> fetchUnpaidInvoices(String customerId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/payments-received/invoices/unpaid/$customerId'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          unpaidInvoices.value = (data['data'] as List)
              .map((e) => InvoiceForPayment.fromJson(e))
              .toList();
        }
      }
    } catch (e) {
      print('Error fetching unpaid invoices: $e');
    }
  }
  
  Future<void> fetchPayments() async {
    try {
      isLoading(true);
      
      String url = '$baseUrl/api/payments-received';
      List<String> queryParams = [];
      
      if (searchQuery.value.isNotEmpty) {
        queryParams.add('search=${searchQuery.value}');
      }
      
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
          payments.value = (data['data'] as List)
              .map((e) => Payment.fromJson(e))
              .toList();
        }
      } else if (response.statusCode == 401) {
        _handleSessionExpired();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load payments: $e');
    } finally {
      isLoading(false);
    }
  }
  
  Future<void> fetchSummary() async {
    try {
      String url = '$baseUrl/api/payments-received/summary';
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
          totalReceived.value = _toDouble(data['data']['totalReceived']);
          thisMonth.value = _toDouble(data['data']['thisMonth']);
          thisWeek.value = _toDouble(data['data']['thisWeek']);
          today.value = _toDouble(data['data']['today']);
          pendingCount.value = data['data']['pending'] ?? 0;
        }
      }
    } catch (e) {
      print('Error fetching summary: $e');
    }
  }
  
  Future<void> recordPayment({
    required String customerId,
    required String invoiceId,
    required double amount,
    required DateTime paymentDate,
    required String paymentMethod,
    required String reference,
    required String bankAccountId,
    required String notes,
  }) async {
    try {
      isRecording(true);
      
      final body = {
        'customerId': customerId,
        'invoiceId': invoiceId,
        'amount': amount,
        'paymentDate': paymentDate.toIso8601String(),
        'paymentMethod': paymentMethod,
        'reference': reference,
        'bankAccountId': bankAccountId,
        'notes': notes,
      };
      
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/payments-received'),
        headers: headers,
        body: jsonEncode(body),
      );
      
      if (response.statusCode == 201) {
        Get.snackbar(
          'Success',
          'Payment recorded successfully!\nJournal entry created',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: kSuccess,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        await fetchPayments();
        await fetchSummary();
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar(
          'Error',
          errorData['message'] ?? 'Failed to record payment',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: kDanger,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to record payment: $e');
    } finally {
      isRecording(false);
    }
  }
  
  void changeFilter(String filter) {
    selectedFilter.value = filter;
    if (filter != 'Custom Range') {
      selectedDateRange.value = null;
      _applyDateFilter(filter);
    }
    fetchPayments();
    fetchSummary();
  }
  
  void setDateRange(DateTimeRange? range) {
    selectedDateRange.value = range;
    if (range != null) {
      selectedFilter.value = 'Custom Range';
    }
    fetchPayments();
    fetchSummary();
  }
  
  void searchPayments(String query) {
    searchQuery.value = query;
    fetchPayments();
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
      default:
        selectedDateRange.value = null;
    }
  }
  
  void viewInvoice(Payment payment) {
    Get.to(() => const InvoicesScreen());
  }
  
  void printReceipt(Payment payment) {
    Get.snackbar(
      'Print',
      'Printing receipt for ${payment.id}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: kPrimary,
      colorText: Colors.white,
    );
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
              title:Text('Export as PDF'),
              onTap: () {
                Get.back();
                exportToPdf();
              },
            ),
            ListTile(
              leading: Icon(Icons.table_chart, color: Color(0xFF2E7D32)),
              title:Text('Export as Excel'),
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
      
      final dir = await getTemporaryDirectory();
      final fileName = 'payments_received_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(await pdf.save());
      
      if (Get.isDialogOpen ?? false) Get.back();
      
      Get.snackbar('Success', '${payments.length} payments exported to PDF',
          backgroundColor: const Color(0xFF2ECC71),
          colorText: Colors.white,
          duration: const Duration(seconds: 2));
      
      await OpenFile.open(file.path);
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar('Error', 'Failed to export PDF: $e');
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
            pw.Text('Payments Received Report',
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
              _pdfSummaryItem('Total Received', _formatAmount(totalReceived.value), PdfColors.green700),
              _pdfSummaryItem('This Month', _formatAmount(thisMonth.value), PdfColors.indigo700),
              _pdfSummaryItem('This Week', _formatAmount(thisWeek.value), PdfColors.indigo700),
              _pdfSummaryItem('Today', _formatAmount(today.value), PdfColors.indigo700),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _pdfSummaryItem('Total Payments', payments.length.toString(), PdfColors.grey700),
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
            pw.Expanded(flex: 3, child: pw.Text('Customer', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text('Invoice #', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
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
            pw.Expanded(flex: 3, child: pw.Text(payment.customerName, style: pw.TextStyle(fontSize: 9))),
            pw.Expanded(flex: 2, child: pw.Text(payment.invoiceNumber, style: pw.TextStyle(fontSize: 9))),
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
      
      final excel = Excel.createExcel();
      
      // Summary Sheet
      final summarySheet = excel['Summary'];
      excel.setDefaultSheet('Summary');
      
      _excelSetCell(summarySheet, 0, 0, 'Payments Received Report',
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
        ['Total Received', _formatAmount(totalReceived.value)],
        ['This Month', _formatAmount(thisMonth.value)],
        ['This Week', _formatAmount(thisWeek.value)],
        ['Today', _formatAmount(today.value)],
        ['Total Payments', payments.length.toString()],
        ['Total Amount', _formatAmount(payments.fold(0.0, (sum, p) => sum + p.amount))],
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
        'Payment #', 'Date', 'Customer', 'Invoice #', 'Invoice Amount', 
        'Amount Paid', 'Payment Method', 'Reference', 'Bank Account', 'Notes'
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
        _excelSetCell(paymentsSheet, row, 2, payment.customerName, bgColor: bg);
        _excelSetCell(paymentsSheet, row, 3, payment.invoiceNumber, bgColor: bg);
        _excelSetCell(paymentsSheet, row, 4, payment.invoiceAmount, bgColor: bg);
        _excelSetCell(paymentsSheet, row, 5, payment.amount, bgColor: bg, fontColor: '2E7D32');
        _excelSetCell(paymentsSheet, row, 6, payment.paymentMethod, bgColor: bg);
        _excelSetCell(paymentsSheet, row, 7, payment.reference.isEmpty ? '-' : payment.reference, bgColor: bg);
        _excelSetCell(paymentsSheet, row, 8, payment.bankAccountName.isEmpty ? '-' : payment.bankAccountName, bgColor: bg);
        _excelSetCell(paymentsSheet, row, 9, payment.notes.isEmpty ? '-' : payment.notes, bgColor: bg);
        row++;
      }
      
      // Totals row
      _excelSetCell(paymentsSheet, row, 4, 'TOTAL', bold: true, bgColor: 'E8EAF6');
      _excelSetCell(paymentsSheet, row, 5, payments.fold(0.0, (sum, p) => sum + p.amount), 
          bold: true, bgColor: 'E8EAF6', fontColor: '2E7D32');
      
      final colWidths = [15.0, 12.0, 25.0, 15.0, 15.0, 15.0, 15.0, 15.0, 20.0, 30.0];
      for (int i = 0; i < colWidths.length; i++) {
        paymentsSheet.setColumnWidth(i, colWidths[i]);
      }
      
      excel.delete('Sheet1');
      
      final bytes = excel.save();
      if (bytes == null) throw Exception('Excel save failed');
      
      final dir = await getTemporaryDirectory();
      final fileName = 'payments_received_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);
      
      if (Get.isDialogOpen ?? false) Get.back();
      
      Get.snackbar('Success', '${payments.length} payments exported to Excel',
          backgroundColor: const Color(0xFF2ECC71),
          colorText: Colors.white,
          duration: const Duration(seconds: 2));
          
      await OpenFile.open(file.path);
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar('Error', 'Failed to export Excel: $e');
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
    Get.snackbar(
      'Print',
      'Preparing payments report...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: kPrimary,
      colorText: Colors.white,
    );
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

class Payment {
  final String id;
  final String paymentNumber;
  final DateTime paymentDate;
  final String customerId;
  final String customerName;
  final String invoiceId;
  final String invoiceNumber;
  final double invoiceAmount;
  final double amount;
  final String paymentMethod;
  final String reference;
  final String bankAccountId;
  final String bankAccountName;
  final String notes;
  final String status;
  final DateTime createdAt;
  
  Payment({
    required this.id,
    required this.paymentNumber,
    required this.paymentDate,
    required this.customerId,
    required this.customerName,
    required this.invoiceId,
    required this.invoiceNumber,
    required this.invoiceAmount,
    required this.amount,
    required this.paymentMethod,
    required this.reference,
    required this.bankAccountId,
    required this.bankAccountName,
    required this.notes,
    required this.status,
    required this.createdAt,
  });
  
  factory Payment.fromJson(Map<String, dynamic> json) {
    double safeToDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }
    
    return Payment(
      id: json['_id'],
      paymentNumber: json['paymentNumber'],
      paymentDate: DateTime.parse(json['paymentDate']),
      customerId: json['customerId']['_id'] ?? json['customerId'],
      customerName: json['customerName'],
      invoiceId: json['invoiceId']['_id'] ?? json['invoiceId'],
      invoiceNumber: json['invoiceNumber'],
      invoiceAmount: safeToDouble(json['invoiceAmount']),
      amount: safeToDouble(json['amount']),
      paymentMethod: json['paymentMethod'],
      reference: json['reference'] ?? '',
      bankAccountId: json['bankAccountId'] ?? '',
      bankAccountName: json['bankAccountName'] ?? '',
      notes: json['notes'] ?? '',
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;
  
  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });
  
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['_id'],
      name: json['name'],
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}

class BankAccount {
  final String id;
  final String name;
  final String number;
  final double balance;
  
  BankAccount({
    required this.id,
    required this.name,
    required this.number,
    required this.balance,
  });
  
  factory BankAccount.fromJson(Map<String, dynamic> json) {
    double safeToDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }
    
    return BankAccount(
      id: json['_id'],
      name: json['accountName'],
      number: json['accountNumber'],
      balance: safeToDouble(json['currentBalance']),
    );
  }
}

class InvoiceForPayment {
  final String id;
  final String invoiceNumber;
  final DateTime date;
  final DateTime dueDate;
  final double totalAmount;
  final double paidAmount;
  final double outstanding;
  final String status;
  
  InvoiceForPayment({
    required this.id,
    required this.invoiceNumber,
    required this.date,
    required this.dueDate,
    required this.totalAmount,
    required this.paidAmount,
    required this.outstanding,
    required this.status,
  });
  
  factory InvoiceForPayment.fromJson(Map<String, dynamic> json) {
    double safeToDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }
    
    return InvoiceForPayment(
      id: json['id'],
      invoiceNumber: json['invoiceNumber'],
      date: DateTime.parse(json['date']),
      dueDate: DateTime.parse(json['dueDate']),
      totalAmount: safeToDouble(json['totalAmount']),
      paidAmount: safeToDouble(json['paidAmount']),
      outstanding: safeToDouble(json['outstanding']),
      status: json['status'],
    );
  }
}