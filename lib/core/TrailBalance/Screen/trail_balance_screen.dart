import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/Utils/responsive_utils.dart';
import 'package:LedgerPro_app/core/TrailBalance/controller/trail_balance_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class TrialBalanceScreen extends StatelessWidget {
  const TrialBalanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TrialBalanceController());

    return Container(
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

        // Single ScrollView that scrolls everything together
        return SingleChildScrollView(
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(controller, context),
              _buildFilterBar(controller, context),
              _buildSummaryCards(controller, context),
              _buildTrialBalanceTable(controller, context),
              const SizedBox(height: 20), // Add bottom padding
            ],
          ),
        );
      }),
    );
  }

  // Custom Header without AppBar
  Widget _buildHeader(TrialBalanceController controller, BuildContext context) {
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
                  'Trial Balance',
                  style: TextStyle(
                    fontSize: isWeb ? 20 : 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Verify the equality of debits and credits',
                  style: TextStyle(
                    fontSize: isWeb ? 13 : 11,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          // Calendar Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.calendar_today_outlined, color: Colors.white, size: isWeb ? 22 : 20),
              onPressed: () => _selectDateRange(controller, context),
            ),
          ),
          const SizedBox(width: 8),
          // Export Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.download_outlined, color: Colors.white, size: isWeb ? 22 : 20),
              onPressed: () => _showExportOptions(controller, context),
            ),
          ),
          if (!isMobile) const SizedBox(width: 8),
          if (!isMobile)
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(Icons.more_horiz, color: Colors.white, size: isWeb ? 22 : 20),
                onPressed: () => _showAdvancedOptions(controller, context),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(TrialBalanceController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    final List<String> filterOptions = [
      'All', 'Assets', 'Liabilities', 'Equity', 'Income', 'Expenses'
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 16 : 12),
      color: kCardBg,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: isWeb ? 2 : 2,
                child: GestureDetector(
                  onTap: () => _selectDateRange(controller, context),
                  child: Obx(
                    () => Container(
                      height: isWeb ? 50 : 45,
                      padding: EdgeInsets.symmetric(horizontal: isWeb ? 16 : 12),
                      decoration: BoxDecoration(
                        color: kBg,
                        borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
                        border: Border.all(color: kBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Row(
                              children: [
                                Icon(Icons.date_range, size: isWeb ? 20 : 18, color: kPrimary),
                                SizedBox(width: isWeb ? 10 : 8),
                                Flexible(
                                  child: Text(
                                    controller.selectedDateRange.value != null
                                        ? '${DateFormat('dd/MM/yy').format(controller.selectedDateRange.value!.start)} - ${DateFormat('dd/MM/yy').format(controller.selectedDateRange.value!.end)}'
                                        : 'Select Date Range',
                                    style: TextStyle(
                                      fontSize: isWeb ? 13 : 11,
                                      color: controller.selectedDateRange.value != null ? kPrimary : kSubText,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_drop_down, size: isWeb ? 24 : 20, color: kSubText),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: isWeb ? 16 : 12),
              Expanded(
                flex: isWeb ? 1 : 1,
                child: Container(
                  height: isWeb ? 50 : 45,
                  decoration: BoxDecoration(
                    color: kBg,
                    borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
                    border: Border.all(color: kBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: Obx(
                      () => DropdownButton<String>(
                        value: controller.selectedFilter.value,
                        icon: Icon(Icons.arrow_drop_down, size: isWeb ? 24 : 20),
                        padding: EdgeInsets.symmetric(horizontal: isWeb ? 16 : 12),
                        isExpanded: true,
                        style: TextStyle(fontSize: isWeb ? 13 : 12, color: kText),
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
          SizedBox(height: isWeb ? 16 : 12),
          Obx(
            () => Container(
              height: isWeb ? 50 : 45,
              padding: EdgeInsets.symmetric(horizontal: isWeb ? 16 : 12),
              decoration: BoxDecoration(
                color: kBg,
                borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
                border: Border.all(color: kBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.visibility_outlined, size: isWeb ? 20 : 18, color: kPrimary),
                      SizedBox(width: isWeb ? 10 : 8),
                      Text(
                        'Show Zero Balance Accounts',
                        style: TextStyle(
                          fontSize: isWeb ? 13 : 12,
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

  Widget _buildSummaryCards(TrialBalanceController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 16 : 12),
        child: Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Debit',
                _formatAmount(controller.totalDebit.value),
                kSuccess,
                Icons.trending_up,
                context,
              ),
            ),
            SizedBox(width: isWeb ? 16 : 12),
            Expanded(
              child: _buildSummaryCard(
                'Total Credit',
                _formatAmount(controller.totalCredit.value),
                kDanger,
                Icons.trending_down,
                context,
              ),
            ),
            SizedBox(width: isWeb ? 16 : 12),
            Expanded(
              child: _buildSummaryCard(
                'Difference',
                _formatAmount(controller.difference.value),
                controller.isBalanced.value ? kSuccess : kWarning,
                Icons.balance,
                context,
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
    IconData icon,
    BuildContext context, {
    String? subtitle,
  }) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Container(
      padding: EdgeInsets.all(isWeb ? 16 : 12),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
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
              Icon(icon, size: isWeb ? 20 : 16, color: color),
              SizedBox(width: isWeb ? 8 : 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isWeb ? 12 : 11,
                    color: kSubText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isWeb ? 8 : 6),
          Text(
            amount,
            style: TextStyle(
              fontSize: isWeb ? 18 : 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          if (subtitle != null)
            Padding(
              padding: EdgeInsets.only(top: isWeb ? 6 : 4),
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: isWeb ? 10 : 9,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTrialBalanceTable(TrialBalanceController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final isMobile = ResponsiveUtils.isMobile(context);
    
    return Obx(() {
      final data = controller.trialBalanceData;

      if (data.isEmpty) {
        return Padding(
          padding: EdgeInsets.all(isWeb ? 40 : 20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance,
                  size: isWeb ? 80 : 64,
                  color: kSubText.withOpacity(0.5),
                ),
                SizedBox(height: isWeb ? 20 : 16),
                Text(
                  'No accounts found',
                  style: TextStyle(
                    fontSize: isWeb ? 18 : 16,
                    color: kSubText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        children: [
          // Header for the accounts list
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 12 : 8),
            child: Text(
              'Accounts Summary',
              style: TextStyle(
                fontSize: isWeb ? 18 : 16,
                fontWeight: FontWeight.w700,
                color: kText,
              ),
            ),
          ),
          // List of accounts
          ...data.map((account) => Padding(
            padding: EdgeInsets.symmetric(horizontal: isWeb ? 20 : 12, vertical: isWeb ? 8 : 6),
            child: _buildAccountRow(account, controller, context),
          )).toList(),
        ],
      );
    });
  }

  Widget _buildAccountRow(
    TrialBalanceAccount account,
    TrialBalanceController controller,
    BuildContext context,
  ) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final isMobile = ResponsiveUtils.isMobile(context);
    
    return Card(
      color: kCardBg,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isWeb ? 14 : 12),
      ),
      child: InkWell(
        onTap: () => _showAccountDetails(account, controller, context),
        borderRadius: BorderRadius.circular(isWeb ? 14 : 12),
        child: Padding(
          padding: EdgeInsets.all(isWeb ? 16 : 12),
          child: isMobile
              ? _buildMobileAccountRow(account, context)
              : _buildDesktopAccountRow(account, context),
        ),
      ),
    );
  }

  Widget _buildDesktopAccountRow(TrialBalanceAccount account, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: isWeb ? 50 : 44,
          height: isWeb ? 50 : 44,
          decoration: BoxDecoration(
            color: _getAccountTypeColor(account.accountType).withOpacity(0.12),
            borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
          ),
          child: Icon(
            _getAccountIcon(account.accountType),
            size: isWeb ? 28 : 24,
            color: _getAccountTypeColor(account.accountType),
          ),
        ),
        SizedBox(width: isWeb ? 16 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                account.accountName,
                style: TextStyle(
                  fontSize: isWeb ? 15 : 14,
                  fontWeight: FontWeight.w700,
                  color: kText,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isWeb ? 8 : 6),
              Wrap(
                spacing: isWeb ? 12 : 8,
                runSpacing: isWeb ? 8 : 6,
                children: [
                  _badge(
                    text: account.accountCode,
                    color: _getAccountTypeColor(account.accountType),
                    context: context,
                  ),
                  _badge(
                    text: account.accountType,
                    color: kSubText,
                    bg: kBg,
                    context: context,
                  ),
                ],
              ),
              SizedBox(height: isWeb ? 12 : 10),
              Row(
                children: [
                  Expanded(
                    child: _amountColumn(
                      title: "Debit",
                      value: account.debitBalance,
                      color: kSuccess,
                      context: context,
                    ),
                  ),
                  SizedBox(width: isWeb ? 16 : 12),
                  Expanded(
                    child: _amountColumn(
                      title: "Credit",
                      value: account.creditBalance,
                      color: kDanger,
                      context: context,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileAccountRow(TrialBalanceAccount account, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getAccountTypeColor(account.accountType).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getAccountIcon(account.accountType),
                size: 22,
                color: _getAccountTypeColor(account.accountType),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.accountName,
                    style:  TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: kText,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _badge(
                        text: account.accountCode,
                        color: _getAccountTypeColor(account.accountType),
                        context: context,
                      ),
                      _badge(
                        text: account.accountType,
                        color: kSubText,
                        bg: kBg,
                        context: context,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kSuccess.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      'Debit',
                      style: TextStyle(fontSize: 10, color: kSubText),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      account.debitBalance > 0 ? _formatCompactAmount(account.debitBalance, context) : '-',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: account.debitBalance > 0 ? kSuccess : kSubText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kDanger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      'Credit',
                      style: TextStyle(fontSize: 10, color: kSubText),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      account.creditBalance > 0 ? _formatCompactAmount(account.creditBalance, context) : '-',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: account.creditBalance > 0 ? kDanger : kSubText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _badge({
    required String text,
    required Color color,
    Color? bg,
    required BuildContext context,
  }) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWeb ? 10 : 8, vertical: isWeb ? 5 : 4),
      decoration: BoxDecoration(
        color: bg ?? color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isWeb ? 6 : 4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isWeb ? 11 : 10,
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
    required BuildContext context,
  }) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isWeb ? 12 : 11,
            color: kSubText,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: isWeb ? 4 : 2),
        Text(
          value > 0 ? _formatCompactAmount(value, context) : '-',
          style: TextStyle(
            fontSize: isWeb ? 18 : 16,
            fontWeight: FontWeight.w800,
            color: value > 0 ? color : kSubText,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  void _selectDateRange(TrialBalanceController controller, BuildContext context) async {
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

  void _showExportOptions(TrialBalanceController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    if (isWeb) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            child: _buildExportContent(controller, ctx),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => Container(
          padding: const EdgeInsets.all(20),
          child: _buildExportContent(controller, ctx),
        ),
      );
    }
  }

  Widget _buildExportContent(TrialBalanceController controller, BuildContext ctx) {
    final isWeb = ResponsiveUtils.isWeb(ctx);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
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
          'Export Trial Balance',
          style: TextStyle(
            fontSize: isWeb ? 20 : 18,
            fontWeight: FontWeight.w800,
            color: kText,
          ),
        ),
        const SizedBox(height: 20),
        ListTile(
          leading: Icon(Icons.picture_as_pdf, size: isWeb ? 28 : 24, color: kDanger),
          title: Text('Export as PDF', style: TextStyle(fontSize: isWeb ? 16 : 14)),
          onTap: () {
            Navigator.pop(ctx);
            controller.exportTrialBalance();
          },
        ),
        ListTile(
          leading: Icon(Icons.table_chart, size: isWeb ? 28 : 24, color: kSuccess),
          title: Text('Export as Excel', style: TextStyle(fontSize: isWeb ? 16 : 14)),
          onTap: () {
            Navigator.pop(ctx);
            controller.exportTrialBalance();
          },
        ),
        ListTile(
          leading: Icon(Icons.print, size: isWeb ? 28 : 24, color: kPrimary),
          title: Text('Print', style: TextStyle(fontSize: isWeb ? 16 : 14)),
          onTap: () {
            Navigator.pop(ctx);
            controller.printTrialBalance();
          },
        ),
        ListTile(
          leading: Icon(Icons.share, size: isWeb ? 28 : 24, color: kWarning),
          title: Text('Share', style: TextStyle(fontSize: isWeb ? 16 : 14)),
          onTap: () {
            Navigator.pop(ctx);
            Get.snackbar('Share', 'Sharing trial balance...');
          },
        ),
      ],
    );
  }

  void _showAdvancedOptions(TrialBalanceController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    if (isWeb) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            child: _buildAdvancedOptionsContent(controller, ctx),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => Container(
          padding: const EdgeInsets.all(20),
          child: _buildAdvancedOptionsContent(controller, ctx),
        ),
      );
    }
  }

  Widget _buildAdvancedOptionsContent(TrialBalanceController controller, BuildContext ctx) {
    final isWeb = ResponsiveUtils.isWeb(ctx);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
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
          'Options',
          style: TextStyle(
            fontSize: isWeb ? 20 : 18,
            fontWeight: FontWeight.w800,
            color: kText,
          ),
        ),
        const SizedBox(height: 20),
        ListTile(
          leading: Icon(Icons.filter_alt, size: isWeb ? 28 : 24, color: kPrimary),
          title: Text('Filter Options', style: TextStyle(fontSize: isWeb ? 16 : 14)),
          onTap: () {
            Navigator.pop(ctx);
          },
        ),
        ListTile(
          leading: Icon(Icons.visibility_off, size: isWeb ? 28 : 24, color: kWarning),
          title: Text('Hide Zero Balance', style: TextStyle(fontSize: isWeb ? 16 : 14)),
          onTap: () {
            Navigator.pop(ctx);
            controller.toggleZeroBalance(!controller.showZeroBalance.value);
          },
        ),
        ListTile(
          leading: Icon(Icons.refresh, size: isWeb ? 28 : 24, color: kSuccess),
          title: Text('Refresh Data', style: TextStyle(fontSize: isWeb ? 16 : 14)),
          onTap: () {
            Navigator.pop(ctx);
            // controller.refreshData();
          },
        ),
      ],
    );
  }

  void _showAccountDetails(
    TrialBalanceAccount account,
    TrialBalanceController controller,
    BuildContext context,
  ) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    if (isWeb) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            child: _buildAccountDetailsContent(account, controller, ctx),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => Container(
          padding: const EdgeInsets.all(20),
          child: _buildAccountDetailsContent(account, controller, ctx),
        ),
      );
    }
  }

  Widget _buildAccountDetailsContent(
    TrialBalanceAccount account,
    TrialBalanceController controller,
    BuildContext ctx,
  ) {
    final isWeb = ResponsiveUtils.isWeb(ctx);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: isWeb ? 70 : 60,
              height: isWeb ? 70 : 60,
              decoration: BoxDecoration(
                color: _getAccountTypeColor(account.accountType).withOpacity(0.1),
                borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
              ),
              child: Icon(
                _getAccountIcon(account.accountType),
                size: isWeb ? 40 : 32,
                color: _getAccountTypeColor(account.accountType),
              ),
            ),
            SizedBox(width: isWeb ? 16 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.accountName,
                    style: TextStyle(
                      fontSize: isWeb ? 20 : 18,
                      fontWeight: FontWeight.w800,
                      color: kText,
                    ),
                  ),
                  Text(
                    '${account.accountCode} • ${account.accountType}',
                    style: TextStyle(
                      fontSize: isWeb ? 14 : 13,
                      color: kSubText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: isWeb ? 24 : 20),
        Container(
          padding: EdgeInsets.all(isWeb ? 20 : 16),
          decoration: BoxDecoration(
            color: kBg,
            borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
          ),
          child: Column(
            children: [
              _buildDetailRow(
                'Debit Balance',
                _formatAmount(account.debitBalance),
                kSuccess,
                ctx
              ),
              SizedBox(height: isWeb ? 16 : 12),
              _buildDetailRow(
                'Credit Balance',
                _formatAmount(account.creditBalance),
                kDanger,
                ctx,
              ),
              SizedBox(height: isWeb ? 16 : 12),
              _buildDetailRow(
                'Net Balance',
                _formatAmount(account.debitBalance - account.creditBalance),
                (account.debitBalance - account.creditBalance) >= 0 ? kSuccess : kDanger,
                ctx,
              ),
            ],
          ),
        ),
        SizedBox(height: isWeb ? 20 : 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Get.toNamed('/general-ledger', arguments: {'accountId': account.accountId});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              padding: EdgeInsets.symmetric(vertical: isWeb ? 16 : 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isWeb ? 14 : 12),
              ),
            ),
            child: Text(
              'View Ledger Details',
              style: TextStyle(
                fontSize: isWeb ? 15 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, Color color, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isWeb ? 14 : 13,
            color: kSubText,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isWeb ? 16 : 14,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getAccountTypeColor(String type) {
    switch (type) {
      case 'Assets': return kSuccess;
      case 'Liabilities': return kDanger;
      case 'Equity': return const Color(0xFF9B59B6);
      case 'Income': return kPrimary;
      case 'Expenses': return kWarning;
      default: return kSubText;
    }
  }

  IconData _getAccountIcon(String type) {
    switch (type) {
      case 'Assets': return Icons.account_balance;
      case 'Liabilities': return Icons.payment;
      case 'Equity': return Icons.account_balance_wallet;
      case 'Income': return Icons.trending_up;
      case 'Expenses': return Icons.trending_down;
      default: return Icons.account_balance;
    }
  }

  String _formatCompactAmount(double amount, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    if (amount >= 1000000) {
      return '₨ ${(amount / 1000000).toStringAsFixed(isWeb ? 2 : 1)}M';
    } else if (amount >= 1000) {
      return '₨ ${(amount / 1000).toStringAsFixed(0)}K';
    }
    return '₨ ${amount.toStringAsFixed(0)}';
  }

  String _formatAmount(double amount) {
    return '₨ ${amount.toStringAsFixed(2)}';
  }
}