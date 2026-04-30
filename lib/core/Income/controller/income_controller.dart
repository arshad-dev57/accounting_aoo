import 'dart:convert';
import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/Utils/toast_utils.dart';
import 'package:LedgerPro_app/config/apiconfig.dart';
import 'package:LedgerPro_app/core/Income/models/income_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';

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
    required double? amount,
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
          AppSnackbar.success(
            kSuccess,
            'Success',
            'Income recorded successfully\nJournal entry created',
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
        AppSnackbar.success(
          kSuccess,
          'Success',
          'Income $incomeNumber deleted successfully',
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
        AppSnackbar.success(
          kSuccess,
          'Success',
          'Income posted successfully\nJournal entry created',
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
  
  // ==================== EXPORT FUNCTIONS ====================
  
  void exportIncomes() {
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
              'Export Incomes',
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
            _pdfIncomesTable(),
          ],
        ),
      );
      
      final bytes = await pdf.save();
      final fileName = 'incomes_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
      
      if (kIsWeb) {
        // WEB: Download using HTML anchor tag
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
        
        if (Get.isDialogOpen ?? false) Get.back();
        
        AppSnackbar.success(
          kSuccess,
          'Success',
          '${incomes.length} incomes exported to PDF',
          duration: const Duration(seconds: 2),
        );
      } else {
        // MOBILE: Save to file and open
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(bytes);
        
        if (Get.isDialogOpen ?? false) Get.back();
        
        AppSnackbar.success(
          kSuccess,
          'Success',
          '${incomes.length} incomes exported to PDF',
          duration: const Duration(seconds: 2),
        );
        
        await OpenFile.open(file.path);
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      AppSnackbar.error(Colors.red, 'Error', 'Failed to export PDF: $e');
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
            pw.Text('Income Report',
                style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.indigo800)),
            pw.Text(
                'Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
                style: const pw.TextStyle(
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
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
          pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
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
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _pdfSummaryItem('Total Income', formatAmount(totalIncome.value), PdfColors.green700),
          _pdfSummaryItem('Total Tax', formatAmount(totalTax.value), PdfColors.orange700),
          _pdfSummaryItem('Total Records', totalCount.value.toString(), PdfColors.indigo700),
          _pdfSummaryItem('This Month', formatAmount(thisMonthTotal.value), PdfColors.blue700),
          _pdfSummaryItem('This Week', formatAmount(thisWeekTotal.value), PdfColors.purple700),
        ],
      ),
    );
  }
  
  pw.Widget _pdfSummaryItem(String label, String value, PdfColor color) {
    return pw.Column(children: [
      pw.Text(label,
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
      pw.SizedBox(height: 4),
      pw.Text(value,
          style: pw.TextStyle(
              fontSize: 11, fontWeight: pw.FontWeight.bold, color: color)),
    ]);
  }
  
  pw.Widget _pdfIncomesTable() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Income Details',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 8),
          decoration: const pw.BoxDecoration(
              border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: 1))),
          child: pw.Row(children: [
            pw.Expanded(flex: 2, child: pw.Text('Income #', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text('Type', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text('Customer', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text('Amount', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text('Status', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          ]),
        ),
        ...incomes.map((income) => pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 6),
          decoration: const pw.BoxDecoration(
              border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5))),
          child: pw.Row(children: [
            pw.Expanded(flex: 2, child: pw.Text(income.incomeNumber, style: const pw.TextStyle(fontSize: 9))),
            pw.Expanded(flex: 2, child: pw.Text(income.incomeType, style: const pw.TextStyle(fontSize: 9))),
            pw.Expanded(flex: 2, child: pw.Text(income.customerName.isEmpty ? '-' : income.customerName, style: const pw.TextStyle(fontSize: 9))),
            pw.Expanded(flex: 2, child: pw.Text(DateFormat('dd MMM yyyy').format(income.date), style: const pw.TextStyle(fontSize: 9))),
            pw.Expanded(flex: 2, child: pw.Text(formatAmount(income.totalAmount), textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9))),
            pw.Expanded(flex: 2, child: pw.Text(income.status, textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 9))),
          ]),
        )).toList(),
        pw.Divider(),
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 8),
          child: pw.Row(children: [
            pw.Expanded(flex: 8, child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text(formatAmount(totalIncome.value),
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.green700))),
            pw.Expanded(flex: 2, child: pw.Text('', textAlign: pw.TextAlign.center)),
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
      
      _excelSetCell(summarySheet, 0, 0, 'Income Report',
          bold: true, fontSize: 14, bgColor: '1A237E', fontColor: 'FFFFFF');
      _excelSetCell(summarySheet, 1, 0,
          'Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
          fontSize: 9, fontColor: '757575');
      _excelSetCell(summarySheet, 2, 0,
          'Filter: ${selectedFilter.value} | Type: ${selectedType.value}',
          fontSize: 10, fontColor: '1A237E');
      
      _excelSetCell(summarySheet, 4, 0, 'SUMMARY', bold: true, fontSize: 11, bgColor: 'E8EAF6');
      
      final summaryRows = [
        ['Total Income', formatAmount(totalIncome.value)],
        ['Total Tax', formatAmount(totalTax.value)],
        ['Total Records', totalCount.value.toString()],
        ['This Month', formatAmount(thisMonthTotal.value)],
        ['This Week', formatAmount(thisWeekTotal.value)],
      ];
      
      for (int r = 0; r < summaryRows.length; r++) {
        for (int c = 0; c < 2; c++) {
          _excelSetCell(summarySheet, 5 + r, c, summaryRows[r][c],
              bgColor: r.isEven ? 'FFFFFF' : 'F5F5F5');
        }
      }
      summarySheet.setColumnWidth(0, 25);
      summarySheet.setColumnWidth(1, 20);
      
      // Income Details Sheet
      final incomeSheet = excel['Income Details'];
      final headers = [
        'Income #', 'Date', 'Type', 'Customer', 'Description',
        'Reference', 'Subtotal', 'Tax', 'Total', 'Status', 'Payment Method'
      ];
      
      for (int i = 0; i < headers.length; i++) {
        _excelSetCell(incomeSheet, 0, i, headers[i],
            bold: true, bgColor: '1A237E', fontColor: 'FFFFFF', fontSize: 10);
      }
      
      int row = 1;
      for (final income in incomes) {
        final bg = row.isEven ? 'F5F5F5' : 'FFFFFF';
        _excelSetCell(incomeSheet, row, 0, income.incomeNumber, bgColor: bg);
        _excelSetCell(incomeSheet, row, 1, DateFormat('dd/MM/yyyy').format(income.date), bgColor: bg);
        _excelSetCell(incomeSheet, row, 2, income.incomeType, bgColor: bg);
        _excelSetCell(incomeSheet, row, 3, income.customerName.isEmpty ? '-' : income.customerName, bgColor: bg);
        _excelSetCell(incomeSheet, row, 4, income.description, bgColor: bg);
        _excelSetCell(incomeSheet, row, 5, income.reference.isEmpty ? '-' : income.reference, bgColor: bg);
        _excelSetCell(incomeSheet, row, 6, income.subtotal, bgColor: bg);
        _excelSetCell(incomeSheet, row, 7, income.taxAmount, bgColor: bg);
        _excelSetCell(incomeSheet, row, 8, income.totalAmount, bgColor: bg, fontColor: '2E7D32');
        _excelSetCell(incomeSheet, row, 9, income.status, 
            bgColor: income.status == 'Posted' ? 'E8F5E9' : 'FFF8E1',
            fontColor: income.status == 'Posted' ? '2E7D32' : 'F39C12');
        _excelSetCell(incomeSheet, row, 10, income.paymentMethod, bgColor: bg);
        row++;
      }
      
      final colWidths = [14.0, 12.0, 15.0, 25.0, 30.0, 15.0, 12.0, 12.0, 12.0, 10.0, 15.0];
      for (int i = 0; i < colWidths.length; i++) {
        incomeSheet.setColumnWidth(i, colWidths[i]);
      }
      
      excel.delete('Sheet1');
      
      final bytes = excel.save();
      if (bytes == null) throw Exception('Excel save failed');
      
      final fileName = 'incomes_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
      
      if (kIsWeb) {
        // WEB: Download Excel
        final blob = html.Blob([bytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
        
        if (Get.isDialogOpen ?? false) Get.back();
        
        AppSnackbar.success(
          kSuccess,
          'Success',
          '${incomes.length} incomes exported to Excel',
          duration: const Duration(seconds: 2),
        );
      } else {
        // MOBILE: Save and open
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(bytes);
        
        if (Get.isDialogOpen ?? false) Get.back();
        
        AppSnackbar.success(
          kSuccess,
          'Success',
          '${incomes.length} incomes exported to Excel',
          duration: const Duration(seconds: 2),
        );
        
        await OpenFile.open(file.path);
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      AppSnackbar.error(Colors.red, 'Error', 'Failed to export Excel: $e');
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
  
  void printIncomes() {
    AppSnackbar.success(
      kPrimary,
      'Print',
      'Preparing income report...');
  }
  
  String formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '\$ ${formatter.format(amount)}';
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
    AppSnackbar.error(Colors.red, 'Error', message);
  }
}