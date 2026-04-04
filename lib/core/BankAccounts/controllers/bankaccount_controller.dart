import 'package:LedgerPro_app/Utils/colors.dart';
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

class BankAccountController extends GetxController {
  var bankAccounts = <BankAccount>[].obs;
  var isLoading = true.obs;
  var selectedFilter = 'All'.obs;
  var searchQuery = ''.obs;
  
  // Summary totals
  var totalBalance = 0.0.obs;
  var totalPKR = 0.0.obs;
  var totalUSD = 0.0.obs;
  var activeCount = 0.obs;
  
  final String baseUrl = Apiconfig().baseUrl;
  String? _cachedToken;
  
  // Predefined colors for bank accounts
  final List<Color> _accountColors = [
    const Color(0xFF1AB4F5),
    const Color(0xFFE74C3C),
    const Color(0xFF2ECC71),
    const Color(0xFFF39C12),
    const Color(0xFF9B59B6),
    const Color(0xFF3498DB),
    const Color(0xFFE67E22),
  ];
  
  Future<String?> _getToken() async {
    try {
      if (_cachedToken != null) return _cachedToken;
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      _cachedToken = token;
      return token;
    } catch (e) {
      print('Error getting token: $e');
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
  
  Color _getColorForAccount(String accountName) {
    int hash = accountName.hashCode;
    return _accountColors[hash.abs() % _accountColors.length];
  }
  
  String _formatAmount(double amount) {
    return 'Rs. ${amount.toStringAsFixed(2)}';
  }
  
  @override
  void onInit() {
    super.onInit();
    fetchBankAccounts();
  }
  
  Future<void> fetchBankAccounts() async {
    try {
      isLoading(true);
      
      String url = '$baseUrl/api/bank-accounts';
      List<String> queryParams = [];
      
      if (selectedFilter.value != 'All') {
        queryParams.add('status=${selectedFilter.value}');
      }
      
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
          final List<dynamic> accountsData = data['data'] ?? [];
          
          bankAccounts.value = accountsData
              .map((e) => BankAccount.fromJson(
                  e as Map<String, dynamic>, 
                  _getColorForAccount((e['accountName'] ?? '').toString())))
              .toList();
          
          final summary = data['summary'] ?? {};
          totalBalance.value = _toDouble(summary['totalBalance']);
          totalPKR.value = _toDouble(summary['totalPKR']);
          totalUSD.value = _toDouble(summary['totalUSD']);
          activeCount.value = (summary['activeCount'] ?? 0).toInt();
        }
      } else if (response.statusCode == 401) {
        _handleSessionExpired();
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar('Error', errorData['message'] ?? 'Failed to load accounts');
      }
    } catch (e) {
      print('Error fetching bank accounts: $e');
      Get.snackbar('Error', 'Failed to load bank accounts: $e');
    } finally {
      isLoading(false);
    }
  }
  
  Future<void> createBankAccount(Map<String, dynamic> accountData) async {
    try {
      isLoading(true);
      
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/bank-accounts'),
        headers: headers,
        body: jsonEncode(accountData),
      );
      
      if (response.statusCode == 201) {
        Get.snackbar(
          'Success',
          'Bank account added successfully\nJournal entry created for opening balance',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF2ECC71),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        await fetchBankAccounts();
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar(
          'Error',
          data['message'] ?? 'Failed to create account',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE74C3C),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error creating bank account: $e');
      Get.snackbar('Error', 'Failed to create account: $e');
    } finally {
      isLoading(false);
    }
  }
  
  Future<void> updateBankAccount(String id, Map<String, dynamic> accountData) async {
    try {
      isLoading(true);
      
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/api/bank-accounts/$id'),
        headers: headers,
        body: jsonEncode(accountData),
      );
      
      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'Bank account updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF2ECC71),
          colorText: Colors.white,
        );
        await fetchBankAccounts();
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar(
          'Error',
          data['message'] ?? 'Failed to update account',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE74C3C),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error updating bank account: $e');
      Get.snackbar('Error', 'Failed to update account: $e');
    } finally {
      isLoading(false);
    }
  }
  
  Future<void> deleteBankAccount(String id, String accountName) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/api/bank-accounts/$id'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'Bank account "$accountName" deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF2ECC71),
          colorText: Colors.white,
        );
        await fetchBankAccounts();
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar(
          'Error',
          data['message'] ?? 'Failed to delete account',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE74C3C),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error deleting bank account: $e');
      Get.snackbar('Error', 'Failed to delete account: $e');
    }
  }
  
  void changeFilter(String filter) {
    selectedFilter.value = filter;
    fetchBankAccounts();
  }
  
  void searchAccounts(String query) {
    searchQuery.value = query;
    fetchBankAccounts();
  }
  
  void syncAccounts() {
    Get.snackbar(
      'Sync',
      'Syncing bank accounts...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: kPrimary,
      colorText: Colors.white,
    );
  }
  
  // ─────────────────────── EXPORT FUNCTIONS ───────────────────────
  
  void exportAccounts() {
    // Show export options bottom sheet
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
              'Export Bank Accounts',
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
      // Show loading
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
            _pdfBankAccountsTable(),
          ],
        ),
      );
      
      final dir = await getTemporaryDirectory();
      final fileName = 'bank_accounts_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(await pdf.save());
      
      if (Get.isDialogOpen ?? false) Get.back();
      
      Get.snackbar('Success', '${bankAccounts.length} accounts exported to PDF',
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
            pw.Text('Bank Accounts Report',
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
          _pdfSummaryItem('Total Balance', _formatAmount(totalBalance.value), PdfColors.green700),
          _pdfSummaryItem('PKR Balance', _formatAmount(totalPKR.value), PdfColors.indigo700),
          _pdfSummaryItem('USD Balance', _formatAmount(totalUSD.value), PdfColors.orange700),
          _pdfSummaryItem('Active Accounts', activeCount.value.toString(), PdfColors.indigo700),
          _pdfSummaryItem('Total Accounts', bankAccounts.length.toString(), PdfColors.grey700),
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
  
  pw.Widget _pdfBankAccountsTable() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Bank Account Details',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 8),
          decoration: const pw.BoxDecoration(
              border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: 1))),
          child: pw.Row(children: [
            pw.Expanded(flex: 1, child: pw.Text('Code', style:  pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 3, child: pw.Text('Account Name', style:  pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text('Bank', style:  pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text('Account No.', style:  pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text('Currency', style:  pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text('Balance', textAlign: pw.TextAlign.right, style:  pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          ]),
        ),
        ...bankAccounts.map((account) => pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 6),
          decoration: const pw.BoxDecoration(
              border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5))),
          child: pw.Row(children: [
            pw.Expanded(flex: 1, child: pw.Text(account.accountNumber.substring(0, 4), style: const pw.TextStyle(fontSize: 9))),
            pw.Expanded(flex: 3, child: pw.Text(account.accountName, style: const pw.TextStyle(fontSize: 9))),
            pw.Expanded(flex: 2, child: pw.Text(account.bankName, style: const pw.TextStyle(fontSize: 9))),
            pw.Expanded(flex: 2, child: pw.Text(account.accountNumber, style: const pw.TextStyle(fontSize: 9))),
            pw.Expanded(flex: 2, child: pw.Text(account.currency, style: const pw.TextStyle(fontSize: 9))),
            pw.Expanded(flex: 2, child: pw.Text(
                _formatAmount(account.currentBalance),
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(fontSize: 9, color: account.currentBalance >= 0 ? PdfColors.green700 : PdfColors.red700))),
          ]),
        )).toList(),
        pw.Divider(),
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 8),
          child: pw.Row(children: [
            pw.Expanded(flex: 10, child: pw.Text('Total', style:  pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text(_formatAmount(totalBalance.value),
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.green700))),
          ]),
        ),
      ],
    );
  }
  
  Future<void> exportToExcel() async {
    try {
      // Show loading
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
      
      _excelSetCell(summarySheet, 0, 0, 'Bank Accounts Report',
          bold: true, fontSize: 14, bgColor: '1A237E', fontColor: 'FFFFFF');
      _excelSetCell(summarySheet, 1, 0,
          'Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
          fontSize: 9, fontColor: '757575');
      _excelSetCell(summarySheet, 2, 0,
          'Filter: ${selectedFilter.value}',
          fontSize: 10, fontColor: '1A237E');
      if (searchQuery.value.isNotEmpty) {
        _excelSetCell(summarySheet, 3, 0,
          'Search: ${searchQuery.value}',
          fontSize: 10, fontColor: '1A237E');
      }
      
      _excelSetCell(summarySheet, 5, 0, 'SUMMARY', bold: true, fontSize: 11, bgColor: 'E8EAF6');
      
      final summaryRows = [
        ['Total Balance (All Currencies)', _formatAmount(totalBalance.value)],
        ['PKR Balance', _formatAmount(totalPKR.value)],
        ['USD Balance', _formatAmount(totalUSD.value)],
        ['Active Accounts', activeCount.value.toString()],
        ['Total Accounts', bankAccounts.length.toString()],
      ];
      
      for (int r = 0; r < summaryRows.length; r++) {
        for (int c = 0; c < 2; c++) {
          _excelSetCell(summarySheet, 6 + r, c, summaryRows[r][c],
              bgColor: r.isEven ? 'FFFFFF' : 'F5F5F5');
        }
      }
      summarySheet.setColumnWidth(0, 25);
      summarySheet.setColumnWidth(1, 20);
      
      // Bank Accounts Sheet
      final accountsSheet = excel['Bank Accounts'];
      final headers = [
        'Account Name', 'Account Number', 'Bank Name', 'Branch Code', 
        'Account Type', 'Currency', 'Opening Balance', 'Current Balance', 'Status'
      ];
      
      for (int i = 0; i < headers.length; i++) {
        _excelSetCell(accountsSheet, 0, i, headers[i],
            bold: true, bgColor: '1A237E', fontColor: 'FFFFFF', fontSize: 10);
      }
      
      int row = 1;
      for (final account in bankAccounts) {
        final bg = row.isEven ? 'F5F5F5' : 'FFFFFF';
        _excelSetCell(accountsSheet, row, 0, account.accountName, bgColor: bg);
        _excelSetCell(accountsSheet, row, 1, account.accountNumber, bgColor: bg);
        _excelSetCell(accountsSheet, row, 2, account.bankName, bgColor: bg);
        _excelSetCell(accountsSheet, row, 3, account.branchCode, bgColor: bg);
        _excelSetCell(accountsSheet, row, 4, account.accountType, bgColor: bg);
        _excelSetCell(accountsSheet, row, 5, account.currency, bgColor: bg);
        _excelSetCell(accountsSheet, row, 6, account.openingBalance, bgColor: bg);
        _excelSetCell(accountsSheet, row, 7, account.currentBalance, bgColor: bg);
        _excelSetCell(accountsSheet, row, 8, account.status, 
            bgColor: account.status == 'Active' ? 'E8F5E9' : 'FFEBEE',
            fontColor: account.status == 'Active' ? '2E7D32' : 'C62828');
        row++;
      }
      
      // Totals row
      _excelSetCell(accountsSheet, row, 6, 'TOTAL', bold: true, bgColor: 'E8EAF6');
      _excelSetCell(accountsSheet, row, 7, totalBalance.value, bold: true, bgColor: 'E8EAF6', fontColor: '2E7D32');
      
      final colWidths = [30.0, 20.0, 25.0, 15.0, 15.0, 10.0, 15.0, 15.0, 12.0];
      for (int i = 0; i < colWidths.length; i++) {
        accountsSheet.setColumnWidth(i, colWidths[i]);
      }
      
      excel.delete('Sheet1');
      
      final bytes = excel.save();
      if (bytes == null) throw Exception('Excel save failed');
      
      final dir = await getTemporaryDirectory();
      final fileName = 'bank_accounts_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);
      
      if (Get.isDialogOpen ?? false) Get.back();
      
      Get.snackbar('Success', '${bankAccounts.length} accounts exported to Excel',
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
  
  void reconcileAccount(BankAccount account) {
    Get.snackbar(
      'Reconcile',
      'Reconciling ${account.accountName}...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: kPrimary,
      colorText: Colors.white,
    );
  }
  
  void viewTransactions(BankAccount account) {
    Get.snackbar(
      'Transactions',
      'Viewing transactions for ${account.accountName}...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: kPrimary,
      colorText: Colors.white,
    );
  }
  
  void transferMoney(BankAccount account) {
    Get.snackbar(
      'Transfer',
      'Transfer from ${account.accountName}...',
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
      backgroundColor: const Color(0xFFE74C3C),
      colorText: Colors.white,
    );
  }
}

class BankAccount {
  final String id;
  final String accountName;
  final String accountNumber;
  final String bankName;
  final String branchCode;
  final String accountType;
  final String currency;
  final double openingBalance;
  final double currentBalance;
  final String status;
  final DateTime lastReconciled;
  final Color color;
  final String chartOfAccountId;
  
  BankAccount({
    required this.id,
    required this.accountName,
    required this.accountNumber,
    required this.bankName,
    required this.branchCode,
    required this.accountType,
    required this.currency,
    required this.openingBalance,
    required this.currentBalance,
    required this.status,
    required this.lastReconciled,
    required this.color,
    this.chartOfAccountId = '',
  });
  
  factory BankAccount.fromJson(Map<String, dynamic> json, Color color) {
    // Handle chartOfAccountId - it could be a String (ID) or populated Object
    String chartOfAccountId = '';
    if (json['chartOfAccountId'] != null) {
      if (json['chartOfAccountId'] is String) {
        chartOfAccountId = json['chartOfAccountId'];
      } else if (json['chartOfAccountId'] is Map) {
        chartOfAccountId = json['chartOfAccountId']['_id'] ?? 
                           json['chartOfAccountId']['id'] ?? '';
      }
    }
    
    // Handle lastReconciled
    DateTime lastReconciled;
    if (json['lastReconciled'] != null) {
      if (json['lastReconciled'] is String) {
        lastReconciled = DateTime.parse(json['lastReconciled']);
      } else if (json['lastReconciled'] is DateTime) {
        lastReconciled = json['lastReconciled'];
      } else {
        lastReconciled = DateTime.now();
      }
    } else {
      lastReconciled = DateTime.now();
    }
    
    return BankAccount(
      id: json['_id'].toString(),
      accountName: json['accountName'].toString(),
      accountNumber: json['accountNumber'].toString(),
      bankName: json['bankName'].toString(),
      branchCode: json['branchCode']?.toString() ?? '',
      accountType: json['accountType']?.toString() ?? 'Current',
      currency: json['currency']?.toString() ?? 'PKR',
      openingBalance: (json['openingBalance'] ?? 0).toDouble(),
      currentBalance: (json['currentBalance'] ?? 0).toDouble(),
      status: json['status']?.toString() ?? 'Active',
      lastReconciled: lastReconciled,
      color: color,
      chartOfAccountId: chartOfAccountId,
    );
  }
}