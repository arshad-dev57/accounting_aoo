import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/core/BankAccounts/controllers/bankaccount_controller.dart';
import 'package:LedgerPro_app/core/BankReconciliation/screens/bank_reconciliation_screen.dart';
import 'package:LedgerPro_app/core/GeneralLedger/Screen/general_ledger_screen.dart';
import 'package:LedgerPro_app/core/Transfer/screen/transfer_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';

class BankAccountsScreen extends StatelessWidget {
  const BankAccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BankAccountController());

    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(controller),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child:LoadingAnimationWidget.waveDots(
                    color: kPrimary,
                    size: 10.w,
                  )
          );
        }

        return Column(
          children: [
            _buildSummaryCards(controller),
            _buildFilterBar(controller),
            Expanded(
              child: _buildBankAccountsList(controller),
            ),
          ],
        );
      }),
      floatingActionButton: _buildFAB(controller),
    );
  }

  PreferredSizeWidget _buildAppBar(BankAccountController controller) {
    return AppBar(
      title: Text(
        'Bank Accounts',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      backgroundColor: kPrimary,
      elevation: 0,
      actions: [
      
        IconButton(
          icon: Icon(Icons.download_outlined, color: Colors.white, size: 5.5.w),
          onPressed: () => controller.exportAccounts(),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(BankAccountController controller) {
    return Obx(() {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildSummaryCard(
                'Total Balance',
                _formatCompactAmount(controller.totalBalance.value),
                kSuccess,
                Icons.account_balance,
                width: 28.w,
              ),
              SizedBox(width: 2.w),
              _buildSummaryCard(
                'PKR Balance',
                _formatCompactAmount(controller.totalPKR.value),
                kPrimary,
                Icons.currency_rupee,
                width: 28.w,
              ),
              SizedBox(width: 2.w),
              _buildSummaryCard(
                'USD Balance',
                _formatCompactAmount(controller.totalUSD.value),
                kWarning,
                Icons.attach_money,
                width: 28.w,
                suffix: ' USD',
              ),
              SizedBox(width: 2.w),
              _buildSummaryCard(
                'Active Accounts',
                controller.activeCount.value.toString(),
                kPrimary,
                Icons.account_balance_wallet,
                width: 28.w,
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
    IconData icon, {
    String? suffix,
    bool isNumber = false,
    required double width,
  }) {
    return Container(
      width: width,
      padding: EdgeInsets.all(2.5.w),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
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
              Icon(icon, size: 4.5.w, color: color),
              SizedBox(width: 1.5.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: kSubText,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            isNumber ? amount : '$amount${suffix ?? ''}',
            style: TextStyle(
              fontSize: 14.sp,
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

  Widget _buildFilterBar(BankAccountController controller) {
    final List<String> filterOptions = ['All', 'Active', 'Inactive'];

    return Container(
      width: 100.w,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      color: kCardBg,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 6.h,
              decoration: BoxDecoration(
                color: kBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kBorder),
              ),
              child: TextField(
                onChanged: (value) => controller.searchAccounts(value),
                style: TextStyle(fontSize: 13.sp),
                decoration: InputDecoration(
                  hintText: 'Search by name, bank, or account number...',
                  hintStyle: TextStyle(fontSize: 12.sp, color: kSubText),
                  prefixIcon: Icon(Icons.search, size: 5.w),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 1.8.h),
                ),
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Container(
            width: 30.w,
            height: 6.h,
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            decoration: BoxDecoration(
              color: kBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorder),
            ),
            child: DropdownButtonHideUnderline(
              child: Obx(() => DropdownButton<String>(
                value: controller.selectedFilter.value,
                icon: Icon(Icons.arrow_drop_down, size: 5.w),
                isExpanded: true,
                style: TextStyle(
                  fontSize: 13.sp,
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

  Widget _buildBankAccountsList(BankAccountController controller) {
    return Obx(() {
      final accounts = controller.bankAccounts;

      if (accounts.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance,
                size: 20.w,
                color: kSubText.withOpacity(0.5),
              ),
              SizedBox(height: 2.h),
              Text(
                'No bank accounts found',
                style: TextStyle(
                  fontSize: 15.sp,
                  color: kSubText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              ElevatedButton(
                onPressed: () => _showAddAccountDialog(Get.context!, controller),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Add Bank Account',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(4.w),
        itemCount: accounts.length,
        itemBuilder: (context, index) {
          final account = accounts[index];
          return _buildAccountCard(account, controller);
        },
      );
    });
  }

  Widget _buildAccountCard(BankAccount account, BankAccountController controller) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showAccountDetails(account, controller),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 14.w,
                      height: 14.w,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [account.color, account.color.withOpacity(0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.account_balance,
                          size: 7.w,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            account.accountName,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                              color: kText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            '${account.bankName} • ${account.accountNumber}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: kSubText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.5.h),
                          Wrap(
                            spacing: 2.w,
                            runSpacing: 0.5.h,
                            children: [
                              _buildStatusBadge(account.status),
                              _buildInfoBadge(account.accountType),
                              _buildInfoBadge(account.currency),
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
                            fontSize: 12.sp,
                            color: kSubText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          _formatAmount(account.currentBalance),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: account.currentBalance >= 0 ? kSuccess : kDanger,
                          ),
                        ),
                        SizedBox(height: 0.3.h),
                        Text(
                          'Last: ${DateFormat('dd MMM').format(account.lastReconciled)}',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: kSubText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Container(
                  height: 0.8.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: kBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: account.openingBalance > 0
                          ? (account.currentBalance / (account.openingBalance * 2)).clamp(0.0, 1.0)
                          : 0.5,
                      backgroundColor: kBg,
                      valueColor: AlwaysStoppedAnimation<Color>(account.color),
                      minHeight: 0.8.h,
                    ),
                  ),
                ),
                SizedBox(height: 1.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Opening: ${_formatAmount(account.openingBalance)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: kSubText,
                      ),
                    ),
                    Text(
                      'Current: ${_formatAmount(account.currentBalance)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: account.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    // Reconcile Button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Navigate to Bank Reconciliation Screen with this account
                          Get.to(() => const BankReconciliationScreen());
                        },
                        icon: Icon(Icons.sync, size: 4.w),
                        label: Text(
                          'Reconcile',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kPrimary,
                          side: BorderSide(color: kPrimary, width: 1),
                          padding: EdgeInsets.symmetric(vertical: 1.2.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    // History Button - Navigate to General Ledger
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Navigate to General Ledger with this account filtered
                          Get.to(() => const GeneralLedgerScreen());
                        },
                        icon: Icon(Icons.history, size: 4.w),
                        label: Text(
                          'History',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kSubText,
                          side: BorderSide(color: kBorder, width: 1),
                          padding: EdgeInsets.symmetric(vertical: 1.2.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    // Transfer Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to Transfer Screen with this account as source
                          Get.to(() => const TransferScreen());
                        },
                        icon: Icon(Icons.swap_horiz, size: 4.w, color: Colors.white),
                        label: Text(
                          'Transfer',
                          style: TextStyle(fontSize: 13.sp),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: account.color,
                          padding: EdgeInsets.symmetric(vertical: 1.2.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
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
  }

  Widget _buildStatusBadge(String status) {
    Color color = status == 'Active' ? kSuccess : kDanger;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11.sp,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoBadge(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
      decoration: BoxDecoration(
        color: kBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.sp,
          color: kSubText,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFAB(BankAccountController controller) {
    return FloatingActionButton(
      onPressed: () => _showAddAccountDialog(Get.context!, controller),
      backgroundColor: kPrimary,
      child: Icon(Icons.add, color: Colors.white, size: 6.w),
      elevation: 3,
    );
  }

  void _showAddAccountDialog(BuildContext context, BankAccountController controller) {
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
              width: 90.w,
              constraints: BoxConstraints(maxHeight: 85.h),
              padding: EdgeInsets.all(5.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Add Bank Account',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: kText,
                    ),
                  ),
                  SizedBox(height: 2.h),
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
                                labelStyle: TextStyle(fontSize: 12.sp),
                              ),
                              style: TextStyle(fontSize: 13.sp),
                              onChanged: (value) => accountName = value,
                              validator: (value) => value == null || value.isEmpty
                                  ? 'Account name required'
                                  : null,
                            ),
                            SizedBox(height: 2.h),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Account Number *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelStyle: TextStyle(fontSize: 12.sp),
                              ),
                              style: TextStyle(fontSize: 13.sp),
                              onChanged: (value) => accountNumber = value,
                              validator: (value) => value == null || value.isEmpty
                                  ? 'Account number required'
                                  : null,
                            ),
                            SizedBox(height: 2.h),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Bank Name *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelStyle: TextStyle(fontSize: 12.sp),
                              ),
                              style: TextStyle(fontSize: 13.sp),
                              onChanged: (value) => bankName = value,
                              validator: (value) => value == null || value.isEmpty
                                  ? 'Bank name required'
                                  : null,
                            ),
                            SizedBox(height: 2.h),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Branch Code',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelStyle: TextStyle(fontSize: 12.sp),
                              ),
                              style: TextStyle(fontSize: 13.sp),
                              onChanged: (value) => branchCode = value,
                            ),
                            SizedBox(height: 2.h),
                            DropdownButtonFormField<String>(
                              value: accountType,
                              decoration: InputDecoration(
                                labelText: 'Account Type',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelStyle: TextStyle(fontSize: 12.sp),
                              ),
                              style: TextStyle(fontSize: 13.sp),
                              items: const [
                                DropdownMenuItem(value: 'Current', child: Text('Current',style: TextStyle(color: Colors.black),)),
                                DropdownMenuItem(value: 'Savings', child: Text('Savings',style: TextStyle(color: Colors.black),)),
                                DropdownMenuItem(value: 'Business', child: Text('Business',style: TextStyle(color: Colors.black),)),
                                DropdownMenuItem(value: 'Islamic', child: Text('Islamic',style: TextStyle(color: Colors.black),)),
                              ],
                              onChanged: (value) => accountType = value!,
                            ),
                            SizedBox(height: 2.h),
                            DropdownButtonFormField<String>(
                              value: currency,
                              decoration: InputDecoration(
                                labelText: 'Currency',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelStyle: TextStyle(fontSize: 12.sp),
                              ),
                              style: TextStyle(fontSize: 13.sp),
                              items: const [
                                DropdownMenuItem(value: 'PKR', child: Text('PKR - Pakistani Rupee',style: TextStyle(color: Colors.black),)),
                                DropdownMenuItem(value: 'USD', child: Text('USD - US Dollar',style: TextStyle(color: Colors.black),)),
                                DropdownMenuItem(value: 'EUR', child: Text('EUR - Euro',style: TextStyle(color: Colors.black),)),
                                DropdownMenuItem(value: 'GBP', child: Text('GBP - British Pound',style: TextStyle(color: Colors.black),)),
                              ],
                              onChanged: (value) => currency = value!,
                            ),
                            SizedBox(height: 2.h),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Opening Balance',
                                hintText: '0.00',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixText: '₨ ',
                                labelStyle: TextStyle(fontSize: 12.sp),
                              ),
                              style: TextStyle(fontSize: 13.sp),
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
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('Cancel', style: TextStyle(fontSize: 13.sp)),
                        ),
                      ),
                      SizedBox(width: 3.w),
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
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('Add Account', style: TextStyle(fontSize: 13.sp)),
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

  void _showAccountDetails(BankAccount account, BankAccountController controller) {
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(5.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 14.w,
                  height: 14.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [account.color, account.color.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Icon(Icons.account_balance, size: 7.w, color: Colors.white),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.accountName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: kText,
                        ),
                      ),
                      Text(
                        account.accountNumber,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: kSubText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            _buildDetailRow('Bank Name', account.bankName),
            _buildDetailRow('Branch Code', account.branchCode),
            _buildDetailRow('Account Type', account.accountType),
            _buildDetailRow('Currency', account.currency),
            _buildDetailRow('Opening Balance', _formatAmount(account.openingBalance)),
            _buildDetailRow('Current Balance', _formatAmount(account.currentBalance)),
            _buildDetailRow('Status', account.status),
            _buildDetailRow(
              'Last Reconciled',
              DateFormat('dd MMM yyyy').format(account.lastReconciled),
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Get.to(() => const BankReconciliationScreen());
                    },
                    icon: Icon(Icons.sync, size: 4.5.w),
                    label: Text('Reconcile', style: TextStyle(fontSize: 12.sp)),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Get.to(() => const GeneralLedgerScreen());
                    },
                    icon: Icon(Icons.history, size: 4.5.w),
                    label: Text('View History', style: TextStyle(fontSize: 12.sp)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: account.color,
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: kSubText,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              color: kText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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