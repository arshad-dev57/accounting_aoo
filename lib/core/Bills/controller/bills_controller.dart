import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/Utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
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

class BillsController extends GetxController {
  var bills = <Bill>[].obs;
  var vendors = <Map<String, dynamic>>[].obs;
  var bankAccounts = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var isProcessing = false.obs;
  var selectedFilter = 'All'.obs;
  var selectedVendorId = ''.obs;
  var startDate = Rx<DateTime?>(null);
  var endDate = Rx<DateTime?>(null);
  
  // Summary totals
  var totalAmount = 0.0.obs;
  var totalPaid = 0.0.obs;
  var totalOutstanding = 0.0.obs;
  
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
    return '\$. ${amount.toStringAsFixed(2)}';
  }
  
  @override
  void onInit() {
    super.onInit();
    fetchVendors();
    fetchBankAccounts();
    fetchBills();
  }
  
  Future<void> fetchVendors() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/accounts-payable/vendors'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          vendors.value = (data['data'] as List).map((e) {
            return {
              '_id': e['_id'].toString(),
              'id': e['_id'].toString(),
              'name': e['name'],
            };
          }).toList();
          
          if (selectedVendorId.value.isNotEmpty) {
            bool vendorExists = vendors.value.any((v) => v['_id'] == selectedVendorId.value);
            if (!vendorExists) {
              selectedVendorId.value = '';
            } else {
              fetchBills();
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching vendors: $e');
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
          bankAccounts.value = List<Map<String, dynamic>>.from(data['data']);
        }
      }
    } catch (e) {
      print('Error fetching bank accounts: $e');
    }
  }
  
  Future<void> fetchBills() async {
    try {
      isLoading(true);
      
      String url = '$baseUrl/api/accounts-payable/bills';
      List<String> queryParams = [];
      
      if (selectedFilter.value != 'All') {
        queryParams.add('status=${selectedFilter.value}');
      }
      
      if (selectedVendorId.value.isNotEmpty) {
        queryParams.add('vendorId=${selectedVendorId.value}');
      }
      
      if (startDate.value != null) {
        queryParams.add('startDate=${startDate.value!.toIso8601String()}');
      }
      
      if (endDate.value != null) {
        queryParams.add('endDate=${endDate.value!.toIso8601String()}');
      }
      
      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }
      
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          bills.value = (data['data'] as List)
              .map((e) => Bill.fromJson(e))
              .toList();
          _calculateSummary();
        }
      }
    } catch (e) {
    } finally {
      isLoading(false);
    }
  }
  
  void _calculateSummary() {
    totalAmount.value = bills.fold(0.0, (sum, b) => sum + b.totalAmount);
    totalPaid.value = bills.fold(0.0, (sum, b) => sum + b.paidAmount);
    totalOutstanding.value = totalAmount.value - totalPaid.value;
  }
  
  Future<void> createBill(Map<String, dynamic> billData) async {
    try {
      isProcessing(true);
      
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/accounts-payable/bills'),
        headers: headers,
        body: jsonEncode(billData),
      );
      
      if (response.statusCode == 201) {
        AppSnackbar.success(
          Colors.green,
          'Success',
          'Bill created successfully!\nJournal entry created',
        );
        await fetchBills();
      } else {
        final data = jsonDecode(response.body);
        AppSnackbar.error(Colors.red, 'Error', data['message'] ?? 'Failed to create bill');
      }
    } catch (e) {
      AppSnackbar.error(Colors.red, 'Error', 'Failed to create bill: $e');
    } finally {
      isProcessing(false);
    }
  }
  
  Future<void> recordPayment({
    required String billId,
    required double amount,
    required DateTime paymentDate,
    required String paymentMethod,
    required String reference,
    required String bankAccountId,
  }) async {
    try {
      isProcessing(true);
      
      final body = {
        'billId': billId,
        'amount': amount,
        'paymentDate': paymentDate.toIso8601String(),
        'paymentMethod': paymentMethod,
        'reference': reference,
        'bankAccountId': bankAccountId,
      };
      
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/accounts-payable/payments'),
        headers: headers,
        body: jsonEncode(body),
      );
      
      if (response.statusCode == 200) {
        AppSnackbar.success(
          Colors.green,
          'Success',
          'Payment recorded successfully!\nJournal entry created',
        );
        await fetchBills();
      } else {
        final errorData = jsonDecode(response.body);
        AppSnackbar.error(Colors.red, 'Error', errorData['message'] ?? 'Failed to record payment');
      }
    } catch (e) {
      AppSnackbar.error(Colors.red, 'Error', 'Failed to record payment: $e');
    } finally {
      isProcessing(false);
    }
  }
  
  void changeFilter(String filter) {
    selectedFilter.value = filter;
    fetchBills();
  }
  
  void filterByVendor(String vendorId) {
    selectedVendorId.value = vendorId;
    fetchBills();
  }
  
  void setDateRange(DateTime? start, DateTime? end) {
    startDate.value = start;
    endDate.value = end;
    fetchBills();
  }
  
  void clearFilters() {
    selectedFilter.value = 'All';
    selectedVendorId.value = '';
    startDate.value = null;
    endDate.value = null;
    fetchBills();
  }
  
  Bill? getBillById(String id) {
    try {
      return bills.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }
  
  List<Bill> getUnpaidBillsForVendor(String vendorId) {
    return bills.where((b) => b.vendorId == vendorId && b.status != 'Paid').toList();
  }
  
  // ─────────────────────── EXPORT FUNCTIONS ───────────────────────
  
  void exportBills() {
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
              'Export Bills',
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
            _pdfBillsSection(),
          ],
        ),
      );
      
      final bytes = await pdf.save();
      final fileName = 'bills_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
      
      if (kIsWeb) {
        // WEB: Download using HTML anchor tag
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
        
        if (Get.isDialogOpen ?? false) Get.back();
        
        AppSnackbar.success(Colors.green, 'Success', '${bills.length} bills exported to PDF');
      } else {
        // MOBILE: Save to file and open
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(bytes);
        
        if (Get.isDialogOpen ?? false) Get.back();
        
        AppSnackbar.success(Colors.green, 'Success', '${bills.length} bills exported to PDF');
        
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
            pw.Text('Bills Report',
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
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _pdfSummaryItem('Total Bills', bills.length.toString(), PdfColors.indigo700),
          _pdfSummaryItem('Total Amount', _formatAmount(totalAmount.value), PdfColors.indigo700),
          _pdfSummaryItem('Total Paid', _formatAmount(totalPaid.value), PdfColors.green700),
          _pdfSummaryItem('Outstanding', _formatAmount(totalOutstanding.value), PdfColors.red700),
          _pdfSummaryItem('Filter', selectedFilter.value, PdfColors.grey700),
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
  
  pw.Widget _pdfBillsSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Bill Details',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 8),
          decoration: const pw.BoxDecoration(
              border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: 1))),
          child: pw.Row(children: [
            pw.Expanded(flex: 2, child: pw.Text('Bill #', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 3, child: pw.Text('Vendor', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text('Due Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text('Amount', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text('Paid', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 3, child: pw.Text('Outstanding', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text('Status', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          ]),
        ),
        ...bills.map((bill) => pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 6),
          decoration: const pw.BoxDecoration(
              border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5))),
          child: pw.Row(children: [
            pw.Expanded(flex: 2, child: pw.Text(bill.billNumber, style: pw.TextStyle(fontSize: 9))),
            pw.Expanded(flex: 3, child: pw.Text(bill.vendorName, style: pw.TextStyle(fontSize: 9))),
            pw.Expanded(flex: 2, child: pw.Text(DateFormat('dd/MM/yyyy').format(bill.date), style: pw.TextStyle(fontSize: 9))),
            pw.Expanded(flex: 2, child: pw.Text(DateFormat('dd/MM/yyyy').format(bill.dueDate), style: pw.TextStyle(fontSize: 9))),
            pw.Expanded(flex: 2, child: pw.Text(_formatAmount(bill.totalAmount), textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9))),
            pw.Expanded(flex: 2, child: pw.Text(_formatAmount(bill.paidAmount), textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9, color: PdfColors.green700))),
            pw.Expanded(flex: 2, child: pw.Text(_formatAmount(bill.outstanding), textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9, color: bill.outstanding > 0 ? PdfColors.red700 : PdfColors.green700))),
            pw.Expanded(flex: 2, child: pw.Text(bill.status, textAlign: pw.TextAlign.right, 
                style: pw.TextStyle(fontSize: 9, color: bill.status == 'Paid' ? PdfColors.green700 : (bill.isOverdue ? PdfColors.red700 : PdfColors.orange700)))),
          ]),
        )).toList(),
        pw.Divider(),
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 8),
          child: pw.Row(children: [
            pw.Expanded(flex: 7, child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text(_formatAmount(totalAmount.value),
                textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.indigo700))),
            pw.Expanded(flex: 2, child: pw.Text(_formatAmount(totalPaid.value),
                textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.green700))),
            pw.Expanded(flex: 2, child: pw.Text(_formatAmount(totalOutstanding.value),
                textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.red700))),
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
      
      _excelSetCell(summarySheet, 0, 0, 'Bills Report',
          bold: true, fontSize: 14, bgColor: '1A237E', fontColor: 'FFFFFF');
      _excelSetCell(summarySheet, 1, 0,
          'Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
          fontSize: 9, fontColor: '757575');
      _excelSetCell(summarySheet, 2, 0,
          'Filter: ${selectedFilter.value}',
          fontSize: 10, fontColor: '1A237E');
      if (selectedVendorId.value.isNotEmpty) {
        final vendor = vendors.firstWhere((v) => v['_id'] == selectedVendorId.value, orElse: () => {});
        _excelSetCell(summarySheet, 3, 0,
          'Vendor: ${vendor['name'] ?? ''}',
          fontSize: 10, fontColor: '1A237E');
      }
      
      _excelSetCell(summarySheet, 5, 0, 'SUMMARY', bold: true, fontSize: 11, bgColor: 'E8EAF6');
      
      final summaryRows = [
        ['Total Bills', bills.length.toString()],
        ['Total Amount', _formatAmount(totalAmount.value)],
        ['Total Paid', _formatAmount(totalPaid.value)],
        ['Total Outstanding', _formatAmount(totalOutstanding.value)],
      ];
      
      for (int r = 0; r < summaryRows.length; r++) {
        for (int c = 0; c < 2; c++) {
          _excelSetCell(summarySheet, 6 + r, c, summaryRows[r][c],
              bgColor: r.isEven ? 'FFFFFF' : 'F5F5F5');
        }
      }
      summarySheet.setColumnWidth(0, 25);
      summarySheet.setColumnWidth(1, 20);
      
      // Bills Sheet
      final billsSheet = excel['Bills'];
      final headers = [
        'Bill #', 'Vendor', 'Date', 'Due Date', 'Subtotal', 'Tax', 'Discount',
        'Total Amount', 'Paid Amount', 'Outstanding', 'Status', 'Notes'
      ];
      
      for (int i = 0; i < headers.length; i++) {
        _excelSetCell(billsSheet, 0, i, headers[i],
            bold: true, bgColor: '1A237E', fontColor: 'FFFFFF', fontSize: 10);
      }
      
      int row = 1;
      for (final bill in bills) {
        final bg = row.isEven ? 'F5F5F5' : 'FFFFFF';
        _excelSetCell(billsSheet, row, 0, bill.billNumber, bgColor: bg);
        _excelSetCell(billsSheet, row, 1, bill.vendorName, bgColor: bg);
        _excelSetCell(billsSheet, row, 2, DateFormat('dd MMM yyyy').format(bill.date), bgColor: bg);
        _excelSetCell(billsSheet, row, 3, DateFormat('dd MMM yyyy').format(bill.dueDate), bgColor: bg);
        _excelSetCell(billsSheet, row, 4, bill.subtotal, bgColor: bg);
        _excelSetCell(billsSheet, row, 5, bill.taxTotal, bgColor: bg);
        _excelSetCell(billsSheet, row, 6, bill.discount, bgColor: bg);
        _excelSetCell(billsSheet, row, 7, bill.totalAmount, bgColor: bg, fontColor: '1A237E');
        _excelSetCell(billsSheet, row, 8, bill.paidAmount, bgColor: bg, fontColor: '2E7D32');
        _excelSetCell(billsSheet, row, 9, bill.outstanding, bgColor: bg, fontColor: bill.outstanding > 0 ? 'C62828' : '2E7D32');
        _excelSetCell(billsSheet, row, 10, bill.status, 
            bgColor: bill.status == 'Paid' ? 'E8F5E9' : (bill.isOverdue ? 'FFEBEE' : 'FFF8E1'),
            fontColor: bill.status == 'Paid' ? '2E7D32' : (bill.isOverdue ? 'C62828' : 'F39C12'));
        _excelSetCell(billsSheet, row, 11, bill.notes, bgColor: bg);
        row++;
      }
      
      // Totals row
      _excelSetCell(billsSheet, row, 7, 'TOTAL', bold: true, bgColor: 'E8EAF6');
      _excelSetCell(billsSheet, row, 8, totalPaid.value, bold: true, bgColor: 'E8EAF6', fontColor: '2E7D32');
      _excelSetCell(billsSheet, row, 9, totalOutstanding.value, bold: true, bgColor: 'E8EAF6', fontColor: 'C62828');
      
      final colWidths = [15.0, 25.0, 12.0, 12.0, 12.0, 12.0, 12.0, 15.0, 15.0, 15.0, 12.0, 30.0];
      for (int i = 0; i < colWidths.length; i++) {
        billsSheet.setColumnWidth(i, colWidths[i]);
      }
      
      // Items Sheet
      final itemsSheet = excel['Bill Items'];
      final itemHeaders = ['Bill #', 'Vendor', 'Description', 'Quantity', 'Unit Price', 'Amount', 'Tax Rate', 'Tax Amount'];
      
      for (int i = 0; i < itemHeaders.length; i++) {
        _excelSetCell(itemsSheet, 0, i, itemHeaders[i],
            bold: true, bgColor: '1A237E', fontColor: 'FFFFFF', fontSize: 10);
      }
      
      int itemRow = 1;
      for (final bill in bills) {
        for (final item in bill.items) {
          final bg = itemRow.isEven ? 'F5F5F5' : 'FFFFFF';
          _excelSetCell(itemsSheet, itemRow, 0, bill.billNumber, bgColor: bg);
          _excelSetCell(itemsSheet, itemRow, 1, bill.vendorName, bgColor: bg);
          _excelSetCell(itemsSheet, itemRow, 2, item.description, bgColor: bg);
          _excelSetCell(itemsSheet, itemRow, 3, item.quantity, bgColor: bg);
          _excelSetCell(itemsSheet, itemRow, 4, item.unitPrice, bgColor: bg);
          _excelSetCell(itemsSheet, itemRow, 5, item.amount, bgColor: bg);
          _excelSetCell(itemsSheet, itemRow, 6, item.taxRate, bgColor: bg);
          _excelSetCell(itemsSheet, itemRow, 7, item.taxAmount, bgColor: bg);
          itemRow++;
        }
      }
      
      final itemColWidths = [15.0, 25.0, 40.0, 10.0, 12.0, 12.0, 10.0, 12.0];
      for (int i = 0; i < itemColWidths.length; i++) {
        itemsSheet.setColumnWidth(i, itemColWidths[i]);
      }
      
      excel.delete('Sheet1');
      
      final bytes = excel.save();
      if (bytes == null) throw Exception('Excel save failed');
      
      final fileName = 'bills_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
      
      if (kIsWeb) {
        // WEB: Download Excel
        final blob = html.Blob([bytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
        
        if (Get.isDialogOpen ?? false) Get.back();
        
        AppSnackbar.success(Colors.green, 'Success', '${bills.length} bills exported to Excel');
      } else {
        // MOBILE: Save and open
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(bytes);
        
        if (Get.isDialogOpen ?? false) Get.back();
        
        AppSnackbar.success(Colors.green, 'Success', '${bills.length} bills exported to Excel');
        
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
}

class Bill {
  final String id;
  final String billNumber;
  final String vendorId;
  final String vendorName;
  final DateTime date;
  final DateTime dueDate;
  final List<BillItem> items;
  final double subtotal;
  final double taxTotal;
  final double discount;
  final double totalAmount;
  final double paidAmount;
  final String status;
  final String notes;
  
  Bill({
    required this.id,
    required this.billNumber,
    required this.vendorId,
    required this.vendorName,
    required this.date,
    required this.dueDate,
    required this.items,
    required this.subtotal,
    required this.taxTotal,
    required this.discount,
    required this.totalAmount,
    required this.paidAmount,
    required this.status,
    required this.notes,
  });
  
  double get outstanding => totalAmount - paidAmount;
  bool get isOverdue => dueDate.isBefore(DateTime.now()) && status != 'Paid';
  
  factory Bill.fromJson(Map<String, dynamic> json) {
    double safeToDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }
    
    return Bill(
      id: json['_id'],
      billNumber: json['billNumber'],
      vendorId: json['vendorId']['_id']?.toString() ?? json['vendorId']?.toString() ?? '',
      vendorName: json['vendorName'],
      date: DateTime.parse(json['date']),
      dueDate: DateTime.parse(json['dueDate']),
      items: (json['items'] as List).map((e) => BillItem.fromJson(e)).toList(),
      subtotal: safeToDouble(json['subtotal']),
      taxTotal: safeToDouble(json['taxTotal']),
      discount: safeToDouble(json['discount']),
      totalAmount: safeToDouble(json['totalAmount']),
      paidAmount: safeToDouble(json['paidAmount']),
      status: json['status'] ?? 'Unpaid',
      notes: json['notes'] ?? '',
    );
  }
}

class BillItem {
  final String description;
  final int quantity;
  final double unitPrice;
  final double amount;
  final double taxRate;
  final double taxAmount;
  
  BillItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.amount,
    required this.taxRate,
    required this.taxAmount,
  });
  
  factory BillItem.fromJson(Map<String, dynamic> json) {
    double safeToDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }
    
    return BillItem(
      description: json['description'],
      quantity: json['quantity'],
      unitPrice: safeToDouble(json['unitPrice']),
      amount: safeToDouble(json['amount']),
      taxRate: safeToDouble(json['taxRate']),
      taxAmount: safeToDouble(json['taxAmount']),
    );
  }
}