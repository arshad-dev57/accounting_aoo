import 'dart:convert';
import 'dart:io';
import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/Utils/toast_utils.dart';
import 'package:LedgerPro_app/config/apiconfig.dart';
import 'package:LedgerPro_app/core/CreditNote/models/credit_note_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';

class CreditNoteController extends GetxController {
  // Observable variables
  var creditNotes = <CreditNote>[].obs;
  var customers = <Customer>[].obs;
  var isLoading = true.obs;
  var selectedFilter = 'All'.obs;
  var selectedDateRange = Rxn<DateTimeRange>();
  var searchQuery = ''.obs;
  var isLoadingBills = false.obs;
  var currentCustomerId = ''.obs;
  var unpaidInvoices = <InvoiceForCreditNote>[].obs;
  
  // Filter options
  final List<String> filterOptions = [
    'All',
    'Issued',
    'Applied',
    'Expired',
    'Custom Range'
  ];
  
  // Summary data
  var totalCount = 0.obs;
  var totalAmount = 0.0.obs;
  var appliedAmount = 0.0.obs;
  var remainingAmount = 0.0.obs;
  var expiredAmount = 0.0.obs;
  var thisMonthTotal = 0.0.obs;
  var thisWeekTotal = 0.0.obs;
  
  // Text editing controller
  TextEditingController searchController = TextEditingController();
  final String baseUrl = Apiconfig().baseUrl;
  
  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    loadCreditNotesData();
    loadCustomers();
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
    filterCreditNotes();
  }
  
  // ==================== HELPER: GET TOKEN ====================
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  
  // ==================== HELPER: GET HEADERS ====================
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  
  // ==================== HELPER: FORMAT AMOUNT ====================
  String _formatAmount(double amount) {
    return '\$. ${amount.toStringAsFixed(2)}';
  }
  
  // ==================== LOAD CREDIT NOTES FROM API ====================
  Future<void> loadCreditNotesData() async {
    try {
      isLoading.value = true;
      
      // Build query parameters
      Map<String, dynamic> params = {};
      
      if (selectedFilter.value != 'All' && selectedFilter.value != 'Custom Range') {
        if (selectedFilter.value != 'All') {
          params['status'] = selectedFilter.value;
        }
      }
      
      if (selectedDateRange.value != null) {
        params['startDate'] = DateFormat('yyyy-MM-dd').format(selectedDateRange.value!.start);
        params['endDate'] = DateFormat('yyyy-MM-dd').format(selectedDateRange.value!.end);
      }
      
      if (searchQuery.value.isNotEmpty) {
        params['search'] = searchQuery.value;
      }
      
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl/api/credit-notes').replace(queryParameters: params);
      final response = await http.get(uri, headers: headers);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          List<dynamic> notesData = responseData['data'];
          creditNotes.value = notesData.map((json) => CreditNote.fromJson(json)).toList();
        } else {
          _showError('Failed to load credit notes');
        }
      } else {
        _showError('Failed to load credit notes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading credit notes: $e');
      _showError('Error loading credit notes');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> loadCustomers() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/accounts-receivable/customers'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          List<dynamic> customersData = responseData['data'];
          customers.value = customersData.map((json) => Customer.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print('Error loading customers: $e');
      _showError('Error loading customers');
    }
  }
  
  // ==================== LOAD SUMMARY FROM API ====================
  Future<void> loadSummary() async {
    try {
      Map<String, dynamic> params = {};
      
      if (selectedDateRange.value != null) {
        params['startDate'] = DateFormat('yyyy-MM-dd').format(selectedDateRange.value!.start);
        params['endDate'] = DateFormat('yyyy-MM-dd').format(selectedDateRange.value!.end);
      }
      
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl/api/credit-notes/summary').replace(queryParameters: params);
      final response = await http.get(uri, headers: headers);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final data = responseData['data'];
          totalCount.value = data['totalCount'] ?? 0;
          totalAmount.value = (data['totalAmount'] ?? 0).toDouble();
          appliedAmount.value = (data['appliedAmount'] ?? 0).toDouble();
          remainingAmount.value = (data['remainingAmount'] ?? 0).toDouble();
          expiredAmount.value = (data['expiredAmount'] ?? 0).toDouble();
          thisMonthTotal.value = (data['thisMonth'] ?? 0).toDouble();
          thisWeekTotal.value = (data['thisWeek'] ?? 0).toDouble();
        }
      }
    } catch (e) {
      print('Error loading summary: $e');
    }
  }
  
  // ==================== GET UNPAID INVOICES ====================
  Future<List<InvoiceForCreditNote>> getUnpaidInvoices(String customerId) async {
    try {
      isLoadingBills.value = true;
      currentCustomerId.value = customerId;
      
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/credit-notes/unpaid-invoices/$customerId'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          List<dynamic> invoicesData = responseData['data'];
          unpaidInvoices.value = invoicesData.map((json) => InvoiceForCreditNote.fromJson(json)).toList();
          return unpaidInvoices.value;
        }
      }
      unpaidInvoices.value = [];
      return [];
    } catch (e) {
      print('Error loading unpaid invoices: $e');
      unpaidInvoices.value = [];
      return [];
    } finally {
      isLoadingBills.value = false;
    }
  }
  
  // ==================== CREATE CREDIT NOTE ====================
  Future<void> createCreditNote({
    required String customerId,
    required String originalInvoiceId,
    required double amount,
    required String reason,
    required String reasonType,
    required List<Map<String, dynamic>> items,
    String? notes,
    int? expiryDays,
  }) async {
    try {
      isLoading.value = true;
      
      final Map<String, dynamic> creditNoteData = {
        'customerId': customerId,
        'originalInvoiceId': originalInvoiceId,
        'amount': amount,
        'reason': reason,
        'reasonType': reasonType,
        'items': items,
        'notes': notes ?? '',
      };
      
      if (expiryDays != null) {
        creditNoteData['expiryDays'] = expiryDays;
      }
      
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/credit-notes'),
        headers: headers,
        body: json.encode(creditNoteData),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          Get.back(); // Close dialog
          AppSnackbar.success(kSuccess, 'Success', 'Credit note created successfully\nJournal entry created');
          
          // Refresh data
          loadCreditNotesData();
          loadSummary();
        } else {
          _showError(responseData['message'] ?? 'Failed to create credit note');
        }
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        _showError(errorData['message'] ?? 'Failed to create credit note');
      }
    } catch (e) {
      print('Error creating credit note: $e');
      _showError('Error creating credit note');
    } finally {
      isLoading.value = false;
    }
  }
  
  // ==================== APPLY CREDIT NOTE ====================
  Future<void> applyCreditNote({
    required String creditNoteId,
    required String invoiceId,
    required double amount,
  }) async {
    try {
      isLoading.value = true;
      
      final Map<String, dynamic> applyData = {
        'creditNoteId': creditNoteId,
        'invoiceId': invoiceId,
        'amount': amount,
      };
      
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/credit-notes/apply'),
        headers: headers,
        body: json.encode(applyData),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          Get.back(); // Close any open dialogs
          AppSnackbar.success(kSuccess, 'Success', 'Credit note applied successfully\nInvoice updated');
          
          // Refresh data
          loadCreditNotesData();
          loadSummary();
        } else {
          _showError(responseData['message'] ?? 'Failed to apply credit note');
        }
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        _showError(errorData['message'] ?? 'Failed to apply credit note');
      }
    } catch (e) {
      print('Error applying credit note: $e');
      _showError('Error applying credit note');
    } finally {
      isLoading.value = false;
    }
  }
  
  // ==================== FILTER METHODS ====================
  void applyDateFilter(String filter) {
    selectedFilter.value = filter;
    
    if (filter == 'Custom Range') {
      selectDateRange();
    } else {
      selectedDateRange.value = null;
      loadCreditNotesData();
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
      loadCreditNotesData();
      loadSummary();
    }
  }
  
  void clearDateRange() {
    selectedDateRange.value = null;
    selectedFilter.value = 'All';
    loadCreditNotesData();
    loadSummary();
  }
  
  void filterCreditNotes() {
    loadCreditNotesData();
  }
  
  // ==================== ACTION HANDLERS ====================
  void viewCreditNoteDetails(CreditNote creditNote) {
    _showCreditNoteDetails(creditNote);
  }
  
  void printCreditNote(CreditNote creditNote) {
    AppSnackbar.info('Print', 'Printing credit note ${creditNote.creditNoteNumber}');
  }
  
  // ─────────────────────── EXPORT FUNCTIONS ───────────────────────
  
  void exportCreditNotes() {
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
              'Export Credit Notes',
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
  // ==================== REPLACE THESE TWO METHODS ONLY ====================

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
          _pdfCreditNotesSection(),
        ],
      ),
    );
    
    final bytes = await pdf.save();
    final fileName = 'credit_notes_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
    
    if (kIsWeb) {
      // WEB: Download using HTML anchor tag
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
      
      if (Get.isDialogOpen ?? false) Get.back();
      
      AppSnackbar.success(kSuccess, 'Success', '${creditNotes.length} credit notes exported to PDF');
    } else {
      // MOBILE: Save to file and open
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);
      
      if (Get.isDialogOpen ?? false) Get.back();
      
      AppSnackbar.success(kSuccess, 'Success', '${creditNotes.length} credit notes exported to PDF');
      
      await OpenFile.open(file.path);
    }
  } catch (e) {
    if (Get.isDialogOpen ?? false) Get.back();
    AppSnackbar.error(kDanger, 'Error', 'Failed to export PDF: $e');
  }
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
    
    _excelSetCell(summarySheet, 0, 0, 'Credit Notes Report',
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
      ['Total Credit Notes', totalCount.value.toString()],
      ['Total Amount', _formatAmount(totalAmount.value)],
      ['Applied Amount', _formatAmount(appliedAmount.value)],
      ['Remaining Amount', _formatAmount(remainingAmount.value)],
      ['Expired Amount', _formatAmount(expiredAmount.value)],
      ['This Month', _formatAmount(thisMonthTotal.value)],
      ['This Week', _formatAmount(thisWeekTotal.value)],
    ];
    
    for (int r = 0; r < summaryRows.length; r++) {
      for (int c = 0; c < 2; c++) {
        _excelSetCell(summarySheet, 7 + r, c, summaryRows[r][c],
            bgColor: r.isEven ? 'FFFFFF' : 'F5F5F5');
      }
    }
    summarySheet.setColumnWidth(0, 25);
    summarySheet.setColumnWidth(1, 20);
    
    // Credit Notes Sheet
    final notesSheet = excel['Credit Notes'];
    final headers = [
      'Credit Note #', 'Date', 'Customer', 'Invoice #', 'Invoice Amount',
      'Credit Amount', 'Applied Amount', 'Remaining Amount', 'Reason Type',
      'Reason', 'Expiry Date', 'Status', 'Notes'
    ];
    
    for (int i = 0; i < headers.length; i++) {
      _excelSetCell(notesSheet, 0, i, headers[i],
          bold: true, bgColor: '1A237E', fontColor: 'FFFFFF', fontSize: 10);
    }
    
    int row = 1;
    for (final note in creditNotes) {
      final bg = row.isEven ? 'F5F5F5' : 'FFFFFF';
      _excelSetCell(notesSheet, row, 0, note.creditNoteNumber, bgColor: bg);
      _excelSetCell(notesSheet, row, 1, DateFormat('dd MMM yyyy').format(note.date), bgColor: bg);
      _excelSetCell(notesSheet, row, 2, note.customerName, bgColor: bg);
      _excelSetCell(notesSheet, row, 3, note.originalInvoiceNumber, bgColor: bg);
      _excelSetCell(notesSheet, row, 4, note.originalInvoiceAmount, bgColor: bg);
      _excelSetCell(notesSheet, row, 5, note.amount, bgColor: bg, fontColor: '1A237E');
      _excelSetCell(notesSheet, row, 6, note.appliedAmount, bgColor: bg, fontColor: '2E7D32');
      _excelSetCell(notesSheet, row, 7, note.remainingAmount, bgColor: bg, fontColor: note.remainingAmount > 0 ? 'F39C12' : '2E7D32');
      _excelSetCell(notesSheet, row, 8, note.reasonType, bgColor: bg);
      _excelSetCell(notesSheet, row, 9, note.reason, bgColor: bg);
      _excelSetCell(notesSheet, row, 10, note.expiryDate != null ? DateFormat('dd MMM yyyy').format(note.expiryDate!) : '-', bgColor: bg);
      _excelSetCell(notesSheet, row, 11, note.status, 
          bgColor: note.status == 'Issued' ? 'FFF8E1' : (note.status == 'Applied' ? 'E8F5E9' : 'FFEBEE'),
          fontColor: note.status == 'Issued' ? 'F39C12' : (note.status == 'Applied' ? '2E7D32' : 'C62828'));
      _excelSetCell(notesSheet, row, 12, note.notes.isEmpty ? '-' : note.notes, bgColor: bg);
      row++;
    }
    
    // Totals row
    _excelSetCell(notesSheet, row, 4, 'TOTAL', bold: true, bgColor: 'E8EAF6');
    _excelSetCell(notesSheet, row, 5, totalAmount.value, bold: true, bgColor: 'E8EAF6', fontColor: '1A237E');
    _excelSetCell(notesSheet, row, 6, appliedAmount.value, bold: true, bgColor: 'E8EAF6', fontColor: '2E7D32');
    _excelSetCell(notesSheet, row, 7, remainingAmount.value, bold: true, bgColor: 'E8EAF6', fontColor: 'F39C12');
    
    final colWidths = [18.0, 12.0, 25.0, 15.0, 15.0, 15.0, 15.0, 15.0, 15.0, 25.0, 12.0, 12.0, 30.0];
    for (int i = 0; i < colWidths.length; i++) {
      notesSheet.setColumnWidth(i, colWidths[i]);
    }
    
    // Items Sheet (if there are items)
    final itemsSheet = excel['Credit Note Items'];
    final itemHeaders = ['Credit Note #', 'Description', 'Quantity', 'Unit Price', 'Amount'];
    
    for (int i = 0; i < itemHeaders.length; i++) {
      _excelSetCell(itemsSheet, 0, i, itemHeaders[i],
          bold: true, bgColor: '1A237E', fontColor: 'FFFFFF', fontSize: 10);
    }
    
    int itemRow = 1;
    for (final note in creditNotes) {
      for (final item in note.items) {
        final bg = itemRow.isEven ? 'F5F5F5' : 'FFFFFF';
        _excelSetCell(itemsSheet, itemRow, 0, note.creditNoteNumber, bgColor: bg);
        _excelSetCell(itemsSheet, itemRow, 1, item.description, bgColor: bg);
        _excelSetCell(itemsSheet, itemRow, 2, item.quantity, bgColor: bg);
        _excelSetCell(itemsSheet, itemRow, 3, item.unitPrice, bgColor: bg);
        _excelSetCell(itemsSheet, itemRow, 4, item.amount, bgColor: bg);
        itemRow++;
      }
    }
    
    final itemColWidths = [18.0, 40.0, 10.0, 15.0, 15.0];
    for (int i = 0; i < itemColWidths.length; i++) {
      itemsSheet.setColumnWidth(i, itemColWidths[i]);
    }
    
    excel.delete('Sheet1');
    
    final bytes = excel.save();
    if (bytes == null) throw Exception('Excel save failed');
    
    final fileName = 'credit_notes_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
    
    if (kIsWeb) {
      // WEB: Download Excel
      final blob = html.Blob([bytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
      
      if (Get.isDialogOpen ?? false) Get.back();
      
      AppSnackbar.success(kSuccess, 'Success', '${creditNotes.length} credit notes exported to Excel');
    } else {
      // MOBILE: Save and open
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);
      
      if (Get.isDialogOpen ?? false) Get.back();
      
      AppSnackbar.success(kSuccess, 'Success', '${creditNotes.length} credit notes exported to Excel');
      
      await OpenFile.open(file.path);
    }
  } catch (e) {
    if (Get.isDialogOpen ?? false) Get.back();
    AppSnackbar.error(kDanger, 'Error', 'Failed to export Excel: $e');
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
            pw.Text('Credit Notes Report',
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
              _pdfSummaryItem('Total Credit Notes', totalCount.value.toString(), PdfColors.indigo700),
              _pdfSummaryItem('Total Amount', _formatAmount(totalAmount.value), PdfColors.indigo700),
              _pdfSummaryItem('Applied Amount', _formatAmount(appliedAmount.value), PdfColors.green700),
              _pdfSummaryItem('Remaining', _formatAmount(remainingAmount.value), PdfColors.orange700),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _pdfSummaryItem('Expired', _formatAmount(expiredAmount.value), PdfColors.red700),
              _pdfSummaryItem('This Month', _formatAmount(thisMonthTotal.value), PdfColors.indigo700),
              _pdfSummaryItem('This Week', _formatAmount(thisWeekTotal.value), PdfColors.indigo700),
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
  
  pw.Widget _pdfCreditNotesSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Credit Note Details',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 8),
          decoration: const pw.BoxDecoration(
              border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: 1))),
          child: pw.Row(children: [
            pw.Expanded(flex: 2, child: pw.Text('Credit Note #', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 3, child: pw.Text('Customer', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text('Invoice #', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text('Amount', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text('Applied', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text('Remaining', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text('Status', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          ]),
        ),
        ...creditNotes.map((note) => pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 6),
          decoration: const pw.BoxDecoration(
              border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5))),
          child: pw.Row(children: [
            pw.Expanded(flex: 2, child: pw.Text(note.creditNoteNumber, style: pw.TextStyle(fontSize: 9))),
            pw.Expanded(flex: 2, child: pw.Text(DateFormat('dd/MM/yyyy').format(note.date), style: pw.TextStyle(fontSize: 9))),
            pw.Expanded(flex: 3, child: pw.Text(note.customerName, style: pw.TextStyle(fontSize: 9))),
            pw.Expanded(flex: 2, child: pw.Text(note.originalInvoiceNumber, style: pw.TextStyle(fontSize: 9))),
            pw.Expanded(flex: 2, child: pw.Text(_formatAmount(note.amount), textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9, color: PdfColors.indigo700))),
            pw.Expanded(flex: 2, child: pw.Text(_formatAmount(note.appliedAmount), textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9, color: PdfColors.green700))),
            pw.Expanded(flex: 2, child: pw.Text(_formatAmount(note.remainingAmount), textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9, color: note.remainingAmount > 0 ? PdfColors.orange700 : PdfColors.green700))),
            pw.Expanded(flex: 2, child: pw.Text(note.status, textAlign: pw.TextAlign.center, 
                style: pw.TextStyle(fontSize: 9, color: note.status == 'Issued' ? PdfColors.orange700 : (note.status == 'Applied' ? PdfColors.green700 : PdfColors.red700)))),
          ]),
        )).toList(),
        pw.Divider(),
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 8),
          child: pw.Row(children: [
            pw.Expanded(flex: 9, child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text(_formatAmount(creditNotes.fold(0.0, (sum, n) => sum + n.amount)),
                textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.indigo700))),
            pw.Expanded(flex: 2, child: pw.Text(_formatAmount(creditNotes.fold(0.0, (sum, n) => sum + n.appliedAmount)),
                textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.green700))),
            pw.Expanded(flex: 2, child: pw.Text(_formatAmount(creditNotes.fold(0.0, (sum, n) => sum + n.remainingAmount)),
                textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.orange700))),
          ]),
        ),
      ],
    );
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
  
  void printCreditNotes() {
    AppSnackbar.info('Print', 'Preparing credit notes report...');
  }
  
  // ==================== DIALOG METHODS ====================
  void showCreateCreditNoteDialog() {
    final formKey = GlobalKey<FormState>();
    String selectedCustomerId = '';
    String selectedInvoiceId = '';
    String reason = '';
    String reasonType = 'Return';
    double amount = 0;
    String notes = '';
    List<Map<String, dynamic>> items = [];
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 90.w,
          constraints: BoxConstraints(maxHeight: 85.h),
          padding: EdgeInsets.all(5.w),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Create Credit Note',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: kText,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            // Customer Selection
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Select Customer *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelStyle: TextStyle(fontSize: 12.sp),
                              ),
                              style: TextStyle(fontSize: 14.sp, color: kText),
                              dropdownColor: kCardBg,
                              value: selectedCustomerId.isEmpty ? null : selectedCustomerId,
                              items: customers.map((customer) {
                                return DropdownMenuItem(
                                  value: customer.id,
                                  child: Text(customer.name, style: TextStyle(color: kText)),
                                );
                              }).toList(),
                              onChanged: (value) async {
                                setState(() {
                                  selectedCustomerId = value!;
                                  selectedInvoiceId = '';
                                  amount = 0;
                                });
                                await getUnpaidInvoices(selectedCustomerId);
                                setState(() {}); // Trigger rebuild after loading
                              },
                              validator: (value) => value == null ? 'Customer required' : null,
                            ),
                            SizedBox(height: 2.h),
                            
                            // Invoice Selection
                            if (selectedCustomerId.isNotEmpty) ...[
                              if (isLoadingBills.value)
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(2.h),
                                    child: CircularProgressIndicator(
                                      color: kPrimary,
                                      strokeWidth: 3.w,
                                    ),
                                  ),
                                )
                              else
                                DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    labelText: 'Select Original Invoice *',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    labelStyle: TextStyle(fontSize: 12.sp),
                                  ),
                                  style: TextStyle(fontSize: 14.sp, color: kText),
                                  dropdownColor: kCardBg,
                                  value: selectedInvoiceId.isEmpty ? null : selectedInvoiceId,
                                  items: unpaidInvoices.map((invoice) {
                                    return DropdownMenuItem(
                                      value: invoice.id,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            invoice.invoiceNumber,
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w600,
                                              color: kText,
                                            ),
                                          ),
                                          Text(
                                            'Amount: ${formatAmount(invoice.amount)} • Outstanding: ${formatAmount(invoice.outstanding)}',
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              color: kSubText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedInvoiceId = value!;
                                      final invoice = unpaidInvoices.firstWhere((inv) => inv.id == value);
                                      amount = invoice.outstanding;
                                    });
                                  },
                                  validator: (value) => value == null ? 'Invoice required' : null,
                                ),
                              SizedBox(height: 2.h),
                            ],
                            
                            // Reason Type
                            DropdownButtonFormField<String>(
                              value: reasonType,
                              decoration: InputDecoration(
                                labelText: 'Reason Type *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelStyle: TextStyle(fontSize: 12.sp),
                              ),
                              style: TextStyle(fontSize: 14.sp, color: kText),
                              dropdownColor: kCardBg,
                              items: const [
                                DropdownMenuItem(value: 'Return', child: Text('Product Return')),
                                DropdownMenuItem(value: 'Refund', child: Text('Service Refund')),
                                DropdownMenuItem(value: 'Discount', child: Text('Discount Adjustment')),
                                DropdownMenuItem(value: 'Adjustment', child: Text('Billing Adjustment')),
                              ],
                              onChanged: (value) => setState(() => reasonType = value!),
                            ),
                            SizedBox(height: 2.h),
                            
                            // Reason
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Reason *',
                                hintText: 'e.g., Damaged goods, Service issue',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelStyle: TextStyle(fontSize: 12.sp),
                              ),
                              style: TextStyle(fontSize: 14.sp, color: kText),
                              maxLines: 2,
                              onChanged: (value) => reason = value,
                              validator: (value) => value == null || value.isEmpty ? 'Reason required' : null,
                            ),
                            SizedBox(height: 2.h),
                            
                            // Amount
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Credit Amount *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelStyle: TextStyle(fontSize: 12.sp),
                                prefixText: '\$ ',
                              ),
                              style: TextStyle(fontSize: 14.sp, color: kText),
                              keyboardType: TextInputType.number,
                              initialValue: amount > 0 ? amount.toString() : '',
                              onChanged: (value) => amount = double.tryParse(value) ?? 0,
                              validator: (value) => value == null || value.isEmpty ? 'Amount required' : null,
                            ),
                            SizedBox(height: 2.h),
                            
                            // Notes
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Notes',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelStyle: TextStyle(fontSize: 12.sp),
                              ),
                              style: TextStyle(fontSize: 14.sp, color: kText),
                              maxLines: 2,
                              onChanged: (value) => notes = value,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              items = [
                                {
                                  'description': reason,
                                  'quantity': 1,
                                  'unitPrice': amount,
                                  'amount': amount,
                                }
                              ];
                              
                              createCreditNote(
                                customerId: selectedCustomerId,
                                originalInvoiceId: selectedInvoiceId,
                                amount: amount,
                                reason: reason,
                                reasonType: reasonType,
                                items: items,
                                notes: notes,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimary,
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('Create Credit Note', style: TextStyle(fontSize: 14.sp, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
  
  void showApplyCreditNoteDialog(CreditNote creditNote) {
    final formKey = GlobalKey<FormState>();
    String selectedInvoiceId = '';
    double amount = creditNote.remainingAmount;
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 85.w,
          padding: EdgeInsets.all(5.w),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Apply Credit Note',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: kText,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${creditNote.creditNoteNumber} - ${formatAmount(creditNote.remainingAmount)} remaining',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: kSubText,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        // Invoice Selection
                        FutureBuilder<List<InvoiceForCreditNote>>(
                          future: getUnpaidInvoices(creditNote.customerId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.all(2.h),
                                  child: CircularProgressIndicator(
                                    color: kPrimary,
                                    strokeWidth: 3.w,
                                  ),
                                ),
                              );
                            }
                            
                            final invoices = snapshot.data ?? [];
                            
                            return DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Select Invoice *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelStyle: TextStyle(fontSize: 12.sp),
                              ),
                              style: TextStyle(fontSize: 14.sp, color: kText),
                              dropdownColor: kCardBg,
                              value: selectedInvoiceId.isEmpty ? null : selectedInvoiceId,
                              items: invoices.map((invoice) {
                                return DropdownMenuItem(
                                  value: invoice.id,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        invoice.invoiceNumber,
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w600,
                                          color: kText,
                                        ),
                                      ),
                                      Text(
                                        'Outstanding: ${formatAmount(invoice.outstanding)}',
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          color: kSubText,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedInvoiceId = value!;
                                  final invoice = invoices.firstWhere((inv) => inv.id == value);
                                  if (invoice.outstanding < amount) {
                                    amount = invoice.outstanding;
                                  }
                                });
                              },
                              validator: (value) => value == null ? 'Invoice required' : null,
                            );
                          },
                        ),
                        SizedBox(height: 2.h),
                        
                        // Amount
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Amount to Apply *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            labelStyle: TextStyle(fontSize: 12.sp),
                            prefixText: '\$ ',
                          ),
                          style: TextStyle(fontSize: 14.sp, color: kText),
                          keyboardType: TextInputType.number,
                          initialValue: amount.toString(),
                          onChanged: (value) => amount = double.tryParse(value) ?? 0,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Amount required';
                            }
                            final double amt = double.tryParse(value) ?? 0;
                            if (amt > creditNote.remainingAmount) {
                              return 'Amount cannot exceed remaining amount (${formatAmount(creditNote.remainingAmount)})';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              Get.back();
                              applyCreditNote(
                                creditNoteId: creditNote.id,
                                invoiceId: selectedInvoiceId,
                                amount: amount,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kSuccess,
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('Apply', style: TextStyle(fontSize: 14.sp, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
  
  void _showCreditNoteDetails(CreditNote creditNote) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        constraints: BoxConstraints(
          maxHeight: 85.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 14.w,
                  height: 14.w,
                  decoration: BoxDecoration(
                    color: kWarning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.note, size: 7.w, color: kWarning),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        creditNote.creditNoteNumber,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: kText,
                        ),
                      ),
                      Text(
                        DateFormat('EEEE, dd MMM yyyy').format(creditNote.date),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: kSubText,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                  decoration: BoxDecoration(
                    color: creditNote.status == 'Issued' ? kWarning.withOpacity(0.1) :
                           creditNote.status == 'Applied' ? kSuccess.withOpacity(0.1) : kDanger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    creditNote.status,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: creditNote.status == 'Issued' ? kWarning :
                             creditNote.status == 'Applied' ? kSuccess : kDanger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            _buildDetailRow('Customer', creditNote.customerName),
            _buildDetailRow('Original Invoice', creditNote.originalInvoiceNumber),
            _buildDetailRow('Invoice Amount', formatAmount(creditNote.originalInvoiceAmount)),
            _buildDetailRow('Credit Amount', formatAmount(creditNote.amount)),
            _buildDetailRow('Reason Type', creditNote.reasonType),
            _buildDetailRow('Reason', creditNote.reason),
            _buildDetailRow('Applied Amount', formatAmount(creditNote.appliedAmount)),
            _buildDetailRow('Remaining Amount', formatAmount(creditNote.remainingAmount)),
            if (creditNote.expiryDate != null)
              _buildDetailRow('Expiry Date', DateFormat('dd MMM yyyy').format(creditNote.expiryDate!)),
            if (creditNote.notes.isNotEmpty) _buildDetailRow('Notes', creditNote.notes),
            _buildDetailRow('Created At', DateFormat('dd MMM yyyy, hh:mm a').format(creditNote.createdAt)),
            
            // Items Section
            if (creditNote.items.isNotEmpty) ...[
              SizedBox(height: 2.h),
              Text(
                'Items',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: kText,
                ),
              ),
              SizedBox(height: 1.h),
              ...creditNote.items.map((item) => Container(
                margin: EdgeInsets.only(bottom: 1.h),
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: kBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.description,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: kText,
                            ),
                          ),
                          Text(
                            'Qty: ${item.quantity} x ${formatAmount(item.unitPrice)}',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: kSubText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      formatAmount(item.amount),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: kWarning,
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ],
            
            SizedBox(height: 2.h),
            Row(
              children: [
                if (creditNote.status == 'Issued')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        showApplyCreditNoteDialog(creditNote);
                      },
                      icon: Icon(Icons.check_circle, size: 4.5.w, color: Colors.white),
                      label: Text('Apply to Invoice', style: TextStyle(fontSize: 12.sp)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSuccess,
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      ),
                    ),
                  ),
                if (creditNote.status == 'Issued') SizedBox(width: 3.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.back();
                      printCreditNote(creditNote);
                    },
                    icon: Icon(Icons.print, size: 4.5.w),
                    label: Text('Print', style: TextStyle(fontSize: 12.sp)),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: kSubText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                color: kText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // ==================== HELPER METHODS ====================
  String formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '\$ ${formatter.format(amount)}';
  }
  
  void _showError(String message) {
    AppSnackbar.error(kDanger, 'Error', message);
  }
}