import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/Utils/responsive_utils.dart';
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

  // Custom Header without AppBar
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
                ),
              ],
            ),
          ),
          // Calculate Equity Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.calculate_outlined, color: Colors.white, size: isWeb ? 22 : 20),
              onPressed: () => controller.calculateEquity(),
            ),
          ),
          if (!isMobile) const SizedBox(width: 8),
          // Export Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.download_outlined, color: Colors.white, size: isWeb ? 22 : 20),
              onPressed: () => controller.exportEquity(),
            ),
          ),
          if (!isMobile) const SizedBox(width: 8),
          // Print Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.print_outlined, color: Colors.white, size: isWeb ? 22 : 20),
              onPressed: () => controller.printEquity(),
            ),
          ),
          if (!isMobile) const SizedBox(width: 8),
          if (!isMobile)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(Icons.add, color: kPrimary, size: isWeb ? 22 : 20),
                onPressed: () {
                  if (controller.equityAccounts.isEmpty) {
                    Get.snackbar(
                      'No Equity Account',
                      'Please add an Equity account from Chart of Accounts first',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: kWarning,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 3),
                    );
                    Get.to(() => const ChartOfAccountsScreen());
                  } else {
                    controller.showAddTransactionDialog();
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

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
              Expanded(child: Text(title, style: TextStyle(fontSize: isWeb ? 12 : 11, color: kSubText, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ),
          SizedBox(height: isWeb ? 8 : 6),
          Text(amount, style: TextStyle(fontSize: isWeb ? 18 : 14, fontWeight: FontWeight.w800, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildFilterBar(EquityController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 12 : 10),
      color: kCardBg,
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
          Expanded(
            flex: isWeb ? 2 : 1,
            child: Container(
              height: isWeb ? 45 : 40,
              decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(isWeb ? 12 : 10), border: Border.all(color: kBorder)),
              child: Obx(() => DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.selectedFilter.value,
                  icon: Icon(Icons.arrow_drop_down, size: isWeb ? 24 : 20, color: kText),
                  padding: EdgeInsets.symmetric(horizontal: isWeb ? 16 : 12),
                  isExpanded: true,
                  style: TextStyle(fontSize: isWeb ? 13 : 12, color: kText),
                  dropdownColor: kCardBg,
                  items: controller.filterOptions.map((filter) {
                    return DropdownMenuItem(value: filter, child: Text(filter, style: TextStyle(color: kText, fontSize: isWeb ? 13 : 12)));
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
    );
  }

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
            height: 500,
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

    return ListView.builder(
      padding: EdgeInsets.all(isWeb ? 20 : 12),
      itemCount: controller.equityAccounts.length,
      itemBuilder: (context, index) {
        final account = controller.equityAccounts[index];
        return Padding(
          padding: EdgeInsets.only(bottom: isWeb ? 12 : 8),
          child: _buildEquityCard(controller, account, context),
        );
      },
    );
  }

  Widget _buildEquityCard(EquityController controller, EquityAccount account, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    Color typeColor = account.accountType == 'Capital' ? kPrimary :
                      account.accountType == 'Retained Earnings' ? kSuccess :
                      account.accountType == 'Reserves' ? kWarning : kDanger;
    
    IconData typeIcon = account.accountType == 'Capital' ? Icons.account_balance :
                        account.accountType == 'Retained Earnings' ? Icons.trending_up :
                        account.accountType == 'Reserves' ? Icons.savings : Icons.remove_circle;
    
    return Container(
      margin: EdgeInsets.only(bottom: isWeb ? 12 : 8),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.showAccountDetails(account),
          borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
          child: Padding(
            padding: EdgeInsets.all(isWeb ? 16 : 12),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: isWeb ? 50 : 40,
                      height: isWeb ? 50 : 40,
                      decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(isWeb ? 12 : 10)),
                      child: Icon(typeIcon, size: isWeb ? 24 : 20, color: typeColor),
                    ),
                    SizedBox(width: isWeb ? 16 : 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(account.accountName, style: TextStyle(fontSize: isWeb ? 15 : 13, fontWeight: FontWeight.w800, color: kText))),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: isWeb ? 8 : 6, vertical: isWeb ? 4 : 2),
                                decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(isWeb ? 6 : 4)),
                                child: Text(account.accountType, style: TextStyle(fontSize: isWeb ? 11 : 10, color: typeColor, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          SizedBox(height: isWeb ? 4 : 2),
                          Text(account.accountCode, style: TextStyle(fontSize: isWeb ? 12 : 11, color: kSubText)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Balance', style: TextStyle(fontSize: isWeb ? 11 : 10, color: kSubText, fontWeight: FontWeight.w500)),
                        SizedBox(height: isWeb ? 4 : 2),
                        Text(controller.formatAmount(account.currentBalance), style: TextStyle(fontSize: isWeb ? 16 : 14, fontWeight: FontWeight.w800, color: typeColor)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: isWeb ? 16 : 12),
                Container(
                  padding: EdgeInsets.symmetric(vertical: isWeb ? 10 : 8),
                  child: Row(
                    children: [
                      Expanded(child: _buildInfoItem('Opening Balance', controller.formatAmount(account.openingBalance), Icons.account_balance, isWeb)),
                      Container(width: 1, height: isWeb ? 32 : 24, color: kBorder),
                      Expanded(child: _buildInfoItem('Additions', controller.formatAmount(account.additions), Icons.add_circle, isWeb)),
                      Container(width: 1, height: isWeb ? 32 : 24, color: kBorder),
                      Expanded(child: _buildInfoItem('Withdrawals', controller.formatAmount(account.withdrawals), Icons.remove_circle, isWeb)),
                    ],
                  ),
                ),
                SizedBox(height: isWeb ? 8 : 6),
                Container(
                  padding: EdgeInsets.symmetric(vertical: isWeb ? 10 : 8),
                  child: Row(
                    children: [
                      Expanded(child: _buildInfoItem('Current Balance', controller.formatAmount(account.currentBalance), Icons.attach_money, isWeb)),
                      Container(width: 1, height: isWeb ? 32 : 24, color: kBorder),
                      Expanded(child: _buildInfoItem('Last Updated', DateFormat('dd MMM yyyy').format(account.lastUpdated), Icons.calendar_today, isWeb)),
                    ],
                  ),
                ),
                if (account.notes.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: isWeb ? 8 : 6),
                    child: Container(
                      padding: EdgeInsets.all(isWeb ? 12 : 10),
                      decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(isWeb ? 10 : 8)),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: isWeb ? 18 : 14, color: kSubText),
                          SizedBox(width: isWeb ? 8 : 6),
                          Expanded(child: Text(account.notes, style: TextStyle(fontSize: isWeb ? 12 : 11, color: kSubText))),
                        ],
                      ),
                    ),
                  ),
                SizedBox(height: isWeb ? 16 : 12),
                Row(
                  children: [
                    if (account.accountType == 'Capital')
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => controller.showAddCapitalDialog(account),
                          icon: Icon(Icons.add_circle, size: isWeb ? 18 : 14, color: kSuccess),
                          label: Text('Add Capital', style: TextStyle(fontSize: isWeb ? 12 : 10, color: kSuccess)),
                          style: _buttonStyle(kSuccess, isWeb),
                        ),
                      ),
                    if (account.accountType == 'Drawings')
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => controller.showRecordDrawingsDialog(account),
                          icon: Icon(Icons.remove_circle, size: isWeb ? 18 : 14, color: kDanger),
                          label: Text('Record Drawings', style: TextStyle(fontSize: isWeb ? 12 : 10, color: kDanger)),
                          style: _buttonStyle(kDanger, isWeb),
                        ),
                      ),
                    if (account.accountType == 'Retained Earnings' || account.accountType == 'Reserves')
                      SizedBox(width: isWeb ? 12 : 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => controller.showTransactionHistory(account),
                        icon: Icon(Icons.history, size: isWeb ? 18 : 14, color: kPrimary),
                        label: Text('History', style: TextStyle(fontSize: isWeb ? 12 : 10, color: kPrimary)),
                        style: _buttonStyle(kPrimary, isWeb),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
              Text(label, style: TextStyle(fontSize: isWeb ? 11 : 9, color: kSubText)),
              Text(value, style: TextStyle(fontSize: isWeb ? 11 : 9, fontWeight: FontWeight.w600, color: kText), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

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
      padding: EdgeInsets.all(isWeb ? 20 : 12),
      itemCount: controller.transactions.length,
      itemBuilder: (context, index) {
        final transaction = controller.transactions[index];
        return Padding(
          padding: EdgeInsets.only(bottom: isWeb ? 12 : 8),
          child: _buildTransactionCard(controller, transaction, context),
        );
      },
    );
  }

  Widget _buildTransactionCard(EquityController controller, OwnerTransaction transaction, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final isMobile = ResponsiveUtils.isMobile(context);
    
    Color typeColor = transaction.type == 'Additional Capital' ? kSuccess :
                      transaction.type == 'Retained Earnings' ? kPrimary :
                      transaction.type == 'Reserve Transfer' ? kWarning : kDanger;
    
    IconData typeIcon = transaction.type == 'Additional Capital' ? Icons.add_circle :
                        transaction.type == 'Retained Earnings' ? Icons.trending_up :
                        transaction.type == 'Reserve Transfer' ? Icons.swap_horiz : Icons.remove_circle;
    
    return Container(
      margin: EdgeInsets.only(bottom: isWeb ? 12 : 8),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(isWeb ? 14 : 10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Container(
        padding: EdgeInsets.all(isWeb ? 16 : 12),
        child: isMobile
            ? _buildMobileTransactionCard(controller, transaction, typeColor, typeIcon, context)
            : _buildDesktopTransactionCard(controller, transaction, typeColor, typeIcon, context),
      ),
    );
  }

  Widget _buildDesktopTransactionCard(EquityController controller, OwnerTransaction transaction, Color typeColor, IconData typeIcon, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Row(
      children: [
        Container(
          width: isWeb ? 50 : 44,
          height: isWeb ? 50 : 44,
          decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(isWeb ? 12 : 10)),
          child: Icon(typeIcon, size: isWeb ? 24 : 20, color: typeColor),
        ),
        SizedBox(width: isWeb ? 16 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(transaction.type, style: TextStyle(fontSize: isWeb ? 14 : 12, fontWeight: FontWeight.w700, color: kText)),
                  SizedBox(width: isWeb ? 8 : 6),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: isWeb ? 8 : 6, vertical: isWeb ? 4 : 2),
                    decoration: BoxDecoration(color: kSuccess.withOpacity(0.1), borderRadius: BorderRadius.circular(isWeb ? 6 : 4)),
                    child: Text(transaction.status, style: TextStyle(fontSize: isWeb ? 11 : 10, color: kSuccess, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              SizedBox(height: isWeb ? 4 : 2),
              Text(transaction.accountName, style: TextStyle(fontSize: isWeb ? 12 : 11, color: kSubText)),
              SizedBox(height: isWeb ? 4 : 2),
              Text(transaction.description, style: TextStyle(fontSize: isWeb ? 12 : 11, color: kSubText)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(controller.formatAmount(transaction.amount), style: TextStyle(fontSize: isWeb ? 16 : 14, fontWeight: FontWeight.w800, color: typeColor)),
            SizedBox(height: isWeb ? 4 : 2),
            Text(DateFormat('dd MMM yyyy').format(transaction.date), style: TextStyle(fontSize: isWeb ? 12 : 11, color: kSubText)),
            Text('Ref: ${transaction.reference}', style: TextStyle(fontSize: isWeb ? 12 : 11, color: kSubText)),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileTransactionCard(EquityController controller, OwnerTransaction transaction, Color typeColor, IconData typeIcon, BuildContext context) {
    return Column(
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
                  Text(transaction.type, style:  TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kText)),
                  Text(transaction.accountName, style:  TextStyle(fontSize: 10, color: kSubText)),
                ],
              ),
            ),
            Text(controller.formatAmount(transaction.amount), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: typeColor)),
          ],
        ),
        const SizedBox(height: 6),
        Text(transaction.description, style:  TextStyle(fontSize: 10, color: kSubText)),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('dd MMM yyyy').format(transaction.date), style:  TextStyle(fontSize: 9, color: kSubText)),
            Text('Ref: ${transaction.reference}', style:  TextStyle(fontSize: 9, color: kSubText)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: kSuccess.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(transaction.status, style: TextStyle(fontSize: 8, color: kSuccess, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ],
    );
  }

  ButtonStyle _buttonStyle(Color color, bool isWeb) {
    return OutlinedButton.styleFrom(
      foregroundColor: color,
      side: BorderSide(color: color),
      padding: EdgeInsets.symmetric(vertical: isWeb ? 10 : 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isWeb ? 8 : 6)),
    );
  }
}