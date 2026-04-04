import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/core/balancesheet/screens/balance_sheet_screen.dart';
import 'package:LedgerPro_app/core/cashflowstatement/screen/cash_flow_statement_screen.dart';
import 'package:LedgerPro_app/core/dashboard/controllers/reports_controller.dart';
import 'package:LedgerPro_app/core/journalEntries/Screens/journal_entries_screen.dart';
import 'package:LedgerPro_app/core/profitlossStatement/screens/profit_loss_statement_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Get.put if controller doesn't exist, otherwise Get.find
    final controller = Get.isRegistered<ReportsController>() 
        ? Get.find<ReportsController>() 
        : Get.put(ReportsController());

    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(controller),
      body: _buildBody(controller),
    );
  }

  PreferredSizeWidget _buildAppBar(ReportsController controller) {
    return AppBar(
      title: Text(
        'Reports',
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
          icon: Icon(Icons.calendar_today_outlined, color: Colors.white, size: 5.w),
          onPressed: () => _showDateRangePicker(controller),
        ),
        IconButton(
          icon: Icon(Icons.download_outlined, color: Colors.white, size: 5.w),
          onPressed: () => controller.exportReport(),
        ),
        IconButton(
          icon: Icon(Icons.print_outlined, color: Colors.white, size: 5.w),
          onPressed: () => controller.printReport(),
        ),
      ],
    );
  }

  Widget _buildBody(ReportsController controller) {
    return Obx(() {
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
              Text('Loading reports...', style: TextStyle(fontSize: 13.sp, color: kSubText)),
            ],
          ),
        );
      }
      
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodSelector(controller),
            _buildDateRangeDisplay(controller),
            SizedBox(height: 2.h),
            _buildReportsGrid(controller),
            SizedBox(height: 2.h),
            _buildRecentReports(controller),
            SizedBox(height: 4.h),
          ],
        ),
      );
    });
  }

  Widget _buildPeriodSelector(ReportsController controller) {
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
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.selectedPeriod.value,
                  icon: Icon(Icons.arrow_drop_down, size: 5.w),
                  isExpanded: true,
                  style: TextStyle(fontSize: 13.sp, color: kText),
                  items: controller.periodOptions.map((period) {
                    return DropdownMenuItem(
                      value: period,
                      child: Text(period, style: TextStyle(fontSize: 13.sp)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      if (value == 'Custom Range') {
                        _showDateRangePicker(controller);
                      } else {
                        controller.changePeriod(value);
                      }
                    }
                  },
                ),
              ),
            ),
          ),
          Obx(() {
            if (controller.selectedDateRange.value != null) {
              return Row(
                children: [
                  SizedBox(width: 2.w),
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: 6.h,
                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                      decoration: BoxDecoration(
                        color: kPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              '${DateFormat('dd MMM yyyy').format(controller.selectedDateRange.value!.start)} - ${DateFormat('dd MMM yyyy').format(controller.selectedDateRange.value!.end)}',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: kPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => controller.clearDateRange(),
                            child: Icon(Icons.close, size: 4.w, color: kPrimary),
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

  Widget _buildDateRangeDisplay(ReportsController controller) {
    return Obx(() {
      if (controller.selectedDateRange.value == null) return const SizedBox.shrink();
      
      final start = controller.selectedDateRange.value!.start;
      final end = controller.selectedDateRange.value!.end;
      final days = end.difference(start).inDays + 1;
      
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kBorder),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 4.w, color: kPrimary),
            SizedBox(width: 2.w),
            Text(
              'Showing data for $days days period',
              style: TextStyle(fontSize: 12.sp, color: kSubText),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildReportsGrid(ReportsController controller) {
    final reports = [
      {
        'name': 'Profit & Loss Statement',
        'icon': Icons.show_chart,
        'description': 'Income and expenses summary',
        'color': kSuccess,
        'route': '/profit-loss-statement', // Use route names instead of direct widget
      },
      {
        'name': 'Balance Sheet',
        'icon': Icons.account_balance,
        'description': 'Assets, liabilities & equity',
        'color': kPrimary,
        'route': '/balance-sheet',
      },
      {
        'name': 'Cash Flow Statement',
        'icon': Icons.attach_money,
        'description': 'Cash inflows and outflows',
        'color': kWarning,
        'route': '/cash-flow-statement',
      },
      {
        'name': 'Journal Entries',
        'icon': Icons.book,
        'description': 'All journal entries',
        'color': kPrimaryDark,
        'route': '/journal-entries',
      },
    ];
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 1.w, bottom: 1.5.h),
            child: Row(
              children: [
                Icon(Icons.description, size: 4.5.w, color: kPrimary),
                SizedBox(width: 2.w),
                Text(
                  'Financial Reports',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: kText,
                  ),
                ),
                const Spacer(),
                Obx(() => Text(
                  controller.periodText.value,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: kSubText,
                  ),
                )),
              ],
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.4,
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 2.h,
            ),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return _buildReportCard(report);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    return InkWell(
      onTap: () => _navigateToScreen(report['route'] as String),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(2.5.w),
              decoration: BoxDecoration(
                color: (report['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(report['icon'] as IconData, size: 6.w, color: report['color']),
            ),
            SizedBox(height: 1.5.h),
            Text(
              report['name'] as String,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: kText,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 0.5.h),
            Text(
              report['description'] as String,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.sp,
                color: kSubText,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentReports(ReportsController controller) {
    final recentReports = [
      {'name': 'Profit & Loss Statement', 'route': '/profit-loss-statement', 'date': DateTime.now().subtract(const Duration(days: 1))},
      {'name': 'Balance Sheet', 'route': '/balance-sheet', 'date': DateTime.now().subtract(const Duration(days: 2))},
      {'name': 'Cash Flow Statement', 'route': '/cash-flow-statement', 'date': DateTime.now().subtract(const Duration(days: 3))},
      {'name': 'Journal Entries', 'route': '/journal-entries', 'date': DateTime.now().subtract(const Duration(days: 5))},
    ];
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 1.w, bottom: 1.5.h),
            child: Row(
              children: [
                Icon(Icons.history, size: 4.5.w, color: kPrimary),
                SizedBox(width: 2.w),
                Text(
                  'Recently Viewed',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: kText,
                  ),
                ),
              ],
            ),
          ),
          ...recentReports.map((report) => _buildRecentReportCard(report)),
        ],
      ),
    );
  }

  Widget _buildRecentReportCard(Map<String, dynamic> report) {
    // Find icon and color for the report
    IconData icon = Icons.description;
    Color color = kPrimary;
    
    switch (report['name'] as String) {
      case 'Profit & Loss Statement':
        icon = Icons.show_chart;
        color = kSuccess;
        break;
      case 'Balance Sheet':
        icon = Icons.account_balance;
        color = kPrimary;
        break;
      case 'Cash Flow Statement':
        icon = Icons.attach_money;
        color = kWarning;
        break;
      case 'Journal Entries':
        icon = Icons.book;
        color = kPrimaryDark;
        break;
    }
    
    return InkWell(
      onTap: () => _navigateToScreen(report['route'] as String),
      child: Container(
        margin: EdgeInsets.only(bottom: 1.5.h),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 5.w, color: color),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report['name'] as String,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: kText,
                    ),
                  ),
                  SizedBox(height: 0.3.h),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 3.w, color: kSubText),
                      SizedBox(width: 1.w),
                      Text(
                        DateFormat('dd MMM yyyy').format(report['date'] as DateTime),
                        style: TextStyle(fontSize: 10.sp, color: kSubText),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _navigateToScreen(report['route'] as String),
              icon: Icon(Icons.open_in_new, size: 4.5.w, color: kSubText),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToScreen(String routeName) {
    try {
      // Use route names for navigation
      Get.toNamed(routeName);
    } catch (e) {
      // If route is not registered, fallback to direct navigation
      print('Route not found: $routeName, error: $e');
      
      // Fallback navigation based on route name
      switch (routeName) {
        case '/profit-loss-statement':
          Get.to(() => const ProfitLossStatementScreen());
          break;
        case '/balance-sheet':
          Get.to(() => const BalanceSheetScreen());
          break;
        case '/cash-flow-statement':
          Get.to(() => const CashFlowStatementScreen());
          break;
        case '/journal-entries':
          Get.to(() => const JournalEntriesScreen());
          break;
        default:
          // Show error snackbar
          Get.snackbar(
            'Navigation Error',
            'Unable to navigate to the selected report',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
      }
    }
  }

  void _showDateRangePicker(ReportsController controller) async {
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
}