import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/core/cashflowstatement/controller/cashflow_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class CashFlowStatementScreen extends StatelessWidget {
  const CashFlowStatementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CashFlowController());

    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(controller),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: kPrimary, strokeWidth: 3.w),
                SizedBox(height: 2.h),
                Text('Loading cash flow statement...', style: TextStyle(fontSize: 13.sp, color: kSubText)),
              ],
            ),
          );
        }
        
        if (controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 12.w, color: kDanger),
                SizedBox(height: 2.h),
                Text(controller.errorMessage.value, style: TextStyle(fontSize: 13.sp, color: kDanger)),
                SizedBox(height: 2.h),
                ElevatedButton(
                  onPressed: () => controller.retryLoad(),
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                  child: Text('Retry', style: TextStyle(fontSize: 13.sp, color: Colors.white)),
                ),
              ],
            ),
          );
        }
        
        return Column(
          children: [
            _buildPeriodSelector(controller),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  children: [
                    _buildReportHeader(controller),
                    SizedBox(height: 2.h),
                    _buildCashBalanceSummary(controller),
                    SizedBox(height: 2.h),
                    _buildOperatingActivitiesSection(controller),
                    SizedBox(height: 2.h),
                    _buildInvestingActivitiesSection(controller),
                    SizedBox(height: 2.h),
                    _buildFinancingActivitiesSection(controller),
                    SizedBox(height: 2.h),
                    _buildNetCashFlowSection(controller),
                    SizedBox(height: 2.h),
                    _buildCashBalanceReconciliation(controller),
                    SizedBox(height: 2.h),
                    _buildActionButtons(controller),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar(CashFlowController controller) {
    return AppBar(
      title: Text(
        'Cash Flow Statement',
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      backgroundColor: kPrimary,
      elevation: 0,
      actions: [
       IconButton(
    icon: Icon(Icons.download_outlined, color: Colors.white),
    onPressed: () => controller.exportToExcel(),
  ),
 
      ],
    );
  }

  Widget _buildPeriodSelector(CashFlowController controller) {
    return Container(
      width: 100.w,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      color: kCardBg,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              height: 6.h,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                color: kBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kBorder),
              ),
              child: Obx(() => DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.selectedPeriod.value,
                  icon: Icon(Icons.arrow_drop_down, size: 5.w, color: kText),
                  isExpanded: true,
                  style: TextStyle(fontSize: 13.sp, color: kText),
                  dropdownColor: kCardBg,
                  items: controller.periodOptions.map((period) {
                    return DropdownMenuItem(
                      value: period,
                      child: Text(period, style: TextStyle(fontSize: 13.sp)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      if (value == 'Custom Range') {
                        _selectDateRange(controller);
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
              return Row(
                children: [
                  SizedBox(width: 3.w),
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: 6.h,
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        color: kPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${DateFormat('dd MMM yyyy').format(controller.selectedDateRange.value!.start)} - ${DateFormat('dd MMM yyyy').format(controller.selectedDateRange.value!.end)}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: kPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => controller.clearDateRange(),
                            child: Icon(Icons.close, size: 5.w, color: kPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildReportHeader(CashFlowController controller) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Cash Flow Statement',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: kText,
            ),
          ),
          SizedBox(height: 0.5.h),
          Obx(() => Text(
            controller.periodText.value,
            style: TextStyle(
              fontSize: 13.sp,
              color: kSubText,
            ),
          )),
          SizedBox(height: 1.h),
          Divider(color: kBorder, height: 1.h),
        ],
      ),
    );
  }

  Widget _buildCashBalanceSummary(CashFlowController controller) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => _buildBalanceCard(
              'Opening Balance',
              controller.formatAmount(controller.openingCashBalance.value),
              kPrimary,
              Icons.account_balance,
            )),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Obx(() => _buildBalanceCard(
              'Net Cash Flow',
              controller.formatAmount(controller.netCashFlow.value),
              controller.netCashFlow.value >= 0 ? kSuccess : kDanger,
              controller.netCashFlow.value >= 0 ? Icons.trending_up : Icons.trending_down,
            )),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Obx(() => _buildBalanceCard(
              'Closing Balance',
              controller.formatAmount(controller.closingCashBalance.value),
              kSuccess,
              Icons.account_balance_wallet,
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(String title, String amount, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(2.5.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 5.w, color: color),
          SizedBox(height: 1.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              color: kSubText,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            amount,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperatingActivitiesSection(CashFlowController controller) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.business_center, size: 5.w, color: kPrimary),
              SizedBox(width: 2.w),
              Text(
                'Cash Flow from Operating Activities',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: kPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          ...controller.operatingItems.map((item) => 
            _buildCashFlowRow(controller, item.name, item.amount)
          ).toList(),
          Divider(color: kBorder, height: 2.h),
          Obx(() => _buildCashFlowRow(
            controller, 
            'Net Cash from Operating Activities', 
            controller.cashFlowFromOperations.value, 
            isBold: true
          )),
        ],
      ),
    );
  }

  Widget _buildInvestingActivitiesSection(CashFlowController controller) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_down, size: 5.w, color: kWarning),
              SizedBox(width: 2.w),
              Text(
                'Cash Flow from Investing Activities',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: kWarning,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          ...controller.investingItems.map((item) => 
            _buildCashFlowRow(controller, item.name, item.amount)
          ).toList(),
          Divider(color: kBorder, height: 2.h),
          Obx(() => _buildCashFlowRow(
            controller, 
            'Net Cash from Investing Activities', 
            controller.cashFlowFromInvesting.value, 
            isBold: true
          )),
        ],
      ),
    );
  }

  Widget _buildFinancingActivitiesSection(CashFlowController controller) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance, size: 5.w, color: kSuccess),
              SizedBox(width: 2.w),
              Text(
                'Cash Flow from Financing Activities',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: kSuccess,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          ...controller.financingItems.map((item) => 
            _buildCashFlowRow(controller, item.name, item.amount)
          ).toList(),
          Divider(color: kBorder, height: 2.h),
          Obx(() => _buildCashFlowRow(
            controller, 
            'Net Cash from Financing Activities', 
            controller.cashFlowFromFinancing.value, 
            isBold: true
          )),
        ],
      ),
    );
  }

  Widget _buildNetCashFlowSection(CashFlowController controller) {
    return Obx(() => Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: controller.netCashFlow.value >= 0 ? kSuccess.withOpacity(0.05) : kDanger.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: controller.netCashFlow.value >= 0 ? kSuccess : kDanger, width: 1),
      ),
      child: Column(
        children: [
          _buildCashFlowRow(controller, 'Net Increase / Decrease in Cash', controller.netCashFlow.value, isBold: true, fontSize: 15.sp),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                controller.netCashFlow.value >= 0 ? Icons.trending_up : Icons.trending_down,
                size: 4.w,
                color: controller.netCashFlow.value >= 0 ? kSuccess : kDanger,
              ),
              SizedBox(width: 1.w),
              Text(
                controller.netCashFlow.value >= 0 ? 'Positive Cash Flow' : 'Negative Cash Flow',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: controller.netCashFlow.value >= 0 ? kSuccess : kDanger,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  Widget _buildCashBalanceReconciliation(CashFlowController controller) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cash Balance Reconciliation',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: kText,
            ),
          ),
          SizedBox(height: 1.5.h),
          Obx(() => _buildReconciliationRow('Opening Cash Balance', controller.formatAmount(controller.openingCashBalance.value))),
          Obx(() => _buildReconciliationRow('Add: Net Cash Flow', controller.formatAmount(controller.netCashFlow.value), isAdd: true)),
          Divider(color: kBorder, height: 2.h),
          Obx(() => _buildReconciliationRow('Closing Cash Balance', controller.formatAmount(controller.closingCashBalance.value), isBold: true)),
        ],
      ),
    );
  }

  Widget _buildCashFlowRow(CashFlowController controller, String label, double amount, {bool isBold = false, double? fontSize}) {
    Color amountColor = amount >= 0 ? kSuccess : kDanger;
    String prefix = amount >= 0 ? '' : '-';
    String displayAmount = prefix + controller.formatAmount(amount.abs());
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize ?? (isBold ? 13.sp : 13.sp),
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: kText,
            ),
          ),
          Text(
            displayAmount,
            style: TextStyle(
              fontSize: fontSize ?? (isBold ? 13.sp : 13.sp),
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReconciliationRow(String label, String amount, {bool isAdd = false, bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isAdd ? '   + $label' : label,
            style: TextStyle(
              fontSize: isBold ? 13.sp : 13.sp,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: kText,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isBold ? 13.sp : 13.sp,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: kText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(CashFlowController controller) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _generateAndPrintPDF(controller),
            icon: Icon(Icons.picture_as_pdf, size: 4.5.w),
            label: Text('Save as PDF', style: TextStyle(fontSize: 12.sp)),
            style: OutlinedButton.styleFrom(
              foregroundColor: kPrimary,
              side: BorderSide(color: kPrimary, width: 1),
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => controller.printReport(),
            icon: Icon(Icons.print, size: 4.5.w, color: Colors.white),
            label: Text('Print Report', style: TextStyle(fontSize: 12.sp)),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _selectDateRange(CashFlowController controller) async {
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

  Future<void> _generateAndPrintPDF(CashFlowController controller) async {
    try {
      Get.dialog(
        Center(
          child: Container(
            padding: EdgeInsets.all(5.w),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LoadingAnimationWidget.waveDots(
                    color: kPrimary,
                    size: 10.w,
                  ),  
                SizedBox(height: 2.h),
                Text('Generating PDF...', style: TextStyle(fontSize: 13.sp, color: kText)),
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
      
      Get.snackbar('Success', 'PDF generated successfully',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: kSuccess, colorText: Colors.white);
    } catch (e) {
      Get.back();
      Get.snackbar('Error', 'Failed to generate PDF: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: kDanger, colorText: Colors.white);
    }
  }

  pw.Widget _buildPdfHeader(CashFlowController controller) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text('Cash Flow Statement',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        pw.Text(controller.periodText.value,
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
        pw.SizedBox(height: 5),
        pw.Text('Generated on: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
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
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color, width: 1),
        borderRadius: pw.BorderRadius.circular(5),
      ),
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
        pw.Text('Cash Flow from Operating Activities',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue)),
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
        pw.Text('Cash Flow from Investing Activities',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.orange)),
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
        pw.Text('Cash Flow from Financing Activities',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.green)),
        pw.SizedBox(height: 10),
        ...controller.financingItems.map((item) => _buildPdfRow(item.name, item.amount)),
        pw.Divider(),
        _buildPdfRow('Net Cash from Financing Activities', controller.cashFlowFromFinancing.value, isBold: true),
      ],
    );
  }

  pw.Widget _buildPdfNetCashFlowSection(CashFlowController controller) {
    PdfColor color = controller.netCashFlow.value >= 0 ? PdfColors.green : PdfColors.red;
    return pw.Container(
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color, width: 1),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        children: [
          _buildPdfRow('Net Increase / Decrease in Cash', controller.netCashFlow.value, isBold: true, color: color),
          pw.SizedBox(height: 5),
          pw.Text(controller.netCashFlow.value >= 0 ? 'Positive Cash Flow' : 'Negative Cash Flow',
              style: pw.TextStyle(fontSize: 9, color: color)),
        ],
      ),
    );
  }

  pw.Widget _buildPdfCashBalanceReconciliation(CashFlowController controller) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Cash Balance Reconciliation',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
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
        pw.Text('This is a computer-generated document and does not require a signature.',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey), textAlign: pw.TextAlign.center),
      ],
    );
  }

  pw.Widget _buildPdfRow(String label, double amount, {bool isBold = false, PdfColor? color}) {
    PdfColor amountColor = amount >= 0 ? PdfColors.green : PdfColors.red;
    String prefix = amount >= 0 ? '' : '-';
    String displayAmount = prefix + _formatAmountForPdf(amount.abs());
    
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label,
            style: pw.TextStyle(fontSize: 10, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
                color: color ?? PdfColors.black)),
        pw.Text(displayAmount,
            style: pw.TextStyle(fontSize: 10, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
                color: color ?? amountColor)),
      ],
    );
  }

  pw.Widget _buildPdfReconciliationRow(String label, String amount, {bool isAdd = false, bool isBold = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(isAdd ? '   + $label' : label,
            style: pw.TextStyle(fontSize: 10, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        pw.Text(amount,
            style: pw.TextStyle(fontSize: 10, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
      ],
    );
  }

  String _formatAmountForPdf(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '₨ ${formatter.format(amount)}';
  }
}