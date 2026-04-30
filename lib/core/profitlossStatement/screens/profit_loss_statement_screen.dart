import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/Utils/responsive_utils.dart';
import 'package:LedgerPro_app/core/profitlossStatement/controllers/profit_and_loss_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ProfitLossStatementScreen extends StatelessWidget {
  const ProfitLossStatementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PLController());

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
                  size: ResponsiveUtils.isWeb(context) ? 60 : 40,
                ),
                SizedBox(height: ResponsiveUtils.isWeb(context) ? 16 : 12),
                Text('Loading report...', style: TextStyle(fontSize: ResponsiveUtils.isWeb(context) ? 14 : 12, color: kSubText)),
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
              _buildReportHeader(controller, context),
              _buildRevenueSection(controller, context),
              SizedBox(height: ResponsiveUtils.isWeb(context) ? 16 : 12),
              if (controller.costOfGoodsSold.value > 0)
                _buildCostOfGoodsSoldSection(controller, context),
              SizedBox(height: ResponsiveUtils.isWeb(context) ? 16 : 12),
              _buildGrossProfitSection(controller, context),
              SizedBox(height: ResponsiveUtils.isWeb(context) ? 16 : 12),
              _buildOperatingExpensesSection(controller, context),
              SizedBox(height: ResponsiveUtils.isWeb(context) ? 16 : 12),
              if (controller.otherIncomeItems.isNotEmpty)
                _buildOtherIncomeSection(controller, context),
              if (controller.otherIncomeItems.isNotEmpty)
                SizedBox(height: ResponsiveUtils.isWeb(context) ? 16 : 12),
              if (controller.otherExpenseItems.isNotEmpty)
                _buildOtherExpensesSection(controller, context),
              if (controller.otherExpenseItems.isNotEmpty)
                SizedBox(height: ResponsiveUtils.isWeb(context) ? 16 : 12),
              _buildNetProfitSection(controller, context),
              SizedBox(height: ResponsiveUtils.isWeb(context) ? 20 : 16),
              _buildActionButtons(controller, context),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader(PLController controller, BuildContext context) {
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
                  'Profit & Loss Statement',
                  style: TextStyle(
                    fontSize: isWeb ? 20 : 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'View financial performance',
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
            icon: Icons.download,
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
  Widget _buildPeriodSelector(PLController controller, BuildContext context) {
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
                    icon: Icon(Icons.arrow_drop_down, size: isWeb ? 24 : 20),
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

  // ==================== REPORT HEADER ====================
  Widget _buildReportHeader(PLController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 16 : 12),
      padding: EdgeInsets.all(isWeb ? 16 : 12),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Text(
            'Profit & Loss Statement',
            style: TextStyle(fontSize: isWeb ? 18 : 16, fontWeight: FontWeight.w800, color: kText),
          ),
          SizedBox(height: isWeb ? 8 : 6),
          Obx(() => Text(
            controller.periodText.value,
            style: TextStyle(fontSize: isWeb ? 13 : 12, color: kSubText),
          )),
          SizedBox(height: isWeb ? 12 : 8),
          Divider(color: kBorder, height: 1),
        ],
      ),
    );
  }

  // ==================== REVENUE SECTION ====================
  Widget _buildRevenueSection(PLController controller, BuildContext context) {
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
          Text(
            'Revenue',
            style: TextStyle(fontSize: isWeb ? 16 : 14, fontWeight: FontWeight.w700, color: kSuccess),
          ),
          SizedBox(height: isWeb ? 12 : 8),
          ...controller.revenueItems.map((item) => _buildReportRow(item.name, item.amount, isWeb)),
          Divider(color: kBorder, height: isWeb ? 16 : 12),
          _buildReportRow('Total Revenue', controller.totalRevenue.value, isWeb, isBold: true),
        ],
      ),
    );
  }

  // ==================== COST OF GOODS SOLD SECTION ====================
  Widget _buildCostOfGoodsSoldSection(PLController controller, BuildContext context) {
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
          Text(
            'Cost of Goods Sold',
            style: TextStyle(fontSize: isWeb ? 16 : 14, fontWeight: FontWeight.w700, color: kDanger),
          ),
          SizedBox(height: isWeb ? 12 : 8),
          _buildReportRow('COGS', controller.costOfGoodsSold.value, isWeb),
          Divider(color: kBorder, height: isWeb ? 16 : 12),
          _buildReportRow('Total COGS', controller.costOfGoodsSold.value, isWeb, isBold: true),
        ],
      ),
    );
  }

  // ==================== GROSS PROFIT SECTION ====================
  Widget _buildGrossProfitSection(PLController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final Color profitColor = controller.grossProfit.value >= 0 ? kSuccess : kDanger;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16),
      padding: EdgeInsets.all(isWeb ? 16 : 12),
      decoration: BoxDecoration(
        color: profitColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
        border: Border.all(color: profitColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gross Profit',
            style: TextStyle(fontSize: isWeb ? 16 : 14, fontWeight: FontWeight.w700, color: kPrimary),
          ),
          SizedBox(height: isWeb ? 12 : 8),
          _buildReportRow('Revenue', controller.totalRevenue.value, isWeb),
          _buildReportRow('Less: COGS', controller.costOfGoodsSold.value, isWeb, isNegative: true),
          Divider(color: kBorder, height: isWeb ? 16 : 12),
          _buildReportRow('Gross Profit', controller.grossProfit.value, isWeb, isBold: true, color: profitColor),
        ],
      ),
    );
  }

  // ==================== OPERATING EXPENSES SECTION ====================
  Widget _buildOperatingExpensesSection(PLController controller, BuildContext context) {
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
          Text(
            'Operating Expenses',
            style: TextStyle(fontSize: isWeb ? 16 : 14, fontWeight: FontWeight.w700, color: kDanger),
          ),
          SizedBox(height: isWeb ? 12 : 8),
          ...controller.expenseItems.map((item) => _buildReportRow(item.name, item.amount, isWeb)),
          Divider(color: kBorder, height: isWeb ? 16 : 12),
          _buildReportRow('Total Operating Expenses', controller.operatingExpenses.value, isWeb, isBold: true),
        ],
      ),
    );
  }

  // ==================== OTHER INCOME SECTION ====================
  Widget _buildOtherIncomeSection(PLController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final double totalOtherIncome = controller.otherIncomeItems.fold(0.0, (sum, item) => sum + item.amount);
    
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
          Text(
            'Other Income',
            style: TextStyle(fontSize: isWeb ? 16 : 14, fontWeight: FontWeight.w700, color: kSuccess),
          ),
          SizedBox(height: isWeb ? 12 : 8),
          ...controller.otherIncomeItems.map((item) => _buildReportRow(item.name, item.amount, isWeb)),
          Divider(color: kBorder, height: isWeb ? 16 : 12),
          _buildReportRow('Total Other Income', totalOtherIncome, isWeb, isBold: true),
        ],
      ),
    );
  }

  // ==================== OTHER EXPENSES SECTION ====================
  Widget _buildOtherExpensesSection(PLController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final double totalOtherExpenses = controller.otherExpenseItems.fold(0.0, (sum, item) => sum + item.amount);
    
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
          Text(
            'Other Expenses',
            style: TextStyle(fontSize: isWeb ? 16 : 14, fontWeight: FontWeight.w700, color: kDanger),
          ),
          SizedBox(height: isWeb ? 12 : 8),
          ...controller.otherExpenseItems.map((item) => _buildReportRow(item.name, item.amount, isWeb)),
          Divider(color: kBorder, height: isWeb ? 16 : 12),
          _buildReportRow('Total Other Expenses', totalOtherExpenses, isWeb, isBold: true),
        ],
      ),
    );
  }

  // ==================== NET PROFIT SECTION ====================
  Widget _buildNetProfitSection(PLController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final Color profitColor = controller.netProfit.value >= 0 ? kSuccess : kDanger;
    final String profitText = controller.netProfit.value >= 0 ? 'Net Profit' : 'Net Loss';
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16),
      padding: EdgeInsets.all(isWeb ? 20 : 16),
      decoration: BoxDecoration(
        color: profitColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isWeb ? 20 : 16),
        border: Border.all(color: profitColor, width: isWeb ? 2 : 1),
      ),
      child: Column(
        children: [
          _buildReportRow(profitText, controller.netProfit.value, isWeb, isBold: true, color: profitColor, fontSize: isWeb ? 20 : 18),
          SizedBox(height: isWeb ? 12 : 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(controller.netProfit.value >= 0 ? Icons.trending_up : Icons.trending_down, size: isWeb ? 20 : 16, color: profitColor),
              SizedBox(width: isWeb ? 8 : 6),
              Text(
                'Profit Margin: ${controller.netProfitMargin.value.toStringAsFixed(2)}%',
                style: TextStyle(fontSize: isWeb ? 13 : 12, color: profitColor, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== REPORT ROW ====================
  Widget _buildReportRow(String label, double amount, bool isWeb, 
      {bool isBold = false, Color? color, bool isNegative = false, double? fontSize}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isWeb ? 8 : 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: fontSize ?? (isWeb ? (isBold ? 14 : 13) : (isBold ? 13 : 12)),
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                color: color ?? (isNegative ? kDanger : kText),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            child: Text(
              isNegative ? _formatAmount(-amount) : _formatAmount(amount),
              style: TextStyle(
                fontSize: fontSize ?? (isWeb ? (isBold ? 14 : 13) : (isBold ? 13 : 12)),
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                color: color ?? (isNegative ? kDanger : kText),
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ACTION BUTTONS ====================
  Widget _buildActionButtons(PLController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => controller.exportToExcel(),
              icon: Icon(Icons.table_chart, size: isWeb ? 20 : 16),
              label: Text('Export Excel', style: TextStyle(fontSize: isWeb ? 14 : 12)),
              style: _buttonStyle(kPrimary, isWeb),
            ),
          ),
          SizedBox(width: isWeb ? 16 : 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => controller.exportToPdf(),
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
  void _selectDateRange(PLController controller, BuildContext context) async {
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

  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '\$ ${formatter.format(amount)}';
  }
}