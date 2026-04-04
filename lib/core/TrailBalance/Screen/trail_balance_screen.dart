import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/core/TrailBalance/controller/trail_balance_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';

class TrialBalanceScreen extends StatelessWidget {
  const TrialBalanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TrialBalanceController());

    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(controller),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child:LoadingAnimationWidget.waveDots(
                    color: kPrimary,
                    size: 10.w,
                  )
          );
        }

        return Column(
          children: [
            _buildFilterBar(controller),
            _buildSummaryCards(controller),
            Expanded(
              child: _buildTrialBalanceTable(controller),
            ),
          ],
        );
      }),
      floatingActionButton: _buildFAB(controller),
    );
  }

  PreferredSizeWidget _buildAppBar(TrialBalanceController controller) {
    return AppBar(
      title: Text(
        'Trial Balance',
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
    icon: Icon(Icons.calendar_today_outlined, color: Colors.white, size: 5.w),
    onPressed: () => _selectDateRange(controller),
  ),
  IconButton(
    icon: Icon(Icons.download_outlined, color: Colors.white, size: 5.w),
    onPressed: () => controller.exportTrialBalance(), // This will show export options
  ),
  
],
    );
  }

  Widget _buildFilterBar(TrialBalanceController controller) {
    final List<String> filterOptions = [
      'All',
      'Assets',
      'Liabilities',
      'Equity',
      'Income',
      'Expenses'
    ];

    return Container(
      width: 100.w,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      color: kCardBg,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () => _selectDateRange(controller),
                  child: Obx(
                    () => Container(
                      height: 6.5.h,
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        color: kBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Row(
                              children: [
                                Icon(Icons.date_range, size: 5.w, color: kPrimary),
                                SizedBox(width: 2.w),
                                Flexible(
                                  child: Text(
                                    controller.selectedDateRange.value != null
                                        ? '${DateFormat('dd/MM/yy').format(controller.selectedDateRange.value!.start)} - ${DateFormat('dd/MM/yy').format(controller.selectedDateRange.value!.end)}'
                                        : 'Select Date Range',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: controller.selectedDateRange.value != null
                                          ? kPrimary
                                          : kSubText,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_drop_down, size: 5.w, color: kSubText),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                flex: 1,
                child: Container(
                  height: 6.5.h,
                  decoration: BoxDecoration(
                    color: kBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: Obx(
                      () => DropdownButton<String>(
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
                          if (value != null) controller.changeFilter(value);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          Obx(
            () => Container(
              height: 6.h,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                color: kBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.visibility_outlined, size: 5.w, color: kPrimary),
                      SizedBox(width: 2.w),
                      Text(
                        'Show Zero Balance Accounts',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: kText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: controller.showZeroBalance.value,
                    onChanged: (value) => controller.toggleZeroBalance(value),
                    activeColor: kPrimary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(TrialBalanceController controller) {
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Debit',
                _formatAmount(controller.totalDebit.value),
                kSuccess,
                Icons.trending_up,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildSummaryCard(
                'Total Credit',
                _formatAmount(controller.totalCredit.value),
                kDanger,
                Icons.trending_down,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildSummaryCard(
                'Difference',
                _formatAmount(controller.difference.value),
                controller.isBalanced.value ? kSuccess : kWarning,
                Icons.balance,
                subtitle: controller.isBalanced.value ? 'Balanced ✓' : 'Not Balanced',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String amount,
    Color color,
    IconData icon, {
    String? subtitle,
  }) {
    return Container(
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 5.w, color: color),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: kSubText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          if (subtitle != null)
            Padding(
              padding: EdgeInsets.only(top: 0.5.h),
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 9.sp,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTrialBalanceTable(TrialBalanceController controller) {
    return Obx(() {
      final data = controller.trialBalanceData;

      if (data.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance,
                size: 20.w,
                color: kSubText.withOpacity(0.5),
              ),
              SizedBox(height: 2.h),
              Text(
                'No accounts found',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: kSubText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(4.w),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final account = data[index];
          return _buildAccountRow(account, controller);
        },
      );
    });
  }

  Widget _buildAccountRow(
    TrialBalanceAccount account,
    TrialBalanceController controller,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showAccountDetails(account, controller),
        borderRadius: BorderRadius.circular(14),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              SizedBox(
                width: 11.w,
                height: 11.w,
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        _getAccountTypeColor(account.accountType).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getAccountIcon(account.accountType),
                    size: 5.5.w,
                    color: _getAccountTypeColor(account.accountType),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              // Main Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      account.accountName,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: kText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.6.h),
                    Wrap(
                      spacing: 1.5.w,
                      runSpacing: 0.5.h,
                      children: [
                        _badge(
                          text: account.accountCode,
                          color: _getAccountTypeColor(account.accountType),
                        ),
                        _badge(
                          text: account.accountType,
                          color: kSubText,
                          bg: kBg,
                        ),
                      ],
                    ),
                    SizedBox(height: 1.2.h),
                    Row(
                      children: [
                        Expanded(
                          child: _amountColumn(
                            title: "Debit",
                            value: account.debitBalance,
                            color: kSuccess,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: _amountColumn(
                            title: "Credit",
                            value: account.creditBalance,
                            color: kDanger,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge({
    required String text,
    required Color color,
    Color? bg,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.6.h),
      decoration: BoxDecoration(
        color: bg ?? color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.sp,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _amountColumn({
    required String title,
    required double value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            color: kSubText,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 0.4.h),
        Text(
          value > 0 ? _formatCompactAmount(value) : '-',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: value > 0 ? color : kSubText,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildFAB(TrialBalanceController controller) {
    return FloatingActionButton(
      onPressed: () => _showAdvancedOptions(controller),
      backgroundColor: kPrimary,
      child: Icon(Icons.more_horiz, color: Colors.white, size: 6.w),
      elevation: 2,
    );
  }

  void _selectDateRange(TrialBalanceController controller) async {
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

  void _showAccountDetails(
    TrialBalanceAccount account,
    TrialBalanceController controller,
  ) {
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(5.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 14.w,
                  height: 14.w,
                  decoration: BoxDecoration(
                    color: _getAccountTypeColor(account.accountType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getAccountIcon(account.accountType),
                    size: 7.w,
                    color: _getAccountTypeColor(account.accountType),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.accountName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: kText,
                        ),
                      ),
                      Text(
                        '${account.accountCode} • ${account.accountType}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: kSubText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: kBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    'Debit Balance',
                    _formatAmount(account.debitBalance),
                    kSuccess,
                  ),
                  SizedBox(height: 1.5.h),
                  _buildDetailRow(
                    'Credit Balance',
                    _formatAmount(account.creditBalance),
                    kDanger,
                  ),
                  SizedBox(height: 1.5.h),
                  _buildDetailRow(
                    'Net Balance',
                    _formatAmount(account.debitBalance - account.creditBalance),
                    (account.debitBalance - account.creditBalance) >= 0
                        ? kSuccess
                        : kDanger,
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            SizedBox(
              width: 100.w,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Get.toNamed('/general-ledger',
                      arguments: {'accountId': account.accountId});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'View Ledger Details',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: kSubText,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showAdvancedOptions(TrialBalanceController controller) {
    showModalBottomSheet(
      context: Get.context!,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(5.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.picture_as_pdf, size: 6.w, color: kDanger),
              title: Text('Export as PDF', style: TextStyle(fontSize: 14.sp)),
              onTap: () {
                Navigator.pop(context);
                controller.exportTrialBalance();
              },
            ),
            ListTile(
              leading: Icon(Icons.table_chart, size: 6.w, color: kSuccess),
              title: Text('Export as Excel', style: TextStyle(fontSize: 14.sp)),
              onTap: () {
                Navigator.pop(context);
                controller.exportTrialBalance();
              },
            ),
            ListTile(
              leading: Icon(Icons.print, size: 6.w, color: kPrimary),
              title: Text('Print', style: TextStyle(fontSize: 14.sp)),
              onTap: () {
                Navigator.pop(context);
                controller.printTrialBalance();
              },
            ),
            ListTile(
              leading: Icon(Icons.share, size: 6.w, color: kWarning),
              title: Text('Share', style: TextStyle(fontSize: 14.sp)),
              onTap: () {
                Navigator.pop(context);
                Get.snackbar('Share', 'Sharing trial balance...');
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getAccountTypeColor(String type) {
    switch (type) {
      case 'Assets':
        return kSuccess;
      case 'Liabilities':
        return kDanger;
      case 'Equity':
        return const Color(0xFF9B59B6);
      case 'Income':
        return kPrimary;
      case 'Expenses':
        return kWarning;
      default:
        return kSubText;
    }
  }

  IconData _getAccountIcon(String type) {
    switch (type) {
      case 'Assets':
        return Icons.account_balance;
      case 'Liabilities':
        return Icons.payment;
      case 'Equity':
        return Icons.account_balance_wallet;
      case 'Income':
        return Icons.trending_up;
      case 'Expenses':
        return Icons.trending_down;
      default:
        return Icons.account_balance;
    }
  }

  String _formatCompactAmount(double amount) {
    if (amount >= 1000000) {
      return '₨ ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '₨ ${(amount / 1000).toStringAsFixed(0)}K';
    }
    return '₨ ${amount.toStringAsFixed(0)}';
  }

  String _formatAmount(double amount) {
    return '₨ ${amount.toStringAsFixed(2)}';
  }
}