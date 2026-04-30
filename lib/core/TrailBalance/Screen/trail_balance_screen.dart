import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/Utils/responsive_utils.dart';
import 'package:LedgerPro_app/Utils/toast_utils.dart';
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

    return Scaffold(
      backgroundColor: kBg,
      body: Obx(() {
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
              _buildSummaryCards(controller, context),
              _buildTrialBalanceTable(controller, context),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader(TrialBalanceController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);

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
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
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
              // Date Range Button - Web ke liye fixed width, mobile ke liye flexible
              isWeb
                  ? SizedBox(
                      width: 300,
                      child: GestureDetector(
                        onTap: () => _selectDateRange(controller, context),
                        child: Obx(
                          () => Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                      Icon(Icons.date_range, size: 20, color: kPrimary),
                                      const SizedBox(width: 10),
                                      Flexible(
                                        child: Text(
                                          controller.selectedDateRange.value != null
                                              ? '${DateFormat('dd/MM/yy').format(controller.selectedDateRange.value!.start)} - ${DateFormat('dd/MM/yy').format(controller.selectedDateRange.value!.end)}'
                                              : 'Select Date Range',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: controller.selectedDateRange.value != null ? kPrimary : kSubText,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_drop_down, size: 24, color: kSubText),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDateRange(controller, context),
                        child: Obx(
                          () => Container(
                            height: 45,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: kBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: kBorder),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Row(
                                    children: [
                                      Icon(Icons.date_range, size: 18, color: kPrimary),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          controller.selectedDateRange.value != null
                                              ? '${DateFormat('dd/MM/yy').format(controller.selectedDateRange.value!.start)} - ${DateFormat('dd/MM/yy').format(controller.selectedDateRange.value!.end)}'
                                              : 'Select Date Range',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: controller.selectedDateRange.value != null ? kPrimary : kSubText,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_drop_down, size: 20, color: kSubText),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
              SizedBox(width: isWeb ? 16 : 12),
              // Filter Dropdown - Web ke liye fixed width
              isWeb
                  ? SizedBox(
                      width: 150,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: kBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: kBorder),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: Obx(
                            () => DropdownButton<String>(
                              value: controller.selectedFilter.value,
                              icon: const Icon(Icons.arrow_drop_down, size: 24),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              isExpanded: true,
                              style:  TextStyle(fontSize: 13, color: kText),
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
                    )
                  : Expanded(
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: kBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: kBorder),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: Obx(
                            () => DropdownButton<String>(
                              value: controller.selectedFilter.value,
                              icon: const Icon(Icons.arrow_drop_down, size: 20),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              isExpanded: true,
                              style:  TextStyle(fontSize: 12, color: kText),
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
            overflow: TextOverflow.ellipsis,
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

    return Obx(() {
      final data = controller.trialBalanceData;

      if (data.isEmpty) {
        return Padding(
          padding: EdgeInsets.all(isWeb ? 40 : 20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_balance,
                    size: isWeb ? 80 : 64, color: kSubText.withOpacity(0.5)),
                SizedBox(height: isWeb ? 20 : 16),
                Text(
                  'No accounts found',
                  style: TextStyle(
                      fontSize: isWeb ? 18 : 16,
                      color: kSubText,
                      fontWeight: FontWeight.w500),
                ),
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
                horizontal: isWeb ? 24 : 16, vertical: isWeb ? 12 : 8),
            child: Row(
              children: [
                Text(
                  'Accounts Summary',
                  style: TextStyle(
                    fontSize: isWeb ? 18 : 16,
                    fontWeight: FontWeight.w700,
                    color: kText,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${data.length} accounts',
                    style: TextStyle(
                      fontSize: isWeb ? 12 : 11,
                      color: kPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isWeb)
            _buildWebTrialBalanceTable(data, controller, context)
          else
            _buildMobileTrialBalanceList(data, controller, context),
        ],
      );
    });
  }

  // WEB TABLE - Simple HTML table style, no Expanded in Row
  Widget _buildWebTrialBalanceTable(
    List<TrialBalanceAccount> data,
    TrialBalanceController controller,
    BuildContext context,
  ) {
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
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Table Header - No Expanded, fixed widths
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  color: kPrimary.withOpacity(0.06),
                  child: Row(
                    children: [
                      Container(width: 60, child: const Text('', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 250, child: const Text('Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 120, child: const Text('Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 180, child: const Text('Debit Balance', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 180, child: const Text('Credit Balance', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 180, child: const Text('Net Balance', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 60, child: const Text('', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    ],
                  ),
                ),
                // Table Rows
                ...data.asMap().entries.map((entry) {
                  final index = entry.key;
                  final account = entry.value;
                  final netBalance = account.debitBalance - account.creditBalance;
                  final isEven = index.isEven;

                  return InkWell(
                    onTap: () => _showAccountDetails(account, controller, context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: isEven ? Colors.transparent : kPrimary.withOpacity(0.01),
                        border: Border(top: BorderSide(color: kBorder.withOpacity(0.5))),
                      ),
                      child: Row(
                        children: [
                          // Icon
                          Container(
                            width: 60,
                            height: 44,
                            decoration: BoxDecoration(
                              color: _getAccountTypeColor(account.accountType).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _getAccountIcon(account.accountType),
                              size: 20,
                              color: _getAccountTypeColor(account.accountType),
                            ),
                          ),
                          // Account Name + Code
                          Container(
                            width: 250,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  account.accountName,
                                  style:  TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kText),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getAccountTypeColor(account.accountType).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    account.accountCode,
                                    style: TextStyle(fontSize: 11, color: _getAccountTypeColor(account.accountType), fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Type Badge
                          Container(
                            width: 120,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: _getAccountTypeColor(account.accountType).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                account.accountType,
                                style: TextStyle(fontSize: 11, color: _getAccountTypeColor(account.accountType), fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          // Debit
                          Container(
                            width: 180,
                            child: Text(
                              account.debitBalance > 0 ? _formatAmount(account.debitBalance) : '-',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: account.debitBalance > 0 ? FontWeight.w700 : FontWeight.w400,
                                color: account.debitBalance > 0 ? kSuccess : kSubText,
                              ),
                            ),
                          ),
                          // Credit
                          Container(
                            width: 180,
                            child: Text(
                              account.creditBalance > 0 ? _formatAmount(account.creditBalance) : '-',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: account.creditBalance > 0 ? FontWeight.w700 : FontWeight.w400,
                                color: account.creditBalance > 0 ? kDanger : kSubText,
                              ),
                            ),
                          ),
                          // Net Balance
                          Container(
                            width: 180,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: netBalance >= 0 ? kSuccess.withOpacity(0.08) : kDanger.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _formatAmount(netBalance.abs()),
                                textAlign: TextAlign.right,
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: netBalance >= 0 ? kSuccess : kDanger),
                              ),
                            ),
                          ),
                          // View Details button
                          Container(
                            width: 60,
                            child: IconButton(
                              onPressed: () => _showAccountDetails(account, controller, context),
                              icon: const Icon(Icons.open_in_new, size: 16),
                              tooltip: 'View Details',
                              padding: EdgeInsets.zero,
                              color: kSubText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                // Footer
                _buildTableFooter(data),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableFooter(List<TrialBalanceAccount> data) {
    final totalDebit = data.fold(0.0, (s, a) => s + a.debitBalance);
    final totalCredit = data.fold(0.0, (s, a) => s + a.creditBalance);
    final diff = totalDebit - totalCredit;
    final balanced = diff.abs() < 0.01;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: kPrimary.withOpacity(0.06),
        border:  Border(top: BorderSide(color: kBorder)),
      ),
      child: Row(
        children: [
          Container(width: 60, child: const Text('')),
          Container(width: 250, child: const Text('TOTALS', style: TextStyle(fontWeight: FontWeight.bold))),
          Container(width: 120, child: const SizedBox()),
          Container(width: 180, child: Text(_formatAmount(totalDebit), textAlign: TextAlign.right, style: const TextStyle(color: kSuccess, fontWeight: FontWeight.bold))),
          Container(width: 180, child: Text(_formatAmount(totalCredit), textAlign: TextAlign.right, style: const TextStyle(color: kDanger, fontWeight: FontWeight.bold))),
          Container(
            width: 180,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: balanced ? kSuccess.withOpacity(0.1) : kWarning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(balanced ? Icons.check_circle : Icons.warning_rounded, size: 14, color: balanced ? kSuccess : kWarning),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      balanced ? 'Balanced' : _formatAmount(diff.abs()),
                      style: TextStyle(color: balanced ? kSuccess : kWarning, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(width: 60, child: const SizedBox()),
        ],
      ),
    );
  }

  // MOBILE LIST
  Widget _buildMobileTrialBalanceList(
    List<TrialBalanceAccount> data,
    TrialBalanceController controller,
    BuildContext context,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final account = data[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Card(
            color: kCardBg,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              onTap: () => _showAccountDetails(account, controller, context),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                account.accountName,
                                style:  TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kText),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getAccountTypeColor(account.accountType).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      account.accountCode,
                                      style: TextStyle(fontSize: 10, color: _getAccountTypeColor(account.accountType), fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(4)),
                                    child: Text(
                                      account.accountType,
                                      style:  TextStyle(fontSize: 10, color: kSubText, fontWeight: FontWeight.w600),
                                    ),
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
                            decoration: BoxDecoration(color: kSuccess.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                 Text('Debit', style: TextStyle(fontSize: 10, color: kSubText)),
                                const SizedBox(height: 4),
                                Text(
                                  account.debitBalance > 0 ? _formatCompactAmount(account.debitBalance, context) : '-',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: account.debitBalance > 0 ? kSuccess : kSubText),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: kDanger.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                 Text('Credit', style: TextStyle(fontSize: 10, color: kSubText)),
                                const SizedBox(height: 4),
                                Text(
                                  account.creditBalance > 0 ? _formatCompactAmount(account.creditBalance, context) : '-',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: account.creditBalance > 0 ? kDanger : kSubText),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           Text('Net Balance', style: TextStyle(fontSize: 11, color: kSubText)),
                          Flexible(
                            child: Text(
                              _formatCompactAmount(account.debitBalance - account.creditBalance, context),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: (account.debitBalance - account.creditBalance) >= 0 ? kSuccess : kDanger,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _selectDateRange(TrialBalanceController controller, BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: controller.selectedDateRange.value,
    );
    if (picked != null) controller.setDateRange(picked);
  }

  void _showExportOptions(TrialBalanceController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: isWeb ? 400 : MediaQuery.of(ctx).size.width * 0.9,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Export Trial Balance', style: TextStyle(fontSize: isWeb ? 20 : 18, fontWeight: FontWeight.w800, color: kText)),
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
            ],
          ),
        ),
      ),
    );
  }

  void _showAccountDetails(
    TrialBalanceAccount account,
    TrialBalanceController controller,
    BuildContext context,
  ) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: isWeb ? 500 : MediaQuery.of(ctx).size.width * 0.9,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: _getAccountTypeColor(account.accountType).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _getAccountIcon(account.accountType),
                      size: 40,
                      color: _getAccountTypeColor(account.accountType),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.accountName,
                          style:  TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kText),
                        ),
                        Text(
                          '${account.accountCode} • ${account.accountType}',
                          style:  TextStyle(fontSize: 14, color: kSubText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    _buildDetailRow('Debit Balance', _formatAmount(account.debitBalance), kSuccess),
                    const SizedBox(height: 16),
                    _buildDetailRow('Credit Balance', _formatAmount(account.creditBalance), kDanger),
                    const SizedBox(height: 16),
                    _buildDetailRow('Net Balance', _formatAmount(account.debitBalance - account.creditBalance),
                        (account.debitBalance - account.creditBalance) >= 0 ? kSuccess : kDanger),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Get.toNamed('/general-ledger', arguments: {'accountId': account.accountId});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('View Ledger Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style:  TextStyle(fontSize: 14, color: kSubText, fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
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
      return '\$ ${(amount / 1000000).toStringAsFixed(isWeb ? 2 : 1)}M';
    } else if (amount >= 1000) {
      return '\$ ${(amount / 1000).toStringAsFixed(0)}K';
    }
    return '\$ ${amount.toStringAsFixed(0)}';
  }

  String _formatAmount(double amount) {
    return '\$ ${amount.toStringAsFixed(2)}';
  }
}