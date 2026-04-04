import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/core/CapitalEquity/controller/equity_controller.dart';
import 'package:LedgerPro_app/core/CapitalEquity/models/equity_model.dart';
import 'package:LedgerPro_app/core/chartofaccounts/screens/chart_of_account_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';

class CapitalEquityScreen extends StatelessWidget {
  const CapitalEquityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EquityController());

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
                Text('Loading equity accounts...', style: TextStyle(fontSize: 14.sp, color: kSubText)),
              ],
            ),
          );
        }
        return Column(
          children: [
            _buildSummaryCards(controller),
            _buildFilterBar(controller),
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    Container(
                      color: kCardBg,
                      child: TabBar(
                        tabs: [
                          Tab(text: 'Equity Accounts', icon: Icon(Icons.account_balance, size: 4.w)),
                          Tab(text: 'Transaction History', icon: Icon(Icons.history, size: 4.w)),
                        ],
                        labelColor: kPrimary,
                        unselectedLabelColor: kSubText,
                        indicatorColor: kPrimary,
                        labelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildEquityAccountsList(controller),
                          _buildTransactionHistory(controller),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
      floatingActionButton: _buildFAB(controller),
    );
  }

  PreferredSizeWidget _buildAppBar(EquityController controller) {
    return AppBar(
      title: Text('Capital & Equity', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: Colors.white)),
      backgroundColor: kPrimary,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(Icons.calculate_outlined, color: Colors.white, size: 5.w),
          onPressed: () => controller.calculateEquity(),
        ),
        IconButton(
          icon: Icon(Icons.download_outlined, color: Colors.white, size: 5.w),
          onPressed: () => controller.exportEquity(),
        ),
        IconButton(
          icon: Icon(Icons.print_outlined, color: Colors.white, size: 5.w),
          onPressed: () => controller.printEquity(),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(EquityController controller) {
    return Obx(() => Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildSummaryCard('Total Capital', controller.formatAmount(controller.totalCapital.value), kPrimary, Icons.account_balance, 28.w),
            SizedBox(width: 2.w),
            _buildSummaryCard('Retained Earnings', controller.formatAmount(controller.totalRetainedEarnings.value), kSuccess, Icons.trending_up, 30.w),
            SizedBox(width: 2.w),
            _buildSummaryCard('Reserves', controller.formatAmount(controller.totalReserves.value), kWarning, Icons.savings, 25.w),
            SizedBox(width: 2.w),
            _buildSummaryCard('Drawings', controller.formatAmount(controller.totalDrawings.value), kDanger, Icons.remove_circle, 25.w),
            SizedBox(width: 2.w),
            _buildSummaryCard('Total Equity', controller.formatAmount(controller.totalEquity.value), kPrimary, Icons.account_balance_wallet, 28.w),
          ],
        ),
      ),
    ));
  }

  Widget _buildSummaryCard(String title, String amount, Color color, IconData icon, double width) {
    return Container(
      width: width,
      padding: EdgeInsets.all(2.5.w),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 4.5.w, color: color),
              SizedBox(width: 1.5.w),
              Expanded(child: Text(title, style: TextStyle(fontSize: 12.sp, color: kSubText, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ),
          SizedBox(height: 1.h),
          Text(amount, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildFilterBar(EquityController controller) {
    return Container(
      width: 100.w,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      color: kCardBg,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              height: 6.h,
              decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
              child: TextField(
                controller: controller.searchController,
                style: TextStyle(fontSize: 14.sp, color: kText),
                decoration: InputDecoration(
                  hintText: 'Search by account name or code...',
                  hintStyle: TextStyle(fontSize: 12.sp, color: kSubText),
                  prefixIcon: Icon(Icons.search, size: 5.w, color: kSubText),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 1.8.h),
                ),
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            flex: 2,
            child: Container(
              height: 6.h,
              decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
              child: Obx(() => DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.selectedFilter.value,
                  icon: Icon(Icons.arrow_drop_down, size: 5.w, color: kText),
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  isExpanded: true,
                  style: TextStyle(fontSize: 14.sp, color: kText),
                  dropdownColor: kCardBg,
                  items: controller.filterOptions.map((filter) {
                    return DropdownMenuItem(value: filter, child: Text(filter, style: TextStyle(color: kText)));
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

  Widget _buildEquityAccountsList(EquityController controller) {
    if (controller.equityAccounts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_outlined, size: 15.w, color: kSubText.withOpacity(0.5)),
            SizedBox(height: 2.h),
            Text('No equity accounts found', style: TextStyle(fontSize: 14.sp, color: kSubText, fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: controller.equityAccounts.length,
      itemBuilder: (context, index) {
        final account = controller.equityAccounts[index];
        return _buildEquityCard(controller, account);
      },
    );
  }

  Widget _buildEquityCard(EquityController controller, EquityAccount account) {
    Color typeColor = account.accountType == 'Capital' ? kPrimary :
                      account.accountType == 'Retained Earnings' ? kSuccess :
                      account.accountType == 'Reserves' ? kWarning : kDanger;
    
    IconData typeIcon = account.accountType == 'Capital' ? Icons.account_balance :
                        account.accountType == 'Retained Earnings' ? Icons.trending_up :
                        account.accountType == 'Reserves' ? Icons.savings : Icons.remove_circle;
    
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.showAccountDetails(account),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 14.w,
                      height: 14.w,
                      decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                      child: Icon(typeIcon, size: 12.w, color: typeColor),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(account.accountName, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: kText))),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                                decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                child: Text(account.accountType, style: TextStyle(fontSize: 12.sp, color: typeColor, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          SizedBox(height: 0.5.h),
                          Text(account.accountCode, style: TextStyle(fontSize: 12.sp, color: kSubText)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Balance', style: TextStyle(fontSize: 12.sp, color: kSubText, fontWeight: FontWeight.w500)),
                        SizedBox(height: 0.5.h),
                        Text(controller.formatAmount(account.currentBalance), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: typeColor)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 1.h),
                  child: Row(
                    children: [
                      Expanded(child: _buildInfoItem('Opening Balance', controller.formatAmount(account.openingBalance), Icons.account_balance)),
                      Container(width: 1, height: 4.h, color: kBorder),
                      Expanded(child: _buildInfoItem('Additions', controller.formatAmount(account.additions), Icons.add_circle)),
                      Container(width: 1, height: 4.h, color: kBorder),
                      Expanded(child: _buildInfoItem('Withdrawals', controller.formatAmount(account.withdrawals), Icons.remove_circle)),
                    ],
                  ),
                ),
                SizedBox(height: 1.h),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 1.h),
                  child: Row(
                    children: [
                      Expanded(child: _buildInfoItem('Current Balance', controller.formatAmount(account.currentBalance), Icons.attach_money)),
                      Container(width: 1, height: 4.h, color: kBorder),
                      Expanded(child: _buildInfoItem('Last Updated', DateFormat('dd MMM yyyy').format(account.lastUpdated), Icons.calendar_today)),
                    ],
                  ),
                ),
                if (account.notes.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 1.h),
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 4.w, color: kSubText),
                          SizedBox(width: 2.w),
                          Expanded(child: Text(account.notes, style: TextStyle(fontSize: 12.sp, color: kSubText))),
                        ],
                      ),
                    ),
                  ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    if (account.accountType == 'Capital')
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => controller.showAddCapitalDialog(account),
                          icon: Icon(Icons.add_circle, size: 4.w, color: kSuccess),
                          label: Text('Add Capital', style: TextStyle(fontSize: 12.sp, color: kSuccess)),
                          style: OutlinedButton.styleFrom(side: BorderSide(color: kSuccess, width: 1), padding: EdgeInsets.symmetric(vertical: 1.2.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        ),
                      ),
                    if (account.accountType == 'Drawings')
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => controller.showRecordDrawingsDialog(account),
                          icon: Icon(Icons.remove_circle, size: 4.w, color: kDanger),
                          label: Text('Record Drawings', style: TextStyle(fontSize: 12.sp, color: kDanger)),
                          style: OutlinedButton.styleFrom(side: BorderSide(color: kDanger, width: 1), padding: EdgeInsets.symmetric(vertical: 1.2.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        ),
                      ),
                    if (account.accountType == 'Retained Earnings' || account.accountType == 'Reserves')
                      SizedBox(width: 3.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => controller.showTransactionHistory(account),
                        icon: Icon(Icons.history, size: 4.w, color: kPrimary),
                        label: Text('History', style: TextStyle(fontSize: 12.sp, color: kPrimary)),
                        style: OutlinedButton.styleFrom(side: BorderSide(color: kPrimary, width: 1), padding: EdgeInsets.symmetric(vertical: 1.2.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
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

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 3.5.w, color: kSubText),
        SizedBox(width: 1.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12.sp, color: kSubText)),
              Text(value, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: kText), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionHistory(EquityController controller) {
    if (controller.transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 15.w, color: kSubText.withOpacity(0.5)),
            SizedBox(height: 2.h),
            Text('No transactions found', style: TextStyle(fontSize: 14.sp, color: kSubText, fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: controller.transactions.length,
      itemBuilder: (context, index) {
        final transaction = controller.transactions[index];
        return _buildTransactionCard(controller, transaction);
      },
    );
  }

  Widget _buildTransactionCard(EquityController controller, OwnerTransaction transaction) {
    Color typeColor = transaction.type == 'Additional Capital' ? kSuccess :
                      transaction.type == 'Retained Earnings' ? kPrimary :
                      transaction.type == 'Reserve Transfer' ? kWarning : kDanger;
    
    IconData typeIcon = transaction.type == 'Additional Capital' ? Icons.add_circle :
                        transaction.type == 'Retained Earnings' ? Icons.trending_up :
                        transaction.type == 'Reserve Transfer' ? Icons.swap_horiz : Icons.remove_circle;
    
    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Container(
        padding: EdgeInsets.all(3.w),
        child: Row(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(typeIcon, size: 6.w, color: typeColor),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(transaction.type, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: kText)),
                      SizedBox(width: 2.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.3.h),
                        decoration: BoxDecoration(color: kSuccess.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text(transaction.status, style: TextStyle(fontSize: 12.sp, color: kSuccess, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.3.h),
                  Text(transaction.accountName, style: TextStyle(fontSize: 11.sp, color: kSubText)),
                  SizedBox(height: 0.3.h),
                  Text(transaction.description, style: TextStyle(fontSize: 12.sp, color: kSubText)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(controller.formatAmount(transaction.amount), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: typeColor)),
                SizedBox(height: 0.3.h),
                Text(DateFormat('dd MMM yyyy').format(transaction.date), style: TextStyle(fontSize: 12.sp, color: kSubText)),
                Text('Ref: ${transaction.reference}', style: TextStyle(fontSize: 12.sp, color: kSubText)),
              ],
            ),
          ],
        ),
      ),
    );
  }
Widget _buildFAB(EquityController controller) {
  return FloatingActionButton(
    onPressed: () {
      // Check if any equity account exists
      if (controller.equityAccounts.isEmpty) {
        Get.snackbar(
          'No Equity Account',
          'Please add an Equity account from Chart of Accounts first',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: kWarning,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        Get.to(() => ChartOfAccountsScreen());
      } else {
        controller.showAddTransactionDialog();
      }
    },
    backgroundColor: kPrimary,
    child: Icon(Icons.add, color: Colors.white, size: 6.w),
    elevation: 3,
  );
}
}