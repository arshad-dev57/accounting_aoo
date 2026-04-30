import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/Utils/responsive_utils.dart';
import 'package:LedgerPro_app/Utils/toast_utils.dart';
import 'package:LedgerPro_app/core/chartofaccounts/controller/chart_of_account_controller.dart';
import 'package:LedgerPro_app/core/journalEntries/Screens/journal_entries_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ChartOfAccountsScreen extends StatelessWidget {
  const ChartOfAccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChartOfAccountController());

    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(context, controller),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: LoadingAnimationWidget.waveDots(
              color: kPrimary,
              size: ResponsiveUtils.isWeb(context) ? 60 : 40,
            ),
          );
        }
        
        return Column(
          children: [
            _buildSummaryCards(controller, context),
            _buildAccountTypeFilter(controller, context),
            Expanded(
              child: _buildAccountsList(controller, context),
            ),
          ],
        );
      }),
      floatingActionButton: ResponsiveUtils.isMobile(context)
          ? FloatingActionButton(
              onPressed: () => _showAddAccountDialog(context, controller),
              backgroundColor: kPrimary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ChartOfAccountController controller) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return AppBar(
      title: Text(
        'Chart of Accounts',
        style: TextStyle(
          fontSize: isWeb ? 20 : 18,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      backgroundColor: kPrimary,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () => _showSearchDialog(context, controller),
        ),
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.white),
          onPressed: () => _showFilterDialog(context, controller),
        ),
        if (!ResponsiveUtils.isMobile(context))
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showAddAccountDialog(context, controller),
          ),
      ],
    );
  }

  Widget _buildSummaryCards(ChartOfAccountController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final isTablet = ResponsiveUtils.isTablet(context);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWeb ? 24 : 16,
        vertical: isWeb ? 20 : 16,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(() => Row(
          children: [
            _buildSummaryCard('Assets', controller.totalAssets.value, const Color(0xFF2ECC71), Icons.account_balance, context),
            SizedBox(width: isWeb ? 16 : 12),
            _buildSummaryCard('Liabilities', controller.totalLiabilities.value, const Color(0xFFE74C3C), Icons.payment, context),
            SizedBox(width: isWeb ? 16 : 12),
            _buildSummaryCard('Equity', controller.totalEquity.value, const Color(0xFF3498DB), Icons.account_balance_wallet, context),
            SizedBox(width: isWeb ? 16 : 12),
            _buildSummaryCard('Income', controller.totalIncome.value, const Color(0xFF2ECC71), Icons.trending_up, context),
            SizedBox(width: isWeb ? 16 : 12),
            _buildSummaryCard('Expenses', controller.totalExpenses.value, const Color(0xFFE74C3C), Icons.trending_down, context),
          ],
        )),
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color, IconData icon, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final isTablet = ResponsiveUtils.isTablet(context);
    
    return Container(
      width: isWeb ? 180 : (isTablet ? 160 : 140),
      padding: EdgeInsets.all(isWeb ? 16 : 12),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: isWeb ? 20 : 16, color: color),
              SizedBox(width: isWeb ? 8 : 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: isWeb ? 13 : 12,
                  color: kSubText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: isWeb ? 12 : 8),
          Text(
            _formatAmount(amount),
            style: TextStyle(
              fontSize: isWeb ? 20 : 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTypeFilter(ChartOfAccountController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final List<String> accountTypes = [
      'All', 'Assets', 'Liabilities', 'Equity', 'Income', 'Expenses'
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWeb ? 24 : 16,
        vertical: isWeb ? 12 : 8,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(() => Row(
          children: accountTypes.map((type) {
            final isSelected = controller.selectedFilter.value == type;
            return Padding(
              padding: EdgeInsets.only(right: isWeb ? 12 : 8),
              child: FilterChip(
                label: Text(type),
                selected: isSelected,
                onSelected: (selected) {
                  controller.changeFilter(type);
                },
                backgroundColor: kBg,
                selectedColor: kPrimary.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: isSelected ? kPrimary : kSubText,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: isWeb ? 13 : 12,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isWeb ? 12 : 8,
                  vertical: isWeb ? 8 : 6,
                ),
              ),
            );
          }).toList(),
        )),
      ),
    );
  }

  Widget _buildAccountsList(ChartOfAccountController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final isTablet = ResponsiveUtils.isTablet(context);
    
    return Obx(() {
      final accounts = controller.accounts;
      
      if (accounts.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_balance, size: isWeb ? 80 : 64, color: kSubText.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text(
                'No accounts found',
                style: TextStyle(
                  fontSize: isWeb ? 18 : 16,
                  color: kSubText,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _showAddAccountDialog(context, controller),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  padding: EdgeInsets.symmetric(
                    horizontal: isWeb ? 32 : 24,
                    vertical: isWeb ? 12 : 10,
                  ),
                ),
                child: Text('Add Account', style: TextStyle(fontSize: isWeb ? 14 : 13)),
              ),
            ],
          ),
        );
      }
      
      return GridView.builder(
        padding: EdgeInsets.all(isWeb ? 24 : 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isWeb ? 2 : (isTablet ? 2 : 1),
          childAspectRatio: isWeb ? 2.5 : 2.8,
          crossAxisSpacing: isWeb ? 20 : 16,
          mainAxisSpacing: isWeb ? 20 : 12,
        ),
        itemCount: accounts.length,
        itemBuilder: (context, index) {
          final account = controller.mapAccountToUI(accounts[index]);
          return _buildAccountCard(context, account, controller);
        },
      );
    });
  }

  Widget _buildAccountCard(BuildContext context, Map<String, dynamic> account, ChartOfAccountController controller) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Container(
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showAccountDetails(context, account, controller),
          borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
          child: Padding(
            padding: EdgeInsets.all(isWeb ? 20 : 16),
            child: Row(
              children: [
                Container(
                  width: isWeb ? 50 : 40,
                  height: isWeb ? 50 : 40,
                  decoration: BoxDecoration(
                    color: (account['typeColor'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isWeb ? 14 : 10),
                  ),
                  child: Icon(
                    account['typeIcon'] as IconData,
                    color: account['typeColor'] as Color,
                    size: isWeb ? 24 : 20,
                  ),
                ),
                SizedBox(width: isWeb ? 16 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account['name'],
                        style: TextStyle(
                          fontSize: isWeb ? 16 : 14,
                          fontWeight: FontWeight.w700,
                          color: kText,
                        ),
                      ),
                      SizedBox(height: isWeb ? 6 : 4),
                      Text(
                        '${account['code']} • ${account['type']}',
                        style: TextStyle(
                          fontSize: isWeb ? 13 : 12,
                          color: kSubText,
                        ),
                      ),
                      if (account['description'] != null && account['description'] != '')
                        Padding(
                          padding: EdgeInsets.only(top: isWeb ? 8 : 6),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, size: isWeb ? 16 : 14, color: kSubText),
                              SizedBox(width: isWeb ? 6 : 4),
                              Expanded(
                                child: Text(
                                  account['description'],
                                  style: TextStyle(
                                    fontSize: isWeb ? 12 : 11,
                                    color: kSubText,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatAmount(account['balance']),
                      style: TextStyle(
                        fontSize: isWeb ? 18 : 16,
                        fontWeight: FontWeight.w800,
                        color: account['balanceType'] == 'Debit' 
                            ? kSuccess 
                            : kDanger,
                      ),
                    ),
                    SizedBox(height: isWeb ? 8 : 4),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isWeb ? 12 : 8,
                        vertical: isWeb ? 6 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: account['balanceType'] == 'Debit' 
                            ? kSuccess.withOpacity(0.1)
                            : kDanger.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
                      ),
                      child: Text(
                        account['balanceType'],
                        style: TextStyle(
                          fontSize: isWeb ? 11 : 10,
                          fontWeight: FontWeight.w600,
                          color: account['balanceType'] == 'Debit' 
                              ? kSuccess 
                              : kDanger,
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

  void _showAddAccountDialog(BuildContext context, ChartOfAccountController controller) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final formKey = GlobalKey<FormState>();
    String accountCode = '';
    String accountName = '';
    String accountType = 'Assets';
    String parentAccount = '';
    String description = '';
    String taxCode = 'N/A';
    double openingBalance = 0.0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isWeb ? 20 : 16)),
            child: Container(
              width: isWeb ? 600 : double.infinity,
              padding: EdgeInsets.all(isWeb ? 24 : 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Add New Account',
                    style: TextStyle(fontSize: isWeb ? 22 : 18, fontWeight: FontWeight.w800, color: kText),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Account Code *',
                                hintText: 'e.g., 1010',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) => accountCode = value,
                              validator: (value) => value == null || value.isEmpty 
                                  ? 'Account code required' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Account Name *',
                                hintText: 'e.g., Cash in Hand',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) => accountName = value,
                              validator: (value) => value == null || value.isEmpty 
                                  ? 'Account name required' : null,
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Account Type *',
                                border: OutlineInputBorder(),
                              ),
                              value: accountType,
                              items: const [
                                DropdownMenuItem(value: 'Assets', child: Text('Assets')),
                                DropdownMenuItem(value: 'Liabilities', child: Text('Liabilities')),
                                DropdownMenuItem(value: 'Equity', child: Text('Equity')),
                                DropdownMenuItem(value: 'Income', child: Text('Income')),
                                DropdownMenuItem(value: 'Expenses', child: Text('Expenses')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  accountType = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Parent Account',
                                border: OutlineInputBorder(),
                              ),
                              value: parentAccount.isEmpty ? null : parentAccount,
                              items: [
                                const DropdownMenuItem(value: 'Current Assets', child: Text('Current Assets')),
                                const DropdownMenuItem(value: 'Fixed Assets', child: Text('Fixed Assets')),
                                const DropdownMenuItem(value: 'Current Liabilities', child: Text('Current Liabilities')),
                                const DropdownMenuItem(value: 'Long Term Liabilities', child: Text('Long Term Liabilities')),
                                const DropdownMenuItem(value: 'Operating Income', child: Text('Operating Income')),
                                const DropdownMenuItem(value: 'Operating Expenses', child: Text('Operating Expenses')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  parentAccount = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Opening Balance',
                                hintText: '0.00',
                                border: OutlineInputBorder(),
                                prefixText: '\$ ',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                openingBalance = double.tryParse(value) ?? 0.0;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                hintText: 'Account description',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 2,
                              onChanged: (value) => description = value,
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Tax Code',
                                border: OutlineInputBorder(),
                              ),
                              value: taxCode,
                              items: const [
                                DropdownMenuItem(value: 'N/A', child: Text('N/A - No Tax')),
                                DropdownMenuItem(value: 'GST-13%', child: Text('GST 13% (Standard)')),
                                DropdownMenuItem(value: 'GST-5%', child: Text('GST 5% (Reduced)')),
                                DropdownMenuItem(value: 'WHT-10%', child: Text('WHT 10%')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  taxCode = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              Navigator.pop(context);
                              
                              final accountData = {
                                'code': accountCode,
                                'name': accountName,
                                'type': accountType,
                                'parentAccount': parentAccount,
                                'openingBalance': openingBalance,
                                'description': description,
                                'taxCode': taxCode,
                              };
                              
                              await controller.createAccount(accountData);
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                          child: const Text('Save Account'),
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

  void _showAccountDetails(BuildContext context, Map<String, dynamic> account, ChartOfAccountController controller) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    if (isWeb) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            child: _buildAccountDetailsContent(context, account, controller),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Container(
          padding: const EdgeInsets.all(20),
          child: _buildAccountDetailsContent(context, account, controller),
        ),
      );
    }
  }

  Widget _buildAccountDetailsContent(BuildContext context, Map<String, dynamic> account, ChartOfAccountController controller) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
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
                color: (account['typeColor'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
              ),
              child: Icon(
                account['typeIcon'] as IconData,
                color: account['typeColor'] as Color,
                size: isWeb ? 32 : 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account['name'],
                    style: TextStyle(
                      fontSize: isWeb ? 20 : 18,
                      fontWeight: FontWeight.w800,
                      color: kText,
                    ),
                  ),
                  Text(
                    '${account['code']} • ${account['type']}',
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
        const SizedBox(height: 20),
        _buildDetailRow('Current Balance', _formatAmount(account['balance']), context),
        _buildDetailRow('Balance Type', account['balanceType'], context),
        _buildDetailRow('Parent Account', account['parentAccount'] ?? 'N/A', context),
        _buildDetailRow('Tax Code', account['taxCode'] ?? 'N/A', context),
        _buildDetailRow('Description', account['description'] ?? 'No description', context),
        _buildDetailRow('Status', account['isActive'] ? 'Active' : 'Inactive', context),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showEditAccountDialog(context, account, controller);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: kPrimary,
                  side: const BorderSide(color: kPrimary),
                ),
                child: const Text('Edit Account'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Get.to(() => const JournalEntriesScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                ),
                child: const Text('View Ledger'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Padding(
      padding: EdgeInsets.only(bottom: isWeb ? 16 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isWeb ? 120 : 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: isWeb ? 14 : 13,
                color: kSubText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isWeb ? 14 : 13,
                color: kText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditAccountDialog(BuildContext context, Map<String, dynamic> account, ChartOfAccountController controller) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final formKey = GlobalKey<FormState>();
    String accountCode = account['code'];
    String accountName = account['name'];
    String accountType = account['type'];
    String parentAccount = account['parentAccount'] ?? '';
    String description = account['description'] ?? '';
    String taxCode = account['taxCode'] ?? 'N/A';
    double openingBalance = account['balance'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isWeb ? 20 : 16)),
            child: Container(
              width: isWeb ? 600 : double.infinity,
              padding: EdgeInsets.all(isWeb ? 24 : 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Edit Account',
                    style: TextStyle(fontSize: isWeb ? 22 : 18, fontWeight: FontWeight.w800, color: kText),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              initialValue: accountCode,
                              decoration: const InputDecoration(
                                labelText: 'Account Code *',
                                hintText: 'e.g., 1010',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) => accountCode = value,
                              validator: (value) => value == null || value.isEmpty 
                                  ? 'Account code required' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              initialValue: accountName,
                              decoration: const InputDecoration(
                                labelText: 'Account Name *',
                                hintText: 'e.g., Cash in Hand',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) => accountName = value,
                              validator: (value) => value == null || value.isEmpty 
                                  ? 'Account name required' : null,
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: accountType,
                              decoration: const InputDecoration(
                                labelText: 'Account Type *',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'Assets', child: Text('Assets')),
                                DropdownMenuItem(value: 'Liabilities', child: Text('Liabilities')),
                                DropdownMenuItem(value: 'Equity', child: Text('Equity')),
                                DropdownMenuItem(value: 'Income', child: Text('Income')),
                                DropdownMenuItem(value: 'Expenses', child: Text('Expenses')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  accountType = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: parentAccount.isEmpty ? null : parentAccount,
                              decoration: const InputDecoration(
                                labelText: 'Parent Account',
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem(value: 'Current Assets', child: Text('Current Assets')),
                                const DropdownMenuItem(value: 'Fixed Assets', child: Text('Fixed Assets')),
                                const DropdownMenuItem(value: 'Current Liabilities', child: Text('Current Liabilities')),
                                const DropdownMenuItem(value: 'Long Term Liabilities', child: Text('Long Term Liabilities')),
                                const DropdownMenuItem(value: 'Operating Income', child: Text('Operating Income')),
                                const DropdownMenuItem(value: 'Operating Expenses', child: Text('Operating Expenses')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  parentAccount = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              initialValue: openingBalance.toString(),
                              decoration: const InputDecoration(
                                labelText: 'Opening Balance',
                                hintText: '0.00',
                                border: OutlineInputBorder(),
                                prefixText: '\$ ',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                openingBalance = double.tryParse(value) ?? 0.0;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              initialValue: description,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                hintText: 'Account description',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 2,
                              onChanged: (value) => description = value,
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: taxCode,
                              decoration: const InputDecoration(
                                labelText: 'Tax Code',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'N/A', child: Text('N/A - No Tax')),
                                DropdownMenuItem(value: 'GST-13%', child: Text('GST 13% (Standard)')),
                                DropdownMenuItem(value: 'GST-5%', child: Text('GST 5% (Reduced)')),
                                DropdownMenuItem(value: 'WHT-10%', child: Text('WHT 10%')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  taxCode = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              Navigator.pop(context);
                              
                              final accountData = {
                                'code': accountCode,
                                'name': accountName,
                                'type': accountType,
                                'parentAccount': parentAccount,
                                'openingBalance': openingBalance,
                                'description': description,
                                'taxCode': taxCode,
                              };
                              
                              await controller.updateAccount(account['id'], accountData);
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                          child: const Text('Update Account'),
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

  void _showSearchDialog(BuildContext context, ChartOfAccountController controller) {
    final isWeb = ResponsiveUtils.isWeb(context);
    TextEditingController searchController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Accounts'),
        content: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Enter account name or code',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (value) {
            controller.searchAccounts(value);
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.searchAccounts(searchController.text);
              Navigator.pop(context);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context, ChartOfAccountController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Accounts'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Show accounts with:'),
            const SizedBox(height: 12),
            Obx(() => CheckboxListTile(
              value: true,
              title: const Text('Positive Balance'),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (value) {},
            )),
            Obx(() => CheckboxListTile(
              value: false,
              title: const Text('Zero Balance'),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (value) {},
            )),
            Obx(() => CheckboxListTile(
              value: true,
              title: const Text('Active Only'),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (value) {},
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              AppSnackbar.success(Colors.green, 'Filter', 'Filter applied');
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    return '\$ ${amount.toStringAsFixed(2)}';
  }
}