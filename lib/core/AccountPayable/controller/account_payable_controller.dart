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

class AccountsPayableController extends GetxController {
  var vendors = <Vendor>[].obs;
  var bills = <Bill>[].obs;
  var isLoading = true.obs;
  var isProcessing = false.obs;
  var selectedFilter = 'All'.obs;
  var selectedVendorId = ''.obs;
  var startDate = Rx<DateTime?>(null);
  var endDate = Rx<DateTime?>(null);
  
  var bankAccounts = <Map<String, dynamic>>[].obs;
  
  var totalOutstanding = 0.0.obs;
  var totalOverdue = 0.0.obs;
  var totalDueThisWeek = 0.0.obs;
  var totalDueThisMonth = 0.0.obs;
  var activeVendors = 0.obs;
  
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
    fetchAllData();
    fetchBankAccounts();
  }
  
  Future<void> fetchAllData() async {
    await Future.wait([
      fetchVendors(),
      fetchBills(),
      fetchSummary(),
    ]);
  }
  
  Future<void> fetchSummary() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/accounts-payable/summary'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          totalOutstanding.value = _toDouble(data['data']['totalOutstanding']);
          totalOverdue.value = _toDouble(data['data']['overdue']);
          totalDueThisWeek.value = _toDouble(data['data']['dueThisWeek']);
          totalDueThisMonth.value = _toDouble(data['data']['dueThisMonth']);
          activeVendors.value = data['data']['activeVendors'] ?? 0;
        }
      }
    } catch (e) {
      print('Error fetching summary: $e');
    }
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
          vendors.value = (data['data'] as List)
              .map((e) => Vendor.fromJson(e))
              .toList();
        }
      }
    } catch (e) {
      print('Error fetching vendors: $e');
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
        }
      }
    } catch (e) {
      print('Error fetching bills: $e');
    } finally {
      isLoading(false);
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
  
  Future<void> createVendor(Map<String, dynamic> vendorData) async {
    try {
      isProcessing(true);
      
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/accounts-payable/vendors'),
        headers: headers,
        body: jsonEncode(vendorData),
      );
      
      if (response.statusCode == 201) {
        AppSnackbar.success(Colors.green, 'Success', 'Vendor added successfully');
        await fetchVendors();
      } else {
        final data = jsonDecode(response.body);
        AppSnackbar.error(Colors.red, 'Error', data['message'] ?? 'Failed to add vendor');
      }
    } catch (e) {
      AppSnackbar.error(Colors.red, 'Error', 'Failed to add vendor: $e');
    } finally {
      isProcessing(false);
    }
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
          duration: const Duration(seconds: 3),
        );
        await fetchBills();
        await fetchSummary();
        await fetchVendors();
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
          duration: const Duration(seconds: 3),
        );
        await fetchBills();
        await fetchSummary();
        await fetchVendors();
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
  
  void exportReport() {
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
              'Export Accounts Payable',
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
            _pdfVendorsSection(),
            pw.SizedBox(height: 16),
            _pdfBillsSection(),
          ],
        ),
      );
      
      final bytes = await pdf.save();
      final fileName = 'accounts_payable_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
      
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
            pw.Text('Accounts Payable Report',
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
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _pdfSummaryItem('Total Outstanding', _formatAmount(totalOutstanding.value), PdfColors.red700),
              _pdfSummaryItem('Overdue', _formatAmount(totalOverdue.value), PdfColors.orange700),
              _pdfSummaryItem('Due This Week', _formatAmount(totalDueThisWeek.value), PdfColors.indigo700),
              _pdfSummaryItem('Due This Month', _formatAmount(totalDueThisMonth.value), PdfColors.indigo700),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _pdfSummaryItem('Active Vendors', activeVendors.value.toString(), PdfColors.green700),
              _pdfSummaryItem('Total Vendors', vendors.length.toString(), PdfColors.grey700),
              _pdfSummaryItem('Total Bills', bills.length.toString(), PdfColors.grey700),
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
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
      pw.SizedBox(height: 4),
      pw.Text(value,
          style: pw.TextStyle(
              fontSize: 11, fontWeight: pw.FontWeight.bold, color: color)),
    ]);
  }
  
  pw.Widget _pdfVendorsSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Vendor Details',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 8),
          decoration: const pw.BoxDecoration(
              border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: 1))),
          child: pw.Row(children: [
            pw.Expanded(flex: 3, child: pw.Text('Vendor Name', style:  pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text('Phone', style:  pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text('Total Bills', textAlign: pw.TextAlign.right, style:  pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text('Total Amount', textAlign: pw.TextAlign.right, style:  pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text('Paid', textAlign: pw.TextAlign.right, style:  pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text('Outstanding', textAlign: pw.TextAlign.right, style:  pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          ]),
        ),
        ...vendors.map((vendor) => pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 6),
          decoration: const pw.BoxDecoration(
              border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5))),
          child: pw.Row(children: [
            pw.Expanded(flex: 3, child: pw.Text(vendor.name, style: const pw.TextStyle(fontSize: 9))),
            pw.Expanded(flex: 2, child: pw.Text(vendor.phone, style: const pw.TextStyle(fontSize: 9))),
            pw.Expanded(flex: 2, child: pw.Text(vendor.billCount.toString(), textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 9))),
            pw.Expanded(flex: 2, child: pw.Text(_formatAmount(vendor.totalAmount), textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9, color: PdfColors.indigo700))),
            pw.Expanded(flex: 2, child: pw.Text(_formatAmount(vendor.paidAmount), textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9, color: PdfColors.green700))),
            pw.Expanded(flex: 2, child: pw.Text(_formatAmount(vendor.outstandingAmount), textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9, color: PdfColors.red700))),
          ]),
        )).toList(),
        pw.Divider(),
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 8),
          child: pw.Row(children: [
            pw.Expanded(flex: 7, child: pw.Text('Total', style:  pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text(_formatAmount(vendors.fold(0.0, (sum, v) => sum + v.totalAmount)),
                textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.indigo700))),
            pw.Expanded(flex: 2, child: pw.Text(_formatAmount(vendors.fold(0.0, (sum, v) => sum + v.paidAmount)),
                textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.green700))),
            pw.Expanded(flex: 2, child: pw.Text(_formatAmount(vendors.fold(0.0, (sum, v) => sum + v.outstandingAmount)),
                textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.red700))),
          ]),
        ),
      ],
    );
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
            pw.Expanded(flex: 2, child: pw.Text('Bill #', style:  pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 3, child: pw.Text('Vendor', style:  pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text('Date', style:  pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text('Due Date', style:  pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text('Amount', textAlign: pw.TextAlign.right, style:  pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text('Outstanding', textAlign: pw.TextAlign.right, style:  pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text('Status', textAlign: pw.TextAlign.right, style:  pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          ]),
        ),
        ...bills.map((bill) => pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 6),
          decoration: const pw.BoxDecoration(
              border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5))),
          child: pw.Row(children: [
            pw.Expanded(flex: 2, child: pw.Text(bill.billNumber, style: const pw.TextStyle(fontSize: 9))),
            pw.Expanded(flex: 3, child: pw.Text(bill.vendorName, style: const pw.TextStyle(fontSize: 9))),
            pw.Expanded(flex: 2, child: pw.Text(DateFormat('dd/MM/yyyy').format(bill.date), style: const pw.TextStyle(fontSize: 9))),
            pw.Expanded(flex: 2, child: pw.Text(DateFormat('dd/MM/yyyy').format(bill.dueDate), style: const pw.TextStyle(fontSize: 9))),
            pw.Expanded(flex: 2, child: pw.Text(_formatAmount(bill.totalAmount), textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 9))),
            pw.Expanded(flex: 2, child: pw.Text(_formatAmount(bill.outstanding), textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9, color: bill.outstanding > 0 ? PdfColors.red700 : PdfColors.green700))),
            pw.Expanded(flex: 2, child: pw.Text(bill.status, textAlign: pw.TextAlign.right, 
                style: pw.TextStyle(fontSize: 9, color: bill.status == 'Paid' ? PdfColors.green700 : (bill.isOverdue ? PdfColors.red700 : PdfColors.orange700)))),
          ]),
        )).toList(),
        pw.Divider(),
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 8),
          child: pw.Row(children: [
            pw.Expanded(flex: 9, child: pw.Text('Total', style:  pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text(_formatAmount(bills.fold(0.0, (sum, b) => sum + b.totalAmount)),
                textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.indigo700))),
            pw.Expanded(flex: 2, child: pw.Text(_formatAmount(bills.fold(0.0, (sum, b) => sum + b.outstanding)),
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
      
      _excelSetCell(summarySheet, 0, 0, 'Accounts Payable Report',
          bold: true, fontSize: 14, bgColor: '1A237E', fontColor: 'FFFFFF');
      _excelSetCell(summarySheet, 1, 0,
          'Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
          fontSize: 9, fontColor: '757575');
      _excelSetCell(summarySheet, 2, 0,
          'Filter: ${selectedFilter.value}',
          fontSize: 10, fontColor: '1A237E');
      if (selectedVendorId.value.isNotEmpty) {
        final vendor = vendors.firstWhere((v) => v.id == selectedVendorId.value, orElse: () => vendors.first);
        _excelSetCell(summarySheet, 3, 0,
          'Vendor: ${vendor.name}',
          fontSize: 10, fontColor: '1A237E');
      }
      
      _excelSetCell(summarySheet, 5, 0, 'SUMMARY', bold: true, fontSize: 11, bgColor: 'E8EAF6');
      
      final summaryRows = [
        ['Total Outstanding', _formatAmount(totalOutstanding.value)],
        ['Overdue', _formatAmount(totalOverdue.value)],
        ['Due This Week', _formatAmount(totalDueThisWeek.value)],
        ['Due This Month', _formatAmount(totalDueThisMonth.value)],
        ['Active Vendors', activeVendors.value.toString()],
        ['Total Vendors', vendors.length.toString()],
        ['Total Bills', bills.length.toString()],
      ];
      
      for (int r = 0; r < summaryRows.length; r++) {
        for (int c = 0; c < 2; c++) {
          _excelSetCell(summarySheet, 6 + r, c, summaryRows[r][c],
              bgColor: r.isEven ? 'FFFFFF' : 'F5F5F5');
        }
      }
      summarySheet.setColumnWidth(0, 25);
      summarySheet.setColumnWidth(1, 20);
      
      // Vendors Sheet
      final vendorsSheet = excel['Vendors'];
      final vendorHeaders = [
        'Vendor Name', 'Email', 'Phone', 'Address', 'Tax ID', 'Payment Terms',
        'Bill Count', 'Total Amount', 'Paid Amount', 'Outstanding Amount'
      ];
      
      for (int i = 0; i < vendorHeaders.length; i++) {
        _excelSetCell(vendorsSheet, 0, i, vendorHeaders[i],
            bold: true, bgColor: '1A237E', fontColor: 'FFFFFF', fontSize: 10);
      }
      
      int row = 1;
      for (final vendor in vendors) {
        final bg = row.isEven ? 'F5F5F5' : 'FFFFFF';
        _excelSetCell(vendorsSheet, row, 0, vendor.name, bgColor: bg);
        _excelSetCell(vendorsSheet, row, 1, vendor.email, bgColor: bg);
        _excelSetCell(vendorsSheet, row, 2, vendor.phone, bgColor: bg);
        _excelSetCell(vendorsSheet, row, 3, vendor.address, bgColor: bg);
        _excelSetCell(vendorsSheet, row, 4, vendor.taxId, bgColor: bg);
        _excelSetCell(vendorsSheet, row, 5, vendor.paymentTerms, bgColor: bg);
        _excelSetCell(vendorsSheet, row, 6, vendor.billCount, bgColor: bg);
        _excelSetCell(vendorsSheet, row, 7, vendor.totalAmount, bgColor: bg, fontColor: '1A237E');
        _excelSetCell(vendorsSheet, row, 8, vendor.paidAmount, bgColor: bg, fontColor: '2E7D32');
        _excelSetCell(vendorsSheet, row, 9, vendor.outstandingAmount, bgColor: bg, fontColor: 'C62828');
        row++;
      }
      
      // Totals row
      _excelSetCell(vendorsSheet, row, 6, 'TOTAL', bold: true, bgColor: 'E8EAF6');
      _excelSetCell(vendorsSheet, row, 7, vendors.fold(0.0, (sum, v) => sum + v.totalAmount), 
          bold: true, bgColor: 'E8EAF6', fontColor: '1A237E');
      _excelSetCell(vendorsSheet, row, 8, vendors.fold(0.0, (sum, v) => sum + v.paidAmount), 
          bold: true, bgColor: 'E8EAF6', fontColor: '2E7D32');
      _excelSetCell(vendorsSheet, row, 9, vendors.fold(0.0, (sum, v) => sum + v.outstandingAmount), 
          bold: true, bgColor: 'E8EAF6', fontColor: 'C62828');
      
      final vendorColWidths = [30.0, 25.0, 15.0, 35.0, 15.0, 12.0, 12.0, 15.0, 15.0, 15.0];
      for (int i = 0; i < vendorColWidths.length; i++) {
        vendorsSheet.setColumnWidth(i, vendorColWidths[i]);
      }
      
      // Bills Sheet
      final billsSheet = excel['Bills'];
      final billHeaders = [
        'Bill #', 'Vendor', 'Date', 'Due Date', 'Subtotal', 'Tax', 'Discount',
        'Total Amount', 'Paid Amount', 'Outstanding', 'Status'
      ];
      
      for (int i = 0; i < billHeaders.length; i++) {
        _excelSetCell(billsSheet, 0, i, billHeaders[i],
            bold: true, bgColor: '1A237E', fontColor: 'FFFFFF', fontSize: 10);
      }
      
      int billRow = 1;
      for (final bill in bills) {
        final bg = billRow.isEven ? 'F5F5F5' : 'FFFFFF';
        _excelSetCell(billsSheet, billRow, 0, bill.billNumber, bgColor: bg);
        _excelSetCell(billsSheet, billRow, 1, bill.vendorName, bgColor: bg);
        _excelSetCell(billsSheet, billRow, 2, DateFormat('dd MMM yyyy').format(bill.date), bgColor: bg);
        _excelSetCell(billsSheet, billRow, 3, DateFormat('dd MMM yyyy').format(bill.dueDate), bgColor: bg);
        _excelSetCell(billsSheet, billRow, 4, bill.subtotal, bgColor: bg);
        _excelSetCell(billsSheet, billRow, 5, bill.taxTotal, bgColor: bg);
        _excelSetCell(billsSheet, billRow, 6, bill.discount, bgColor: bg);
        _excelSetCell(billsSheet, billRow, 7, bill.totalAmount, bgColor: bg, fontColor: '1A237E');
        _excelSetCell(billsSheet, billRow, 8, bill.paidAmount, bgColor: bg, fontColor: '2E7D32');
        _excelSetCell(billsSheet, billRow, 9, bill.outstanding, bgColor: bg, fontColor: bill.outstanding > 0 ? 'C62828' : '2E7D32');
        _excelSetCell(billsSheet, billRow, 10, bill.status, 
            bgColor: bill.status == 'Paid' ? 'E8F5E9' : (bill.isOverdue ? 'FFEBEE' : 'FFF8E1'),
            fontColor: bill.status == 'Paid' ? '2E7D32' : (bill.isOverdue ? 'C62828' : 'F39C12'));
        billRow++;
      }
      
      // Totals row
      _excelSetCell(billsSheet, billRow, 7, 'TOTAL', bold: true, bgColor: 'E8EAF6');
      _excelSetCell(billsSheet, billRow, 8, bills.fold(0.0, (sum, b) => sum + b.paidAmount), 
          bold: true, bgColor: 'E8EAF6', fontColor: '2E7D32');
      _excelSetCell(billsSheet, billRow, 9, bills.fold(0.0, (sum, b) => sum + b.outstanding), 
          bold: true, bgColor: 'E8EAF6', fontColor: 'C62828');
      
      final billColWidths = [15.0, 25.0, 12.0, 12.0, 12.0, 12.0, 12.0, 15.0, 15.0, 15.0, 12.0];
      for (int i = 0; i < billColWidths.length; i++) {
        billsSheet.setColumnWidth(i, billColWidths[i]);
      }
      
      excel.delete('Sheet1');
      
      final bytes = excel.save();
      if (bytes == null) throw Exception('Excel save failed');
      
      final fileName = 'accounts_payable_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
      
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

// Models (Vendor, Bill, BillItem classes remain the same as in your original code)
class Vendor {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String taxId;
  final String paymentTerms;
  final bool isActive;
  final int billCount;
  final double totalAmount;
  final double paidAmount;
  final double outstandingAmount;
  
  Vendor({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.taxId,
    required this.paymentTerms,
    required this.isActive,
    required this.billCount,
    required this.totalAmount,
    required this.paidAmount,
    required this.outstandingAmount,
  });
  
  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['_id'],
      name: json['name'],
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      taxId: json['taxId'] ?? '',
      paymentTerms: json['paymentTerms'] ?? 'Net 30',
      isActive: json['isActive'] ?? true,
      billCount: json['billCount'] ?? 0,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      paidAmount: (json['paidAmount'] ?? 0).toDouble(),
      outstandingAmount: (json['outstandingAmount'] ?? 0).toDouble(),
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
  
  double get outstanding => (totalAmount - paidAmount).toDouble();
  
  bool get isOverdue {
    if (status == 'Paid') return false;
    return dueDate.isBefore(DateTime.now());
  }
  
  factory Bill.fromJson(Map<String, dynamic> json) {
    double safeToDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }
    
    return Bill(
      id: json['_id'] ?? '',
      billNumber: json['billNumber'] ?? '',
      vendorId: json['vendorId'] is Map 
          ? json['vendorId']['_id'] ?? '' 
          : json['vendorId'] ?? '',
      vendorName: json['vendorName'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : DateTime.now(),
      items: json['items'] != null 
          ? (json['items'] as List).map((e) => BillItem.fromJson(e)).toList()
          : [],
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
      description: json['description'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: safeToDouble(json['unitPrice']),
      amount: safeToDouble(json['amount']),
      taxRate: safeToDouble(json['taxRate']),
      taxAmount: safeToDouble(json['taxAmount']),
    );
  }
}