import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/Utils/responsive_utils.dart';
import 'package:LedgerPro_app/core/balancesheet/controller/balance_sheet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class BalanceSheetScreen extends StatelessWidget {
  const BalanceSheetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BalanceSheetController());
    final isWeb = ResponsiveUtils.isWeb(context);
    final isMobile = ResponsiveUtils.isMobile(context);

    // ✅ Scaffold for Material context - this fixes the Material error
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
                Text('Loading balance sheet...',
                    style: TextStyle(fontSize: isWeb ? 14 : 12, color: kSubText)),
              ],
            ),
          );
        }
        return isWeb 
            ? _buildWebLayout(controller, context)
            : _buildMobileLayout(controller, context);
      }),
    );
  }

  // Custom Header for all devices - ✅ Fixed IconButton to InkWell
  Widget _buildHeader(BalanceSheetController controller, BuildContext context) {
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Balance Sheet',
                  style: TextStyle(
                    fontSize: isWeb ? 20 : 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Financial position summary',
                  style: TextStyle(
                    fontSize: isWeb ? 13 : 11,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Period Dropdown - ✅ Wrapped in Material
          Material(
            color: Colors.transparent,
            child: Container(
              margin: EdgeInsets.only(right: isWeb ? 8 : 4),
              padding: EdgeInsets.symmetric(horizontal: isWeb ? 12 : 8, vertical: isWeb ? 6 : 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(isWeb ? 10 : 8),
              ),
              child: Obx(() => DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.selectedPeriod.value,
                  icon: Icon(Icons.arrow_drop_down,
                      color: Colors.white, size: isWeb ? 24 : 20),
                  style: TextStyle(
                    fontSize: isWeb ? 14 : 12,
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
                          fontSize: isWeb ? 14 : 12,
                          color: kText,
                        ),
                        overflow: TextOverflow.ellipsis,
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
          ),
          const SizedBox(width: 8),
          // Export Button - ✅ Using InkWell instead of IconButton
          _headerIconBtn(
            icon: Icons.download_outlined,
            size: isWeb ? 22 : 20,
            onTap: () => controller.exportToExcel(),
          ),
        ],
      ),
    );
  }

  // ✅ New helper method for header icons
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

  // WEB LAYOUT - Two columns side by side (Assets on right, Liabilities on left)
  Widget _buildWebLayout(BalanceSheetController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Column(
      children: [
        _buildHeader(controller, context),
        // Date Header
        Container(
          padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 12 : 8),
          alignment: Alignment.centerLeft,
          child: Obx(() => Text(
            'Balance Sheet as of ${DateFormat('dd MMM yyyy').format(controller.asOfDate.value)}',
            style: TextStyle(
              fontSize: isWeb ? 14 : 12,
              color: kSubText,
              fontWeight: FontWeight.w500,
            ),
          )),
        ),
        // Main content - Two column layout
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column - Liabilities
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: EdgeInsets.only(right: isWeb ? 16 : 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Liabilities',
                          style: TextStyle(
                            fontSize: isWeb ? 18 : 16,
                            fontWeight: FontWeight.w800,
                            color: kText,
                          ),
                        ),
                        SizedBox(height: isWeb ? 16 : 12),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...controller.liabilitiesData.entries.map((entry) {
                                  return Column(
                                    children: [
                                      _buildSection(
                                        title: entry.key,
                                        items: entry.value,
                                        isWeb: isWeb,
                                      ),
                                      SizedBox(height: isWeb ? 16 : 12),
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
                // Right Column - Assets
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: EdgeInsets.only(left: isWeb ? 16 : 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assets',
                          style: TextStyle(
                            fontSize: isWeb ? 18 : 16,
                            fontWeight: FontWeight.w800,
                            color: kText,
                          ),
                        ),
                        SizedBox(height: isWeb ? 16 : 12),
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
                                        isWeb: isWeb,
                                      ),
                                      SizedBox(height: isWeb ? 16 : 12),
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
        _buildTotalsBar(controller, context, isWeb),
      ],
    );
  }

  // MOBILE/TABLET LAYOUT - Single column with vertical scrolling
  Widget _buildMobileLayout(BalanceSheetController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Column(
      children: [
        _buildHeader(controller, context),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isWeb ? 20 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Header
                Container(
                  padding: EdgeInsets.symmetric(vertical: isWeb ? 8 : 6),
                  child: Obx(() => Text(
                    'Balance Sheet as of ${DateFormat('dd MMM yyyy').format(controller.asOfDate.value)}',
                    style: TextStyle(
                      fontSize: isWeb ? 14 : 12,
                      color: kSubText,
                      fontWeight: FontWeight.w500,
                    ),
                  )),
                ),
                SizedBox(height: isWeb ? 16 : 12),
                
                // Assets Section
                Container(
                  decoration: BoxDecoration(
                    color: kCardBg,
                    borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(isWeb ? 16 : 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assets',
                        style: TextStyle(
                          fontSize: isWeb ? 18 : 16,
                          fontWeight: FontWeight.w800,
                          color: kText,
                        ),
                      ),
                      SizedBox(height: isWeb ? 12 : 8),
                      ...controller.assetsData.entries.map((entry) {
                        return Column(
                          children: [
                            _buildSection(
                              title: entry.key,
                              items: entry.value,
                              isWeb: isWeb,
                            ),
                            SizedBox(height: isWeb ? 12 : 8),
                          ],
                        );
                      }).toList(),
                      Divider(color: kBorder, height: isWeb ? 24 : 16),
                      _buildTotalRow('Total Assets', controller.totalAssets.value, isWeb, isBold: true),
                    ],
                  ),
                ),
                
                SizedBox(height: isWeb ? 20 : 16),
                
                // Liabilities Section
                Container(
                  decoration: BoxDecoration(
                    color: kCardBg,
                    borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(isWeb ? 16 : 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Liabilities',
                        style: TextStyle(
                          fontSize: isWeb ? 18 : 16,
                          fontWeight: FontWeight.w800,
                          color: kText,
                        ),
                      ),
                      SizedBox(height: isWeb ? 12 : 8),
                      ...controller.liabilitiesData.entries.map((entry) {
                        return Column(
                          children: [
                            _buildSection(
                              title: entry.key,
                              items: entry.value,
                              isWeb: isWeb,
                            ),
                            SizedBox(height: isWeb ? 12 : 8),
                          ],
                        );
                      }).toList(),
                      Divider(color: kBorder, height: isWeb ? 24 : 16),
                      _buildTotalRow('Total Liabilities', controller.totalLiabilities.value, isWeb, isBold: true),
                    ],
                  ),
                ),
                
                SizedBox(height: isWeb ? 20 : 16),
                
                // Equity Section (if available)
                if (controller.equity.value > 0)
                  Container(
                    decoration: BoxDecoration(
                      color: kCardBg,
                      borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(isWeb ? 16 : 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Equity',
                          style: TextStyle(
                            fontSize: isWeb ? 18 : 16,
                            fontWeight: FontWeight.w800,
                            color: kText,
                          ),
                        ),
                        SizedBox(height: isWeb ? 12 : 8),
                        ...controller.equityData.entries.map((entry) {
                          return Column(
                            children: [
                              _buildSection(
                                title: entry.key,
                                items: entry.value,
                                isWeb: isWeb,
                              ),
                              SizedBox(height: isWeb ? 12 : 8),
                            ],
                          );
                        }).toList(),
                        Divider(color: kBorder, height: isWeb ? 24 : 16),
                        _buildTotalRow('Total Equity', controller.equity.value, isWeb, isBold: true),
                      ],
                    ),
                  ),
                
                SizedBox(height: isWeb ? 20 : 16),
                
                // Grand Total Check
                _buildGrandTotalCard(controller, isWeb),
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
    required bool isWeb,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isWeb ? 14 : 13,
            fontWeight: FontWeight.w600,
            color: kSubText,
          ),
        ),
        SizedBox(height: isWeb ? 8 : 6),
        ...items.entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(left: isWeb ? 16 : 12, bottom: isWeb ? 8 : 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: isWeb ? 13 : 12,
                      color: kText,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    _formatAmount(entry.value),
                    style: TextStyle(
                      fontSize: isWeb ? 13 : 12,
                      fontWeight: FontWeight.w500,
                      color: entry.value < 0 ? kDanger : kText,
                    ),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTotalRow(String title, double amount, bool isWeb, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isWeb ? 8 : 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isWeb ? (isBold ? 15 : 14) : (isBold ? 14 : 13),
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: kText,
            ),
          ),
          Flexible(
            child: Text(
              _formatAmount(amount),
              style: TextStyle(
                fontSize: isWeb ? (isBold ? 15 : 14) : (isBold ? 14 : 13),
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

  Widget _buildTotalsBar(BalanceSheetController controller, BuildContext context, bool isWeb) {
    return Container(
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
        padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 16 : 12),
        child: Row(
          children: [
            // Left Total - Liabilities
            Expanded(
              flex: 5,
              child: Padding(
                padding: EdgeInsets.only(right: isWeb ? 16 : 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Liabilities',
                      style: TextStyle(
                        fontSize: isWeb ? 14 : 13,
                        fontWeight: FontWeight.w700,
                        color: kText,
                      ),
                    ),
                    Obx(() => Flexible(
                      child: Text(
                        controller.formatAmount(controller.totalLiabilities.value),
                        style: TextStyle(
                          fontSize: isWeb ? 14 : 13,
                          fontWeight: FontWeight.w800,
                          color: kText,
                        ),
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )),
                  ],
                ),
              ),
            ),
            // Vertical Divider
            Container(
              width: 1,
              height: isWeb ? 40 : 32,
              color: kBorder,
            ),
            // Right Total - Assets
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.only(left: isWeb ? 16 : 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Assets',
                      style: TextStyle(
                        fontSize: isWeb ? 14 : 13,
                        fontWeight: FontWeight.w700,
                        color: kText,
                      ),
                    ),
                    Obx(() => Flexible(
                      child: Text(
                        controller.formatAmount(controller.totalAssets.value),
                        style: TextStyle(
                          fontSize: isWeb ? 14 : 13,
                          fontWeight: FontWeight.w800,
                          color: kText,
                        ),
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrandTotalCard(BalanceSheetController controller, bool isWeb) {
    Color balanceColor = (controller.totalAssets.value - controller.totalLiabilities.value).abs() < 1
        ? kSuccess
        : kDanger;
    
    return Container(
      decoration: BoxDecoration(
        color: balanceColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
        border: Border.all(color: balanceColor, width: 1),
      ),
      padding: EdgeInsets.all(isWeb ? 20 : 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Assets',
                style: TextStyle(
                  fontSize: isWeb ? 15 : 14,
                  fontWeight: FontWeight.w600,
                  color: kText,
                ),
              ),
              Flexible(
                child: Text(
                  _formatAmount(controller.totalAssets.value),
                  style: TextStyle(
                    fontSize: isWeb ? 15 : 14,
                    fontWeight: FontWeight.w700,
                    color: kText,
                  ),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: isWeb ? 12 : 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Liabilities',
                style: TextStyle(
                  fontSize: isWeb ? 15 : 14,
                  fontWeight: FontWeight.w600,
                  color: kText,
                ),
              ),
              Flexible(
                child: Text(
                  _formatAmount(controller.totalLiabilities.value),
                  style: TextStyle(
                    fontSize: isWeb ? 15 : 14,
                    fontWeight: FontWeight.w700,
                    color: kText,
                  ),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Divider(color: kBorder, height: isWeb ? 20 : 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                (controller.totalAssets.value - controller.totalLiabilities.value).abs() < 1
                    ? '✓ Balanced'
                    : '✗ Not Balanced',
                style: TextStyle(
                  fontSize: isWeb ? 14 : 13,
                  fontWeight: FontWeight.w700,
                  color: balanceColor,
                ),
              ),
              Flexible(
                child: Text(
                  'Difference: ${_formatAmount((controller.totalAssets.value - controller.totalLiabilities.value).abs())}',
                  style: TextStyle(
                    fontSize: isWeb ? 13 : 12,
                    color: balanceColor,
                  ),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '\$ ${formatter.format(amount)}';
  }
}