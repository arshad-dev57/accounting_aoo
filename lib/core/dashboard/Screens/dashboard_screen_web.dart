// lib/core/dashboard/screens/dashboard_screen_web.dart
// Professional CRM Dashboard — LedgerPro

import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/core/About/about_app_screen.dart';
import 'package:LedgerPro_app/core/About/privacypolicy_screen.dart';
import 'package:LedgerPro_app/core/About/termsofservice_screen.dart';
import 'package:LedgerPro_app/core/AccountPayable/screen/Account_payable_screen.dart';
import 'package:LedgerPro_app/core/AccountRecievables/screens/account_recievables_screen.dart';
import 'package:LedgerPro_app/core/AgedRecievables/screens/aged_recievables_screen.dart';
import 'package:LedgerPro_app/core/BankAccounts/screens/bank_acccounts_screen.dart';
import 'package:LedgerPro_app/core/Bills/Screen/bill_Screen.dart';
import 'package:LedgerPro_app/core/CapitalEquity/screens/capital_equity_screen.dart';
import 'package:LedgerPro_app/core/Contact/Screens/Contact_Screen.dart';
import 'package:LedgerPro_app/core/CreditNote/screens/credit_notes_screen.dart';
import 'package:LedgerPro_app/core/Customers/Screens/customers_screen.dart';
import 'package:LedgerPro_app/core/Expense/screen/expense_screen.dart';
import 'package:LedgerPro_app/core/Feedback/feedback_screen.dart';
import 'package:LedgerPro_app/core/FixedAssets/Screens/fixed_assets_screen.dart';
import 'package:LedgerPro_app/core/GeneralLedger/Screen/general_ledger_screen.dart';
import 'package:LedgerPro_app/core/Income/Screen/income_screen.dart';
import 'package:LedgerPro_app/core/Invoice/Screens/Invoice_Screen.dart';
import 'package:LedgerPro_app/core/PaymentMade/screens/payment_made_screen.dart';
import 'package:LedgerPro_app/core/ReportIsuue/Report_issue_screen.dart';
import 'package:LedgerPro_app/core/TrailBalance/Screen/trail_balance_screen.dart';
import 'package:LedgerPro_app/core/UserGuide/screen/user_guide_screen.dart';
import 'package:LedgerPro_app/core/Vendor&Supplier/screens/vendor_supplier_screen.dart';
import 'package:LedgerPro_app/core/balancesheet/screens/balance_sheet_screen.dart';
import 'package:LedgerPro_app/core/cashflowstatement/screen/cash_flow_statement_screen.dart';
import 'package:LedgerPro_app/core/changepassword/screen/change_password_screen.dart';
import 'package:LedgerPro_app/core/chartofaccounts/screens/chart_of_account_screen.dart';
import 'package:LedgerPro_app/core/companyprofile/screen/company_profile_screen.dart';
import 'package:LedgerPro_app/core/dashboard/controllers/dashboard_controller.dart';
import 'package:LedgerPro_app/core/journalEntries/Screens/journal_entries_screen.dart';
import 'package:LedgerPro_app/core/loanBorrowing/screen/_loan_borrowing_screen.dart';
import 'package:LedgerPro_app/core/login/screen/login_screen.dart';
import 'package:LedgerPro_app/core/paymentRecieved/Screens/payment_recieved_screen.dart';
import 'package:LedgerPro_app/core/plans/controllers/subscription_controller.dart';
import 'package:LedgerPro_app/core/plans/views/Subscription_plans.dart';
import 'package:LedgerPro_app/core/profitlossStatement/screens/profit_loss_statement_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Sidebar Section Model ───────────────────────────────────────────────────
class _SidebarSection {
  final String icon;
  final String label;
  final List<_SidebarItem>? children;
  final VoidCallback? onTap;
  final String routeName;
  
  const _SidebarSection({
    required this.icon, 
    required this.label, 
    this.children, 
    this.onTap,
    this.routeName = '',
  });
}


class _SidebarItem {
  final String icon;
  final String label;
  final String routeName;
  
  const _SidebarItem({
    required this.icon, 
    required this.label, 
    required this.routeName,
  });
}
// ══════════════════════════════════════════════════════════════════════════════
// MAIN SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class WebDashboardScreen extends StatefulWidget {
  const WebDashboardScreen({super.key});

  @override
  State<WebDashboardScreen> createState() => _WebDashboardScreenState();
}

class _WebDashboardScreenState extends State<WebDashboardScreen> {
  bool _sidebarCollapsed = false;
  late final DashboardController _ctrl;
  late final SubscriptionController _subCtrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(DashboardController());
    _subCtrl = Get.find<SubscriptionController>();
    
    _ctrl.currentScreen.value = _DashboardBody(
      ctrl: _ctrl,
      subCtrl: _subCtrl,
      onNavigate: _changeScreen,
    );
    _ctrl.currentRoute.value = 'dashboard';
  }

 void _changeScreen(Widget screen, {String route = 'dashboard'}) {
  print('🖱️ Changing screen to: $route');  // Debug print
  _ctrl.navigateTo(screen, route: route);
}

  String _getTitleForScreen(Widget? screen) {
    if (screen is _DashboardBody) return 'Dashboard';
    if (screen is IncomeScreen) return 'Income';
    if (screen is ExpenseScreen) return 'Expense';
    if (screen is ProfitLossStatementScreen) return 'Profit & Loss Statement';
    if (screen is BalanceSheetScreen) return 'Balance Sheet';
    if (screen is CashFlowStatementScreen) return 'Cash Flow Statement';
    if (screen is AgedReceivablesScreen) return 'Aged Receivables';
    if (screen is ChartOfAccountsScreen) return 'Chart of Accounts';
    if (screen is JournalEntriesScreen) return 'Journal Entries';
    if (screen is GeneralLedgerScreen) return 'General Ledger';
    if (screen is TrialBalanceScreen) return 'Trial Balance';
    if (screen is BankAccountsScreen) return 'Bank Accounts';
    if (screen is AccountsReceivableScreen) return 'Accounts Receivable';
    if (screen is AccountsPayableScreen) return 'Accounts Payable';
    if (screen is CustomersScreen) return 'Customers';
    if (screen is BillsScreen) return 'Bills';
    if (screen is VendorsScreen) return 'Vendors / Suppliers';
    if (screen is PaymentsReceivedScreen) return 'Payments Received';
    if (screen is PaymentsMadeScreen) return 'Payments Made';
    if (screen is CreditNotesScreen) return 'Credit Notes';
    if (screen is FixedAssetsScreen) return 'Fixed Assets';
    if (screen is LoansBorrowingsScreen) return 'Loans & Borrowings';
    if (screen is CapitalEquityScreen) return 'Capital / Equity';
    if (screen is TermsOfServiceScreen) return 'Terms of Service';
    if (screen is PrivacyPolicyScreen) return 'Privacy Policy';
    if (screen is AboutAppScreen) return 'About App';
    if (screen is ChangePasswordScreen) return 'Change Password';
    if (screen is ProfileScreen) return 'My Profile';
    if (screen is SelectPlanScreen) return 'Subscription';
    if (screen is UserGuideScreen) return 'User Guide';
    if (screen is ContactScreen) return 'Contact Support';
    if (screen is ReportIssueScreen) return 'Report an Issue';
    if (screen is FeedbackScreen) return 'Feedback';
    return 'LedgerPro';
  }

  void _showLogoutDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: kCardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: kBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: kDanger.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.logout_rounded, color: kDanger, size: 28),
              ),
              const SizedBox(height: 20),
              Text('Sign Out', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: kText)),
              const SizedBox(height: 8),
              Text('Are you sure you want to sign out of LedgerPro?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: kSubText)),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kSubText,
                        side: BorderSide(color: kBorder),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.clear();
                        Get.offAll(() => const LoginScreen());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kDanger,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w600)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Row(
        children: [
          _WebSidebar(
            collapsed: _sidebarCollapsed,
            ctrl: _ctrl,
            subCtrl: _subCtrl,
            onToggle: () => setState(() => _sidebarCollapsed = !_sidebarCollapsed),
            onLogout: _showLogoutDialog,
            onChangeScreen: _changeScreen,
          ),
          Expanded(
            child: Column(
              children: [
                Obx(() => _TopBar(
                  ctrl: _ctrl,
                  title: _getTitleForScreen(_ctrl.currentScreen.value),
                )),
                Expanded(
                  child: Obx(() => _ctrl.currentScreen.value ?? Container()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WebSidebar extends StatelessWidget {
  final bool collapsed;
  final DashboardController ctrl;
  final SubscriptionController subCtrl;
  final VoidCallback onToggle;
  final VoidCallback onLogout;
  final Function(Widget, {String route}) onChangeScreen;

  _WebSidebar({
    required this.collapsed,
    required this.ctrl,
    required this.subCtrl,
    required this.onToggle,
    required this.onLogout,
    required this.onChangeScreen,
  });
  final List<_SidebarSection> _sections = const [
    _SidebarSection(
      icon: Mdi.view_dashboard,
      label: 'Dashboard',
      routeName: 'dashboard',
    ),
    _SidebarSection(
      icon: Mdi.account_circle,
      label: 'LedgerPro Core',
      children: [
        _SidebarItem(icon: Mdi.chart_tree, label: 'Chart of Accounts', routeName: 'chart_of_accounts'),
        _SidebarItem(icon: Mdi.book_open_page_variant, label: 'Journal Entries', routeName: 'journal_entries'),
        _SidebarItem(icon: Mdi.book_open_blank_variant, label: 'General Ledger', routeName: 'general_ledger'),
        _SidebarItem(icon: Mdi.scale_balance, label: 'Trial Balance', routeName: 'trial_balance'),
        _SidebarItem(icon: Mdi.bank, label: 'Bank Accounts', routeName: 'bank_accounts'),
        _SidebarItem(icon: Mdi.trending_up, label: 'Income', routeName: 'income'),
        _SidebarItem(icon: Mdi.trending_down, label: 'Expense', routeName: 'expense'),
      ],
    ),
    _SidebarSection(
      icon: Mdi.swap_horizontal,
      label: 'Receivables & Payables',
      children: [
        _SidebarItem(icon: Mdi.cash_plus, label: 'Accounts Receivable', routeName: 'accounts_receivable'),
        _SidebarItem(icon: Mdi.cash_minus, label: 'Accounts Payable', routeName: 'accounts_payable'),
        _SidebarItem(icon: Mdi.account_group, label: 'Customers', routeName: 'customers'),
        _SidebarItem(icon: Mdi.file_document_outline, label: 'Bills', routeName: 'bills'),
        _SidebarItem(icon: Mdi.truck_delivery_outline, label: 'Vendors / Suppliers', routeName: 'vendors'),
        _SidebarItem(icon: Mdi.credit_card_outline, label: 'Payments Received', routeName: 'payments_received'),
        _SidebarItem(icon: Mdi.cash_check, label: 'Payments Made', routeName: 'payments_made'),
        _SidebarItem(icon: Mdi.file_undo_outline, label: 'Credit Notes', routeName: 'credit_notes'),
      ],
    ),
    _SidebarSection(
      icon: Mdi.business,
      label: 'Assets & Liabilities',
      children: [
        _SidebarItem(icon: Mdi.office_building_outline, label: 'Fixed Assets', routeName: 'fixed_assets'),
        _SidebarItem(icon: Mdi.hand_coin_outline, label: 'Loans & Borrowings', routeName: 'loans'),
        _SidebarItem(icon: Mdi.chart_donut, label: 'Capital / Equity', routeName: 'capital_equity'),
      ],
    ),
    _SidebarSection(
      icon: Mdi.chart_line,
      label: 'Financial Reports',
      children: [
        _SidebarItem(icon: Mdi.chart_line, label: 'Profit & Loss Statement', routeName: 'profit_loss'),
        _SidebarItem(icon: Mdi.clipboard_list_outline, label: 'Balance Sheet', routeName: 'balance_sheet'),
        _SidebarItem(icon: Mdi.cash, label: 'Cash Flow Statement', routeName: 'cash_flow'),
        _SidebarItem(icon: Mdi.account_clock, label: 'Aged Receivables', routeName: 'aged_receivables'),
      ],
    ),
    _SidebarSection(
      icon: Mdi.crown,
      label: 'Subscription',
      routeName: 'subscription',
    ),
    _SidebarSection(
      icon: Mdi.message_draw,
      label: 'Feedback',
      routeName: 'feedback',
    ),
    _SidebarSection(
      icon: Mdi.information,
      label: 'About',
      children: [
        _SidebarItem(icon: Mdi.information_outline, label: 'About App', routeName: 'about_app'),
        _SidebarItem(icon: Mdi.file_sign, label: 'Terms of Service', routeName: 'terms'),
        _SidebarItem(icon: Mdi.shield_lock_outline, label: 'Privacy Policy', routeName: 'privacy'),
      ],
    ),
  ];

  final Map<int, RxBool> _expandedStates = {};

  bool _isExpanded(int index) {
    if (!_expandedStates.containsKey(index)) {
      _expandedStates[index] = false.obs;
    }
    return _expandedStates[index]!.value;
  }

  void _toggleExpanded(int index) {
    if (!_expandedStates.containsKey(index)) {
      _expandedStates[index] = false.obs;
    }
    _expandedStates[index]!.toggle();
  }

  Widget _getScreenForRoute(String routeName) {
    switch (routeName) {
      case 'dashboard':
        return _DashboardBody(ctrl: ctrl, subCtrl: subCtrl, onNavigate: onChangeScreen);
      case 'chart_of_accounts':
        return const ChartOfAccountsScreen();
      case 'journal_entries':
        return const JournalEntriesScreen();
      case 'general_ledger':
        return const GeneralLedgerScreen();
      case 'trial_balance':
        return const TrialBalanceScreen();
      case 'bank_accounts':
        return const BankAccountsScreen();
      case 'income':
        return const IncomeScreen();
      case 'expense':
        return const ExpenseScreen();
      case 'accounts_receivable':
        return const AccountsReceivableScreen();
      case 'accounts_payable':
        return const AccountsPayableScreen();
      case 'customers':
        return const CustomersScreen();
      case 'bills':
        return const BillsScreen();
      case 'vendors':
        return const VendorsScreen();
      case 'payments_received':
        return const PaymentsReceivedScreen();
      case 'payments_made':
        return const PaymentsMadeScreen();
      case 'credit_notes':
        return const CreditNotesScreen();
      case 'fixed_assets':
        return const FixedAssetsScreen();
      case 'loans':
        return const LoansBorrowingsScreen();
      case 'capital_equity':
        return const CapitalEquityScreen();
      case 'profit_loss':
        return const ProfitLossStatementScreen();
      case 'balance_sheet':
        return const BalanceSheetScreen();
      case 'cash_flow':
        return const CashFlowStatementScreen();
      case 'aged_receivables':
        return const AgedReceivablesScreen();
      case 'subscription':
        return const SelectPlanScreen();
      case 'feedback':
        return const FeedbackScreen();
      case 'about_app':
        return const AboutAppScreen();
      case 'terms':
        return const TermsOfServiceScreen();
      case 'privacy':
        return const PrivacyPolicyScreen();
      default:
        return _DashboardBody(ctrl: ctrl, subCtrl: subCtrl, onNavigate: onChangeScreen);
    }
  }

  void _onItemTap(String routeName) {
    final screen = _getScreenForRoute(routeName);
    onChangeScreen(screen, route: routeName);
  }

  @override
  Widget build(BuildContext context) {
    final w = collapsed ? 72.0 : 268.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: w,
      decoration: BoxDecoration(
        color: kCardBg,
        border: Border(right: BorderSide(color: kBorder)),
      ),
      child: Column(
        children: [
          _buildLogoArea(),
          if (collapsed)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: GestureDetector(
                onTap: onToggle,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: kBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kBorder),
                  ),
                  child: Icon(Icons.chevron_right_rounded, color: kSubText, size: 20),
                ),
              ),
            ),
          if (!collapsed)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
              child: Row(
                children: [
                  Text('NAVIGATION',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: kSubText.withOpacity(0.5),
                          letterSpacing: 1.4)),
                ],
              ),
            ),
          const SizedBox(height: 4),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: collapsed ? 10 : 10),
              itemCount: _sections.length,
              itemBuilder: (_, i) => _buildSectionTile(i),
            ),
          ),
          _buildUserCard(),
        ],
      ),
    );
  }

  Widget _buildLogoArea() {
    return Container(
      height: 72,
      padding: EdgeInsets.symmetric(horizontal: collapsed ? 16 : 18),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: kBorder)),
      ),
      child: Row(
        mainAxisAlignment: collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [kPrimary, kPrimaryDark]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 18),
          ),
          if (!collapsed) ...[
            const SizedBox(width: 12),
            Text('LedgerPro', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: kText, letterSpacing: -0.3)),
            const Spacer(),
            GestureDetector(
              onTap: onToggle,
              child: Icon(Icons.chevron_left_rounded, color: kSubText, size: 20),
            ),
          ],
        ],
      ),
    );
  }
  Widget _buildSectionTile(int i) {
  final section = _sections[i];
  final isDirect = section.children == null;

  if (isDirect) {
    return Obx(() => _DirectNavTile(
          icon: section.icon,
          label: section.label,
          collapsed: collapsed,
          isActive: ctrl.isActive(section.routeName),
          onTap: () => _onItemTap(section.routeName),
        ));
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Obx(() => _ExpandableHeader(
        icon: section.icon,
        label: section.label,
        isOpen: _isExpanded(i),
        collapsed: collapsed,
        onToggle: () => _toggleExpanded(i),
        onNavigate: null,  // ← Keep null, don't navigate on header click
      )),
      Obx(() => (!collapsed && _isExpanded(i))
          ? Column(
              children: section.children!.map((item) => Obx(() => _SubItemTile(
                    icon: item.icon,
                    label: item.label,
                    isActive: ctrl.isActive(item.routeName),
                    onTap: () => _onItemTap(item.routeName),
                  ))).toList(),
            )
          : const SizedBox.shrink()),
    ],
  );
} Widget _buildUserCard() {
    return Container(
      margin: EdgeInsets.all(collapsed ? 10 : 12),
      padding: EdgeInsets.all(collapsed ? 10 : 14),
      decoration: BoxDecoration(
        color: kBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: collapsed
          ? GestureDetector(
              onTap: onLogout,
              child: Icon(Icons.logout_rounded, color: kDanger, size: 18),
            )
          : Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [kPrimary, kPrimaryDark]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => Text(
                            ctrl.companyName.value.isEmpty ? 'Company' : ctrl.companyName.value,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kText),
                            overflow: TextOverflow.ellipsis,
                          )),
                      Obx(() => Text(
                            subCtrl.hasActiveSubscription.value ? 'Premium' : subCtrl.isTrialActive.value ? 'Trial' : 'Expired',
                            style: TextStyle(fontSize: 11, color: kPrimary, fontWeight: FontWeight.w500),
                          )),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onLogout,
                  child: Icon(Icons.logout_rounded, color: kDanger, size: 16),
                ),
              ],
            ),
    );
  }
}

// ─── Direct Nav Tile ─────────────────────────────────────────────────────────
class _DirectNavTile extends StatelessWidget {
  final String icon, label;
  final bool collapsed;
  final bool isActive;
  final VoidCallback onTap;

  const _DirectNavTile({
    required this.icon,
    required this.label,
    required this.collapsed,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? kPrimary : kSubText;
    final bgColor = isActive ? kPrimary.withOpacity(0.08) : Colors.transparent;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 2),
          padding: EdgeInsets.symmetric(horizontal: collapsed ? 0 : 12, vertical: 11),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: collapsed
              ? Tooltip(
                  message: label,
                  preferBelow: false,
                  child: Center(
                    child: Iconify(icon, color: color, size: 20),
                  ),
                )
              : Row(
                  children: [
                    const SizedBox(width: 12),
                    Iconify(icon, color: color, size: 18),
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                        color: color,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
class _ExpandableHeader extends StatelessWidget {
  final String icon, label;
  final bool isOpen, collapsed;
  final VoidCallback onToggle;
  final VoidCallback? onNavigate;

  const _ExpandableHeader({
    required this.icon,
    required this.label,
    required this.isOpen,
    required this.collapsed,
    required this.onToggle,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final color = isOpen ? kPrimary : kSubText;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          onToggle();  // Sirf expand/collapse, navigate nahi
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 2),
          padding: EdgeInsets.symmetric(horizontal: collapsed ? 0 : 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: collapsed
              ? Tooltip(
                  message: label,
                  preferBelow: false,
                  child: Center(
                    child: Iconify(icon, color: color, size: 20),
                  ),
                )
              : Row(
                  children: [
                    const SizedBox(width: 12),
                    Iconify(icon, color: color, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: color,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: isOpen ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(Icons.keyboard_arrow_down_rounded, color: kSubText, size: 18),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}// ─── Sub Item Tile ────────────────────────────────────────────────────────────
class _SubItemTile extends StatelessWidget {
  final String icon, label;
  final bool isActive;
  final VoidCallback onTap;

  const _SubItemTile({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? kPrimary : kSubText;
    final bgColor = isActive ? kPrimary.withOpacity(0.08) : Colors.transparent;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 1, left: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive ? kPrimary : kSubText.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Iconify(icon, color: color, size: 15),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TOP BAR
// ══════════════════════════════════════════════════════════════════════════════
class _TopBar extends StatelessWidget {
  final String title;
  final DashboardController ctrl;
  const _TopBar({required this.title, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: kCardBg,
        border: Border(bottom: BorderSide(color: kBorder)),
      ),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kText, letterSpacing: -0.5)),
              Text(DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()), style: TextStyle(fontSize: 12, color: kSubText)),
            ],
          ),
          const Spacer(),
          Container(
            width: 260, height: 40,
            decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: kBorder)),
            child: TextField(
              style: TextStyle(fontSize: 13, color: kText),
              decoration: InputDecoration(
                hintText: 'Search anything...',
                hintStyle: TextStyle(color: kSubText.withOpacity(0.5), fontSize: 13),
                prefixIcon: Icon(Icons.search_rounded, color: kSubText, size: 18),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Get.to(() => ProfileScreen()),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(gradient: LinearGradient(colors: [kPrimary, kPrimaryDark]), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// DASHBOARD BODY (Remains same as before - unchanged)
// ══════════════════════════════════════════════════════════════════════════════
class _DashboardBody extends StatefulWidget {
  final DashboardController ctrl;
  final SubscriptionController subCtrl;
  final Function(Widget, {String route}) onNavigate;
  const _DashboardBody({required this.ctrl, required this.subCtrl, required this.onNavigate});

  @override
  State<_DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<_DashboardBody> {
  int _chartTab = 0;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ctrl = widget.ctrl;

      if (ctrl.isLoading.value && ctrl.chartData.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: LoadingAnimationWidget.waveDots(color: kPrimary, size: 32),
              ),
              const SizedBox(height: 16),
              Text('Loading your workspace...', style: TextStyle(fontSize: 14, color: kSubText)),
            ],
          ),
        );
      }

      if (ctrl.hasError.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(color: kDanger.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Icon(Icons.error_outline_rounded, color: kDanger, size: 32),
              ),
              const SizedBox(height: 16),
              Text(ctrl.errorMessage.value, style: TextStyle(fontSize: 14, color: kSubText)),
              const SizedBox(height: 20),
              _PrimaryButton(label: 'Retry', onTap: ctrl.refreshData),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          ctrl.refreshData();
          await widget.subCtrl.checkSubscriptionStatus();
        },
        color: kPrimary,
        backgroundColor: kCardBg,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SubscriptionBanner(subCtrl: widget.subCtrl),
              const SizedBox(height: 24),
              _KPIRow(ctrl: ctrl),
              const SizedBox(height: 28),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: _ChartCard(ctrl: ctrl, chartTab: _chartTab, onTabChange: (t) => setState(() => _chartTab = t))),
                  const SizedBox(width: 20),
                  Expanded(flex: 2, child: _QuickActionsCard(ctrl: ctrl, onNavigate: widget.onNavigate)),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    });
  }
}

class _SubscriptionBanner extends StatelessWidget {
  final SubscriptionController subCtrl;
  const _SubscriptionBanner({required this.subCtrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (subCtrl.hasActiveSubscription.value || subCtrl.isTrialActive.value) {
        return const SizedBox.shrink();
      }
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(color: kDanger.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: kDanger.withOpacity(0.3))),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: kDanger, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text('Your subscription has expired. Renew to continue accessing all features.', style: TextStyle(fontSize: 13, color: kText))),
            TextButton(
              onPressed: () => Get.to(() => const SelectPlanScreen()),
              style: TextButton.styleFrom(backgroundColor: kDanger, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
              child: const Text('Renew Plan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
    });
  }
}

class _KPIRow extends StatelessWidget {
  final DashboardController ctrl;
  const _KPIRow({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Obx(() => _KPICard(label: 'Total Revenue', value: ctrl.totalRevenueFormatted.value, trend: '+${ctrl.revenueChange.value.toStringAsFixed(1)}%', trendUp: true, icon: Icons.trending_up_rounded, iconColor: kSuccess, iconBg: kSuccess.withOpacity(0.1)))),
        const SizedBox(width: 16),
        Expanded(child: Obx(() => _KPICard(label: 'Total Expenses', value: ctrl.totalExpensesFormatted.value, trend: '−${ctrl.expenseChange.value.toStringAsFixed(1)}%', trendUp: false, icon: Icons.trending_down_rounded, iconColor: kDanger, iconBg: kDanger.withOpacity(0.1)))),
        const SizedBox(width: 16),
        Expanded(child: Obx(() => _KPICard(label: 'Outstanding', value: ctrl.outstandingFormatted.value, trend: '${ctrl.outstandingCount.value} invoices', trendUp: null, icon: Icons.receipt_long_rounded, iconColor: kWarning, iconBg: kWarning.withOpacity(0.1)))),
        const SizedBox(width: 16),
        Expanded(child: Obx(() => _KPICard(label: 'Cash Balance', value: ctrl.cashBalanceFormatted.value, trend: '+${ctrl.cashChange.value.toStringAsFixed(1)}%', trendUp: true, icon: Icons.account_balance_wallet_rounded, iconColor: kPrimary, iconBg: kPrimary.withOpacity(0.1)))),
      ],
    );
  }
}

class _KPICard extends StatefulWidget {
  final String label, value, trend;
  final bool? trendUp;
  final IconData icon;
  final Color iconColor, iconBg;
  const _KPICard({required this.label, required this.value, required this.trend, required this.trendUp, required this.icon, required this.iconColor, required this.iconBg});

  @override
  State<_KPICard> createState() => _KPICardState();
}

class _KPICardState extends State<_KPICard> {
  bool _h = false;

  @override
  Widget build(BuildContext context) {
    final trendColor = widget.trendUp == null ? kSubText : widget.trendUp! ? kSuccess : kDanger;

    return MouseRegion(
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: _h ? kBg : kCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _h ? kPrimary.withOpacity(0.25) : kBorder),
          boxShadow: _h ? [BoxShadow(color: kPrimary.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))] : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: kSubText)),
                Container(width: 36, height: 36, decoration: BoxDecoration(color: widget.iconBg, borderRadius: BorderRadius.circular(10)), child: Icon(widget.icon, color: widget.iconColor, size: 18)),
              ],
            ),
            const SizedBox(height: 14),
            Text(widget.value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: kText, letterSpacing: -0.5)),
            const SizedBox(height: 10),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: trendColor.withOpacity(0.12), borderRadius: BorderRadius.circular(6)), child: Text(widget.trend, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: trendColor))),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final DashboardController ctrl;
  final int chartTab;
  final ValueChanged<int> onTabChange;
  const _ChartCard({required this.ctrl, required this.chartTab, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: kCardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Financial Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kText)),
                  const SizedBox(height: 2),
                  Text('Revenue & expense trends', style: TextStyle(fontSize: 12, color: kSubText)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: kBorder)),
                child: Row(
                  children: [
                    _ChartTabPill('Bar', 0, chartTab, onTabChange),
                    _ChartTabPill('Line', 1, chartTab, onTabChange),
                    _ChartTabPill('Pie', 2, chartTab, onTabChange),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Obx(() {
            if (ctrl.chartData.isEmpty) {
              return SizedBox(height: 260, child: Center(child: Text('No data available', style: TextStyle(color: kSubText))));
            }
            return SizedBox(
              height: 260,
              child: chartTab == 0 ? _BarChartWidget(ctrl: ctrl) : chartTab == 1 ? _LineChartWidget(ctrl: ctrl) : _PieChartWidget(ctrl: ctrl),
            );
          }),
          if (chartTab != 2) ...[
            const SizedBox(height: 16),
            Row(children: [_ChartLegend('Revenue', kPrimary), const SizedBox(width: 24), _ChartLegend('Expenses', kDanger)]),
          ],
        ],
      ),
    );
  }
}

class _ChartTabPill extends StatelessWidget {
  final String label;
  final int index, current;
  final ValueChanged<int> onTap;
  const _ChartTabPill(this.label, this.index, this.current, this.onTap);

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(color: active ? kPrimary : Colors.transparent, borderRadius: BorderRadius.circular(7)),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: active ? Colors.white : kSubText)),
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final String label;
  final Color color;
  const _ChartLegend(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: kSubText, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _BarChartWidget extends StatelessWidget {
  final DashboardController ctrl;
  const _BarChartWidget({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    double maxV = 0;
    for (var d in ctrl.chartData) {
      final r = (d['revenue'] ?? 0).toDouble();
      final e = (d['expenses'] ?? 0).toDouble();
      if (r > maxV) maxV = r;
      if (e > maxV) maxV = e;
    }
    maxV *= 1.25;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxV,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBorder: BorderSide(color: kBorder),
            tooltipBorderRadius: BorderRadius.circular(8),
            getTooltipItem: (group, gi, rod, ri) => BarTooltipItem('\$ ${NumberFormat('#,##0').format(rod.toY)}', TextStyle(color: kText, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                final i = val.toInt();
                if (i < 0 || i >= ctrl.chartData.length) return const SizedBox.shrink();
                return Padding(padding: const EdgeInsets.only(top: 8), child: Text(ctrl.getMonthName(i), style: TextStyle(fontSize: 10, color: kSubText)));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 50, getTitlesWidget: (val, meta) => Text(_fmtNum(val), style: TextStyle(fontSize: 10, color: kSubText))),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: kBorder, strokeWidth: 1)),
        barGroups: List.generate(
          ctrl.chartData.length,
          (i) => BarChartGroupData(
            x: i,
            barsSpace: 6,
            barRods: [
              BarChartRodData(toY: ctrl.getMonthlyRevenue(i), color: kPrimary, width: 16, borderRadius: const BorderRadius.vertical(top: Radius.circular(5))),
              BarChartRodData(toY: ctrl.getMonthlyExpenses(i), color: kDanger.withOpacity(0.7), width: 16, borderRadius: const BorderRadius.vertical(top: Radius.circular(5))),
            ],
          ),
        ),
      ),
    );
  }
}

class _LineChartWidget extends StatelessWidget {
  final DashboardController ctrl;
  const _LineChartWidget({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: kBorder, strokeWidth: 1)),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                final i = val.toInt();
                if (i < 0 || i >= ctrl.chartData.length) return const SizedBox.shrink();
                return Padding(padding: const EdgeInsets.only(top: 8), child: Text(ctrl.getMonthName(i), style: TextStyle(fontSize: 10, color: kSubText)));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 50, getTitlesWidget: (val, meta) => Text(_fmtNum(val), style: TextStyle(fontSize: 10, color: kSubText))),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(ctrl.chartData.length, (i) => FlSpot(i.toDouble(), ctrl.getMonthlyRevenue(i))),
            isCurved: true,
            color: kPrimary,
            barWidth: 2.5,
            dotData: FlDotData(show: true, getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(radius: 3, color: kPrimary, strokeWidth: 2, strokeColor: kCardBg)),
            belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [kPrimary.withOpacity(0.15), Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          ),
          LineChartBarData(
            spots: List.generate(ctrl.chartData.length, (i) => FlSpot(i.toDouble(), ctrl.getMonthlyExpenses(i))),
            isCurved: true,
            color: kDanger,
            barWidth: 2.5,
            dotData: FlDotData(show: true, getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(radius: 3, color: kDanger, strokeWidth: 2, strokeColor: kCardBg)),
            belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [kDanger.withOpacity(0.08), Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          ),
        ],
      ),
    );
  }
}

class _PieChartWidget extends StatelessWidget {
  final DashboardController ctrl;
  const _PieChartWidget({required this.ctrl});

  static final _colors = [kPrimary, kSuccess, kWarning, kDanger, const Color(0xFF8B5CF6), const Color(0xFFEC4899)];

  @override
  Widget build(BuildContext context) {
    if (ctrl.expenseCategories.isEmpty) {
      return Center(child: Text('No expense data', style: TextStyle(color: kSubText)));
    }
    final total = ctrl.expenseCategories.fold(0.0, (s, c) => s + (c['amount'] ?? 0).toDouble());
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              sections: ctrl.expenseCategories.asMap().entries.map((e) {
                final amt = (e.value['amount'] ?? 0).toDouble();
                final pct = total > 0 ? (amt / total * 100).toStringAsFixed(1) : '0';
                return PieChartSectionData(value: amt, title: '$pct%', radius: 75, titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white), color: _colors[e.key % _colors.length]);
              }).toList(),
              sectionsSpace: 3,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: ctrl.expenseCategories.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Container(width: 10, height: 10, decoration: BoxDecoration(color: _colors[e.key % _colors.length], borderRadius: BorderRadius.circular(3))),
                      const SizedBox(width: 8),
                      Expanded(child: Text(e.value['name'] ?? '', style: TextStyle(fontSize: 12, color: kSubText))),
                    ],
                  ),
                )).toList(),
          ),
        ),
      ],
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  final DashboardController ctrl;
  final Function(Widget, {String route}) onNavigate;
  const _QuickActionsCard({required this.ctrl, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: kCardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kText)),
          const SizedBox(height: 4),
          Text('Common tasks', style: TextStyle(fontSize: 12, color: kSubText)),
          const SizedBox(height: 20),
          _QuickAction(icon: Icons.add_circle_outline_rounded, color: kSuccess, bg: kSuccess.withOpacity(0.1), label: 'Add Income', sub: 'Record a payment', onTap: () => onNavigate(const IncomeScreen(), route: 'income')),
          const SizedBox(height: 10),
          _QuickAction(icon: Icons.remove_circle_outline_rounded, color: kDanger, bg: kDanger.withOpacity(0.1), label: 'Add Expense', sub: 'Log an expense', onTap: () => onNavigate(const ExpenseScreen(), route: 'expense')),
          const SizedBox(height: 10),
          _QuickAction(icon: Icons.receipt_long_rounded, color: kPrimary, bg: kPrimary.withOpacity(0.1), label: 'New Invoice', sub: 'Create invoice', onTap: () {}),
          const SizedBox(height: 10),
          _QuickAction(icon: Icons.people_alt_rounded, color: kWarning, bg: kWarning.withOpacity(0.1), label: 'Customers', sub: 'Manage customers', onTap: () => onNavigate(const CustomersScreen(), route: 'customers')),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _QuickAction extends StatefulWidget {
  final IconData icon;
  final Color color, bg;
  final String label, sub;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.color, required this.bg, required this.label, required this.sub, required this.onTap});

  @override
  State<_QuickAction> createState() => _QuickActionState();
}

class _QuickActionState extends State<_QuickAction> {
  bool _h = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _h ? widget.bg : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _h ? widget.color.withOpacity(0.2) : kBorder),
          ),
          child: Row(
            children: [
              Container(width: 36, height: 36, decoration: BoxDecoration(color: widget.bg, borderRadius: BorderRadius.circular(10)), child: Icon(widget.icon, color: widget.color, size: 18)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kText)),
                    Text(widget.sub, style: TextStyle(fontSize: 11, color: kSubText)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: _h ? widget.color : kSubText.withOpacity(0.5), size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

String _fmtNum(double v) {
  if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
  if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
  return v.toStringAsFixed(0);
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(backgroundColor: kPrimary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), elevation: 0),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}