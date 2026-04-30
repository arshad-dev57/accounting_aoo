import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/Utils/responsive_utils.dart';
import 'package:LedgerPro_app/Utils/toast_utils.dart';
import 'package:LedgerPro_app/core/cashflowstatement/controller/cashflow_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class CashFlowStatementScreen extends StatelessWidget {
  const CashFlowStatementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CashFlowController());
    final isWeb = ResponsiveUtils.isWeb(context);

    // ✅ Scaffold for Material context
    return Scaffold(
      backgroundColor: kBg,
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LoadingAnimationWidget.waveDots(
                  color: kPrimary,
                  size: isWeb ? 60 : 40,
                ),
                SizedBox(height: isWeb ? 16 : 12),
                Text('Loading cash flow statement...', style: TextStyle(fontSize: isWeb ? 14 : 12, color: kSubText)),
              ],
            ),
          );
        }
        
        if (controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: isWeb ? 80 : 64, color: kDanger),
                SizedBox(height: isWeb ? 20 : 16),
                Text(controller.errorMessage.value, style: TextStyle(fontSize: isWeb ? 14 : 12, color: kDanger)),
                SizedBox(height: isWeb ? 20 : 16),
                ElevatedButton(
                  onPressed: () => controller.retryLoad(),
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                  child: Text('Retry', style: TextStyle(fontSize: isWeb ? 14 : 12, color: Colors.white)),
                ),
              ],
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
              _buildPeriodSelector(controller, context),
              _buildCashBalanceSummary(controller, context),
              _buildOperatingActivitiesSection(controller, context),
              _buildInvestingActivitiesSection(controller, context),
              _buildFinancingActivitiesSection(controller, context),
              _buildNetCashFlowSection(controller, context),
              _buildCashBalanceReconciliation(controller, context),
              _buildActionButtons(controller, context),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader(CashFlowController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final isMobile = ResponsiveUtils.isMobile(context);
    
    return Container(
      padding: EdgeInsets.fromLTRB(
        isWeb ? 24 : 16,
        isWeb ? 20 : 16,
        isWeb ? 24 : 16,
        isWeb ? 16 : 12,
      ),
      decoration: const BoxDecoration(
        color: kPrimary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cash Flow Statement',
                  style: TextStyle(
                    fontSize: isWeb ? 20 : 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Track cash inflows and outflows',
                  style: TextStyle(
                    fontSize: isWeb ? 13 : 11,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _headerIconBtn(
            icon: Icons.download_outlined,
            size: isWeb ? 22 : 20,
            onTap: () => controller.exportToExcel(),
          ),
        ],
      ),
    );
  }

  Widget _headerIconBtn({
    required IconData icon,
    required double size,
    required VoidCallback onTap,
    bool isWhiteBg = false,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isWhiteBg ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor ?? Colors.white, size: size),
      ),
    );
  }

  // ==================== PERIOD SELECTOR ====================
  Widget _buildPeriodSelector(CashFlowController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Material(
      color: kCardBg,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 12 : 10),
        child: Row(
          children: [
            SizedBox(
              width: isWeb ? 200 : 150,
              height: isWeb ? 45 : 40,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: isWeb ? 12 : 8),
                decoration: BoxDecoration(
                  color: kBg,
                  borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
                  border: Border.all(color: kBorder),
                ),
                child: Obx(() => DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.selectedPeriod.value,
                    icon: Icon(Icons.arrow_drop_down, size: isWeb ? 24 : 20, color: kText),
                    isExpanded: true,
                    style: TextStyle(fontSize: isWeb ? 13 : 12, color: kText),
                    dropdownColor: kCardBg,
                    items: controller.periodOptions.map((period) {
                      return DropdownMenuItem(
                        value: period,
                        child: Text(period, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        if (value == 'Custom Range') {
                          _selectDateRange(controller, context);
                        } else {
                          controller.changePeriod(value);
                        }
                      }
                    },
                  ),
                )),
              ),
            ),
            Obx(() {
              if (controller.selectedDateRange.value != null) {
                final range = controller.selectedDateRange.value!;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: isWeb ? 12 : 8),
                    child: Container(
                      height: isWeb ? 45 : 40,
                      padding: EdgeInsets.symmetric(horizontal: isWeb ? 12 : 8),
                      decoration: BoxDecoration(
                        color: kPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              '${DateFormat('dd MMM yyyy').format(range.start)} - ${DateFormat('dd MMM yyyy').format(range.end)}',
                              style: TextStyle(
                                fontSize: isWeb ? 12 : 11,
                                color: kPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => controller.clearDateRange(),
                            child: Icon(Icons.close, size: isWeb ? 20 : 16, color: kPrimary),
                          ),
                        ],
                      ),
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

  // ==================== CASH BALANCE SUMMARY ====================
  Widget _buildCashBalanceSummary(CashFlowController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 16 : 12),
      padding: EdgeInsets.all(isWeb ? 16 : 12),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => _buildBalanceCard(
              'Opening Balance',
              controller.formatAmount(controller.openingCashBalance.value),
              kPrimary,
              Icons.account_balance,
              isWeb,
            )),
          ),
          SizedBox(width: isWeb ? 16 : 12),
          Expanded(
            child: Obx(() => _buildBalanceCard(
              'Net Cash Flow',
              controller.formatAmount(controller.netCashFlow.value),
              controller.netCashFlow.value >= 0 ? kSuccess : kDanger,
              controller.netCashFlow.value >= 0 ? Icons.trending_up : Icons.trending_down,
              isWeb,
            )),
          ),
          SizedBox(width: isWeb ? 16 : 12),
          Expanded(
            child: Obx(() => _buildBalanceCard(
              'Closing Balance',
              controller.formatAmount(controller.closingCashBalance.value),
              kSuccess,
              Icons.account_balance_wallet,
              isWeb,
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(String title, String amount, Color color, IconData icon, bool isWeb) {
    return Container(
      padding: EdgeInsets.all(isWeb ? 16 : 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: isWeb ? 24 : 20, color: color),
          SizedBox(height: isWeb ? 8 : 6),
          Text(title, style: TextStyle(fontSize: isWeb ? 12 : 11, color: kSubText, fontWeight: FontWeight.w500)),
          SizedBox(height: isWeb ? 4 : 2),
          Text(amount, style: TextStyle(fontSize: isWeb ? 16 : 14, fontWeight: FontWeight.w800, color: color), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  // ==================== OPERATING ACTIVITIES SECTION ====================
  Widget _buildOperatingActivitiesSection(CashFlowController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16),
      padding: EdgeInsets.all(isWeb ? 16 : 12),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.business_center, size: isWeb ? 24 : 20, color: kPrimary),
              SizedBox(width: isWeb ? 12 : 8),
              Text(
                'Cash Flow from Operating Activities',
                style: TextStyle(fontSize: isWeb ? 16 : 14, fontWeight: FontWeight.w700, color: kPrimary),
              ),
            ],
          ),
          SizedBox(height: isWeb ? 12 : 8),
          ...controller.operatingItems.map((item) => _buildCashFlowRow(controller, item.name, item.amount, isWeb)),
          Divider(color: kBorder, height: isWeb ? 16 : 12),
          Obx(() => _buildCashFlowRow(controller, 'Net Cash from Operating Activities', controller.cashFlowFromOperations.value, isWeb, isBold: true)),
        ],
      ),
    );
  }

  // ==================== INVESTING ACTIVITIES SECTION ====================
  Widget _buildInvestingActivitiesSection(CashFlowController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16),
      padding: EdgeInsets.all(isWeb ? 16 : 12),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_down, size: isWeb ? 24 : 20, color: kWarning),
              SizedBox(width: isWeb ? 12 : 8),
              Text(
                'Cash Flow from Investing Activities',
                style: TextStyle(fontSize: isWeb ? 16 : 14, fontWeight: FontWeight.w700, color: kWarning),
              ),
            ],
          ),
          SizedBox(height: isWeb ? 12 : 8),
          ...controller.investingItems.map((item) => _buildCashFlowRow(controller, item.name, item.amount, isWeb)),
          Divider(color: kBorder, height: isWeb ? 16 : 12),
          Obx(() => _buildCashFlowRow(controller, 'Net Cash from Investing Activities', controller.cashFlowFromInvesting.value, isWeb, isBold: true)),
        ],
      ),
    );
  }

  // ==================== FINANCING ACTIVITIES SECTION ====================
  Widget _buildFinancingActivitiesSection(CashFlowController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16),
      padding: EdgeInsets.all(isWeb ? 16 : 12),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance, size: isWeb ? 24 : 20, color: kSuccess),
              SizedBox(width: isWeb ? 12 : 8),
              Text(
                'Cash Flow from Financing Activities',
                style: TextStyle(fontSize: isWeb ? 16 : 14, fontWeight: FontWeight.w700, color: kSuccess),
              ),
            ],
          ),
          SizedBox(height: isWeb ? 12 : 8),
          ...controller.financingItems.map((item) => _buildCashFlowRow(controller, item.name, item.amount, isWeb)),
          Divider(color: kBorder, height: isWeb ? 16 : 12),
          Obx(() => _buildCashFlowRow(controller, 'Net Cash from Financing Activities', controller.cashFlowFromFinancing.value, isWeb, isBold: true)),
        ],
      ),
    );
  }

  // ==================== NET CASH FLOW SECTION ====================
  Widget _buildNetCashFlowSection(CashFlowController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Obx(() => Container(
      margin: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16),
      padding: EdgeInsets.all(isWeb ? 16 : 12),
      decoration: BoxDecoration(
        color: controller.netCashFlow.value >= 0 ? kSuccess.withOpacity(0.05) : kDanger.withOpacity(0.05),
        borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
        border: Border.all(color: controller.netCashFlow.value >= 0 ? kSuccess : kDanger, width: 1),
      ),
      child: Column(
        children: [
          _buildCashFlowRow(controller, 'Net Increase / Decrease in Cash', controller.netCashFlow.value, isWeb, isBold: true, fontSize: isWeb ? 18 : 16),
          SizedBox(height: isWeb ? 12 : 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(controller.netCashFlow.value >= 0 ? Icons.trending_up : Icons.trending_down, size: isWeb ? 20 : 16, color: controller.netCashFlow.value >= 0 ? kSuccess : kDanger),
              SizedBox(width: isWeb ? 8 : 6),
              Text(
                controller.netCashFlow.value >= 0 ? 'Positive Cash Flow' : 'Negative Cash Flow',
                style: TextStyle(fontSize: isWeb ? 13 : 12, color: controller.netCashFlow.value >= 0 ? kSuccess : kDanger, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  // ==================== CASH BALANCE RECONCILIATION ====================
  Widget _buildCashBalanceReconciliation(CashFlowController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16),
      padding: EdgeInsets.all(isWeb ? 16 : 12),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cash Balance Reconciliation', style: TextStyle(fontSize: isWeb ? 16 : 14, fontWeight: FontWeight.w700, color: kText)),
          SizedBox(height: isWeb ? 12 : 8),
          Obx(() => _buildReconciliationRow('Opening Cash Balance', controller.formatAmount(controller.openingCashBalance.value), isWeb)),
          Obx(() => _buildReconciliationRow('Add: Net Cash Flow', controller.formatAmount(controller.netCashFlow.value), isWeb, isAdd: true)),
          Divider(color: kBorder, height: isWeb ? 16 : 12),
          Obx(() => _buildReconciliationRow('Closing Cash Balance', controller.formatAmount(controller.closingCashBalance.value), isWeb, isBold: true)),
        ],
      ),
    );
  }

  // ==================== CASH FLOW ROW ====================
  Widget _buildCashFlowRow(CashFlowController controller, String label, double amount, bool isWeb, {bool isBold = false, double? fontSize}) {
    final Color amountColor = amount >= 0 ? kSuccess : kDanger;
    final String prefix = amount >= 0 ? '' : '-';
    final String displayAmount = prefix + controller.formatAmount(amount.abs());
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isWeb ? 8 : 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                fontSize: fontSize ?? (isWeb ? (isBold ? 14 : 13) : (isBold ? 13 : 12)),
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                color: kText,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            flex: 1,
            child: Text(
              displayAmount,
              style: TextStyle(
                fontSize: fontSize ?? (isWeb ? (isBold ? 14 : 13) : (isBold ? 13 : 12)),
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                color: amountColor,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== RECONCILIATION ROW ====================
  Widget _buildReconciliationRow(String label, String amount, bool isWeb, {bool isAdd = false, bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isWeb ? 8 : 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 3,
            child: Text(
              isAdd ? '   + $label' : label,
              style: TextStyle(
                fontSize: isWeb ? (isBold ? 14 : 13) : (isBold ? 13 : 12),
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                color: kText,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            flex: 1,
            child: Text(
              amount,
              style: TextStyle(
                fontSize: isWeb ? (isBold ? 14 : 13) : (isBold ? 13 : 12),
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                color: kText,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ACTION BUTTONS ====================
  Widget _buildActionButtons(CashFlowController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _generateAndPrintPDF(controller, context),
              icon: Icon(Icons.picture_as_pdf, size: isWeb ? 20 : 16),
              label: Text('Save as PDF', style: TextStyle(fontSize: isWeb ? 14 : 12)),
              style: _buttonStyle(kPrimary, isWeb),
            ),
          ),
          SizedBox(width: isWeb ? 16 : 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => controller.printReport(),
              icon: Icon(Icons.print, size: isWeb ? 20 : 16, color: Colors.white),
              label: Text('Print Report', style: TextStyle(fontSize: isWeb ? 14 : 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                padding: EdgeInsets.symmetric(vertical: isWeb ? 12 : 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isWeb ? 12 : 10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ButtonStyle _buttonStyle(Color color, bool isWeb) {
    return OutlinedButton.styleFrom(
      foregroundColor: color,
      side: BorderSide(color: color, width: 1),
      padding: EdgeInsets.symmetric(vertical: isWeb ? 12 : 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isWeb ? 12 : 10)),
    );
  }

  // ==================== DATE RANGE PICKER ====================
  void _selectDateRange(CashFlowController controller, BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: controller.selectedDateRange.value,
    );
    if (picked != null) {
      controller.setDateRange(picked);
    }
  }

  // ==================== PDF GENERATION ====================
  Future<void> _generateAndPrintPDF(CashFlowController controller, BuildContext context) async {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    try {
      Get.dialog(
        Center(
          child: Container(
            padding: EdgeInsets.all(isWeb ? 24 : 20),
            decoration: BoxDecoration(color: kCardBg, borderRadius: BorderRadius.circular(isWeb ? 20 : 16)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LoadingAnimationWidget.waveDots(color: kPrimary, size: isWeb ? 50 : 40),
                SizedBox(height: isWeb ? 16 : 12),
                Text('Generating PDF...', style: TextStyle(fontSize: isWeb ? 14 : 12, color: kText)),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      final pdf = pw.Document();
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(20),
          build: (context) => [
            _buildPdfHeader(controller),
            pw.SizedBox(height: 20),
            _buildPdfCashBalanceSummary(controller),
            pw.SizedBox(height: 20),
            _buildPdfOperatingActivitiesSection(controller),
            pw.SizedBox(height: 15),
            _buildPdfInvestingActivitiesSection(controller),
            pw.SizedBox(height: 15),
            _buildPdfFinancingActivitiesSection(controller),
            pw.SizedBox(height: 20),
            _buildPdfNetCashFlowSection(controller),
            pw.SizedBox(height: 20),
            _buildPdfCashBalanceReconciliation(controller),
            pw.SizedBox(height: 30),
            _buildPdfFooter(),
          ],
        ),
      );

      Get.back();
      
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'Cash_Flow_Statement_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf',
      );
      
      AppSnackbar.success(Colors.green, 'Success', 'PDF generated successfully', duration: const Duration(seconds: 2));
    } catch (e) {
      Get.back();
      AppSnackbar.error(Colors.red, 'Error', 'Failed to generate PDF: $e', duration: const Duration(seconds: 2));
    }
  }

  pw.Widget _buildPdfHeader(CashFlowController controller) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text('Cash Flow Statement', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        pw.Text(controller.periodText.value, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
        pw.SizedBox(height: 5),
        pw.Text('Generated on: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
        pw.Divider(),
      ],
    );
  }

  pw.Widget _buildPdfCashBalanceSummary(CashFlowController controller) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _buildPdfBalanceCard('Opening Balance', controller.formatAmount(controller.openingCashBalance.value), PdfColors.blue),
        _buildPdfBalanceCard('Net Cash Flow', controller.formatAmount(controller.netCashFlow.value),
            controller.netCashFlow.value >= 0 ? PdfColors.green : PdfColors.red),
        _buildPdfBalanceCard('Closing Balance', controller.formatAmount(controller.closingCashBalance.value), PdfColors.green),
      ],
    );
  }

  pw.Widget _buildPdfBalanceCard(String title, String amount, PdfColor color) {
    return pw.Container(
      width: 150,
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: color, width: 1), borderRadius: pw.BorderRadius.circular(5)),
      child: pw.Column(
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
          pw.SizedBox(height: 5),
          pw.Text(amount, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  pw.Widget _buildPdfOperatingActivitiesSection(CashFlowController controller) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Cash Flow from Operating Activities', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue)),
        pw.SizedBox(height: 10),
        ...controller.operatingItems.map((item) => _buildPdfRow(item.name, item.amount)),
        pw.Divider(),
        _buildPdfRow('Net Cash from Operating Activities', controller.cashFlowFromOperations.value, isBold: true),
      ],
    );
  }

  pw.Widget _buildPdfInvestingActivitiesSection(CashFlowController controller) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Cash Flow from Investing Activities', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.orange)),
        pw.SizedBox(height: 10),
        ...controller.investingItems.map((item) => _buildPdfRow(item.name, item.amount)),
        pw.Divider(),
        _buildPdfRow('Net Cash from Investing Activities', controller.cashFlowFromInvesting.value, isBold: true),
      ],
    );
  }

  pw.Widget _buildPdfFinancingActivitiesSection(CashFlowController controller) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Cash Flow from Financing Activities', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.green)),
        pw.SizedBox(height: 10),
        ...controller.financingItems.map((item) => _buildPdfRow(item.name, item.amount)),
        pw.Divider(),
        _buildPdfRow('Net Cash from Financing Activities', controller.cashFlowFromFinancing.value, isBold: true),
      ],
    );
  }

  pw.Widget _buildPdfNetCashFlowSection(CashFlowController controller) {
    final PdfColor color = controller.netCashFlow.value >= 0 ? PdfColors.green : PdfColors.red;
    return pw.Container(
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: color, width: 1), borderRadius: pw.BorderRadius.circular(5)),
      child: pw.Column(
        children: [
          _buildPdfRow('Net Increase / Decrease in Cash', controller.netCashFlow.value, isBold: true, color: color),
          pw.SizedBox(height: 5),
          pw.Text(controller.netCashFlow.value >= 0 ? 'Positive Cash Flow' : 'Negative Cash Flow', style: pw.TextStyle(fontSize: 9, color: color)),
        ],
      ),
    );
  }

  pw.Widget _buildPdfCashBalanceReconciliation(CashFlowController controller) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Cash Balance Reconciliation', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        _buildPdfReconciliationRow('Opening Cash Balance', controller.formatAmount(controller.openingCashBalance.value)),
        _buildPdfReconciliationRow('Add: Net Cash Flow', controller.formatAmount(controller.netCashFlow.value), isAdd: true),
        pw.Divider(),
        _buildPdfReconciliationRow('Closing Cash Balance', controller.formatAmount(controller.closingCashBalance.value), isBold: true),
      ],
    );
  }

  pw.Widget _buildPdfFooter() {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.SizedBox(height: 10),
        pw.Text('This is a computer-generated document and does not require a signature.', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey), textAlign: pw.TextAlign.center),
      ],
    );
  }

  pw.Widget _buildPdfRow(String label, double amount, {bool isBold = false, PdfColor? color}) {
    final PdfColor amountColor = amount >= 0 ? PdfColors.green : PdfColors.red;
    final String prefix = amount >= 0 ? '' : '-';
    final String displayAmount = prefix + _formatAmountForPdf(amount.abs());
    
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 10, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal, color: color ?? PdfColors.black)),
        pw.Text(displayAmount, style: pw.TextStyle(fontSize: 10, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal, color: color ?? amountColor)),
      ],
    );
  }

  pw.Widget _buildPdfReconciliationRow(String label, String amount, {bool isAdd = false, bool isBold = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(isAdd ? '   + $label' : label, style: pw.TextStyle(fontSize: 10, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        pw.Text(amount, style: pw.TextStyle(fontSize: 10, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
      ],
    );
  }

  String _formatAmountForPdf(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '\$ ${formatter.format(amount)}';
  }
}