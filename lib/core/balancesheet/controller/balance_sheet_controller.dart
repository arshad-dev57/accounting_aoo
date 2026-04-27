import 'dart:convert';
import 'dart:io';
import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/config/apiconfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';

class BalanceSheetController extends GetxController {
  // Observable variables
  var isLoading = true.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var selectedPeriod = 'All Time'.obs;
  var asOfDate = DateTime.now().obs;

  // Balance Sheet Data
  var liabilitiesData = <String, Map<String, double>>{}.obs;
  var assetsData = <String, Map<String, double>>{}.obs;
  var equityData = <String, Map<String, double>>{}.obs;

  // Totals
  var totalLiabilities = 0.0.obs;
  var totalAssets = 0.0.obs;
  var equity = 0.0.obs;

  final List<String> periodOptions = [
    'All Time',
    'This Year',
    'This Quarter',
    'This Month'
  ];

  final String baseUrl = Apiconfig().baseUrl;

  @override
  void onInit() {
    super.onInit();
    // Landscape set karein screen open hone par
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    loadBalanceSheet();
  }

  @override
  void onClose() {
    // Portrait restore karein jab screen close ho
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.onClose();
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

  String _formatAmount(double amount) {
    return 'Rs. ${amount.toStringAsFixed(2)}';
  }

  // ==================== LOAD BALANCE SHEET FROM API ====================
  Future<void> loadBalanceSheet() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Build query parameters
      Map<String, dynamic> params = {};
      if (selectedPeriod.value != 'All Time') {
        params['period'] = selectedPeriod.value;
      }

      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl/api/reports/balance-sheet')
          .replace(queryParameters: params);

      print("🌐 Balance Sheet URL: $uri");
      print("📋 Headers: $headers");

      final response = await http.get(uri, headers: headers);

      print("📡 Response Status: ${response.statusCode}");
      print("📡 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final data = responseData['data'];

          // Parse asOfDate
          if (data['asOfDate'] != null) {
            asOfDate.value = DateTime.parse(data['asOfDate']);
          }

          // Parse liabilities
          if (data['liabilities'] != null && data['liabilities'] is Map) {
            liabilitiesData.clear();
            (data['liabilities'] as Map).forEach((key, value) {
              Map<String, double> items = {};
              if (value is Map) {
                (value as Map).forEach((itemKey, itemValue) {
                  items[itemKey] = (itemValue as num).toDouble();
                });
              }
              liabilitiesData[key] = items;
            });
          } else {
            liabilitiesData.clear();
          }

          // Parse assets
          if (data['assets'] != null && data['assets'] is Map) {
            assetsData.clear();
            (data['assets'] as Map).forEach((key, value) {
              Map<String, double> items = {};
              if (value is Map) {
                (value as Map).forEach((itemKey, itemValue) {
                  items[itemKey] = (itemValue as num).toDouble();
                });
              }
              assetsData[key] = items;
            });
          } else {
            assetsData.clear();
          }

          // Parse equity
          if (data['equityDetails'] != null && data['equityDetails'] is Map) {
            equityData.clear();
            (data['equityDetails'] as Map).forEach((key, value) {
              Map<String, double> items = {};
              if (value is Map) {
                (value as Map).forEach((itemKey, itemValue) {
                  items[itemKey] = (itemValue as num).toDouble();
                });
              }
              equityData[key] = items;
            });
          } else {
            equityData.clear();
          }

          // Set totals
          totalLiabilities.value = (data['totalLiabilities'] ?? 0).toDouble();
          totalAssets.value = (data['totalAssets'] ?? 0).toDouble();
          equity.value = (data['equity'] ?? 0).toDouble();

          print("✅ Balance sheet loaded successfully");
          print("📊 Total Liabilities: ${totalLiabilities.value}");
          print("📊 Total Assets: ${totalAssets.value}");
          print("📊 Equity: ${equity.value}");
        } else {
          hasError.value = true;
          errorMessage.value =
              responseData['message'] ?? 'Failed to load balance sheet';
          print("❌ API returned success=false: ${errorMessage.value}");
          _showError(errorMessage.value);
        }
      } else if (response.statusCode == 401) {
        hasError.value = true;
        errorMessage.value = 'Session expired. Please login again.';
        print("❌ Unauthorized - Token expired");
        _handleSessionExpired();
      } else {
        hasError.value = true;
        errorMessage.value = 'Server error: ${response.statusCode}';
        print("❌ HTTP Error: ${response.statusCode}");
        _showError(errorMessage.value);
      }
    } catch (e, stackTrace) {
      hasError.value = true;
      errorMessage.value = 'Network error: ${e.toString()}';
      print("🔥 Error loading balance sheet: $e");
      print("🔥 StackTrace: $stackTrace");
      _showError(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== RETRY LOADING ====================
  void retryLoad() {
    loadBalanceSheet();
  }

  // ==================== CHANGE PERIOD ====================
  void changePeriod(String period) {
    if (selectedPeriod.value == period) return;
    selectedPeriod.value = period;
    loadBalanceSheet();
  }

  // ==================== FORMAT AMOUNT ====================
  String formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '₨ ${formatter.format(amount)}';
  }

  // ==================== EXPORT FUNCTIONS ====================
  void exportToExcel() {
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
           Text(
              'Export Balance Sheet',
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
                exportToExcelFile();
              },
            ),
          ],
        ),
      ),
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
            _pdfAssetsSection(),
            pw.SizedBox(height: 16),
            _pdfLiabilitiesSection(),
            pw.SizedBox(height: 16),
            _pdfEquitySection(),
          ],
        ),
      );
      
      final dir = await getTemporaryDirectory();
      final fileName = 'balance_sheet_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(await pdf.save());
      
      if (Get.isDialogOpen ?? false) Get.back();
      
      Get.snackbar('Success', 'Balance sheet exported to PDF',
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
            pw.Text('Balance Sheet Report',
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
          pw.Text('As of Date: ${DateFormat('dd MMM yyyy').format(asOfDate.value)}',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          pw.Text('Period: ${selectedPeriod.value}',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _pdfSummaryItem('Total Assets', _formatAmount(totalAssets.value), PdfColors.green700),
              _pdfSummaryItem('Total Liabilities', _formatAmount(totalLiabilities.value), PdfColors.red700),
              _pdfSummaryItem('Equity', _formatAmount(equity.value), PdfColors.indigo700),
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
  
  pw.Widget _pdfAssetsSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('ASSETS',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.green700)),
        pw.SizedBox(height: 8),
        ...assetsData.keys.map((category) => _pdfCategorySection(category, assetsData[category] ?? {}, false)).toList(),
        pw.Divider(),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Row(children: [
            pw.Expanded(child: pw.Text('Total Assets', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold))),
            pw.Text(_formatAmount(totalAssets.value), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.green700)),
          ]),
        ),
      ],
    );
  }
  
  pw.Widget _pdfLiabilitiesSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('LIABILITIES',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.red700)),
        pw.SizedBox(height: 8),
        ...liabilitiesData.keys.map((category) => _pdfCategorySection(category, liabilitiesData[category] ?? {}, true)).toList(),
        pw.Divider(),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Row(children: [
            pw.Expanded(child: pw.Text('Total Liabilities', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold))),
            pw.Text(_formatAmount(totalLiabilities.value), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.red700)),
          ]),
        ),
      ],
    );
  }
  
  pw.Widget _pdfEquitySection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('EQUITY',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo700)),
        pw.SizedBox(height: 8),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Row(children: [
            pw.Expanded(child: pw.Text('Total Equity', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold))),
            pw.Text(_formatAmount(equity.value), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo700)),
          ]),
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
              color: PdfColors.indigo50,
              borderRadius: pw.BorderRadius.circular(8)),
          child: pw.Row(children: [
            pw.Expanded(child: pw.Text('Total Liabilities & Equity', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold))),
            pw.Text(_formatAmount(totalLiabilities.value + equity.value), 
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo800)),
          ]),
        ),
      ],
    );
  }
  
  pw.Widget _pdfCategorySection(String category, Map<String, double> items, bool isLiability) {
    if (items.isEmpty) return pw.SizedBox();
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(category,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, 
                color: isLiability ? PdfColors.red600 : PdfColors.green600)),
        pw.SizedBox(height: 4),
        ...items.entries.map((item) => pw.Container(
          padding:  pw.EdgeInsets.only(left: 16,),
          child: pw.Row(children: [
            pw.Expanded(child: pw.Text(item.key, style: pw.TextStyle(fontSize: 10))),
            pw.Text(_formatAmount(item.value), style: pw.TextStyle(fontSize: 10)),
          ]),
        )).toList(),
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 16, top: 4, bottom: 8),
          child: pw.Row(children: [
            pw.Expanded(child: pw.Text('Total $category', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
            pw.Text(_formatAmount(items.values.fold(0.0, (sum, val) => sum + val)), 
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          ]),
        ),
        pw.SizedBox(height: 4),
      ],
    );
  }
  
  Future<void> exportToExcelFile() async {
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
      
      final excelFile = Excel.createExcel();
      
      // Summary Sheet
      final summarySheet = excelFile['Summary'];
      excelFile.setDefaultSheet('Summary');
      
      _excelSetCell(summarySheet, 0, 0, 'Balance Sheet Report',
          bold: true, fontSize: 14, bgColor: '1A237E', fontColor: 'FFFFFF');
      _excelSetCell(summarySheet, 1, 0,
          'Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
          fontSize: 9, fontColor: '757575');
      _excelSetCell(summarySheet, 2, 0,
          'As of Date: ${DateFormat('dd MMM yyyy').format(asOfDate.value)}',
          fontSize: 10, fontColor: '1A237E');
      _excelSetCell(summarySheet, 3, 0,
          'Period: ${selectedPeriod.value}',
          fontSize: 10, fontColor: '1A237E');
      
      _excelSetCell(summarySheet, 5, 0, 'SUMMARY', bold: true, fontSize: 11, bgColor: 'E8EAF6');
      
      final summaryRows = [
        ['Total Assets', _formatAmount(totalAssets.value)],
        ['Total Liabilities', _formatAmount(totalLiabilities.value)],
        ['Equity', _formatAmount(equity.value)],
        ['Total Liabilities & Equity', _formatAmount(totalLiabilities.value + equity.value)],
      ];
      
      for (int r = 0; r < summaryRows.length; r++) {
        for (int c = 0; c < 2; c++) {
          _excelSetCell(summarySheet, 6 + r, c, summaryRows[r][c],
              bgColor: r.isEven ? 'FFFFFF' : 'F5F5F5');
        }
      }
      summarySheet.setColumnWidth(0, 25);
      summarySheet.setColumnWidth(1, 20);
      
      // Assets Sheet
      final assetsSheet = excelFile['Assets'];
      _excelSetCell(assetsSheet, 0, 0, 'ASSETS', bold: true, fontSize: 14, bgColor: '2E7D32', fontColor: 'FFFFFF');
      
      int row = 2;
      for (final category in assetsData.keys) {
        final items = assetsData[category] ?? {};
        if (items.isNotEmpty) {
          _excelSetCell(assetsSheet, row, 0, category, bold: true, fontSize: 11, bgColor: 'E8EAF6');
          row++;
          
          for (final item in items.entries) {
            _excelSetCell(assetsSheet, row, 0, '   ${item.key}', bgColor: row.isEven ? 'F5F5F5' : 'FFFFFF');
            _excelSetCell(assetsSheet, row, 1, item.value, bgColor: row.isEven ? 'F5F5F5' : 'FFFFFF');
            row++;
          }
          
          _excelSetCell(assetsSheet, row, 0, '   Total $category', bold: true, bgColor: 'E8EAF6');
          _excelSetCell(assetsSheet, row, 1, items.values.fold(0.0, (sum, val) => sum + val), 
              bold: true, bgColor: 'E8EAF6', fontColor: '2E7D32');
          row += 2;
        }
      }
      
      _excelSetCell(assetsSheet, row, 0, 'TOTAL ASSETS', bold: true, fontSize: 12, bgColor: '2E7D32', fontColor: 'FFFFFF');
      _excelSetCell(assetsSheet, row, 1, totalAssets.value, bold: true, bgColor: '2E7D32', fontColor: 'FFFFFF');
      
      assetsSheet.setColumnWidth(0, 40);
      assetsSheet.setColumnWidth(1, 20);
      
      // Liabilities Sheet
      final liabilitiesSheet = excelFile['Liabilities'];
      _excelSetCell(liabilitiesSheet, 0, 0, 'LIABILITIES', bold: true, fontSize: 14, bgColor: 'C62828', fontColor: 'FFFFFF');
      
      row = 2;
      for (final category in liabilitiesData.keys) {
        final items = liabilitiesData[category] ?? {};
        if (items.isNotEmpty) {
          _excelSetCell(liabilitiesSheet, row, 0, category, bold: true, fontSize: 11, bgColor: 'E8EAF6');
          row++;
          
          for (final item in items.entries) {
            _excelSetCell(liabilitiesSheet, row, 0, '   ${item.key}', bgColor: row.isEven ? 'F5F5F5' : 'FFFFFF');
            _excelSetCell(liabilitiesSheet, row, 1, item.value, bgColor: row.isEven ? 'F5F5F5' : 'FFFFFF');
            row++;
          }
          
          _excelSetCell(liabilitiesSheet, row, 0, '   Total $category', bold: true, bgColor: 'E8EAF6');
          _excelSetCell(liabilitiesSheet, row, 1, items.values.fold(0.0, (sum, val) => sum + val), 
              bold: true, bgColor: 'E8EAF6', fontColor: 'C62828');
          row += 2;
        }
      }
      
      _excelSetCell(liabilitiesSheet, row, 0, 'TOTAL LIABILITIES', bold: true, fontSize: 12, bgColor: 'C62828', fontColor: 'FFFFFF');
      _excelSetCell(liabilitiesSheet, row, 1, totalLiabilities.value, bold: true, bgColor: 'C62828', fontColor: 'FFFFFF');
      
      liabilitiesSheet.setColumnWidth(0, 40);
      liabilitiesSheet.setColumnWidth(1, 20);
      
      // Equity Sheet
      final equitySheet = excelFile['Equity'];
      _excelSetCell(equitySheet, 0, 0, 'EQUITY', bold: true, fontSize: 14, bgColor: '1A237E', fontColor: 'FFFFFF');
      _excelSetCell(equitySheet, 2, 0, 'Total Equity', bold: true);
      _excelSetCell(equitySheet, 2, 1, equity.value, bold: true, fontColor: '1A237E');
      _excelSetCell(equitySheet, 4, 0, 'Total Liabilities & Equity', bold: true, fontSize: 12, bgColor: 'E8EAF6');
      _excelSetCell(equitySheet, 4, 1, totalLiabilities.value + equity.value, 
          bold: true, bgColor: 'E8EAF6', fontColor: '1A237E');
      
      equitySheet.setColumnWidth(0, 30);
      equitySheet.setColumnWidth(1, 20);
      
      excelFile.delete('Sheet1');
      
      final bytes = excelFile.save();
      if (bytes == null) throw Exception('Excel save failed');
      
      final dir = await getTemporaryDirectory();
      final fileName = 'balance_sheet_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);
      
      if (Get.isDialogOpen ?? false) Get.back();
      
      Get.snackbar('Success', 'Balance sheet exported to Excel',
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

  // ==================== PRINT BALANCE SHEET ====================
  void printBalanceSheet() {
    Get.snackbar(
      'Print',
      'Preparing balance sheet for print...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: kPrimary,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
    // TODO: Implement actual print functionality
  }

  // ==================== HANDLE SESSION EXPIRED ====================
  void _handleSessionExpired() {
    Get.snackbar(
      'Session Expired',
      'Please login again',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: kDanger,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
    // TODO: Navigate to login screen
  }

  // ==================== SHOW ERROR ====================
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: kDanger,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  // ==================== GETTERS FOR UI ====================
  List<String> get liabilityCategories => liabilitiesData.keys.toList();
  List<String> get assetCategories => assetsData.keys.toList();
  List<String> get equityCategories => equityData.keys.toList();

  Map<String, double> getCategoryItems(String category, bool isLiability) {
    if (isLiability) {
      return liabilitiesData[category] ?? {};
    }
    return assetsData[category] ?? {};
  }

  double getCategoryTotal(String category, bool isLiability) {
    final items = getCategoryItems(category, isLiability);
    return items.values.fold(0.0, (sum, val) => sum + val);
  }

  bool get hasData => liabilitiesData.isNotEmpty || assetsData.isNotEmpty;
}