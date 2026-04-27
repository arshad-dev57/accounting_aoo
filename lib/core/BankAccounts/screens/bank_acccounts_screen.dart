import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/Utils/responsive_utils.dart';
import 'package:LedgerPro_app/core/BankAccounts/controllers/bankaccount_controller.dart';
import 'package:LedgerPro_app/core/BankReconciliation/screens/bank_reconciliation_screen.dart';
import 'package:LedgerPro_app/core/GeneralLedger/Screen/general_ledger_screen.dart';
import 'package:LedgerPro_app/core/Transfer/screen/transfer_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class BankAccountsScreen extends StatelessWidget {
  const BankAccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BankAccountController());

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
              _buildSummaryCards(controller, context),
              _buildFilterBar(controller, context),
              _buildBankAccountsList(controller, context),
              const SizedBox(height: 20), // Add bottom padding
            ],
          ),
        );
      }),
    );
  }

  // Custom Header without AppBar
  Widget _buildHeader(BankAccountController controller, BuildContext context) {
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
                  'Bank Accounts',
                  style: TextStyle(
                    fontSize: isWeb ? 20 : 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage all your bank accounts',
                  style: TextStyle(
                    fontSize: isWeb ? 13 : 11,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          // Add Account Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.add, color: Colors.white, size: isWeb ? 22 : 20),
              onPressed: () => _showAddAccountDialog(Get.context!, controller, context),
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
              onPressed: () => controller.exportAccounts(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BankAccountController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Obx(() {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 16 : 12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildSummaryCard(
                'Total Balance',
                _formatCompactAmount(controller.totalBalance.value),
                kSuccess,
                Icons.account_balance,
                context,
              ),
              SizedBox(width: isWeb ? 16 : 12),
              _buildSummaryCard(
                'PKR Balance',
                _formatCompactAmount(controller.totalPKR.value),
                kPrimary,
                Icons.currency_rupee,
                context,
              ),
              SizedBox(width: isWeb ? 16 : 12),
              _buildSummaryCard(
                'USD Balance',
                _formatCompactAmount(controller.totalUSD.value),
                kWarning,
                Icons.attach_money,
                context,
                suffix: ' USD',
              ),
              SizedBox(width: isWeb ? 16 : 12),
              _buildSummaryCard(
                'Active Accounts',
                controller.activeCount.value.toString(),
                kPrimary,
                Icons.account_balance_wallet,
                context,
                isNumber: true,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSummaryCard(
    String title,
    String amount,
    Color color,
    IconData icon,
    BuildContext context, {
    String? suffix,
    bool isNumber = false,
  }) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Container(
      width: isWeb ? 220 : 160,
      padding: EdgeInsets.all(isWeb ? 16 : 12),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: isWeb ? 24 : 20, color: color),
              SizedBox(width: isWeb ? 8 : 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isWeb ? 12 : 11,
                    color: kSubText,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: isWeb ? 8 : 6),
          Text(
            isNumber ? amount : '$amount${suffix ?? ''}',
            style: TextStyle(
              fontSize: isWeb ? 18 : 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BankAccountController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final List<String> filterOptions = ['All', 'Active', 'Inactive'];

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
              decoration: BoxDecoration(
                color: kBg,
                borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
                border: Border.all(color: kBorder),
              ),
              child: TextField(
                onChanged: (value) => controller.searchAccounts(value),
                style: TextStyle(fontSize: isWeb ? 14 : 12),
                decoration: InputDecoration(
                  hintText: isWeb ? 'Search by name, bank, or account number...' : 'Search...',
                  hintStyle: TextStyle(fontSize: isWeb ? 12 : 11, color: kSubText),
                  prefixIcon: Icon(Icons.search, size: isWeb ? 20 : 18),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: isWeb ? 12 : 10),
                ),
              ),
            ),
          ),
          SizedBox(width: isWeb ? 16 : 12),
          Container(
            width: isWeb ? 180 : 130,
            height: isWeb ? 45 : 40,
            padding: EdgeInsets.symmetric(horizontal: isWeb ? 12 : 8),
            decoration: BoxDecoration(
              color: kBg,
              borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
              border: Border.all(color: kBorder),
            ),
            child: DropdownButtonHideUnderline(
              child: Obx(() => DropdownButton<String>(
                value: controller.selectedFilter.value,
                icon: Icon(Icons.arrow_drop_down, size: isWeb ? 24 : 20),
                isExpanded: true,
                style: TextStyle(
                  fontSize: isWeb ? 13 : 12,
                  color: kText,
                  fontWeight: FontWeight.w500,
                ),
                items: filterOptions.map((filter) {
                  return DropdownMenuItem(
                    value: filter,
                    child: Text(filter),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) controller.changeFilter(value);
                },
              )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankAccountsList(BankAccountController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Obx(() {
      final accounts = controller.bankAccounts;

      if (accounts.isEmpty) {
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
                  'No bank accounts found',
                  style: TextStyle(
                    fontSize: isWeb ? 18 : 16,
                    color: kSubText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: isWeb ? 20 : 16),
                ElevatedButton(
                  onPressed: () => _showAddAccountDialog(Get.context!, controller, context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 12 : 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
                    ),
                  ),
                  child: Text(
                    'Add Bank Account',
                    style: TextStyle(
                      fontSize: isWeb ? 14 : 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Header for the accounts list
      return Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 12 : 8),
            child: Text(
              'Bank Accounts',
              style: TextStyle(
                fontSize: isWeb ? 18 : 16,
                fontWeight: FontWeight.w700,
                color: kText,
              ),
            ),
          ),
          ...accounts.map((account) => Padding(
            padding: EdgeInsets.symmetric(horizontal: isWeb ? 20 : 12, vertical: isWeb ? 8 : 6),
            child: _buildAccountCard(account, controller, context),
          )).toList(),
        ],
      );
    });
  }

  Widget _buildAccountCard(BankAccount account, BankAccountController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final isMobile = ResponsiveUtils.isMobile(context);
    
    return Container(
      margin: EdgeInsets.only(bottom: isWeb ? 12 : 8),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showAccountDetails(account, controller, context),
          borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
          child: Padding(
            padding: EdgeInsets.all(isWeb ? 16 : 12),
            child: isMobile
                ? _buildMobileAccountCard(account, controller, context)
                : _buildDesktopAccountCard(account, controller, context),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopAccountCard(BankAccount account, BankAccountController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: isWeb ? 50 : 44,
              height: isWeb ? 50 : 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [account.color, account.color.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
              ),
              child: Center(
                child: Icon(
                  Icons.account_balance,
                  size: isWeb ? 24 : 20,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: isWeb ? 16 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    account.accountName,
                    style: TextStyle(
                      fontSize: isWeb ? 15 : 13,
                      fontWeight: FontWeight.w800,
                      color: kText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isWeb ? 4 : 2),
                  Text(
                    '${account.bankName} • ${account.accountNumber}',
                    style: TextStyle(
                      fontSize: isWeb ? 12 : 10,
                      color: kSubText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isWeb ? 8 : 6),
                  Wrap(
                    spacing: isWeb ? 8 : 6,
                    runSpacing: isWeb ? 4 : 2,
                    children: [
                      _buildStatusBadge(account.status, context),
                      _buildInfoBadge(account.accountType, context),
                      _buildInfoBadge(account.currency, context),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Balance',
                  style: TextStyle(
                    fontSize: isWeb ? 11 : 10,
                    color: kSubText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: isWeb ? 4 : 2),
                Text(
                  _formatAmount(account.currentBalance),
                  style: TextStyle(
                    fontSize: isWeb ? 16 : 14,
                    fontWeight: FontWeight.w800,
                    color: account.currentBalance >= 0 ? kSuccess : kDanger,
                  ),
                ),
                SizedBox(height: isWeb ? 2 : 1),
                Text(
                  'Last: ${DateFormat('dd MMM').format(account.lastReconciled)}',
                  style: TextStyle(
                    fontSize: isWeb ? 10 : 8,
                    color: kSubText,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: isWeb ? 12 : 8),
        Container(
          height: isWeb ? 4 : 3,
          width: double.infinity,
          decoration: BoxDecoration(
            color: kBg,
            borderRadius: BorderRadius.circular(isWeb ? 4 : 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isWeb ? 4 : 2),
            child: LinearProgressIndicator(
              value: account.openingBalance > 0
                  ? (account.currentBalance / (account.openingBalance * 2)).clamp(0.0, 1.0)
                  : 0.5,
              backgroundColor: kBg,
              valueColor: AlwaysStoppedAnimation<Color>(account.color),
              minHeight: isWeb ? 4 : 3,
            ),
          ),
        ),
        SizedBox(height: isWeb ? 8 : 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Opening: ${_formatAmount(account.openingBalance)}',
              style: TextStyle(
                fontSize: isWeb ? 11 : 9,
                color: kSubText,
              ),
            ),
            Text(
              'Current: ${_formatAmount(account.currentBalance)}',
              style: TextStyle(
                fontSize: isWeb ? 11 : 9,
                color: account.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: isWeb ? 12 : 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Get.to(() => const BankReconciliationScreen());
                },
                icon: Icon(Icons.sync, size: isWeb ? 18 : 14),
                label: Text('Reconcile', style: TextStyle(fontSize: isWeb ? 12 : 10)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kPrimary,
                  side: BorderSide(color: kPrimary, width: 1),
                  padding: EdgeInsets.symmetric(vertical: isWeb ? 10 : 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isWeb ? 8 : 6),
                  ),
                ),
              ),
            ),
            SizedBox(width: isWeb ? 12 : 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Get.to(() => const GeneralLedgerScreen());
                },
                icon: Icon(Icons.history, size: isWeb ? 18 : 14),
                label: Text('History', style: TextStyle(fontSize: isWeb ? 12 : 10)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kSubText,
                  side: BorderSide(color: kBorder, width: 1),
                  padding: EdgeInsets.symmetric(vertical: isWeb ? 10 : 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isWeb ? 8 : 6),
                  ),
                ),
              ),
            ),
            SizedBox(width: isWeb ? 12 : 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.to(() => const TransferScreen());
                },
                icon: Icon(Icons.swap_horiz, size: isWeb ? 18 : 14, color: Colors.white),
                label: Text('Transfer', style: TextStyle(fontSize: isWeb ? 12 : 10)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: account.color,
                  padding: EdgeInsets.symmetric(vertical: isWeb ? 10 : 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isWeb ? 8 : 6),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileAccountCard(BankAccount account, BankAccountController controller, BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [account.color, account.color.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(Icons.account_balance, size: 20, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    account.accountName,
                    style:  TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: kText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${account.bankName} • ${account.accountNumber}',
                    style:  TextStyle(fontSize: 10, color: kSubText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 2,
                    children: [
                      _buildStatusBadge(account.status, context),
                      _buildInfoBadge(account.accountType, context),
                      _buildInfoBadge(account.currency, context),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Balance',
                  style:  TextStyle(fontSize: 9, color: kSubText, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatCompactAmount(account.currentBalance),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: account.currentBalance >= 0 ? kSuccess : kDanger,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Get.to(() => const BankReconciliationScreen());
                },
                icon: Icon(Icons.sync, size: 14),
                label: const Text('Reconcile', style: TextStyle(fontSize: 9)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kPrimary,
                  side: const BorderSide(color: kPrimary, width: 1),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Get.to(() => const GeneralLedgerScreen());
                },
                icon: Icon(Icons.history, size: 14),
                label: const Text('History', style: TextStyle(fontSize: 9)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kSubText,
                  side: BorderSide(color: kBorder, width: 1),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.to(() => const TransferScreen());
                },
                icon: Icon(Icons.swap_horiz, size: 14, color: Colors.white),
                label: const Text('Transfer', style: TextStyle(fontSize: 9)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: account.color,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    Color color = status == 'Active' ? kSuccess : kDanger;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWeb ? 8 : 6, vertical: isWeb ? 4 : 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isWeb ? 6 : 4),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: isWeb ? 10 : 8,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoBadge(String text, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWeb ? 8 : 6, vertical: isWeb ? 4 : 2),
      decoration: BoxDecoration(
        color: kBg,
        borderRadius: BorderRadius.circular(isWeb ? 6 : 4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isWeb ? 10 : 8,
          color: kSubText,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showAddAccountDialog(BuildContext context, BankAccountController controller, BuildContext ctx) {
    final isWeb = ResponsiveUtils.isWeb(ctx);
    final formKey = GlobalKey<FormState>();
    String accountName = '';
    String accountNumber = '';
    String bankName = '';
    String branchCode = '';
    String accountType = 'Current';
    String currency = 'PKR';
    double openingBalance = 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              width: isWeb ? 500 : double.infinity,
              constraints: BoxConstraints(maxHeight: isWeb ? 700 : 600),
              padding: EdgeInsets.all(isWeb ? 24 : 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Add Bank Account',
                    style: TextStyle(
                      fontSize: isWeb ? 20 : 18,
                      fontWeight: FontWeight.w800,
                      color: kText,
                    ),
                  ),
                  SizedBox(height: isWeb ? 20 : 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Account Name *',
                                hintText: 'e.g., HBL Current Account',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelStyle: TextStyle(fontSize: isWeb ? 12 : 11),
                              ),
                              style: TextStyle(fontSize: isWeb ? 13 : 12),
                              onChanged: (value) => accountName = value,
                              validator: (value) => value == null || value.isEmpty
                                  ? 'Account name required'
                                  : null,
                            ),
                            SizedBox(height: isWeb ? 16 : 12),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Account Number *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelStyle: TextStyle(fontSize: isWeb ? 12 : 11),
                              ),
                              style: TextStyle(fontSize: isWeb ? 13 : 12),
                              onChanged: (value) => accountNumber = value,
                              validator: (value) => value == null || value.isEmpty
                                  ? 'Account number required'
                                  : null,
                            ),
                            SizedBox(height: isWeb ? 16 : 12),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Bank Name *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelStyle: TextStyle(fontSize: isWeb ? 12 : 11),
                              ),
                              style: TextStyle(fontSize: isWeb ? 13 : 12),
                              onChanged: (value) => bankName = value,
                              validator: (value) => value == null || value.isEmpty
                                  ? 'Bank name required'
                                  : null,
                            ),
                            SizedBox(height: isWeb ? 16 : 12),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Branch Code',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelStyle: TextStyle(fontSize: isWeb ? 12 : 11),
                              ),
                              style: TextStyle(fontSize: isWeb ? 13 : 12),
                              onChanged: (value) => branchCode = value,
                            ),
                            SizedBox(height: isWeb ? 16 : 12),
                            DropdownButtonFormField<String>(
                              value: accountType,
                              decoration: InputDecoration(
                                labelText: 'Account Type',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelStyle: TextStyle(fontSize: isWeb ? 12 : 11),
                              ),
                              style: TextStyle(fontSize: isWeb ? 13 : 12),
                              items: const [
                                DropdownMenuItem(value: 'Current', child: Text('Current', style: TextStyle(color: Colors.black))),
                                DropdownMenuItem(value: 'Savings', child: Text('Savings', style: TextStyle(color: Colors.black))),
                                DropdownMenuItem(value: 'Business', child: Text('Business', style: TextStyle(color: Colors.black))),
                                DropdownMenuItem(value: 'Islamic', child: Text('Islamic', style: TextStyle(color: Colors.black))),
                              ],
                              onChanged: (value) => accountType = value!,
                            ),
                            SizedBox(height: isWeb ? 16 : 12),
                            DropdownButtonFormField<String>(
                              value: currency,
                              decoration: InputDecoration(
                                labelText: 'Currency',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelStyle: TextStyle(fontSize: isWeb ? 12 : 11),
                              ),
                              style: TextStyle(fontSize: isWeb ? 13 : 12),
                              items: const [
                                DropdownMenuItem(value: 'PKR', child: Text('PKR - Pakistani Rupee', style: TextStyle(color: Colors.black))),
                                DropdownMenuItem(value: 'USD', child: Text('USD - US Dollar', style: TextStyle(color: Colors.black))),
                                DropdownMenuItem(value: 'EUR', child: Text('EUR - Euro', style: TextStyle(color: Colors.black))),
                                DropdownMenuItem(value: 'GBP', child: Text('GBP - British Pound', style: TextStyle(color: Colors.black))),
                              ],
                              onChanged: (value) => currency = value!,
                            ),
                            SizedBox(height: isWeb ? 16 : 12),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Opening Balance',
                                hintText: '0.00',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixText: '₨ ',
                                labelStyle: TextStyle(fontSize: isWeb ? 12 : 11),
                              ),
                              style: TextStyle(fontSize: isWeb ? 13 : 12),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                openingBalance = double.tryParse(value) ?? 0;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isWeb ? 20 : 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: isWeb ? 12 : 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('Cancel', style: TextStyle(fontSize: isWeb ? 14 : 12)),
                        ),
                      ),
                      SizedBox(width: isWeb ? 16 : 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              Navigator.pop(context);
                              controller.createBankAccount({
                                'accountName': accountName,
                                'accountNumber': accountNumber,
                                'bankName': bankName,
                                'branchCode': branchCode,
                                'accountType': accountType,
                                'currency': currency,
                                'openingBalance': openingBalance,
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimary,
                            padding: EdgeInsets.symmetric(vertical: isWeb ? 12 : 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('Add Account', style: TextStyle(fontSize: isWeb ? 14 : 12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAccountDetails(BankAccount account, BankAccountController controller, BuildContext context) {
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => Container(
          padding: const EdgeInsets.all(20),
          child: _buildAccountDetailsContent(account, controller, ctx),
        ),
      );
    }
  }

  Widget _buildAccountDetailsContent(BankAccount account, BankAccountController controller, BuildContext ctx) {
    final isWeb = ResponsiveUtils.isWeb(ctx);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: isWeb ? 60 : 50,
              height: isWeb ? 60 : 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [account.color, account.color.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(isWeb ? 14 : 10),
              ),
              child: Center(
                child: Icon(Icons.account_balance, size: isWeb ? 28 : 24, color: Colors.white),
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
                      fontSize: isWeb ? 18 : 16,
                      fontWeight: FontWeight.w800,
                      color: kText,
                    ),
                  ),
                  Text(
                    account.accountNumber,
                    style: TextStyle(
                      fontSize: isWeb ? 14 : 12,
                      color: kSubText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: isWeb ? 20 : 16),
        Container(
          padding: EdgeInsets.all(isWeb ? 16 : 12),
          decoration: BoxDecoration(
            color: kBg,
            borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
          ),
          child: Column(
            children: [
              _buildDetailRow('Bank Name', account.bankName, ctx),
              SizedBox(height: isWeb ? 12 : 8),
              _buildDetailRow('Branch Code', account.branchCode, ctx),
              SizedBox(height: isWeb ? 12 : 8),
              _buildDetailRow('Account Type', account.accountType, ctx),
              SizedBox(height: isWeb ? 12 : 8),
              _buildDetailRow('Currency', account.currency, ctx),
              SizedBox(height: isWeb ? 12 : 8),
              _buildDetailRow('Opening Balance', _formatAmount(account.openingBalance), ctx),
              SizedBox(height: isWeb ? 12 : 8),
              _buildDetailRow('Current Balance', _formatAmount(account.currentBalance), ctx),
              SizedBox(height: isWeb ? 12 : 8),
              _buildDetailRow('Status', account.status, ctx),
              SizedBox(height: isWeb ? 12 : 8),
              _buildDetailRow('Last Reconciled', DateFormat('dd MMM yyyy').format(account.lastReconciled), ctx),
            ],
          ),
        ),
        SizedBox(height: isWeb ? 20 : 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  Get.to(() => const BankReconciliationScreen());
                },
                icon: Icon(Icons.sync, size: isWeb ? 20 : 16),
                label: Text('Reconcile', style: TextStyle(fontSize: isWeb ? 14 : 12)),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: isWeb ? 12 : 10),
                ),
              ),
            ),
            SizedBox(width: isWeb ? 12 : 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  Get.to(() => const GeneralLedgerScreen());
                },
                icon: Icon(Icons.history, size: isWeb ? 20 : 16),
                label: Text('View History', style: TextStyle(fontSize: isWeb ? 14 : 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: account.color,
                  padding: EdgeInsets.symmetric(vertical: isWeb ? 12 : 10),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isWeb ? 13 : 11,
            color: kSubText,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isWeb ? 13 : 11,
            color: kText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatCompactAmount(double amount) {
    if (amount >= 10000000) {
      return '₨ ${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '₨ ${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '₨ ${(amount / 1000).toStringAsFixed(0)}K';
    }
    return '₨ ${amount.toStringAsFixed(0)}';
  }

  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '₨ ${formatter.format(amount)}';
  }
}