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
  const _SidebarSection({required this.icon, required this.label, this.children, this.onTap});
}

class _SidebarItem {
  final String icon;
  final String label;
  final Widget screen;
  const _SidebarItem({required this.icon, required this.label, required this.screen});
}

// ══════════════════════════════════════════════════════════════════════════════
// MAIN SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class WebDashboardScreen extends StatefulWidget {
  const WebDashboardScreen({super.key});

  @override
  State<WebDashboardScreen> createState() => _WebDashboardScreenState();
}

class _WebDashboardScreenState extends State<WebDashboardScreen>
    with TickerProviderStateMixin {
  bool _sidebarCollapsed = false;
  Widget? _currentScreen;

  late final DashboardController _ctrl;
  late final SubscriptionController _subCtrl;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(DashboardController());
    _subCtrl = Get.find<SubscriptionController>();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    _currentScreen = _DashboardBody(
      ctrl: _ctrl,
      subCtrl: _subCtrl,
      onNavigate: _changeScreen,
    );
  }

  void _changeScreen(Widget screen) {
    setState(() {
      _currentScreen = screen;
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
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
                _TopBar(ctrl: _ctrl, title: _getTitleForScreen(_currentScreen)),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: _currentScreen ?? Container(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
}

// ══════════════════════════════════════════════════════════════════════════════
// SIDEBAR
// ══════════════════════════════════════════════════════════════════════════════
class _WebSidebar extends StatefulWidget {
  final bool collapsed;
  final DashboardController ctrl;
  final SubscriptionController subCtrl;
  final VoidCallback onToggle;
  final VoidCallback onLogout;
  final Function(Widget) onChangeScreen;

  const _WebSidebar({
    required this.collapsed,
    required this.ctrl,
    required this.subCtrl,
    required this.onToggle,
    required this.onLogout,
    required this.onChangeScreen,
  });

  @override
  State<_WebSidebar> createState() => _WebSidebarState();
}

class _WebSidebarState extends State<_WebSidebar> {
  final Map<int, bool> _expanded = {};

  late final List<_SidebarSection> _sections = [
    _SidebarSection(
      icon: Mdi.view_dashboard,
      label: 'Dashboard',
      onTap: () => widget.onChangeScreen(_DashboardBody(
        ctrl: widget.ctrl,
        subCtrl: widget.subCtrl,
        onNavigate: widget.onChangeScreen,
      )),
    ),
    _SidebarSection(
      icon: Mdi.account_circle,
      label: 'LedgerPro Core',
      children: [
        _SidebarItem(icon: _iconForItem('Chart of Accounts'), label: 'Chart of Accounts', screen: const ChartOfAccountsScreen()),
        _SidebarItem(icon: _iconForItem('Journal Entries'), label: 'Journal Entries', screen: const JournalEntriesScreen()),
        _SidebarItem(icon: _iconForItem('General Ledger'), label: 'General Ledger', screen: const GeneralLedgerScreen()),
        _SidebarItem(icon: _iconForItem('Trial Balance'), label: 'Trial Balance', screen: const TrialBalanceScreen()),
        _SidebarItem(icon: _iconForItem('Bank Accounts'), label: 'Bank Accounts', screen: const BankAccountsScreen()),
        _SidebarItem(icon: _iconForItem('Income'), label: 'Income', screen: const IncomeScreen()),
        _SidebarItem(icon: _iconForItem('Expense'), label: 'Expense', screen: const ExpenseScreen()),
      ],
    ),
    _SidebarSection(
      icon: Mdi.swap_horizontal,
      label: 'Receivables & Payables',
      children: [
        _SidebarItem(icon: _iconForItem('Accounts Receivable'), label: 'Accounts Receivable', screen: const AccountsReceivableScreen()),
        _SidebarItem(icon: _iconForItem('Accounts Payable'), label: 'Accounts Payable', screen: const AccountsPayableScreen()),
        _SidebarItem(icon: _iconForItem('Customers'), label: 'Customers', screen: const CustomersScreen()),
        _SidebarItem(icon: _iconForItem('Bills'), label: 'Bills', screen: const BillsScreen()),
        _SidebarItem(icon: _iconForItem('Vendors / Suppliers'), label: 'Vendors / Suppliers', screen: const VendorsScreen()),
        _SidebarItem(icon: _iconForItem('Payments Received'), label: 'Payments Received', screen: const PaymentsReceivedScreen()),
        _SidebarItem(icon: _iconForItem('Payments Made'), label: 'Payments Made', screen: const PaymentsMadeScreen()),
        _SidebarItem(icon: _iconForItem('Credit Notes'), label: 'Credit Notes', screen: const CreditNotesScreen()),
      ],
    ),
    _SidebarSection(
      icon: Mdi.business,
      label: 'Assets & Liabilities',
      children: [
        _SidebarItem(icon: _iconForItem('Fixed Assets'), label: 'Fixed Assets', screen: const FixedAssetsScreen()),
        _SidebarItem(icon: _iconForItem('Loans & Borrowings'), label: 'Loans & Borrowings', screen: const LoansBorrowingsScreen()),
        _SidebarItem(icon: _iconForItem('Capital / Equity'), label: 'Capital / Equity', screen: const CapitalEquityScreen()),
      ],
    ),
    _SidebarSection(
      icon: Mdi.chart_line,
      label: 'Financial Reports',
      children: [
        _SidebarItem(icon: _iconForItem('Profit & Loss Statement'), label: 'Profit & Loss Statement', screen: const ProfitLossStatementScreen()),
        _SidebarItem(icon: _iconForItem('Balance Sheet'), label: 'Balance Sheet', screen: const BalanceSheetScreen()),
        _SidebarItem(icon: _iconForItem('Cash Flow Statement'), label: 'Cash Flow Statement', screen: const CashFlowStatementScreen()),
        _SidebarItem(icon: _iconForItem('Aged Receivables'), label: 'Aged Receivables', screen: const AgedReceivablesScreen()),
      ],
    ),
    _SidebarSection(
      icon: Mdi.crown,
      label: 'Subscription',
      onTap: () => widget.onChangeScreen(const SelectPlanScreen()),
    ),
    _SidebarSection(
      icon: Mdi.message_draw,
      label: 'Feedback',
      onTap: () => widget.onChangeScreen(const FeedbackScreen()),
    ),
    _SidebarSection(
      icon: Mdi.information,
      label: 'About',
      children: [
        _SidebarItem(icon: _iconForItem('About App'), label: 'About App', screen: const AboutAppScreen()),
        _SidebarItem(icon: _iconForItem('Terms of Service'), label: 'Terms of Service', screen: const TermsOfServiceScreen()),
        _SidebarItem(icon: _iconForItem('Privacy Policy'), label: 'Privacy Policy', screen: const PrivacyPolicyScreen()),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final w = widget.collapsed ? 72.0 : 268.0;

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
          if (widget.collapsed)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: GestureDetector(
                onTap: widget.onToggle,
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: kBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kBorder),
                  ),
                  child: Icon(Icons.chevron_right_rounded, color: kSubText, size: 20),
                ),
              ),
            ),
          if (!widget.collapsed)
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
              padding: EdgeInsets.symmetric(horizontal: widget.collapsed ? 10 : 10),
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
      padding: EdgeInsets.symmetric(horizontal: widget.collapsed ? 16 : 18),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: kBorder)),
      ),
      child: Row(
        mainAxisAlignment: widget.collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [kPrimary, kPrimaryDark]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 18),
          ),
          if (!widget.collapsed) ...[
            const SizedBox(width: 12),
            Text('LedgerPro', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: kText, letterSpacing: -0.3)),
            const Spacer(),
            GestureDetector(
              onTap: widget.onToggle,
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
      return _DirectNavTile(
        icon: section.icon,
        label: section.label,
        collapsed: widget.collapsed,
        onTap: section.onTap!,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ExpandableHeader(
          icon: section.icon,
          label: section.label,
          isOpen: _expanded[i] == true,
          collapsed: widget.collapsed,
          onTap: () {
            if (widget.collapsed) {
              widget.onToggle();
              return;
            }
            setState(() => _expanded[i] = !(_expanded[i] == true));
          },
        ),
        if (!widget.collapsed && _expanded[i] == true)
          ...section.children!.map((item) => _SubItemTile(
                item: item,
                onChangeScreen: widget.onChangeScreen,
              )),
      ],
    );
  }

  Widget _buildUserCard() {
    return Container(
      margin: EdgeInsets.all(widget.collapsed ? 10 : 12),
      padding: EdgeInsets.all(widget.collapsed ? 10 : 14),
      decoration: BoxDecoration(
        color: kBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: widget.collapsed
          ? GestureDetector(
              onTap: widget.onLogout,
              child: Icon(Icons.logout_rounded, color: kDanger, size: 18),
            )
          : Row(
              children: [
                Container(
                  width: 36, height: 36,
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
                            widget.ctrl.companyName.value.isEmpty ? 'Company' : widget.ctrl.companyName.value,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kText),
                            overflow: TextOverflow.ellipsis,
                          )),
                      Obx(() => Text(
                            widget.subCtrl.hasActiveSubscription.value ? 'Premium' : widget.subCtrl.isTrialActive.value ? 'Trial' : 'Expired',
                            style: TextStyle(fontSize: 11, color: kPrimary, fontWeight: FontWeight.w500),
                          )),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: widget.onLogout,
                  child: Icon(Icons.logout_rounded, color: kDanger, size: 16),
                ),
              ],
            ),
    );
  }
}

// ─── Direct Nav Tile ─────────────────────────────────────────────────────────
class _DirectNavTile extends StatefulWidget {
  final String icon, label;
  final bool collapsed;
  final VoidCallback onTap;
  const _DirectNavTile({required this.icon, required this.label, required this.collapsed, required this.onTap});

  @override
  State<_DirectNavTile> createState() => _DirectNavTileState();
}

class _DirectNavTileState extends State<_DirectNavTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final col = _hovered ? kText : kSubText;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 2),
          padding: EdgeInsets.symmetric(horizontal: widget.collapsed ? 0 : 12, vertical: 11),
          decoration: BoxDecoration(
            color: _hovered ? kBg : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: widget.collapsed
              ? Tooltip(
                  message: widget.label,
                  preferBelow: false,
                  child: Center(child: Iconify(widget.icon, color: col, size: 20)),
                )
              : Row(
                  children: [
                    const SizedBox(width: 12),
                    Iconify(widget.icon, color: col, size: 18),
                    const SizedBox(width: 12),
                    Text(widget.label, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: col, letterSpacing: -0.2)),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─── Expandable Header ────────────────────────────────────────────────────────
class _ExpandableHeader extends StatefulWidget {
  final String icon, label;
  final bool isOpen, collapsed;
  final VoidCallback onTap;
  const _ExpandableHeader({required this.icon, required this.label, required this.isOpen, required this.collapsed, required this.onTap});

  @override
  State<_ExpandableHeader> createState() => _ExpandableHeaderState();
}

class _ExpandableHeaderState extends State<_ExpandableHeader> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 2),
          padding: EdgeInsets.symmetric(horizontal: widget.collapsed ? 0 : 12, vertical: 10),
          decoration: BoxDecoration(
            color: _hovered ? kBg : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: widget.collapsed
              ? Tooltip(
                  message: widget.label,
                  preferBelow: false,
                  child: Center(child: Iconify(widget.icon, color: kSubText, size: 20)),
                )
              : Row(
                  children: [
                    const SizedBox(width: 12),
                    Iconify(widget.icon, color: widget.isOpen ? kPrimary : kSubText, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(widget.label, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: widget.isOpen ? kText : kSubText, letterSpacing: -0.2)),
                    ),
                    AnimatedRotation(
                      turns: widget.isOpen ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(Icons.keyboard_arrow_down_rounded, color: kSubText, size: 18),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─── Sub Item Tile ────────────────────────────────────────────────────────────
class _SubItemTile extends StatefulWidget {
  final _SidebarItem item;
  final Function(Widget) onChangeScreen;
  const _SubItemTile({required this.item, required this.onChangeScreen});

  @override
  State<_SubItemTile> createState() => _SubItemTileState();
}

class _SubItemTileState extends State<_SubItemTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => widget.onChangeScreen(widget.item.screen),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.only(bottom: 1, left: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: _hovered ? kPrimary.withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            children: [
              Container(
                width: 6, height: 6,
                decoration: BoxDecoration(color: _hovered ? kPrimary : kSubText.withOpacity(0.4), shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Iconify(widget.item.icon, color: _hovered ? kPrimary : kSubText, size: 15),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.item.label,
                  style: TextStyle(fontSize: 12.5, fontWeight: _hovered ? FontWeight.w600 : FontWeight.w400, color: _hovered ? kText : kSubText),
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

String _iconForItem(String item) {
  switch (item) {
    case 'Chart of Accounts': return Mdi.chart_tree;
    case 'Journal Entries': return Mdi.book_open_page_variant;
    case 'General Ledger': return Mdi.book_open_blank_variant;
    case 'Trial Balance': return Mdi.scale_balance;
    case 'Bank Accounts': return Mdi.bank;
    case 'Income': return Mdi.trending_up;
    case 'Expense': return Mdi.trending_down;
    case 'Accounts Receivable': return Mdi.cash_plus;
    case 'Accounts Payable': return Mdi.cash_minus;
    case 'Customers': return Mdi.account_group;
    case 'Bills': return Mdi.file_document_outline;
    case 'Vendors / Suppliers': return Mdi.truck_delivery_outline;
    case 'Payments Received': return Mdi.credit_card_outline;
    case 'Payments Made': return Mdi.cash_check;
    case 'Credit Notes': return Mdi.file_undo_outline;
    case 'Fixed Assets': return Mdi.office_building_outline;
    case 'Loans & Borrowings': return Mdi.hand_coin_outline;
    case 'Capital / Equity': return Mdi.chart_donut;
    case 'Profit & Loss Statement': return Mdi.chart_line;
    case 'Balance Sheet': return Mdi.clipboard_list_outline;
    case 'Cash Flow Statement': return Mdi.cash;
    case 'Aged Receivables': return Mdi.account_clock;
    case 'My Profile': return Mdi.account_circle_outline;
    case 'Change Password': return Mdi.lock_reset;
    case 'User Guide': return Mdi.book_information_variant;
    case 'Contact Support': return Mdi.headset;
    case 'Report an Issue': return Mdi.bug_outline;
    case 'Subscription': return Mdi.crown;
    case 'Feedback': return Mdi.message_draw;
    case 'About App': return Mdi.information_outline;
    case 'Terms of Service': return Mdi.file_sign;
    case 'Privacy Policy': return Mdi.shield_lock_outline;
    default: return Mdi.circle_outline;
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
          const SizedBox(width: 12),
          _NotifBtn(),
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

class _NotifBtn extends StatefulWidget {
  @override
  State<_NotifBtn> createState() => _NotifBtnState();
}

class _NotifBtnState extends State<_NotifBtn> {
  bool _h = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: _h ? kBg : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _h ? kBorder : Colors.transparent),
            ),
            child: Icon(Icons.notifications_none_rounded, color: _h ? kText : kSubText, size: 20),
          ),
          Positioned(
            top: 6, right: 6,
            child: Container(
              width: 8, height: 8,
              decoration: BoxDecoration(color: kDanger, shape: BoxShape.circle, border: Border.all(color: kCardBg, width: 1.5)),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// DASHBOARD BODY
// ══════════════════════════════════════════════════════════════════════════════
class _DashboardBody extends StatefulWidget {
  final DashboardController ctrl;
  final SubscriptionController subCtrl;
  final Function(Widget) onNavigate;
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 
               
                ],
              ),
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
            getTooltipItem: (group, gi, rod, ri) => BarTooltipItem('₨ ${NumberFormat('#,##0').format(rod.toY)}', TextStyle(color: kText, fontSize: 12, fontWeight: FontWeight.w600)),
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
  final Function(Widget) onNavigate;
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
          _QuickAction(icon: Icons.add_circle_outline_rounded, color: kSuccess, bg: kSuccess.withOpacity(0.1), label: 'Add Income', sub: 'Record a payment', onTap: () => onNavigate(const IncomeScreen())),
          const SizedBox(height: 10),
          _QuickAction(icon: Icons.remove_circle_outline_rounded, color: kDanger, bg: kDanger.withOpacity(0.1), label: 'Add Expense', sub: 'Log an expense', onTap: () => onNavigate(const ExpenseScreen())),
          const SizedBox(height: 10),
          _QuickAction(icon: Icons.receipt_long_rounded, color: kPrimary, bg: kPrimary.withOpacity(0.1), label: 'New Invoice', sub: 'Create invoice', onTap: () {}),
          const SizedBox(height: 10),
          _QuickAction(icon: Icons.people_alt_rounded, color: kWarning, bg: kWarning.withOpacity(0.1), label: 'Customers', sub: 'Manage customers', onTap: () => onNavigate(const CustomersScreen())),
          const SizedBox(height: 10),
          _QuickAction(icon: Icons.bar_chart_rounded, color: const Color(0xFF8B5CF6), bg: const Color(0xFF8B5CF6).withOpacity(0.1), label: 'View Reports', sub: 'Analytics & insights', onTap: () => onNavigate(const ProfitLossStatementScreen())),
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

class _RecentTransactionsCard extends StatelessWidget {
  final DashboardController ctrl;
  const _RecentTransactionsCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.recentTransactions.isEmpty) return const SizedBox.shrink();
      final recent = ctrl.recentTransactions.take(6).toList();

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
                    Text('Recent Transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kText)),
                    const SizedBox(height: 2),
                    Text('Latest financial activity', style: TextStyle(fontSize: 12, color: kSubText)),
                  ],
                ),
                TextButton(onPressed: () {}, style: TextButton.styleFrom(foregroundColor: kPrimary, padding: EdgeInsets.zero), child: const Text('View All →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Expanded(flex: 3, child: Text('Description', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: kSubText.withOpacity(0.6), letterSpacing: 0.5))),
                  Expanded(flex: 2, child: Text('Date', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: kSubText.withOpacity(0.6), letterSpacing: 0.5))),
                  Expanded(flex: 1, child: Text('Type', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: kSubText.withOpacity(0.6), letterSpacing: 0.5))),
                  Expanded(flex: 2, child: Text('Amount', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: kSubText.withOpacity(0.6), letterSpacing: 0.5))),
                ],
              ),
            ),
            const SizedBox(height: 4),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recent.length,
              separatorBuilder: (_, __) => Divider(color: kBorder, height: 1),
              itemBuilder: (_, i) {
                final tx = recent[i];
                final date = tx['date'] is DateTime ? tx['date'] as DateTime : DateTime.parse(tx['date'].toString());
                final isIncome = tx['type'] == 'income';
                final amount = (tx['amount'] ?? 0).toDouble();
                final title = tx['title']?.toString() ?? '';
                return _TxRow(title: title, date: DateFormat('dd MMM yyyy').format(date), isIncome: isIncome, amount: '₨ ${NumberFormat('#,##0').format(amount)}');
              },
            ),
          ],
        ),
      );
    });
  }
}

class _TxRow extends StatefulWidget {
  final String title, date, amount;
  final bool isIncome;
  const _TxRow({required this.title, required this.date, required this.isIncome, required this.amount});

  @override
  State<_TxRow> createState() => _TxRowState();
}

class _TxRowState extends State<_TxRow> {
  bool _h = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: _h ? kBg : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Container(width: 32, height: 32, margin: const EdgeInsets.only(right: 10), decoration: BoxDecoration(color: widget.isIncome ? kSuccess.withOpacity(0.1) : kDanger.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(widget.isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: widget.isIncome ? kSuccess : kDanger, size: 15)),
            Expanded(flex: 3, child: Text(widget.title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: kText), overflow: TextOverflow.ellipsis)),
            Expanded(flex: 2, child: Text(widget.date, style: TextStyle(fontSize: 12, color: kSubText))),
            Expanded(flex: 1, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: widget.isIncome ? kSuccess.withOpacity(0.1) : kDanger.withOpacity(0.1), borderRadius: BorderRadius.circular(5)), child: Text(widget.isIncome ? 'Income' : 'Expense', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: widget.isIncome ? kSuccess : kDanger)))),
            Expanded(flex: 2, child: Text(widget.amount, textAlign: TextAlign.right, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: widget.isIncome ? kSuccess : kText))),
          ],
        ),
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor, iconBg;
  final String label;
  final String Function() getValue;
  final Widget subWidget;
  final Color? valueColor;

  const _MiniStatCard({required this.icon, required this.iconColor, required this.iconBg, required this.label, required this.getValue, required this.subWidget, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: kCardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 36, height: 36, decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: iconColor, size: 18)),
              const SizedBox(width: 10),
              Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kSubText)),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => Text(getValue(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: valueColor ?? kText, letterSpacing: -0.5))),
          const SizedBox(height: 8),
          subWidget,
        ],
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