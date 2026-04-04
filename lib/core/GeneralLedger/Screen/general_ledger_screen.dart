import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/core/GeneralLedger/Controller/general_ledger_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart' hide Border;

class GeneralLedgerScreen extends StatelessWidget {
  const GeneralLedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GeneralLedgerController());

    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(controller),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: LoadingAnimationWidget.waveDots(
                    color: kPrimary,
                    size: 10.w,
                  ));
        }
        
        return Column(
          children: [
            _buildFilterBar(controller),
            _buildAccountSummaryCards(controller),
            Expanded(
              child: _buildLedgerEntriesList(controller),
            ),
          ],
        );
      }),
      floatingActionButton: _buildFAB(controller),
    );
  }

  PreferredSizeWidget _buildAppBar(GeneralLedgerController controller) {
    return AppBar(
      title: Text(
        'General Ledger',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      backgroundColor: kPrimary,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(Icons.download_outlined, color: Colors.white, size: 5.w),
          onPressed: () => _showExportBottomSheet(controller),
        ),
        IconButton(
          icon: Icon(Icons.print_outlined, color: Colors.white, size: 5.w),
          onPressed: () => controller.printLedger(),
        ),
      ],
    );
  }

  // ─────────────────────── EXPORT BOTTOM SHEET ───────────────────────
  void _showExportBottomSheet(GeneralLedgerController controller) {
    showModalBottomSheet(
      context: Get.context!,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      backgroundColor: kCardBg,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: kBorder, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
             Text(
              'Export General Ledger',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800, color: kText),
            ),
             SizedBox(height: 6),
            Text(
              '${controller.ledgerEntries.length} entries will be exported',
              style:  TextStyle(fontSize: 13, color: kSubText),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                // PDF Button
                Expanded(
                  child: _exportOptionCard(
                    icon: Icons.picture_as_pdf_outlined,
                    label: 'PDF',
                    subtitle: 'Formatted report',
                    color: const Color(0xFFE53935),
                    bgColor: const Color(0xFFFFEBEE),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await Future.delayed(const Duration(milliseconds: 100));
                      _showExportingLoader('Generating PDF...');
                      try {
                        await _exportToPdf(controller);
                      } catch (e) {
                        if (Get.isDialogOpen ?? false) Get.back();
                        Get.snackbar('Error', 'Failed to export PDF: $e');
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Excel Button
                Expanded(
                  child: _exportOptionCard(
                    icon: Icons.table_chart_outlined,
                    label: 'Excel',
                    subtitle: 'Spreadsheet',
                    color: const Color(0xFF2E7D32),
                    bgColor: const Color(0xFFE8F5E9),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await Future.delayed(const Duration(milliseconds: 100));
                      _showExportingLoader('Building Excel...');
                      try {
                        await _exportToExcel(controller);
                      } catch (e) {
                        if (Get.isDialogOpen ?? false) Get.back();
                        Get.snackbar('Error', 'Failed to export Excel: $e');
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _exportOptionCard({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:  EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 10),
            Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: color)),
            const SizedBox(height: 2),
            Text(subtitle,
                style:
                    TextStyle(fontSize: 10, color: color.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }

  void _showExportingLoader(String message) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LoadingAnimationWidget.waveDots(color: kPrimary, size: 48),
            const SizedBox(height: 16),
            Text(message,
                style:  TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500, color: kText)),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  // ─────────────────────── PDF EXPORT ───────────────────────
  Future<void> _exportToPdf(GeneralLedgerController controller) async {
    try {
      final entries = controller.ledgerEntries;
      final selectedAccount = controller.selectedAccount.value;
      
      // Calculate totals
      double totalDebit = entries.fold(0, (sum, e) => sum + e.debit);
      double totalCredit = entries.fold(0, (sum, e) => sum + e.credit);
      double closingBalance = entries.isNotEmpty ? entries.last.balance : 0;
      
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          header: (ctx) => _pdfHeader(),
          footer: (ctx) => _pdfFooter(ctx),
          build: (ctx) => [
            _pdfSummarySection(selectedAccount, totalDebit, totalCredit, closingBalance, entries.length),
            pw.SizedBox(height: 16),
            _pdfLedgerEntriesSection(entries),
          ],
        ),
      );
      
      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/general_ledger_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf');
      await file.writeAsBytes(await pdf.save());
      
      if (Get.isDialogOpen ?? false) Get.back();
      
      Get.snackbar('Success', '${entries.length} entries exported to PDF',
          backgroundColor: const Color(0xFF2ECC71),
          colorText: Colors.white,
          duration: const Duration(seconds: 2));
          
      await OpenFile.open(file.path);
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      rethrow;
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
            pw.Text('General Ledger Report',
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
  
  pw.Widget _pdfSummarySection(String account, double totalDebit, double totalCredit, double closingBalance, int count) {
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
              _pdfSummaryItem('Account', account, PdfColors.indigo700),
              _pdfSummaryItem('Total Entries', count.toString(), PdfColors.indigo700),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _pdfSummaryItem('Total Debit', _formatAmount(totalDebit), PdfColors.green700),
              _pdfSummaryItem('Total Credit', _formatAmount(totalCredit), PdfColors.red700),
              _pdfSummaryItem('Closing Balance', _formatAmount(closingBalance), 
                  closingBalance >= 0 ? PdfColors.green700 : PdfColors.red700),
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
  
  pw.Widget _pdfLedgerEntriesSection(List<LedgerEntry> entries) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 8),
          decoration: const pw.BoxDecoration(
              border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: 1))),
          child: pw.Row(children: [
            pw.Expanded(flex: 2, child: pw.Text('Date', style:  pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text('Ref', style:  pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 4, child: pw.Text('Description', style:  pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text('Debit', textAlign: pw.TextAlign.right, style:     pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text('Credit', textAlign: pw.TextAlign.right, style:     pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text('Balance', textAlign: pw.TextAlign.right, style:     pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          ]),
        ),
        ...entries.map((entry) => pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 6),
          decoration: const pw.BoxDecoration(
              border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5))),
          child: pw.Row(children: [
            pw.Expanded(flex: 2, child: pw.Text(DateFormat('dd/MM/yyyy').format(entry.date), style: const pw.TextStyle(fontSize: 9))),
            pw.Expanded(flex: 2, child: pw.Text(entry.reference.isEmpty ? '-' : entry.reference, style: const pw.TextStyle(fontSize: 9))),
            pw.Expanded(flex: 4, child: pw.Text(entry.description, style: const pw.TextStyle(fontSize: 9))),
            pw.Expanded(flex: 2, child: pw.Text(entry.debit > 0 ? _formatAmount(entry.debit) : '-', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9, color: PdfColors.green700))),
            pw.Expanded(flex: 2, child: pw.Text(entry.credit > 0 ? _formatAmount(entry.credit) : '-', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9, color: PdfColors.red700))),
            pw.Expanded(flex: 2, child: pw.Text(_formatAmount(entry.balance), textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
          ]),
        )).toList(),
      ],
    );
  }
  
  // ─────────────────────── EXCEL EXPORT ───────────────────────
  Future<void> _exportToExcel(GeneralLedgerController controller) async {
    try {
      final entries = controller.ledgerEntries;
      final selectedAccount = controller.selectedAccount.value;
      
      final excel = Excel.createExcel();
      
      // Summary Sheet
      final summarySheet = excel['Summary'];
      excel.setDefaultSheet('Summary');
      
      _excelSetCell(summarySheet, 0, 0, 'General Ledger Report',
          bold: true, fontSize: 14, bgColor: '1A237E', fontColor: 'FFFFFF');
      _excelSetCell(summarySheet, 1, 0,
          'Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
          fontSize: 9, fontColor: '757575');
      _excelSetCell(summarySheet, 2, 0, 'Account: $selectedAccount',
          fontSize: 10, fontColor: '1A237E', bold: true);
      _excelSetCell(summarySheet, 3, 0, 'Total Entries: ${entries.length}',
          fontSize: 10, fontColor: '1A237E');
      
      _excelSetCell(summarySheet, 5, 0, 'SUMMARY', bold: true, fontSize: 11, bgColor: 'E8EAF6');
      
      final totalDebit = entries.fold(0.0, (sum, e) => sum + e.debit);
      final totalCredit = entries.fold(0.0, (sum, e) => sum + e.credit);
      final closingBalance = entries.isNotEmpty ? entries.last.balance : 0.0;
      
      final summaryRows = [
        ['Total Debit', _formatAmount(totalDebit)],
        ['Total Credit', _formatAmount(totalCredit)],
        ['Closing Balance', _formatAmount(closingBalance)],
      ];
      
      for (int r = 0; r < summaryRows.length; r++) {
        for (int c = 0; c < 2; c++) {
          _excelSetCell(summarySheet, 6 + r, c, summaryRows[r][c],
              bgColor: r.isEven ? 'FFFFFF' : 'F5F5F5');
        }
      }
      summarySheet.setColumnWidth(0, 25);
      summarySheet.setColumnWidth(1, 20);
      
      // Ledger Entries Sheet
      final entriesSheet = excel['Ledger Entries'];
      final headers = [
        'Date', 'Reference', 'Description', 'Account', 'Debit', 'Credit', 'Balance'
      ];
      
      for (int i = 0; i < headers.length; i++) {
        _excelSetCell(entriesSheet, 0, i, headers[i],
            bold: true, bgColor: '1A237E', fontColor: 'FFFFFF', fontSize: 10);
      }
      
      int row = 1;
      for (final entry in entries) {
        final bg = row.isEven ? 'F5F5F5' : 'FFFFFF';
        _excelSetCell(entriesSheet, row, 0, DateFormat('dd/MM/yyyy').format(entry.date), bgColor: bg);
        _excelSetCell(entriesSheet, row, 1, entry.reference.isEmpty ? '-' : entry.reference, bgColor: bg);
        _excelSetCell(entriesSheet, row, 2, entry.description, bgColor: bg);
        _excelSetCell(entriesSheet, row, 3, entry.accountName, bgColor: bg);
        _excelSetCell(entriesSheet, row, 4, entry.debit > 0 ? entry.debit : '', bgColor: bg, fontColor: '2E7D32');
        _excelSetCell(entriesSheet, row, 5, entry.credit > 0 ? entry.credit : '', bgColor: bg, fontColor: 'C62828');
        _excelSetCell(entriesSheet, row, 6, entry.balance, bgColor: bg, fontColor: entry.balance >= 0 ? '2E7D32' : 'C62828');
        row++;
      }
      
      final colWidths = [12.0, 15.0, 35.0, 25.0, 12.0, 12.0, 15.0];
      for (int i = 0; i < colWidths.length; i++) {
        entriesSheet.setColumnWidth(i, colWidths[i]);
      }
      
      excel.delete('Sheet1');
      
      final bytes = excel.save();
      if (bytes == null) throw Exception('Excel save failed');
      
      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/general_ledger_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx');
      await file.writeAsBytes(bytes);
      
      if (Get.isDialogOpen ?? false) Get.back();
      
      Get.snackbar('Success', '${entries.length} entries exported to Excel',
          backgroundColor: const Color(0xFF2ECC71),
          colorText: Colors.white,
          duration: const Duration(seconds: 2));
          
      await OpenFile.open(file.path);
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      rethrow;
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
  
  String _formatAmount(double amount) {
    return 'Rs. ${amount.toStringAsFixed(2)}';
  }

  // ─────────────────────── FILTER BAR ───────────────────────
  Widget _buildFilterBar(GeneralLedgerController controller) {
    final List<String> filterOptions = [
      'All', 'Today', 'This Week', 'This Month', 'This Quarter', 'This Year', 'Custom Range'
    ];

    return Container(
      width: 100.w,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      color: kCardBg,
      child: Column(
        children: [
          // Account Selector
          Container(
            height: 6.5.h,
            decoration: BoxDecoration(
              color: kBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorder),
            ),
            child: DropdownButtonHideUnderline(
              child: Obx(() => DropdownButton<String>(
                value: controller.selectedAccount.value,
                icon: Icon(Icons.arrow_drop_down, size: 5.w),
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                isExpanded: true,
                style: TextStyle(fontSize: 13.sp, color: kText),
                items: [
                  const DropdownMenuItem(
                    value: 'All Accounts',
                    child: Text('All Accounts'),
                  ),
                  ...controller.accountSummaries.map((account) {
                    return DropdownMenuItem(
                      value: account.accountName,
                      child: Text(account.accountName),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  if (value != null) controller.changeAccount(value);
                },
              )),
            ),
          ),
          SizedBox(height: 1.5.h),
          
          // Search and Date Filter
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  height: 6.5.h,
                  decoration: BoxDecoration(
                    color: kBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kBorder),
                  ),
                  child: TextField(
                    onChanged: (value) => controller.searchEntries(value),
                    style: TextStyle(fontSize: 13.sp),
                    decoration: InputDecoration(
                      hintText: 'Search by description or reference...',
                      hintStyle: TextStyle(fontSize: 13.sp, color: kSubText),
                      prefixIcon: Icon(Icons.search, size: 5.w),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 1.8.h),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                flex: 2,
                child: Container(
                  height: 6.5.h,
                  decoration: BoxDecoration(
                    color: kBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.fromBorderSide(BorderSide(color: kBorder)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: Obx(() => DropdownButton<String>(
                      value: controller.selectedFilter.value,
                      icon: Icon(Icons.arrow_drop_down, size: 5.w),
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      isExpanded: true,
                      style: TextStyle(fontSize: 13.sp, color: kText),
                      items: filterOptions.map((filter) {
                        return DropdownMenuItem(
                          value: filter,
                          child: Text(filter),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          if (value == 'Custom Range') {
                            _selectDateRange(controller);
                          } else {
                            controller.changeFilter(value);
                          }
                        }
                      },
                    )),
                  ),
                ),
              ),
            ],
          ),
          
          // Debit/Credit Filter Row
          Padding(
            padding: EdgeInsets.only(top: 1.5.h),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() => GestureDetector(
                    onTap: () => controller.toggleDebitFilter(),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 1.2.h),
                      decoration: BoxDecoration(
                        color: controller.showOnlyDebit.value 
                            ? kSuccess.withValues(alpha: 0.2) 
                            : kBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.fromBorderSide(
                          BorderSide(
                            color: controller.showOnlyDebit.value 
                                ? kSuccess 
                                : kBorder,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.trending_up,
                            size: 4.w,
                            color: controller.showOnlyDebit.value 
                                ? kSuccess 
                                : kSubText,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Debit Only',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: controller.showOnlyDebit.value 
                                  ? FontWeight.w600 
                                  : FontWeight.w400,
                              color: controller.showOnlyDebit.value 
                                  ? kSuccess 
                                  : kSubText,
                            ),
                          ),
                          if (controller.showOnlyDebit.value)
                            Padding(
                              padding: EdgeInsets.only(left: 2.w),
                              child: Icon(
                                Icons.check_circle,
                                size: 3.5.w,
                                color: kSuccess,
                              ),
                            ),
                        ],
                      ),
                    ),
                  )),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Obx(() => GestureDetector(
                    onTap: () => controller.toggleCreditFilter(),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 1.2.h),
                      decoration: BoxDecoration(
                        color: controller.showOnlyCredit.value 
                            ? kDanger.withOpacity(0.2) 
                            : kBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: controller.showOnlyCredit.value 
                              ? kDanger 
                              : kBorder,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.trending_down,
                            size: 4.w,
                            color: controller.showOnlyCredit.value 
                                ? kDanger 
                                : kSubText,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Credit Only',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: controller.showOnlyCredit.value 
                                  ? FontWeight.w600 
                                  : FontWeight.w400,
                              color: controller.showOnlyCredit.value 
                                  ? kDanger 
                                  : kSubText,
                            ),
                          ),
                          if (controller.showOnlyCredit.value)
                            Padding(
                              padding: EdgeInsets.only(left: 2.w),
                              child: Icon(
                                Icons.check_circle,
                                size: 3.5.w,
                                color: kDanger,
                              ),
                            ),
                        ],
                      ),
                    ),
                  )),
                ),
              ],
            ),
          ),
          
          Obx(() {
            if (controller.selectedDateRange.value != null) {
              final range = controller.selectedDateRange.value!;
              return Padding(
                padding: EdgeInsets.only(top: 1.5.h),
                child: Container(
                  width: 100.w,
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '${DateFormat('dd MMM yyyy').format(range.start)} - ${DateFormat('dd MMM yyyy').format(range.end)}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: kPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => controller.setDateRange(null),
                        child: Icon(Icons.close, size: 5.w, color: kPrimary),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildAccountSummaryCards(GeneralLedgerController controller) {
    return Obx(() {
      final accounts = controller.accountSummaries;
      
      if (accounts.isEmpty) {
        return SizedBox(
          height: 20.h,
          child: Center(child: Text('No accounts found', style: TextStyle(fontSize: 13.sp))),
        );
      }
      
      return Container(
        height: 25.h,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: accounts.length,
          separatorBuilder: (context, index) => SizedBox(width: 3.w),
          itemBuilder: (context, index) {
            final account = accounts[index];
            return _buildAccountCard(account);
          },
        ),
      );
    });
  }

  Widget _buildAccountCard(AccountSummary account) {
    Color balanceColor = account.closingBalance >= 0 ? kSuccess : kDanger;
    IconData balanceIcon = account.accountType == 'Assets' || account.accountType == 'Expenses'
        ? Icons.trending_up
        : Icons.trending_down;
    
    return Container(
      height: 250.h,
      width: 40.w,
      padding: EdgeInsets.all(2.5.w),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.8.h),
                decoration: BoxDecoration(
                  color: _getAccountTypeColor(account.accountType).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  account.accountCode,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: _getAccountTypeColor(account.accountType),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(balanceIcon, size: 6.w, color: balanceColor),
            ],
          ),
          Text(
            account.accountName,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: kText,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            _formatAmountLocal(account.closingBalance),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: balanceColor,
            ),
          ),
           Text(
                'Dr: ${_formatAmountLocal(account.totalDebit)}',
                style: TextStyle(fontSize: 13.sp, color: kSuccess, fontWeight: FontWeight.w500),
              ),
           Text(
                'Cr: ${_formatAmountLocal(account.totalCredit)}',
                style: TextStyle(fontSize: 13.sp, color: kDanger, fontWeight: FontWeight.w500),
              ),
        
        ],
      ),
    );
  }

  Widget _buildLedgerEntriesList(GeneralLedgerController controller) {
    return Obx(() {
      final entries = controller.filteredLedgerEntries;
      
      if (entries.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_balance, size: 20.w, color: kSubText.withOpacity(0.5)),
              SizedBox(height: 2.h),
              Text(
                'No ledger entries found',
                style: TextStyle(fontSize: 16.sp, color: kSubText, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(4.w),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          return _buildLedgerEntryCard(entry);
        },
      );
    });
  }

  Widget _buildLedgerEntryCard(LedgerEntry entry) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(3.5.w),
            decoration: BoxDecoration(
              color: kBg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 14.w,
                  height: 14.w,
                  decoration: BoxDecoration(
                    color: _getAccountTypeColor(_getAccountType(entry.accountName)).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getAccountIcon(_getAccountType(entry.accountName)),
                    size: 7.w,
                    color: _getAccountTypeColor(_getAccountType(entry.accountName)),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.accountName,
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: kText),
                      ),
                      SizedBox(height: 0.3.h),
                      Text(
                        '${entry.accountCode} • ${entry.reference}',
                        style: TextStyle(fontSize: 13.sp, color: kSubText),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat('dd MMM yyyy').format(entry.date),
                      style: TextStyle(fontSize: 13.sp, color: kSubText),
                    ),
                    SizedBox(height: 0.8.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.6.h),
                      decoration: BoxDecoration(
                        color: kPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        entry.id,
                        style: TextStyle(fontSize: 13.sp, color: kPrimary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(3.5.w),
            child: Column(
              children: [
                Text(
                  entry.description,
                  style: TextStyle(fontSize: 13.sp, color: kText),
                ),
                SizedBox(height: 2.5.h),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Debit', style: TextStyle(fontSize: 13.sp, color: kSubText, fontWeight: FontWeight.w500)),
                          SizedBox(height: 0.5.h),
                          Text(
                            entry.debit > 0 ? _formatAmountLocal(entry.debit) : '-',
                            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: kSuccess),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Credit', style: TextStyle(fontSize: 13.sp, color: kSubText, fontWeight: FontWeight.w500)),
                          SizedBox(height: 0.5.h),
                          Text(
                            entry.credit > 0 ? _formatAmountLocal(entry.credit) : '-',
                            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: kDanger),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Running Balance', style: TextStyle(fontSize: 13.sp, color: kSubText, fontWeight: FontWeight.w500)),
                          SizedBox(height: 0.5.h),
                          Text(
                            _formatAmountLocal(entry.balance),
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: entry.balance >= 0 ? kSuccess : kDanger,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(GeneralLedgerController controller) {
    return FloatingActionButton(
      onPressed: () => _showFilterDialog(controller),
      backgroundColor: kPrimary,
      child: Icon(Icons.filter_alt, color: Colors.white, size: 6.w),
      elevation: 2,
    );
  }

  void _selectDateRange(GeneralLedgerController controller) async {
    final picked = await showDateRangePicker(
      context: Get.context!,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: controller.selectedDateRange.value,
    );
    if (picked != null) {
      controller.setDateRange(picked);
    }
  }

  void _showFilterDialog(GeneralLedgerController controller) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: Text('Filter Ledger', style: TextStyle(fontSize: 16.sp)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() => ListTile(
              leading: Icon(Icons.trending_up, color: kSuccess),
              title: Text('Show Debit Entries Only', style: TextStyle(fontSize: 14.sp)),
              trailing: Switch(
                value: controller.showOnlyDebit.value,
                onChanged: (val) {
                  controller.toggleDebitFilter();
                  Navigator.pop(context);
                },
                activeColor: kSuccess,
              ),
            )),
            Obx(() => ListTile(
              leading: Icon(Icons.trending_down, color: kDanger),
              title: Text('Show Credit Entries Only', style: TextStyle(fontSize: 14.sp)),
              trailing: Switch(
                value: controller.showOnlyCredit.value,
                onChanged: (val) {
                  controller.toggleCreditFilter();
                  Navigator.pop(context);
                },
                activeColor: kDanger,
              ),
            )),
            const Divider(),
            ListTile(
              leading: Icon(Icons.date_range),
              title:Text('Date Range'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.pop(context);
                _selectDateRange(controller);
              },
            ),
            if (controller.showOnlyDebit.value || controller.showOnlyCredit.value)
              ListTile(
                leading: Icon(Icons.clear_all, color: kSubText),
                title: Text('Clear Filters', style: TextStyle(fontSize: 14.sp)),
                onTap: () {
                  controller.clearFilters();
                  Navigator.pop(context);
                },
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:Text('Close'),
          ),
        ],
      ),
    );
  }

  Color _getAccountTypeColor(String type) {
    switch (type) {
      case 'Assets': return kSuccess;
      case 'Liabilities': return kDanger;
      case 'Income': return kPrimary;
      case 'Expenses': return kWarning;
      default: return kSubText;
    }
  }

  IconData _getAccountIcon(String type) {
    switch (type) {
      case 'Assets': return Icons.account_balance;
      case 'Liabilities': return Icons.payment;
      case 'Income': return Icons.trending_up;
      case 'Expenses': return Icons.trending_down;
      default: return Icons.account_balance;
    }
  }

  String _getAccountType(String accountName) {
    if (accountName.contains('Cash') || accountName.contains('Bank') || accountName.contains('Receivable')) {
      return 'Assets';
    } else if (accountName.contains('Payable') || accountName.contains('Loan')) {
      return 'Liabilities';
    } else if (accountName.contains('Revenue') || accountName.contains('Sales')) {
      return 'Income';
    } else if (accountName.contains('Expense') || accountName.contains('Rent') || accountName.contains('Salary')) {
      return 'Expenses';
    }
    return 'Assets';
  }

  String _formatAmountLocal(double amount) {
    return '₨ ${amount.toStringAsFixed(2)}';
  }
}