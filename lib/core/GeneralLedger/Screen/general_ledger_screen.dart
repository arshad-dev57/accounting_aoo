import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/Utils/responsive_utils.dart';
import 'package:LedgerPro_app/Utils/toast_utils.dart';
import 'package:LedgerPro_app/core/GeneralLedger/Controller/general_ledger_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart' hide Border;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

class GeneralLedgerScreen extends StatelessWidget {
  const GeneralLedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GeneralLedgerController());

    return Material(
      // ✅ FIX 1: Material widget wrap — DropdownButton/Switch/IconButton sab ko
      // Material ancestor chahiye. Container(color: kBg) Material nahi hai.
      color: kBg,
      child: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: LoadingAnimationWidget.waveDots(
              color: kPrimary,
              size: ResponsiveUtils.isWeb(context) ? 60 : 40,
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(controller, context),
              _buildFilterBar(controller, context),
              _buildAccountSummaryCards(controller, context),
              _buildLedgerEntriesList(controller, context),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  // ─────────────────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────────────────
  Widget _buildHeader(GeneralLedgerController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final isMobile = ResponsiveUtils.isMobile(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        isWeb ? 24 : 16,
        isWeb ? 20 : 16,
        isWeb ? 24 : 16,
        isWeb ? 16 : 12,
      ),
      decoration: BoxDecoration(
        color: kPrimary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      // ✅ FIX 2: Header Row overflow — title Flexible mein hai, icons fixed size
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'General Ledger',
                  style: TextStyle(
                    fontSize: isWeb ? 20 : 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'View and manage all ledger entries',
                  style: TextStyle(
                    fontSize: isWeb ? 13 : 11,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  overflow: TextOverflow.ellipsis, // ✅ overflow prevent
                ),
              ],
            ),
          ),
          // Download button
          _headerIconBtn(
            icon: Icons.download_outlined,
            size: isWeb ? 22 : 20,
            onTap: () => _showExportBottomSheet(controller, context),
          ),
          if (!isMobile) const SizedBox(width: 8),
          if (!isMobile)
            _headerIconBtn(
              icon: Icons.filter_alt,
              size: isWeb ? 22 : 20,
              onTap: () => _showFilterDialog(controller, context),
            ),
        ],
      ),
    );
  }

  // ✅ FIX 3: IconButton Material error — InkWell + Container se replace kiya
  Widget _headerIconBtn({
    required IconData icon,
    required double size,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: size),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // EXPORT BOTTOM SHEET
  // ─────────────────────────────────────────────────────────
  void _showExportBottomSheet(
      GeneralLedgerController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);

    if (isWeb) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: SizedBox(
            width: 500,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _buildExportContent(controller, ctx),
            ),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        backgroundColor: kCardBg,
        builder: (ctx) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: _buildExportContent(controller, ctx),
        ),
      );
    }
  }

  Widget _buildExportContent(
      GeneralLedgerController controller, BuildContext ctx) {
    final isWeb = ResponsiveUtils.isWeb(ctx);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isWeb)
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: kBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        if (!isWeb) const SizedBox(height: 20),
        Text(
          'Export General Ledger',
          style: TextStyle(
            fontSize: isWeb ? 20 : 18,
            fontWeight: FontWeight.w800,
            color: kText,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${controller.ledgerEntries.length} entries will be exported',
          style: TextStyle(fontSize: isWeb ? 14 : 13, color: kSubText),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
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
                    AppSnackbar.error(
                        Colors.red, 'Error', 'Failed to export PDF: $e');
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
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
                    AppSnackbar.error(
                        Colors.red, 'Error', 'Failed to export Excel: $e');
                  }
                },
              ),
            ),
          ],
        ),
      ],
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
    final isWeb = ResponsiveUtils.isWeb(Get.context!);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            vertical: isWeb ? 24 : 20, horizontal: isWeb ? 16 : 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(isWeb ? 20 : 16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(isWeb ? 14 : 10),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
              ),
              child: Icon(icon, color: Colors.white, size: isWeb ? 28 : 24),
            ),
            SizedBox(height: isWeb ? 16 : 10),
            Text(
              label,
              style: TextStyle(
                fontSize: isWeb ? 16 : 14,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                  fontSize: isWeb ? 11 : 10, color: color.withOpacity(0.7)),
            ),
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
            Text(
              message,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: kText),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  // ─────────────────────────────────────────────────────────
  // EXPORT PDF
  // ─────────────────────────────────────────────────────────
  Future<void> _exportToPdf(GeneralLedgerController controller) async {
    try {
      final entries = controller.ledgerEntries;
      final selectedAccount = controller.selectedAccount.value;

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
            _pdfSummarySection(selectedAccount, totalDebit, totalCredit,
                closingBalance, entries.length),
            pw.SizedBox(height: 16),
            _pdfLedgerEntriesSection(entries),
          ],
        ),
      );

      final bytes = await pdf.save();
      final fileName =
          'general_ledger_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';

      if (kIsWeb) {
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(bytes);
        await OpenFile.open(file.path);
      }

      if (Get.isDialogOpen ?? false) Get.back();
      AppSnackbar.success(kSuccess, 'Success',
          '${entries.length} entries exported to PDF',
          duration: const Duration(seconds: 2));
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      AppSnackbar.error(kDanger, 'Error', 'Failed to export PDF: $e');
    }
  }

  pw.Widget _pdfHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border:
            pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('General Ledger Report',
                  style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.indigo800)),
              pw.Text(
                  'Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
                  style:
                      const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
            ],
          ),
          pw.Container(
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
        border:
            pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 1)),
      ),
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

  pw.Widget _pdfSummarySection(String account, double totalDebit,
      double totalCredit, double closingBalance, int count) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.indigo50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.indigo200),
      ),
      child: pw.Column(children: [
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceAround, children: [
          _pdfSummaryItem('Account', account, PdfColors.indigo700),
          _pdfSummaryItem('Total Entries', count.toString(), PdfColors.indigo700),
        ]),
        pw.SizedBox(height: 8),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceAround, children: [
          _pdfSummaryItem(
              'Total Debit', _formatAmount(totalDebit), PdfColors.green700),
          _pdfSummaryItem(
              'Total Credit', _formatAmount(totalCredit), PdfColors.red700),
          _pdfSummaryItem(
              'Closing Balance',
              _formatAmount(closingBalance),
              closingBalance >= 0 ? PdfColors.green700 : PdfColors.red700),
        ]),
      ]),
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
                bottom: pw.BorderSide(color: PdfColors.grey300, width: 1)),
          ),
          child: pw.Row(children: [
            pw.Expanded(
                flex: 2,
                child: pw.Text('Date',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(
                flex: 2,
                child: pw.Text('Ref',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(
                flex: 4,
                child: pw.Text('Description',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(
                flex: 2,
                child: pw.Text('Debit',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(
                flex: 2,
                child: pw.Text('Credit',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(
                flex: 2,
                child: pw.Text('Balance',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          ]),
        ),
        ...entries
            .map((entry) => pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 6),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                        bottom: pw.BorderSide(
                            color: PdfColors.grey200, width: 0.5)),
                  ),
                  child: pw.Row(children: [
                    pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                            DateFormat('dd/MM/yyyy').format(entry.date),
                            style: const pw.TextStyle(fontSize: 9))),
                    pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                            entry.reference.isEmpty ? '-' : entry.reference,
                            style: const pw.TextStyle(fontSize: 9))),
                    pw.Expanded(
                        flex: 4,
                        child: pw.Text(entry.description,
                            style: const pw.TextStyle(fontSize: 9))),
                    pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                            entry.debit > 0 ? _formatAmount(entry.debit) : '-',
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(
                                fontSize: 9, color: PdfColors.green700))),
                    pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                            entry.credit > 0
                                ? _formatAmount(entry.credit)
                                : '-',
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(
                                fontSize: 9, color: PdfColors.red700))),
                    pw.Expanded(
                        flex: 2,
                        child: pw.Text(_formatAmount(entry.balance),
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold))),
                  ]),
                ))
            .toList(),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  // EXPORT EXCEL
  // ─────────────────────────────────────────────────────────
  Future<void> _exportToExcel(GeneralLedgerController controller) async {
    try {
      final entries = controller.ledgerEntries;
      final selectedAccount = controller.selectedAccount.value;

      final excel = Excel.createExcel();
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
      _excelSetCell(summarySheet, 5, 0, 'SUMMARY',
          bold: true, fontSize: 11, bgColor: 'E8EAF6');

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
        _excelSetCell(entriesSheet, row, 0,
            DateFormat('dd/MM/yyyy').format(entry.date), bgColor: bg);
        _excelSetCell(entriesSheet, row, 1,
            entry.reference.isEmpty ? '-' : entry.reference, bgColor: bg);
        _excelSetCell(entriesSheet, row, 2, entry.description, bgColor: bg);
        _excelSetCell(entriesSheet, row, 3, entry.accountName, bgColor: bg);
        _excelSetCell(entriesSheet, row, 4,
            entry.debit > 0 ? entry.debit : '', bgColor: bg, fontColor: '2E7D32');
        _excelSetCell(entriesSheet, row, 5,
            entry.credit > 0 ? entry.credit : '', bgColor: bg, fontColor: 'C62828');
        _excelSetCell(entriesSheet, row, 6, entry.balance,
            bgColor: bg, fontColor: entry.balance >= 0 ? '2E7D32' : 'C62828');
        row++;
      }

      final colWidths = [12.0, 15.0, 35.0, 25.0, 12.0, 12.0, 15.0];
      for (int i = 0; i < colWidths.length; i++) {
        entriesSheet.setColumnWidth(i, colWidths[i]);
      }

      excel.delete('Sheet1');

      final bytes = excel.save();
      if (bytes == null) throw Exception('Excel save failed');

      final fileName =
          'general_ledger_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';

      if (kIsWeb) {
        final blob = html.Blob([bytes],
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(bytes);
        await OpenFile.open(file.path);
      }

      if (Get.isDialogOpen ?? false) Get.back();
      AppSnackbar.success(kSuccess, 'Success',
          '${entries.length} entries exported to Excel',
          duration: const Duration(seconds: 2));
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      AppSnackbar.error(kDanger, 'Error', 'Failed to export Excel: $e');
    }
  }

  void _excelSetCell(Sheet sheet, int row, int col, dynamic value,
      {bool bold = false,
      double fontSize = 10,
      String? bgColor,
      String fontColor = '000000'}) {
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

  String _formatAmount(double amount) => '\$. ${amount.toStringAsFixed(2)}';

  // ─────────────────────────────────────────────────────────
  // FILTER BAR
  // ─────────────────────────────────────────────────────────
  Widget _buildFilterBar(
      GeneralLedgerController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);

    final List<String> filterOptions = [
      'All', 'Today', 'This Week', 'This Month', 'This Quarter', 'This Year',
      'Custom Range'
    ];

    // ✅ FIX 4: Material wrapper — DropdownButton Material ancestor chahiye
    return Material(
      color: kCardBg,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
            horizontal: isWeb ? 24 : 16, vertical: isWeb ? 16 : 12),
        child: Column(
          children: [
            // Account Dropdown
            Container(
              height: isWeb ? 50 : 45,
              decoration: BoxDecoration(
                color: kBg,
                borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
                border: Border.all(color: kBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: Obx(() => DropdownButton<String>(
                      value: controller.selectedAccount.value,
                      icon: Icon(Icons.arrow_drop_down,
                          size: isWeb ? 28 : 24),
                      padding: EdgeInsets.symmetric(
                          horizontal: isWeb ? 16 : 12),
                      isExpanded: true,
                      style: TextStyle(
                          fontSize: isWeb ? 14 : 13, color: kText),
                      items: [
                        const DropdownMenuItem(
                            value: 'All Accounts',
                            child: Text('All Accounts')),
                        ...controller.accountSummaries.map((account) {
                          return DropdownMenuItem(
                            value: account.accountName,
                            child: Text(account.accountName,
                                overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        if (value != null) controller.changeAccount(value);
                      },
                    )),
              ),
            ),
            SizedBox(height: isWeb ? 16 : 12),

            // Search + Filter Row
            // ✅ FIX 5: Row overflow — search field Flexible, filter dropdown fixed width
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: isWeb ? 50 : 45,
                    decoration: BoxDecoration(
                      color: kBg,
                      borderRadius:
                          BorderRadius.circular(isWeb ? 12 : 10),
                      border: Border.all(color: kBorder),
                    ),
                    child: TextField(
                      onChanged: (value) =>
                          controller.searchEntries(value),
                      style: TextStyle(fontSize: isWeb ? 14 : 13),
                      decoration: InputDecoration(
                        hintText: isWeb
                            ? 'Search by description or reference...'
                            : 'Search...',
                        hintStyle: TextStyle(
                            fontSize: isWeb ? 13 : 12, color: kSubText),
                        prefixIcon: Icon(Icons.search,
                            size: isWeb ? 22 : 20, color: kSubText),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: isWeb ? 14 : 12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: isWeb ? 16 : 8),
                // ✅ Fixed width dropdown — overflow nahi hoga
                SizedBox(
                  width: isWeb ? 160 : 130,
                  height: isWeb ? 50 : 45,
                  child: Container(
                    decoration: BoxDecoration(
                      color: kBg,
                      borderRadius:
                          BorderRadius.circular(isWeb ? 12 : 10),
                      border: Border.all(color: kBorder),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: Obx(() => DropdownButton<String>(
                            value: controller.selectedFilter.value,
                            icon: Icon(Icons.arrow_drop_down,
                                size: isWeb ? 28 : 24),
                            padding: EdgeInsets.symmetric(
                                horizontal: isWeb ? 12 : 8),
                            isExpanded: true,
                            style: TextStyle(
                                fontSize: isWeb ? 14 : 12, color: kText),
                            items: filterOptions.map((filter) {
                              return DropdownMenuItem(
                                  value: filter, child: Text(filter));
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                if (value == 'Custom Range') {
                                  _selectDateRange(controller, context);
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

            // Debit/Credit Toggle Row
            // ✅ FIX 6: Toggle buttons overflow — Flexible text use kiya
            Padding(
              padding: EdgeInsets.only(top: isWeb ? 16 : 12),
              child: Row(
                children: [
                  Expanded(
                    child: Obx(() => GestureDetector(
                          onTap: () => controller.toggleDebitFilter(),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: isWeb ? 10 : 8),
                            decoration: BoxDecoration(
                              color: controller.showOnlyDebit.value
                                  ? kSuccess.withOpacity(0.2)
                                  : kBg,
                              borderRadius:
                                  BorderRadius.circular(isWeb ? 10 : 8),
                              border: Border.all(
                                color: controller.showOnlyDebit.value
                                    ? kSuccess
                                    : kBorder,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.trending_up,
                                    size: isWeb ? 20 : 16,
                                    color: controller.showOnlyDebit.value
                                        ? kSuccess
                                        : kSubText),
                                SizedBox(width: isWeb ? 6 : 4),
                                Flexible(
                                  child: Text(
                                    'Debit',
                                    style: TextStyle(
                                      fontSize: isWeb ? 13 : 11,
                                      fontWeight:
                                          controller.showOnlyDebit.value
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                      color: controller.showOnlyDebit.value
                                          ? kSuccess
                                          : kSubText,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (controller.showOnlyDebit.value)
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: isWeb ? 6 : 4),
                                    child: Icon(Icons.check_circle,
                                        size: isWeb ? 16 : 13,
                                        color: kSuccess),
                                  ),
                              ],
                            ),
                          ),
                        )),
                  ),
                  SizedBox(width: isWeb ? 16 : 10),
                  Expanded(
                    child: Obx(() => GestureDetector(
                          onTap: () => controller.toggleCreditFilter(),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: isWeb ? 10 : 8),
                            decoration: BoxDecoration(
                              color: controller.showOnlyCredit.value
                                  ? kDanger.withOpacity(0.2)
                                  : kBg,
                              borderRadius:
                                  BorderRadius.circular(isWeb ? 10 : 8),
                              border: Border.all(
                                color: controller.showOnlyCredit.value
                                    ? kDanger
                                    : kBorder,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.trending_down,
                                    size: isWeb ? 20 : 16,
                                    color: controller.showOnlyCredit.value
                                        ? kDanger
                                        : kSubText),
                                SizedBox(width: isWeb ? 6 : 4),
                                Flexible(
                                  child: Text(
                                    'Credit',
                                    style: TextStyle(
                                      fontSize: isWeb ? 13 : 11,
                                      fontWeight:
                                          controller.showOnlyCredit.value
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                      color:
                                          controller.showOnlyCredit.value
                                              ? kDanger
                                              : kSubText,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (controller.showOnlyCredit.value)
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: isWeb ? 6 : 4),
                                    child: Icon(Icons.check_circle,
                                        size: isWeb ? 16 : 13,
                                        color: kDanger),
                                  ),
                              ],
                            ),
                          ),
                        )),
                  ),
                ],
              ),
            ),

            // Date Range Display
            Obx(() {
              if (controller.selectedDateRange.value != null) {
                final range = controller.selectedDateRange.value!;
                return Padding(
                  padding: EdgeInsets.only(top: isWeb ? 16 : 12),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                        horizontal: isWeb ? 16 : 12,
                        vertical: isWeb ? 12 : 10),
                    decoration: BoxDecoration(
                      color: kPrimary.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(isWeb ? 12 : 10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${DateFormat('dd MMM yyyy').format(range.start)} - ${DateFormat('dd MMM yyyy').format(range.end)}',
                            style: TextStyle(
                              fontSize: isWeb ? 13 : 12,
                              color: kPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => controller.setDateRange(null),
                          child: Icon(Icons.close,
                              size: isWeb ? 20 : 18, color: kPrimary),
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
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // ACCOUNT SUMMARY CARDS
  // ─────────────────────────────────────────────────────────
  Widget _buildAccountSummaryCards(
      GeneralLedgerController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final isTablet = ResponsiveUtils.isTablet(context);

    return Obx(() {
      final accounts = controller.accountSummaries;

      if (accounts.isEmpty) {
        return SizedBox(
          height: isWeb ? 160 : 130,
          child: Center(
            child: Text('No accounts found',
                style: TextStyle(
                    fontSize: isWeb ? 14 : 12, color: kSubText)),
          ),
        );
      }

      return SizedBox(
        height: isWeb ? 180 : (isTablet ? 160 : 150),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16),
          itemCount: accounts.length,
          separatorBuilder: (_, __) =>
              SizedBox(width: isWeb ? 16 : 12),
          itemBuilder: (context, index) =>
              _buildAccountCard(accounts[index], context),
        ),
      );
    });
  }

  Widget _buildAccountCard(AccountSummary account, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final isTablet = ResponsiveUtils.isTablet(context);

    Color balanceColor =
        account.closingBalance >= 0 ? kSuccess : kDanger;
    IconData balanceIcon =
        account.accountType == 'Assets' || account.accountType == 'Expenses'
            ? Icons.trending_up
            : Icons.trending_down;

    double cardWidth = isWeb ? 260 : (isTablet ? 220 : 180);

    return SizedBox(
      width: cardWidth,
      child: Card(
        color: kCardBg,
        elevation: 2,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isWeb ? 14 : 12)),
        child: Padding(
          padding: EdgeInsets.all(isWeb ? 14 : 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ FIX 7: Card header row overflow
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: isWeb ? 8 : 6,
                          vertical: isWeb ? 4 : 2),
                      decoration: BoxDecoration(
                        color: _getAccountTypeColor(account.accountType)
                            .withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(isWeb ? 6 : 4),
                      ),
                      child: Text(
                        account.accountCode,
                        style: TextStyle(
                          fontSize: isWeb ? 13 : 11,
                          color: _getAccountTypeColor(account.accountType),
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(balanceIcon,
                      size: isWeb ? 22 : 18, color: balanceColor),
                ],
              ),
              SizedBox(height: isWeb ? 8 : 6),
              Text(
                account.accountName,
                style: TextStyle(
                    fontSize: isWeb ? 13 : 11,
                    fontWeight: FontWeight.w600,
                    color: kText),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isWeb ? 8 : 6),
              Text(
                _formatAmountLocal(account.closingBalance),
                style: TextStyle(
                    fontSize: isWeb ? 20 : 16,
                    fontWeight: FontWeight.w800,
                    color: balanceColor),
              ),
              SizedBox(height: isWeb ? 6 : 4),
              Text('Dr: ${_formatAmountLocal(account.totalDebit)}',
                  style: TextStyle(
                      fontSize: isWeb ? 11 : 9,
                      color: kSuccess,
                      fontWeight: FontWeight.w500)),
              Text('Cr: ${_formatAmountLocal(account.totalCredit)}',
                  style: TextStyle(
                      fontSize: isWeb ? 11 : 9,
                      color: kDanger,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // LEDGER ENTRIES LIST
  // ─────────────────────────────────────────────────────────
  Widget _buildLedgerEntriesList(
      GeneralLedgerController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);

    return Obx(() {
      final entries = controller.filteredLedgerEntries;

      if (entries.isEmpty) {
        return Padding(
          padding: EdgeInsets.all(isWeb ? 40 : 20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_balance,
                    size: isWeb ? 80 : 64,
                    color: kSubText.withOpacity(0.5)),
                SizedBox(height: isWeb ? 20 : 16),
                Text('No ledger entries found',
                    style: TextStyle(
                        fontSize: isWeb ? 18 : 16,
                        color: kSubText,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isWeb ? 24 : 16,
                vertical: isWeb ? 12 : 8),
            child: Row(
              children: [
                Text(
                  'Ledger Entries',
                  style: TextStyle(
                      fontSize: isWeb ? 18 : 16,
                      fontWeight: FontWeight.w700,
                      color: kText),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${entries.length} entries',
                    style: TextStyle(
                        fontSize: isWeb ? 12 : 11,
                        color: kPrimary,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          if (isWeb)
            _buildWebLedgerTable(entries, context)
          else
            ...entries
                .map((entry) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: _buildLedgerEntryCard(entry, context),
                    ))
                .toList(),
        ],
      );
    });
  }

  // ─────────────────────────────────────────────────────────
  // WEB TABLE
  // ─────────────────────────────────────────────────────────
  Widget _buildWebLedgerTable(
      List<LedgerEntry> entries, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Container(
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2))
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 24,
                horizontalMargin: 20,
                headingRowColor: WidgetStateProperty.resolveWith(
                    (states) => kPrimary.withOpacity(0.06)),
                dataRowColor:
                    WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.hovered)) {
                    return kPrimary.withOpacity(0.03);
                  }
                  return null;
                }),
                columns: const [
                  DataColumn(
                      label: Text('Date',
                          style:
                              TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Journal ID',
                          style:
                              TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Account',
                          style:
                              TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Reference',
                          style:
                              TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Description',
                          style:
                              TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Debit',
                          style:
                              TextStyle(fontWeight: FontWeight.bold)),
                      numeric: true),
                  DataColumn(
                      label: Text('Credit',
                          style:
                              TextStyle(fontWeight: FontWeight.bold)),
                      numeric: true),
                  DataColumn(
                      label: Text('Running Balance',
                          style:
                              TextStyle(fontWeight: FontWeight.bold)),
                      numeric: true),
                ],
                rows: entries.map((entry) {
                  final isDebit = entry.debit > 0;
                  final balancePositive = entry.balance >= 0;
                  return DataRow(cells: [
                    DataCell(Text(
                        DateFormat('dd MMM yyyy').format(entry.date),
                        style: const TextStyle(fontSize: 13))),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: kPrimary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        'JE-${entry.id.substring(0, entry.id.length > 6 ? 6 : entry.id.length)}',
                        style: TextStyle(
                            fontSize: 12,
                            color: kPrimary,
                            fontWeight: FontWeight.w600),
                      ),
                    )),
                    DataCell(SizedBox(
                      width: 160,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: _getAccountTypeColor(
                                      _getAccountType(entry.accountName))
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              _getAccountIcon(
                                  _getAccountType(entry.accountName)),
                              size: 14,
                              color: _getAccountTypeColor(
                                  _getAccountType(entry.accountName)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(entry.accountName,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1),
                                Text(entry.accountCode,
                                    style: TextStyle(
                                        fontSize: 10, color: kSubText)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                    DataCell(Text(
                        entry.reference.isEmpty ? '-' : entry.reference,
                        style:
                            TextStyle(fontSize: 13, color: kSubText))),
                    DataCell(SizedBox(
                      width: 220,
                      child: Text(entry.description,
                          style: const TextStyle(fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    )),
                    DataCell(Text(
                      entry.debit > 0
                          ? _formatAmountLocal(entry.debit)
                          : '-',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: isDebit
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isDebit ? kSuccess : kSubText),
                    )),
                    DataCell(Text(
                      entry.credit > 0
                          ? _formatAmountLocal(entry.credit)
                          : '-',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: !isDebit
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: !isDebit ? kDanger : kSubText),
                    )),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: balancePositive
                            ? kSuccess.withOpacity(0.08)
                            : kDanger.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _formatAmountLocal(entry.balance),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: balancePositive ? kSuccess : kDanger),
                      ),
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // MOBILE CARD
  // ─────────────────────────────────────────────────────────
  Widget _buildLedgerEntryCard(LedgerEntry entry, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final isMobile = ResponsiveUtils.isMobile(context);

    return Card(
      color: kCardBg,
      elevation: 2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isWeb ? 14 : 12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(isWeb ? 14 : 12),
            decoration: BoxDecoration(
              color: kBg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: isWeb ? 44 : 36,
                  height: isWeb ? 44 : 36,
                  decoration: BoxDecoration(
                    color: _getAccountTypeColor(
                            _getAccountType(entry.accountName))
                        .withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(isWeb ? 10 : 8),
                  ),
                  child: Icon(
                    _getAccountIcon(_getAccountType(entry.accountName)),
                    size: isWeb ? 24 : 18,
                    color: _getAccountTypeColor(
                        _getAccountType(entry.accountName)),
                  ),
                ),
                SizedBox(width: isWeb ? 12 : 10),
                // ✅ FIX 8: Card header overflow — Expanded with ellipsis
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.accountName,
                        style: TextStyle(
                            fontSize: isWeb ? 15 : 13,
                            fontWeight: FontWeight.w700,
                            color: kText),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isWeb ? 4 : 2),
                      Text(
                        '${entry.accountCode} • ${entry.reference.isEmpty ? 'No Ref' : entry.reference}',
                        style: TextStyle(
                            fontSize: isWeb ? 12 : 10, color: kSubText),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Date + JE badge — fixed, no expansion
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('dd MMM yy').format(entry.date), // shorter on mobile
                      style: TextStyle(
                          fontSize: isWeb ? 12 : 10, color: kSubText),
                    ),
                    SizedBox(height: isWeb ? 6 : 4),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: isWeb ? 8 : 6,
                          vertical: isWeb ? 4 : 2),
                      decoration: BoxDecoration(
                        color: kPrimary.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(isWeb ? 6 : 4),
                      ),
                      child: Text(
                        'JE-${entry.id.substring(0, entry.id.length > 6 ? 6 : entry.id.length)}',
                        style: TextStyle(
                            fontSize: isWeb ? 11 : 9,
                            color: kPrimary,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: EdgeInsets.all(isWeb ? 14 : 12),
            child: Column(
              children: [
                Text(entry.description,
                    style:
                        TextStyle(fontSize: isWeb ? 14 : 12, color: kText)),
                SizedBox(height: isWeb ? 12 : 10),

                if (!isMobile)
                  // Tablet / Web non-table layout
                  Row(
                    children: [
                      Expanded(
                          child: _amountColumn('Debit',
                              entry.debit > 0
                                  ? _formatAmountLocal(entry.debit)
                                  : '-',
                              kSuccess, isWeb)),
                      Expanded(
                          child: _amountColumn('Credit',
                              entry.credit > 0
                                  ? _formatAmountLocal(entry.credit)
                                  : '-',
                              kDanger, isWeb)),
                      Expanded(
                          child: _amountColumnRight(
                              'Running Balance',
                              _formatAmountLocal(entry.balance),
                              entry.balance >= 0 ? kSuccess : kDanger,
                              isWeb)),
                    ],
                  ),

                if (isMobile)
                  // ✅ FIX 9: Mobile amounts — two cards + balance row, no overflow
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _mobileAmountCard(
                                'Debit',
                                entry.debit > 0
                                    ? _formatAmountLocal(entry.debit)
                                    : '-',
                                kSuccess),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _mobileAmountCard(
                                'Credit',
                                entry.credit > 0
                                    ? _formatAmountLocal(entry.credit)
                                    : '-',
                                kDanger),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: kPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Running Balance',
                                style: TextStyle(
                                    fontSize: 11, color: kSubText)),
                            Flexible(
                              child: Text(
                                _formatAmountLocal(entry.balance),
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: entry.balance >= 0
                                        ? kSuccess
                                        : kDanger),
                                overflow: TextOverflow.ellipsis,
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

  // Amount column helpers
  Widget _amountColumn(
      String label, String value, Color color, bool isWeb) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: isWeb ? 12 : 10,
                color: kSubText,
                fontWeight: FontWeight.w500)),
        SizedBox(height: isWeb ? 4 : 2),
        Text(value,
            style: TextStyle(
                fontSize: isWeb ? 18 : 14,
                fontWeight: FontWeight.w800,
                color: color),
            overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _amountColumnRight(
      String label, String value, Color color, bool isWeb) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: isWeb ? 12 : 10,
                color: kSubText,
                fontWeight: FontWeight.w500)),
        SizedBox(height: isWeb ? 4 : 2),
        Text(value,
            style: TextStyle(
                fontSize: isWeb ? 18 : 14,
                fontWeight: FontWeight.w800,
                color: color),
            overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _mobileAmountCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 10, color: kSubText)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: color),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // DIALOGS & PICKERS
  // ─────────────────────────────────────────────────────────
  void _selectDateRange(
      GeneralLedgerController controller, BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: controller.selectedDateRange.value,
    );
    if (picked != null) controller.setDateRange(picked);
  }

  void _showFilterDialog(
      GeneralLedgerController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isWeb ? 20 : 16)),
        child: Container(
          width: isWeb ? 400 : double.infinity,
          padding: EdgeInsets.all(isWeb ? 24 : 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Filter Ledger',
                  style: TextStyle(
                      fontSize: isWeb ? 20 : 18,
                      fontWeight: FontWeight.w800,
                      color: kText)),
              const SizedBox(height: 20),
              Obx(() => SwitchListTile(
                    secondary: Icon(Icons.trending_up, color: kSuccess),
                    title: Text('Show Debit Entries Only',
                        style: TextStyle(fontSize: isWeb ? 14 : 13)),
                    value: controller.showOnlyDebit.value,
                    onChanged: (val) {
                      controller.toggleDebitFilter();
                      Navigator.pop(context);
                    },
                    activeColor: kSuccess,
                  )),
              Obx(() => SwitchListTile(
                    secondary: Icon(Icons.trending_down, color: kDanger),
                    title: Text('Show Credit Entries Only',
                        style: TextStyle(fontSize: isWeb ? 14 : 13)),
                    value: controller.showOnlyCredit.value,
                    onChanged: (val) {
                      controller.toggleCreditFilter();
                      Navigator.pop(context);
                    },
                    activeColor: kDanger,
                  )),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.date_range),
                title: const Text('Date Range'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.pop(context);
                  _selectDateRange(controller, context);
                },
              ),
              if (controller.showOnlyDebit.value ||
                  controller.showOnlyCredit.value)
                ListTile(
                  leading: Icon(Icons.clear_all, color: kSubText),
                  title: Text('Clear Filters',
                      style: TextStyle(fontSize: isWeb ? 14 : 13)),
                  onTap: () {
                    controller.clearFilters();
                    Navigator.pop(context);
                  },
                ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                    child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'))),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────
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
    if (accountName.contains('Cash') ||
        accountName.contains('Bank') ||
        accountName.contains('Receivable')) return 'Assets';
    if (accountName.contains('Payable') ||
        accountName.contains('Loan')) return 'Liabilities';
    if (accountName.contains('Revenue') ||
        accountName.contains('Sales')) return 'Income';
    if (accountName.contains('Expense') ||
        accountName.contains('Rent') ||
        accountName.contains('Salary')) return 'Expenses';
    return 'Assets';
  }

  String _formatAmountLocal(double amount) =>
      '\$ ${amount.toStringAsFixed(2)}';
}