import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/Utils/responsive_utils.dart';
import 'package:LedgerPro_app/core/BankAccounts/controllers/bankaccount_controller.dart';
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

    // ✅ Material wrapper - exactly like General Ledger
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
              _buildSummaryCards(controller, context),
              _buildFilterBar(controller, context),
              _buildBankAccountsList(controller, context),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  // ─────────────────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────────────────
  Widget _buildHeader(BankAccountController controller, BuildContext context) {
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
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _headerIconBtn(
            icon: Icons.add,
            size: isWeb ? 22 : 20,
            onTap: () => _showAddAccountDialog(Get.context!, controller, context),
          ),
          const SizedBox(width: 8),
          _headerIconBtn(
            icon: Icons.download_outlined,
            size: isWeb ? 22 : 20,
            onTap: () => controller.exportAccounts(),
          ),
        ],
      ),
    );
  }

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

  // ─────────────────────────────────────────────────────────
  // SUMMARY CARDS
  // ─────────────────────────────────────────────────────────
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
                '\$ Balance',
                _formatCompactAmount(controller.total$.value),
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

  // ─────────────────────────────────────────────────────────
  // FILTER BAR
  // ─────────────────────────────────────────────────────────
  Widget _buildFilterBar(BankAccountController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final List<String> filterOptions = ['All', 'Active', 'Inactive'];

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
            SizedBox(
              width: isWeb ? 150 : 120,
              height: isWeb ? 45 : 40,
              child: Container(
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
                    padding: EdgeInsets.symmetric(horizontal: isWeb ? 12 : 8),
                    style: TextStyle(
                      fontSize: isWeb ? 13 : 12,
                      color: kText,
                      fontWeight: FontWeight.w500,
                    ),
                    items: filterOptions.map((filter) {
                      return DropdownMenuItem(
                        value: filter,
                        child: Text(filter, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) controller.changeFilter(value);
                    },
                  )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // BANK ACCOUNTS LIST - Web table / Mobile cards
  // ─────────────────────────────────────────────────────────
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
                Icon(Icons.account_balance,
                    size: isWeb ? 80 : 64, color: kSubText.withOpacity(0.5)),
                SizedBox(height: isWeb ? 20 : 16),
                Text(
                  'No bank accounts found',
                  style: TextStyle(
                      fontSize: isWeb ? 18 : 16,
                      color: kSubText,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(height: isWeb ? 20 : 16),
                ElevatedButton(
                  onPressed: () =>
                      _showAddAccountDialog(Get.context!, controller, context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    padding: EdgeInsets.symmetric(
                        horizontal: isWeb ? 24 : 16,
                        vertical: isWeb ? 12 : 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
                    ),
                  ),
                  child: Text('Add Bank Account',
                      style: TextStyle(
                          fontSize: isWeb ? 14 : 12,
                          fontWeight: FontWeight.w600)),
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
                  'Bank Accounts',
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
                    '${accounts.length} accounts',
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
            _buildWebBankAccountsTable(accounts, controller, context)
          else
            _buildMobileBankAccountsList(accounts, controller, context),
        ],
      );
    });
  }

  // ─────────────────────────────────────────────────────────
  // WEB TABLE - Fixed widths, no Expanded in Row
  // ─────────────────────────────────────────────────────────
  Widget _buildWebBankAccountsTable(
    List<BankAccount> accounts,
    BankAccountController controller,
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
              children: [
                // Header - Fixed widths
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  color: kPrimary.withOpacity(0.06),
                  child: Row(
                    children: [
                      Container(width: 60, child: const Text('', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 200, child: const Text('Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 180, child: const Text('Bank', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 100, child: const Text('Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 90, child: const Text('Currency', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 150, child: const Text('Opening Balance', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 150, child: const Text('Current Balance', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 100, child: const Text('Status', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 80, child: const Text('Actions', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    ],
                  ),
                ),
                ...accounts.asMap().entries.map((entry) {
                  final index = entry.key;
                  final account = entry.value;
                  final isEven = index.isEven;
                  final balancePositive = account.currentBalance >= 0;

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
                            width: 60, height: 44,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [account.color, account.color.withOpacity(0.7)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.account_balance, size: 20, color: Colors.white),
                          ),
                          SizedBox(width: 10,),
                          // Account name + number
                          Container(
                            width: 200,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(account.accountName,
                                    style:  TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kText),
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 3),
                                Text(account.accountNumber,
                                    style:  TextStyle(fontSize: 11, color: kSubText)),
                              ],
                            ),
                          ),
                          // Bank + branch
                          Container(
                            width: 180,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(account.bankName,
                                    style:  TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: kText),
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 3),
                                Text(account.branchCode.isEmpty ? '-' : account.branchCode,
                                    style:  TextStyle(fontSize: 11, color: kSubText)),
                              ],
                            ),
                          ),
                          // Type
                          Container(
                            width: 100,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                              decoration: BoxDecoration(
                                color: kPrimary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(account.accountType,
                                  style: const TextStyle(fontSize: 11, color: kPrimary, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ),
                          // Currency
                          Container(
                            width: 90,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                              decoration: BoxDecoration(
                                color: kSubText.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(account.currency,
                                  style:  TextStyle(fontSize: 11, color: kSubText, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          // Opening Balance
                          Container(
                            width: 150,
                            child: Text(
                              _formatAmount(account.openingBalance),
                              textAlign: TextAlign.right,
                              style:  TextStyle(fontSize: 13, color: kSubText, fontWeight: FontWeight.w500),
                            ),
                          ),
                          // Current Balance
                          Container(
                            width: 150,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(
                                  color: balancePositive ? kSuccess.withOpacity(0.08) : kDanger.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _formatAmount(account.currentBalance),
                                  style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w700,
                                    color: balancePositive ? kSuccess : kDanger,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Status
                          Container(
                            width: 100,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: account.status == 'Active'
                                      ? kSuccess.withOpacity(0.1)
                                      : kDanger.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6, height: 6,
                                      decoration: BoxDecoration(
                                        color: account.status == 'Active' ? kSuccess : kDanger,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      account.status,
                                      style: TextStyle(
                                        fontSize: 11, fontWeight: FontWeight.w600,
                                        color: account.status == 'Active' ? kSuccess : kDanger,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Actions
                          Container(
                            width: 80,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () => Get.to(() => const GeneralLedgerScreen()),
                                  icon: const Icon(Icons.history, size: 18),
                                  tooltip: 'History',
                                  padding: EdgeInsets.zero,
                                  color: kSubText,
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () => Get.to(() => const TransferScreen()),
                                  icon: const Icon(Icons.swap_horiz, size: 18),
                                  tooltip: 'Transfer',
                                  padding: EdgeInsets.zero,
                                  color: account.color,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                // Footer
                _buildTableFooter(accounts),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableFooter(List<BankAccount> accounts) {
    final totalOpening = accounts.fold(0.0, (s, a) => s + a.openingBalance);
    final totalCurrent = accounts.fold(0.0, (s, a) => s + a.currentBalance);
    final activeCount = accounts.where((a) => a.status == 'Active').length;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: kPrimary.withOpacity(0.06),
        border:  Border(top: BorderSide(color: kBorder)),
      ),
      child: Row(
        children: [
          Container(width: 60, child: const Text('')),
          Container(width: 200, child: const Text('TOTALS', style: TextStyle(fontWeight: FontWeight.bold))),
          Container(width: 180, child: const SizedBox()),
          Container(width: 100, child: const SizedBox()),
          Container(width: 90, child: const SizedBox()),
          Container(width: 150, child: Text(_formatAmount(totalOpening), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold))),
          Container(width: 150, child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(color: kSuccess.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(_formatAmount(totalCurrent), style: const TextStyle(fontWeight: FontWeight.bold, color: kSuccess)),
            ),
          )),
          Container(width: 100, child: Center(child: Text('$activeCount Active', style: const TextStyle(fontWeight: FontWeight.bold, color: kSuccess)))),
          Container(width: 80, child: const SizedBox()),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // MOBILE LIST - Card based
  // ─────────────────────────────────────────────────────────
  Widget _buildMobileBankAccountsList(
    List<BankAccount> accounts,
    BankAccountController controller,
    BuildContext context,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: accounts.length,
      itemBuilder: (context, index) {
        final account = accounts[index];
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
                            gradient: LinearGradient(
                              colors: [account.color, account.color.withOpacity(0.7)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Icon(Icons.account_balance, size: 20, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                account.accountName,
                                style:  TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: kText),
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
                                  _buildMobileStatusBadge(account.status),
                                  _buildMobileInfoBadge(account.accountType),
                                  _buildMobileInfoBadge(account.currency),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                             Text('Balance', style: TextStyle(fontSize: 9, color: kSubText, fontWeight: FontWeight.w500)),
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
                            onPressed: () => Get.to(() => const GeneralLedgerScreen()),
                            icon: const Icon(Icons.history, size: 14),
                            label: const Text('History', style: TextStyle(fontSize: 11)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: kSubText,
                              side: BorderSide(color: kBorder),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Get.to(() => const TransferScreen()),
                            icon: const Icon(Icons.swap_horiz, size: 14, color: Colors.white),
                            label: const Text('Transfer', style: TextStyle(fontSize: 11)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: account.color,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
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
      },
    );
  }

  Widget _buildMobileStatusBadge(String status) {
    Color color = status == 'Active' ? kSuccess : kDanger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(status, style: TextStyle(fontSize: 8, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildMobileInfoBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: kBg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style:  TextStyle(fontSize: 8, color: kSubText, fontWeight: FontWeight.w500)),
    );
  }

  // ─────────────────────────────────────────────────────────
  // DIALOGS
  // ─────────────────────────────────────────────────────────
  void _showAddAccountDialog(BuildContext context, BankAccountController controller, BuildContext ctx) {
    final isWeb = ResponsiveUtils.isWeb(ctx);
    final formKey = GlobalKey<FormState>();
    String accountName = '';
    String accountNumber = '';
    String bankName = '';
    String branchCode = '';
    String accountType = 'Current';
    String currency = '\$';
    double openingBalance = 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              width: isWeb ? 500 : MediaQuery.of(context).size.width * 0.9,
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
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                labelStyle: TextStyle(fontSize: isWeb ? 12 : 11),
                              ),
                              style: TextStyle(fontSize: isWeb ? 13 : 12),
                              onChanged: (value) => accountName = value,
                              validator: (value) => value == null || value.isEmpty ? 'Account name required' : null,
                            ),
                            SizedBox(height: isWeb ? 16 : 12),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Account Number *',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                labelStyle: TextStyle(fontSize: isWeb ? 12 : 11),
                              ),
                              style: TextStyle(fontSize: isWeb ? 13 : 12),
                              onChanged: (value) => accountNumber = value,
                              validator: (value) => value == null || value.isEmpty ? 'Account number required' : null,
                            ),
                            SizedBox(height: isWeb ? 16 : 12),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Bank Name *',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                labelStyle: TextStyle(fontSize: isWeb ? 12 : 11),
                              ),
                              style: TextStyle(fontSize: isWeb ? 13 : 12),
                              onChanged: (value) => bankName = value,
                              validator: (value) => value == null || value.isEmpty ? 'Bank name required' : null,
                            ),
                            SizedBox(height: isWeb ? 16 : 12),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Branch Code',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                labelStyle: TextStyle(fontSize: isWeb ? 12 : 11),
                              ),
                              style: TextStyle(fontSize: isWeb ? 13 : 12),
                              items: const [
                                DropdownMenuItem(value: 'Current', child: Text('Current')),
                                DropdownMenuItem(value: 'Savings', child: Text('Savings')),
                                DropdownMenuItem(value: 'Business', child: Text('Business')),
                                DropdownMenuItem(value: 'Islamic', child: Text('Islamic')),
                              ],
                              onChanged: (value) => accountType = value!,
                            ),
                            SizedBox(height: isWeb ? 16 : 12),
                            DropdownButtonFormField<String>(
                              value: currency,
                              decoration: InputDecoration(
                                labelText: 'Currency',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                labelStyle: TextStyle(fontSize: isWeb ? 12 : 11),
                              ),
                              style: TextStyle(fontSize: isWeb ? 13 : 12),
                              items: const [
                                DropdownMenuItem(value: '\$', child: Text('\$ - Pakistani Rupee')),
                                DropdownMenuItem(value: 'USD', child: Text('USD - US Dollar')),
                                DropdownMenuItem(value: 'EUR', child: Text('EUR - Euro')),
                                DropdownMenuItem(value: 'GBP', child: Text('GBP - British Pound')),
                              ],
                              onChanged: (value) => currency = value!,
                            ),
                            SizedBox(height: isWeb ? 16 : 12),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Opening Balance',
                                hintText: '0.00',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                prefixText: '\$ ',
                                labelStyle: TextStyle(fontSize: isWeb ? 12 : 11),
                              ),
                              style: TextStyle(fontSize: isWeb ? 13 : 12),
                              keyboardType: TextInputType.number,
                              onChanged: (value) => openingBalance = double.tryParse(value) ?? 0,
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [account.color, account.color.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Icon(Icons.account_balance, size: 28, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.accountName,
                          style:  TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kText),
                        ),
                        Text(
                          account.accountNumber,
                          style:  TextStyle(fontSize: 14, color: kSubText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Bank Name', account.bankName, context),
                    const SizedBox(height: 12),
                    _buildDetailRow('Branch Code', account.branchCode.isEmpty ? '-' : account.branchCode, context),
                    const SizedBox(height: 12),
                    _buildDetailRow('Account Type', account.accountType, context),
                    const SizedBox(height: 12),
                    _buildDetailRow('Currency', account.currency, context),
                    const SizedBox(height: 12),
                    _buildDetailRow('Opening Balance', _formatAmount(account.openingBalance), context),
                    const SizedBox(height: 12),
                    _buildDetailRow('Current Balance', _formatAmount(account.currentBalance), context),
                    const SizedBox(height: 12),
                    _buildDetailRow('Status', account.status, context),
                    const SizedBox(height: 12),
                    _buildDetailRow('Last Reconciled', DateFormat('dd MMM yyyy').format(account.lastReconciled), context),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Get.to(() => const GeneralLedgerScreen());
                      },
                      icon: const Icon(Icons.history, size: 20),
                      label: const Text('View History', style: TextStyle(fontSize: 14)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: account.color,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
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
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: isWeb ? 13 : 11,
              color: kText,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────
  String _formatCompactAmount(double amount) {
    if (amount >= 10000000) {
      return '\$ ${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '\$ ${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '\$ ${(amount / 1000).toStringAsFixed(0)}K';
    }
    return '\$ ${amount.toStringAsFixed(0)}';
  }

  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '\$ ${formatter.format(amount)}';
  }
}