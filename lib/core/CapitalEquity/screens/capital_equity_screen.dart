import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/Utils/responsive_utils.dart';
import 'package:LedgerPro_app/Utils/toast_utils.dart';
import 'package:LedgerPro_app/core/CapitalEquity/controller/equity_controller.dart';
import 'package:LedgerPro_app/core/CapitalEquity/models/equity_model.dart';
import 'package:LedgerPro_app/core/chartofaccounts/screens/chart_of_account_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CapitalEquityScreen extends StatelessWidget {
  const CapitalEquityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EquityController());

    // ✅ Scaffold already at root, just need Material in TabBarView
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
                Text('Loading equity accounts...', style: TextStyle(fontSize: ResponsiveUtils.isWeb(context) ? 14 : 12, color: kSubText)),
              ],
            ),
          );
        }
        
        return Column(
          children: [
            _buildHeader(controller, context),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildSummaryCards(controller, context),
                    _buildFilterBar(controller, context),
                    _buildTabSection(controller, context),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader(EquityController controller, BuildContext context) {
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
                  'Capital & Equity',
                  style: TextStyle(
                    fontSize: isWeb ? 20 : 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage capital, reserves, and retained earnings',
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
            icon: Icons.calculate_outlined,
            size: isWeb ? 22 : 20,
            onTap: () => controller.calculateEquity(),
          ),
          if (!isMobile) const SizedBox(width: 8),
          _headerIconBtn(
            icon: Icons.download_outlined,
            size: isWeb ? 22 : 20,
            onTap: () => controller.exportEquity(),
          ),
          if (!isMobile) const SizedBox(width: 8),
          _headerIconBtn(
            icon: Icons.print_outlined,
            size: isWeb ? 22 : 20,
            onTap: () => controller.printEquity(),
          ),
          if (!isMobile) const SizedBox(width: 8),
          if (!isMobile)
            _headerIconBtn(
              icon: Icons.add,
              size: isWeb ? 22 : 20,
              onTap: () {
                if (controller.equityAccounts.isEmpty) {
                  AppSnackbar.error(
                    Colors.yellow,
                    'No Equity Account',
                    'Please add an Equity account from Chart of Accounts first',
                    duration: const Duration(seconds: 3),
                  );
                  Get.to(() => const ChartOfAccountsScreen());
                } else {
                  controller.showAddTransactionDialog();
                }
              },
              isWhiteBg: true,
              iconColor: kPrimary,
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

  // ==================== SUMMARY CARDS ====================
  Widget _buildSummaryCards(EquityController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Obx(() => Container(
      padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 16 : 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildSummaryCard('Total Capital', controller.formatAmount(controller.totalCapital.value), kPrimary, Icons.account_balance, context, width: isWeb ? 200 : 160),
            SizedBox(width: isWeb ? 16 : 12),
            _buildSummaryCard('Retained Earnings', controller.formatAmount(controller.totalRetainedEarnings.value), kSuccess, Icons.trending_up, context, width: isWeb ? 230 : 180),
            SizedBox(width: isWeb ? 16 : 12),
            _buildSummaryCard('Reserves', controller.formatAmount(controller.totalReserves.value), kWarning, Icons.savings, context, width: isWeb ? 200 : 160),
            SizedBox(width: isWeb ? 16 : 12),
            _buildSummaryCard('Drawings', controller.formatAmount(controller.totalDrawings.value), kDanger, Icons.remove_circle, context, width: isWeb ? 200 : 160),
            SizedBox(width: isWeb ? 16 : 12),
            _buildSummaryCard('Total Equity', controller.formatAmount(controller.totalEquity.value), kPrimary, Icons.account_balance_wallet, context, width: isWeb ? 220 : 170),
          ],
        ),
      ),
    ));
  }

  Widget _buildSummaryCard(String title, String amount, Color color, IconData icon, BuildContext context, {double width = 160}) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Container(
      width: width,
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
              Icon(icon, size: isWeb ? 24 : 20, color: color),
              SizedBox(width: isWeb ? 8 : 6),
              Expanded(child: Text(title, style: TextStyle(fontSize: isWeb ? 12 : 11, color: kSubText, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
            ],
          ),
          SizedBox(height: isWeb ? 8 : 6),
          Text(amount, style: TextStyle(fontSize: isWeb ? 18 : 14, fontWeight: FontWeight.w800, color: color), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  // ==================== FILTER BAR ====================
  Widget _buildFilterBar(EquityController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Material(
      color: kCardBg,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 12 : 10),
        child: Row(
          children: [
            Expanded(
              flex: isWeb ? 3 : 2,
              child: Container(
                height: isWeb ? 45 : 40,
                decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(isWeb ? 12 : 10), border: Border.all(color: kBorder)),
                child: TextField(
                  controller: controller.searchController,
                  style: TextStyle(fontSize: isWeb ? 14 : 12, color: kText),
                  decoration: InputDecoration(
                    hintText: isWeb ? 'Search by account name or code...' : 'Search...',
                    hintStyle: TextStyle(fontSize: isWeb ? 12 : 11, color: kSubText),
                    prefixIcon: Icon(Icons.search, size: isWeb ? 20 : 18, color: kSubText),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: isWeb ? 12 : 10),
                  ),
                ),
              ),
            ),
            SizedBox(width: isWeb ? 16 : 12),
            SizedBox(
              width: isWeb ? 150 : 120,
              height: isWeb ? 45 : 40,
              child: Container(
                decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(isWeb ? 12 : 10), border: Border.all(color: kBorder)),
                child: Obx(() => DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.selectedFilter.value,
                    icon: Icon(Icons.arrow_drop_down, size: isWeb ? 24 : 20, color: kText),
                    padding: EdgeInsets.symmetric(horizontal: isWeb ? 12 : 8),
                    isExpanded: true,
                    style: TextStyle(fontSize: isWeb ? 13 : 12, color: kText),
                    dropdownColor: kCardBg,
                    items: controller.filterOptions.map((filter) {
                      return DropdownMenuItem(value: filter, child: Text(filter, overflow: TextOverflow.ellipsis));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) controller.applyFilter(value);
                    },
                  ),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== TAB SECTION ====================
  Widget _buildTabSection(EquityController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return DefaultTabController(
      length: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: kCardBg,
            child: TabBar(
              tabs: const [
                Tab(text: 'Equity Accounts'),
                Tab(text: 'Transaction History'),
              ],
              labelColor: kPrimary,
              unselectedLabelColor: kSubText,
              indicatorColor: kPrimary,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: TextStyle(fontSize: isWeb ? 14 : 12, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            height: isWeb ? 600 : 500,
            child: TabBarView(
              children: [
                _buildEquityAccountsList(controller, context),
                _buildTransactionHistory(controller, context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== EQUITY ACCOUNTS LIST ====================
  Widget _buildEquityAccountsList(EquityController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    if (controller.equityAccounts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_outlined, size: isWeb ? 80 : 64, color: kSubText.withOpacity(0.5)),
            SizedBox(height: isWeb ? 20 : 16),
            Text('No equity accounts found', style: TextStyle(fontSize: isWeb ? 18 : 16, color: kSubText, fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    if (isWeb) {
      return _buildWebEquityAccountsTable(controller, context);
    } else {
      return ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: controller.equityAccounts.length,
        itemBuilder: (context, index) {
          final account = controller.equityAccounts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildEquityCard(controller, account, context),
          );
        },
      );
    }
  }

  // ==================== WEB TABLE ====================
  Widget _buildWebEquityAccountsTable(EquityController controller, BuildContext context) {
    final accounts = controller.equityAccounts;
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Container(
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: [
                // Header - Fixed widths
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  color: kPrimary.withOpacity(0.06),
                  child: Row(
                    children: [
                      Container(width: 60, child: const Text('', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 120, child: const Text('Account Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 220, child: const Text('Account Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 140, child: const Text('Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 150, child: const Text('Opening Balance', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 150, child: const Text('Additions', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 150, child: const Text('Withdrawals', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 150, child: const Text('Current Balance', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 80, child: const Text('Actions', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    ],
                  ),
                ),
                ...accounts.asMap().entries.map((entry) {
                  final index = entry.key;
                  final account = entry.value;
                  final isEven = index.isEven;
                  final typeColor = account.accountType == 'Capital' ? kPrimary :
                                    account.accountType == 'Retained Earnings' ? kSuccess :
                                    account.accountType == 'Reserves' ? kWarning : kDanger;
                  
                  return Container(
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
                          decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: Icon(
                            account.accountType == 'Capital' ? Icons.account_balance :
                            account.accountType == 'Retained Earnings' ? Icons.trending_up :
                            account.accountType == 'Reserves' ? Icons.savings : Icons.remove_circle,
                            size: 22,
                            color: typeColor,
                          ),
                        ),
                        // Account Code
                        Container(
                          width: 120,
                          child: Text(account.accountCode, style:  TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kText)),
                        ),
                        // Account Name
                        Container(
                          width: 220,
                          child: Text(account.accountName, style:  TextStyle(fontSize: 13, color: kText), overflow: TextOverflow.ellipsis),
                        ),
                        // Type
                        Container(
                          width: 140,
                          child: Text(account.accountType, style:  TextStyle(fontSize: 13, color: kText), overflow: TextOverflow.ellipsis),
                        ),
                        // Opening Balance
                        Container(
                          width: 150,
                          child: Text(controller.formatAmount(account.openingBalance), textAlign: TextAlign.right, style:  TextStyle(fontSize: 13, color: kText)),
                        ),
                        // Additions
                        Container(
                          width: 150,
                          child: Text(controller.formatAmount(account.additions), textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, color: kSuccess)),
                        ),
                        // Withdrawals
                        Container(
                          width: 150,
                          child: Text(controller.formatAmount(account.withdrawals), textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, color: kDanger)),
                        ),
                        // Current Balance
                        Container(
                          width: 150,
                          child: Text(controller.formatAmount(account.currentBalance), textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kPrimary)),
                        ),
                        // Actions
                        Container(
                          width: 80,
                          child: IconButton(
                            onPressed: () => controller.showAccountDetails(account),
                            icon: const Icon(Icons.remove_red_eye, size: 18),
                            padding: EdgeInsets.zero,
                            color: kPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                // Footer
                _buildEquityTableFooter(controller, accounts),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEquityTableFooter(EquityController controller, List<EquityAccount> accounts) {
    final totalOpening = accounts.fold(0.0, (sum, a) => sum + a.openingBalance);
    final totalAdditions = accounts.fold(0.0, (sum, a) => sum + a.additions);
    final totalWithdrawals = accounts.fold(0.0, (sum, a) => sum + a.withdrawals);
    final totalCurrent = accounts.fold(0.0, (sum, a) => sum + a.currentBalance);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: kPrimary.withOpacity(0.06),
        border:  Border(top: BorderSide(color: kBorder)),
      ),
      child: Row(
        children: [
          Container(width: 60, child: const Text('')),
          Container(width: 120, child: const Text('TOTALS', style: TextStyle(fontWeight: FontWeight.bold))),
          Container(width: 220, child: const SizedBox()),
          Container(width: 140, child: const SizedBox()),
          Container(width: 150, child: Text(controller.formatAmount(totalOpening), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold))),
          Container(width: 150, child: Text(controller.formatAmount(totalAdditions), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, color: kSuccess))),
          Container(width: 150, child: Text(controller.formatAmount(totalWithdrawals), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, color: kDanger))),
          Container(width: 150, child: Text(controller.formatAmount(totalCurrent), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, color: kPrimary))),
          Container(width: 80, child: const SizedBox()),
        ],
      ),
    );
  }

  // ==================== EQUITY CARD (MOBILE) ====================
  Widget _buildEquityCard(EquityController controller, EquityAccount account, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final Color typeColor = account.accountType == 'Capital' ? kPrimary :
                            account.accountType == 'Retained Earnings' ? kSuccess :
                            account.accountType == 'Reserves' ? kWarning : kDanger;
    
    final IconData typeIcon = account.accountType == 'Capital' ? Icons.account_balance :
                              account.accountType == 'Retained Earnings' ? Icons.trending_up :
                              account.accountType == 'Reserves' ? Icons.savings : Icons.remove_circle;
    
    return Card(
      color: kCardBg,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => controller.showAccountDetails(account),
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
                    decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: Icon(typeIcon, size: 20, color: typeColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(account.accountName, style:  TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: kText), overflow: TextOverflow.ellipsis)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                              child: Text(account.accountType, style: TextStyle(fontSize: 9, color: typeColor, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(account.accountCode, style:  TextStyle(fontSize: 10, color: kSubText)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                       Text('Balance', style: TextStyle(fontSize: 9, color: kSubText)),
                      const SizedBox(height: 2),
                      Text(controller.formatAmount(account.currentBalance), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: typeColor)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildInfoItem('Opening', controller.formatAmount(account.openingBalance), Icons.account_balance, false)),
                  Expanded(child: _buildInfoItem('Additions', controller.formatAmount(account.additions), Icons.add_circle, false)),
                  Expanded(child: _buildInfoItem('Withdrawals', controller.formatAmount(account.withdrawals), Icons.remove_circle, false)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (account.accountType == 'Capital')
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => controller.showAddCapitalDialog(account),
                        icon: Icon(Icons.add_circle, size: 14, color: kSuccess),
                        label: const Text('Add', style: TextStyle(fontSize: 10)),
                        style: _buttonStyle(kSuccess, false),
                      ),
                    ),
                  if (account.accountType == 'Drawings')
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => controller.showRecordDrawingsDialog(account),
                        icon: Icon(Icons.remove_circle, size: 14, color: kDanger),
                        label: const Text('Draw', style: TextStyle(fontSize: 10)),
                        style: _buttonStyle(kDanger, false),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.showTransactionHistory(account),
                      icon: const Icon(Icons.history, size: 14),
                      label: const Text('History', style: TextStyle(fontSize: 10)),
                      style: _buttonStyle(kPrimary, false),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, bool isWeb) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: isWeb ? 16 : 12, color: kSubText),
        SizedBox(width: isWeb ? 8 : 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: isWeb ? 11 : 8, color: kSubText)),
              Text(value, style: TextStyle(fontSize: isWeb ? 11 : 9, fontWeight: FontWeight.w600, color: kText), overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== TRANSACTION HISTORY ====================
  Widget _buildTransactionHistory(EquityController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    if (controller.transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: isWeb ? 80 : 64, color: kSubText.withOpacity(0.5)),
            SizedBox(height: isWeb ? 20 : 16),
            Text('No transactions found', style: TextStyle(fontSize: isWeb ? 18 : 16, color: kSubText, fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: controller.transactions.length,
      itemBuilder: (context, index) {
        final transaction = controller.transactions[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildTransactionCard(controller, transaction, context),
        );
      },
    );
  }

  Widget _buildTransactionCard(EquityController controller, OwnerTransaction transaction, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    final Color typeColor = transaction.type == 'Additional Capital' ? kSuccess :
                            transaction.type == 'Retained Earnings' ? kPrimary :
                            transaction.type == 'Reserve Transfer' ? kWarning : kDanger;
    
    final IconData typeIcon = transaction.type == 'Additional Capital' ? Icons.add_circle :
                              transaction.type == 'Retained Earnings' ? Icons.trending_up :
                              transaction.type == 'Reserve Transfer' ? Icons.swap_horiz : Icons.remove_circle;
    
    return Card(
      color: kCardBg,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(typeIcon, size: 20, color: typeColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(transaction.type, style:  TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kText)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: kSuccess.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text(transaction.status, style: TextStyle(fontSize: 9, color: kSuccess, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(transaction.accountName, style:  TextStyle(fontSize: 10, color: kSubText), overflow: TextOverflow.ellipsis),
                  Text(transaction.description, style:  TextStyle(fontSize: 10, color: kSubText), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(controller.formatAmount(transaction.amount), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: typeColor)),
                const SizedBox(height: 2),
                Text(DateFormat('dd MMM yyyy').format(transaction.date), style:  TextStyle(fontSize: 9, color: kSubText)),
                Text('Ref: ${transaction.reference}', style:  TextStyle(fontSize: 9, color: kSubText)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle(Color color, bool isWeb) {
    return OutlinedButton.styleFrom(
      foregroundColor: color,
      side: BorderSide(color: color),
      padding: EdgeInsets.symmetric(vertical: isWeb ? 10 : 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isWeb ? 8 : 6)),
    );
  }
}