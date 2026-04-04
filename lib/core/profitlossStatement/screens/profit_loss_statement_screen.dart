import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/core/profitlossStatement/controllers/profit_and_loss_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';

class ProfitLossStatementScreen extends StatelessWidget {
  const ProfitLossStatementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PLController());

    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(controller),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LoadingAnimationWidget.waveDots(
                    color: kPrimary,
                    size: 10.w,
                  ),
                SizedBox(height: 2.h),
                Text('Loading report...', style: TextStyle(fontSize: 13.sp, color: kSubText)),
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
                    _buildRevenueSection(controller),
                    SizedBox(height: 2.h),
                    _buildCostOfGoodsSoldSection(controller),
                    SizedBox(height: 2.h),
                    _buildGrossProfitSection(controller),
                    SizedBox(height: 2.h),
                    _buildOperatingExpensesSection(controller),
                    if (controller.otherIncomeItems.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      _buildOtherIncomeSection(controller),
                    ],
                    if (controller.otherExpenseItems.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      _buildOtherExpensesSection(controller),
                    ],
                    SizedBox(height: 2.h),
                    _buildNetProfitSection(controller),
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

  PreferredSizeWidget _buildAppBar(PLController controller) {
    return AppBar(
      title: Text(
        'Profit & Loss Statement',
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
          icon: Icon(Icons.download, color: Colors.white, size: 5.w),
          onPressed: () => controller.exportToExcel(),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector(PLController controller) {
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
                  icon: Icon(Icons.arrow_drop_down, size: 5.w),
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
            return SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildReportHeader(PLController controller) {
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
            'Profit & Loss Statement',
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

  Widget _buildRevenueSection(PLController controller) {
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
            'Revenue',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: kSuccess,
            ),
          ),
          SizedBox(height: 1.5.h),
          ...controller.revenueItems.map((item) => _buildReportRow(item.name, item.amount)),
          Divider(color: kBorder, height: 2.h),
          _buildReportRow('Total Revenue', controller.totalRevenue.value, isBold: true),
        ],
      ),
    );
  }

  Widget _buildCostOfGoodsSoldSection(PLController controller) {
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
            'Cost of Goods Sold',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: kDanger,
            ),
          ),
          SizedBox(height: 1.5.h),
          _buildReportRow('COGS', controller.costOfGoodsSold.value),
          Divider(color: kBorder, height: 2.h),
          _buildReportRow('Total COGS', controller.costOfGoodsSold.value, isBold: true),
        ],
      ),
    );
  }

  Widget _buildGrossProfitSection(PLController controller) {
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
            'Gross Profit',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: kPrimary,
            ),
          ),
          SizedBox(height: 1.5.h),
          _buildReportRow('Revenue', controller.totalRevenue.value),
          _buildReportRow('Less: COGS', controller.costOfGoodsSold.value, isNegative: true),
          Divider(color: kBorder, height: 2.h),
          _buildReportRow('Gross Profit', controller.grossProfit.value, isBold: true, 
              color: controller.grossProfit.value >= 0 ? kSuccess : kDanger),
        ],
      ),
    );
  }

  Widget _buildOperatingExpensesSection(PLController controller) {
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
            'Operating Expenses',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: kDanger,
            ),
          ),
          SizedBox(height: 1.5.h),
          ...controller.expenseItems.map((item) => _buildReportRow(item.name, item.amount)),
          Divider(color: kBorder, height: 2.h),
          _buildReportRow('Total Operating Expenses', controller.operatingExpenses.value, isBold: true),
        ],
      ),
    );
  }

  Widget _buildOtherIncomeSection(PLController controller) {
    double totalOtherIncome = controller.otherIncomeItems.fold(0.0, (sum, item) => sum + item.amount);
    
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
            'Other Income',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: kSuccess,
            ),
          ),
          SizedBox(height: 1.5.h),
          ...controller.otherIncomeItems.map((item) => _buildReportRow(item.name, item.amount)),
          Divider(color: kBorder, height: 2.h),
          _buildReportRow('Total Other Income', totalOtherIncome, isBold: true),
        ],
      ),
    );
  }

  Widget _buildOtherExpensesSection(PLController controller) {
    double totalOtherExpenses = controller.otherExpenseItems.fold(0.0, (sum, item) => sum + item.amount);
    
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
            'Other Expenses',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: kDanger,
            ),
          ),
          SizedBox(height: 1.5.h),
          ...controller.otherExpenseItems.map((item) => _buildReportRow(item.name, item.amount)),
          Divider(color: kBorder, height: 2.h),
          _buildReportRow('Total Other Expenses', totalOtherExpenses, isBold: true),
        ],
      ),
    );
  }

  Widget _buildNetProfitSection(PLController controller) {
    Color profitColor = controller.netProfit.value >= 0 ? kSuccess : kDanger;
    String profitText = controller.netProfit.value >= 0 ? 'Net Profit' : 'Net Loss';
    
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: profitColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: profitColor, width: 1),
      ),
      child: Column(
        children: [
          _buildReportRow(profitText, controller.netProfit.value, isBold: true, 
              color: profitColor, fontSize: 16.sp),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                controller.netProfit.value >= 0 ? Icons.trending_up : Icons.trending_down,
                size: 4.w,
                color: profitColor,
              ),
              SizedBox(width: 1.w),
              Text(
                'Profit Margin: ${controller.netProfitMargin.value.toStringAsFixed(2)}%',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: profitColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportRow(String label, double amount, {bool isBold = false, Color? color, bool isNegative = false, double? fontSize}) {
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
              color: color ?? (isNegative ? kDanger : kText),
            ),
          ),
          Text(
            isNegative ? _formatAmount(-amount) : _formatAmount(amount),
            style: TextStyle(
              fontSize: fontSize ?? (isBold ? 13.sp : 13.sp),
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: color ?? (isNegative ? kDanger : kText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(PLController controller) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => controller.printReport(),
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

  void _selectDateRange(PLController controller) async {
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

  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '₨ ${formatter.format(amount)}';
  }
}