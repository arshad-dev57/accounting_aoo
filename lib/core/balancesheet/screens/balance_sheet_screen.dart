import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/core/balancesheet/controller/balance_sheet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';

class BalanceSheetScreen extends StatelessWidget {
  const BalanceSheetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BalanceSheetController());


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
                Text('Loading balance sheet...',
                    style: TextStyle(fontSize: 13.sp, color: kSubText)),
              ],
            ),
          );
        }
        return _buildBody(controller);
      }),
    );
  }

  PreferredSizeWidget _buildAppBar(BalanceSheetController controller) {
    return AppBar(
      title: Text(
        'Balance Sheet',
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      backgroundColor: kPrimary,
      elevation: 0,
      actions: [
        // Period Dropdown
        Container(
          margin: EdgeInsets.only(right: 4.w),
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Obx(() => DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.selectedPeriod.value,
                  icon: Icon(Icons.arrow_drop_down,
                      color: Colors.white, size: 5.w),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  dropdownColor: kCardBg,
                  items: controller.periodOptions.map((period) {
                    return DropdownMenuItem(
                      value: period,
                      child: Text(
                        period,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: kText,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.changePeriod(value);
                    }
                  },
                ),
              )),
        ),
        // Print Icon
        IconButton(
    icon: Icon(Icons.download_outlined, color: Colors.white),
    onPressed: () => controller.exportToExcel(),
  ),
  IconButton(
    icon: Icon(Icons.print_outlined, color: Colors.white),
    onPressed: () => controller.printBalanceSheet(),
  ),
      ],
    );
  }

  Widget _buildBody(BalanceSheetController controller) {
    return Column(
      children: [
        // Date Header
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          alignment: Alignment.centerLeft,
          child: Obx(() => Text(
                'Balance Sheet as of ${DateFormat('dd MMM yyyy').format(controller.asOfDate.value)}',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: kSubText,
                  fontWeight: FontWeight.w500,
                ),
              )),
        ),
        // Main content - Scrollable sections
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column - Liabilities (Scrollable)
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: EdgeInsets.only(right: 2.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          'Liabilities',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: kText,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        // Scrollable content
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...controller.liabilitiesData.entries
                                    .map((entry) {
                                  return Column(
                                    children: [
                                      _buildSection(
                                        title: entry.key,
                                        items: entry.value,
                                      ),
                                      SizedBox(height: 2.h),
                                    ],
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Vertical Divider
                Container(
                  width: 1,
                  height: double.infinity,
                  color: kBorder,
                ),
                // Right Column - Assets (Scrollable)
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: EdgeInsets.only(left: 2.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          'Assets',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: kText,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        // Scrollable content
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...controller.assetsData.entries.map((entry) {
                                  return Column(
                                    children: [
                                      _buildSection(
                                        title: entry.key,
                                        items: entry.value,
                                      ),
                                      SizedBox(height: 2.h),
                                    ],
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Bottom Sheet - Totals (Fixed at bottom)
        Container(
          decoration: BoxDecoration(
            color: kCardBg,
            border: Border(
              top: BorderSide(color: kBorder, width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            child: Row(
              children: [
                // Left Total - Liabilities
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: EdgeInsets.only(right: 2.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Liabilities',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: kText,
                          ),
                        ),
                        Obx(() => Text(
                              controller.formatAmount(
                                  controller.totalLiabilities.value),
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w800,
                                color: kText,
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
                // Vertical Divider
                Container(
                  width: 1,
                  height: 4.h,
                  color: kBorder,
                ),
                // Right Total - Assets
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: EdgeInsets.only(left: 2.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Assets',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: kText,
                          ),
                        ),
                        Obx(() => Text(
                              controller
                                  .formatAmount(controller.totalAssets.value),
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w800,
                                color: kText,
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required Map<String, double> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: kSubText,
          ),
        ),
        SizedBox(height: 0.8.h),
        ...items.entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(left: 2.w, bottom: 0.8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: kText,
                  ),
                ),
                Text(
                  _formatAmount(entry.value),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: entry.value < 0 ? kDanger : kText,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '\$${formatter.format(amount)}';
  }
}