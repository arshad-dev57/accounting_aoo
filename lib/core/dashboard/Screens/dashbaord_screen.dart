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
import 'package:LedgerPro_app/core/dashboard/Screens/transaction_screen.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentTab = 0;
  int _selectedChartIndex = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final DashboardController _controller;
  late final SubscriptionController _subscriptionController;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(DashboardController());
    _subscriptionController = Get.find<SubscriptionController>();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _checkSubscriptionPeriodically();
    });
  }

  void _checkSubscriptionPeriodically() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _checkAndHandleExpiry();
    });
    Future.delayed(const Duration(minutes: 5), () {
      if (mounted) _checkSubscriptionPeriodically();
    });
  }

  Future<void> _checkAndHandleExpiry() async {
    await _subscriptionController.checkSubscriptionStatus();
    if (!_subscriptionController.hasActiveSubscription.value &&
        _subscriptionController.subscriptionStatus.value == 'expired') {
      _showExpiredDialog();
    }
  }

  void _showExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Subscription Expired'),
        content: Text(
          _subscriptionController.trialDaysRemaining.value > 0
              ? 'Your free trial has ended. Please subscribe to continue using the app.'
              : 'Your subscription has expired. Please renew to continue using the app.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Get.to(() => const SelectPlanScreen());
            },
            child: const Text('Subscribe Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ FIX 2: _controller already initialized in initState — no Get.put here
    return Scaffold(
      key: _scaffoldKey, // ✅ FIX 1: attach key
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
      drawer: _buildDrawer(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    const titles = ['Dashboard', 'Transactions', 'Invoices', 'More'];
    return AppBar(
      title: Text(
        titles[_currentTab],
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -0.3,
        ),
      ),
      backgroundColor: kPrimary,
      elevation: 0,
      actions: [
        IconButton(
          icon: Iconify(Mdi.account_outline, color: Colors.white, size: 5.5.w),
          onPressed: () => Get.to(() => const ProfileScreen()),
        ),
        SizedBox(width: 1.w),
      ],
    );
  }

  // ✅ FIX 3: _buildBody no longer handles tab 4 with addPostFrameCallback
  Widget _buildBody() {
    switch (_currentTab) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return const TransactionsScreen();
      case 2:
        return const InvoicesScreen();
     
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    return RefreshIndicator(
      onRefresh: () async {
        _controller.refreshData();
        await _subscriptionController.checkSubscriptionStatus();
      },
      child: Obx(() {
        if (_controller.isLoading.value && _controller.chartData.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LoadingAnimationWidget.waveDots(color: kPrimary, size: 10.w),
                SizedBox(height: 2.h),
                Text(
                  'Loading dashboard...',
                  style: TextStyle(fontSize: 13.sp, color: kSubText),
                ),
              ],
            ),
          );
        }

        if (_controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Iconify(Mdi.alert_circle_outline, size: 12.w, color: kDanger),
                SizedBox(height: 2.h),
                Text(
                  _controller.errorMessage.value,
                  style: TextStyle(fontSize: 13.sp, color: kDanger),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2.h),
                ElevatedButton(
                  onPressed: () => _controller.refreshData(),
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                  child: Text('Retry', style: TextStyle(fontSize: 13.sp)),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(bottom: 4.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildWelcomeHeader(),
              Transform.translate(
                offset: Offset(0, -2.5.h),
                child: _buildKPICards(),
              ),
              SizedBox(height: 0.5.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: _buildChartTabs(),
              ),
              SizedBox(height: 2.h),
              _buildRevenueExpenseChart(),
              SizedBox(height: 2.h),
              _buildCashAndOutstanding(),
              SizedBox(height: 2.h),
              _buildRecentTransactions(),
              SizedBox(height: 2.h),
              _buildQuickActions(),
              SizedBox(height: 1.h),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSimpleSubscriptionStatus() {
    return Obx(() {
      String statusText = '';
      String statusIcon = Mdi.check_circle;
      bool isExpired = false;

      if (_subscriptionController.isTrialActive.value) {
        statusText =
            '${_subscriptionController.trialDaysRemaining.value} days free trial remaining';
        statusIcon = Mdi.crown;
      } else if (_subscriptionController.hasActiveSubscription.value) {
        statusText =
            '${_subscriptionController.subscriptionPlan.value.toUpperCase()} plan · ${_subscriptionController.subscriptionDaysRemaining.value} days left';
        statusIcon = Mdi.crown;
      } else {
        statusText = 'Subscription expired · Renew to continue';
        statusIcon = Mdi.alert;
        isExpired = true;
      }

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isExpired
              ? Colors.red.withOpacity(0.18)
              : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(2.5.w),
          border: Border.all(
            color: isExpired
                ? Colors.red.withOpacity(0.45)
                : Colors.white.withOpacity(0.30),
          ),
        ),
        child: Row(
          children: [
            Iconify(
              statusIcon,
              color: isExpired
                  ? Colors.redAccent.shade100
                  : Colors.white.withOpacity(0.95),
              size: 4.5.w,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: isExpired
                      ? Colors.red.shade100
                      : Colors.white.withOpacity(0.92),
                  letterSpacing: 0.1,
                ),
              ),
            ),
            if (isExpired)
              GestureDetector(
                onTap: () => Get.to(() => const SelectPlanScreen()),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: Colors.white.withOpacity(0.35)),
                  ),
                  child: Text(
                    'Renew',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            if (_subscriptionController.isTrialActive.value)
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.4.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'FREE',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildWelcomeHeader() {
    return Container(
      margin: EdgeInsets.fromLTRB(4.w, 0, 4.w, 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kPrimary,
            kPrimaryDark,
            Color.lerp(kPrimaryDark, const Color(0xFF0B8BC4), 0.35)!
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(5.w),
          bottomRight: Radius.circular(5.w),
        ),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -8.w,
            top: -1.h,
            child: IgnorePointer(
              child: Container(
                width: 35.w,
                height: 35.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
          ),
          Positioned(
            left: -5.w,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSimpleSubscriptionStatus(),
              Padding(
                padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 4.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 0.4.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Iconify(Mdi.chart_line,
                                    size: 3.5.w,
                                    color:
                                        Colors.white.withValues(alpha: 0.95)),
                                SizedBox(width: 1.w),
                                Text(
                                  'Overview',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color:
                                        Colors.white.withValues(alpha: 0.95),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 1.2.h),
                          Text(
                            'Welcome back',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.white.withValues(alpha: 0.85),
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(height: 0.4.h),
                          Obx(
                            () => Text(
                              _controller.companyName.value,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.15,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          SizedBox(height: 0.8.h),
                          Text(
                            'Financial snapshot · ${DateFormat('EEEE').format(DateTime.now())}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.white.withValues(alpha: 0.78),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 3.w, vertical: 1.2.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(3.w),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.22)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            DateFormat('dd').format(DateTime.now()),
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                          Text(
                            DateFormat('MMM')
                                .format(DateTime.now())
                                .toUpperCase(),
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.white70,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 0.3.h),
                          Text(
                            DateFormat('yyyy').format(DateTime.now()),
                            style: TextStyle(
                                fontSize: 13.sp, color: Colors.white60),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKPICards() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: SizedBox(
        height: 17.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: 4,
          separatorBuilder: (_, __) => SizedBox(width: 3.w),
          itemBuilder: (context, i) {
            switch (i) {
              case 0:
                return Obx(() => _buildKPICard(
                      'Total Revenue',
                      _controller.totalRevenueFormatted.value,
                      kSuccess,
                      Mdi.trending_up,
                      '${_controller.revenueChange.value.toStringAsFixed(1)}%',
                      'vs last month',
                      _controller.isRevenuePositive.value,
                    ));
              case 1:
                return Obx(() => _buildKPICard(
                      'Total Expenses',
                      _controller.totalExpensesFormatted.value,
                      kDanger,
                      Mdi.trending_down,
                      '${_controller.expenseChange.value.toStringAsFixed(1)}%',
                      'vs last month',
                      !_controller.isExpensePositive.value,
                    ));
              case 2:
                return Obx(() => _buildKPICard(
                      'Outstanding',
                      _controller.outstandingFormatted.value,
                      kWarning,
                      Mdi.lan_pending,
                      '${_controller.outstandingCount.value} invoices',
                      'due',
                      true,
                    ));
              case 3:
                return Obx(() => _buildKPICard(
                      'Cash Balance',
                      _controller.cashBalanceFormatted.value,
                      kPrimary,
                      Mdi.wallet,
                      '${_controller.cashChange.value.toStringAsFixed(1)}%',
                      'vs last month',
                      _controller.isCashPositive.value,
                    ));
              default:
                return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }

  Widget _buildKPICard(String title, String amount, Color color, String icon,
      String trend, String trendText, bool isPositive) {
    final showArrow = trendText == 'vs last month';
    return Container(
      width: 42.w,
      padding: EdgeInsets.fromLTRB(3.2.w, 2.h, 3.2.w, 2.h),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(color: kBorder.withOpacity(0.85)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 6)),
          BoxShadow(
              color: kPrimary.withOpacity(0.04),
              blurRadius: 0,
              offset: Offset.zero),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 0.9.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 2.5.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                      fontSize: 13.sp,
                      color: kSubText,
                      fontWeight: FontWeight.w600,
                      height: 1.25),
                  maxLines: 2,
                ),
              ),
              Container(
                padding: EdgeInsets.all(1.8.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(0.14),
                      color.withOpacity(0.06)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2.2.w),
                ),
                child: Iconify(icon, color: color, size: 4.8.w),
              ),
            ],
          ),
          Text(
            amount,
            style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: kText,
                letterSpacing: -0.3),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showArrow) ...[
                Padding(
                  padding: EdgeInsets.only(top: 0.2.h),
                  child: Iconify(
                      isPositive ? Mdi.trending_up : Mdi.trending_down,
                      size: 3.2.w,
                      color: isPositive ? kSuccess : kDanger),
                ),
                SizedBox(width: 0.8.w),
              ],
              Expanded(
                child: RichText(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: TextStyle(
                        fontSize: 13.sp, color: kSubText, height: 1.25),
                    children: [
                      TextSpan(
                        text: trend,
                        style: TextStyle(
                          color: showArrow
                              ? (isPositive ? kSuccess : kDanger)
                              : color,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextSpan(text: ' · $trendText'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartTabs() {
    return Container(
      padding: EdgeInsets.all(1.2.w),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(color: kBorder.withOpacity(0.9)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _buildChartTab('Revenue vs Expenses', 0)),
          SizedBox(width: 1.5.w),
          Expanded(child: _buildChartTab('Trends', 1)),
          SizedBox(width: 1.5.w),
          Expanded(child: _buildChartTab('Categories', 2)),
        ],
      ),
    );
  }

  Widget _buildChartTab(String title, int index) {
    final isSelected = _selectedChartIndex == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _selectedChartIndex = index),
        borderRadius: BorderRadius.circular(3.w),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(vertical: 1.2.h, horizontal: 1.w),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [kPrimary, kPrimaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight)
                : null,
            color: isSelected ? null : kBg,
            borderRadius: BorderRadius.circular(3.w),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: kPrimary.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ]
                : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : kSubText,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRevenueExpenseChart() {
    final titles = [
      'Revenue vs expenses',
      'Monthly financial trends',
      'Expense breakdown'
    ];
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(5.w),
        border: Border.all(color: kBorder.withOpacity(0.85)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, 8)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kBg, kCardBg],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border(
                    bottom: BorderSide(color: kBorder.withOpacity(0.6))),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: kPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(2.5.w),
                    ),
                    child: Iconify(Mdi.chart_line, color: kPrimary, size: 5.w),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titles[_selectedChartIndex],
                          style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                              color: kText,
                              letterSpacing: -0.3),
                        ),
                        SizedBox(height: 0.3.h),
                        Text('Tap tabs above to switch view',
                            style:
                                TextStyle(fontSize: 13.sp, color: kSubText)),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 2.5.w, vertical: 0.6.h),
                    decoration: BoxDecoration(
                      color: kPrimary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: kPrimary.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Iconify(Mdi.calendar_month,
                            size: 3.w, color: kPrimary),
                        SizedBox(width: 1.w),
                        Text(
                            DateFormat('yyyy').format(DateTime.now()),
                            style: TextStyle(
                                fontSize: 13.sp,
                                color: kPrimary,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 3.w),
              child: Column(
                children: [
                  SizedBox(
                    height: 28.h,
                    child: _selectedChartIndex == 0
                        ? _buildDynamicBarChart()
                        : _selectedChartIndex == 1
                            ? _buildDynamicLineChart()
                            : _buildDynamicPieChart(),
                  ),
                  if (_selectedChartIndex != 2) ...[
                    SizedBox(height: 1.5.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLegend('Revenue', kPrimary),
                        SizedBox(width: 5.w),
                        _buildLegend('Expenses', kDanger),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicBarChart() {
    if (_controller.chartData.isEmpty) {
      return Center(
        child: Text('No chart data available',
            style: TextStyle(fontSize: 13.sp, color: kSubText)),
      );
    }
    double maxValue = 0;
    for (var data in _controller.chartData) {
      final revenue = (data['revenue'] ?? 0).toDouble();
      final expenses = (data['expenses'] ?? 0).toDouble();
      if (revenue > maxValue) maxValue = revenue;
      if (expenses > maxValue) maxValue = expenses;
    }
    maxValue = maxValue * 1.2;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                rod.toY.toStringAsFixed(0),
                TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 &&
                    index < _controller.chartData.length) {
                  return Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(
                      _controller.getMonthName(index),
                      style:
                          TextStyle(fontSize: 11.sp, color: kSubText),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 5.h,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: EdgeInsets.only(right: 4.w),
                  child: Text(
                    _formatCompactNumber(value),
                    style: TextStyle(fontSize: 11.sp, color: kSubText),
                  ),
                );
              },
              reservedSize: 10.w,
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: kBorder, strokeWidth: 0.5),
        ),
        barGroups: List.generate(
          _controller.chartData.length,
          (index) => BarChartGroupData(
            x: index,
            barsSpace: 3.w,
            barRods: [
              BarChartRodData(
                toY: _controller.getMonthlyRevenue(index),
                color: kPrimary,
                width: 2.5.w,
                borderRadius: BorderRadius.circular(1.w),
              ),
              BarChartRodData(
                toY: _controller.getMonthlyExpenses(index),
                color: kDanger,
                width: 2.5.w,
                borderRadius: BorderRadius.circular(1.w),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicLineChart() {
    if (_controller.chartData.isEmpty) {
      return Center(
        child: Text('No chart data available',
            style: TextStyle(fontSize: 13.sp, color: kSubText)),
      );
    }
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: kBorder, strokeWidth: 0.5),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 &&
                    index < _controller.chartData.length) {
                  return Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(
                      _controller.getMonthName(index),
                      style:
                          TextStyle(fontSize: 11.sp, color: kSubText),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 5.h,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: EdgeInsets.only(right: 4.w),
                  child: Text(
                    _formatCompactNumber(value),
                    style: TextStyle(fontSize: 11.sp, color: kSubText),
                  ),
                );
              },
              reservedSize: 10.w,
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              _controller.chartData.length,
              (index) => FlSpot(index.toDouble(),
                  _controller.getMonthlyRevenue(index)),
            ),
            isCurved: true,
            color: kPrimary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
                show: true, color: kPrimary.withOpacity(0.1)),
          ),
          LineChartBarData(
            spots: List.generate(
              _controller.chartData.length,
              (index) => FlSpot(index.toDouble(),
                  _controller.getMonthlyExpenses(index)),
            ),
            isCurved: true,
            color: kDanger,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
                show: true, color: kDanger.withOpacity(0.1)),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicPieChart() {
    if (_controller.expenseCategories.isEmpty) {
      return Center(
        child: Text('No expense data available',
            style: TextStyle(fontSize: 13.sp, color: kSubText)),
      );
    }
    final total = _controller.expenseCategories
        .fold(0.0, (sum, cat) => sum + (cat['amount'] ?? 0).toDouble());

    return PieChart(
      PieChartData(
        sections: _controller.expenseCategories.asMap().entries.map((entry) {
          final category = entry.value;
          final amount = (category['amount'] ?? 0).toDouble();
          final percentage =
              total > 0 ? (amount / total * 100).toStringAsFixed(1) : '0';
          final color = _getCategoryColor(category['name'] ?? '');
          return PieChartSectionData(
            value: amount,
            title: '${category['name']}\n$percentage%',
            radius: 12.w,
            titleStyle: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            color: color,
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 8.w,
      ),
    );
  }

  String _formatCompactNumber(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}K';
    return value.toStringAsFixed(0);
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Rent':
        return kPrimary;
      case 'Salary':
        return kSuccess;
      case 'Utilities':
        return kWarning;
      case 'Supplies':
        return kDanger;
      case 'Marketing':
        return kPrimaryDark;
      default:
        return kPrimary;
    }
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 2.8.w,
          height: 2.8.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(0.8.w),
            boxShadow: [
              BoxShadow(
                  color: color.withOpacity(0.45),
                  blurRadius: 4,
                  offset: const Offset(0, 1))
            ],
          ),
        ),
        SizedBox(width: 1.8.w),
        Text(label,
            style: TextStyle(
                fontSize: 13.sp,
                color: kSubText,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildCashAndOutstanding() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.w),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 16,
                offset: const Offset(0, 6))
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5.w),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [kPrimary.withOpacity(0.09), kCardBg],
                      ),
                      border: Border.all(color: kBorder.withOpacity(0.7)),
                    ),
                    child: Obx(() => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Iconify(Mdi.piggy_bank_outline,
                                    size: 4.5.w, color: kPrimary),
                                SizedBox(width: 1.5.w),
                                Text('Cash balance',
                                    style: TextStyle(
                                        fontSize: 13.sp,
                                        color: kSubText,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                            SizedBox(height: 1.2.h),
                            Text(
                              _controller.cashBalanceFormatted.value,
                              style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w800,
                                  color: kText,
                                  letterSpacing: -0.5),
                            ),
                            SizedBox(height: 1.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 2.5.w, vertical: 0.6.h),
                              decoration: BoxDecoration(
                                color: kSuccess.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: kSuccess.withOpacity(0.25)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Iconify(
                                    _controller.isCashPositive.value
                                        ? Mdi.trending_up
                                        : Mdi.trending_down,
                                    size: 3.5.w,
                                    color: _controller.isCashPositive.value
                                        ? kSuccess
                                        : kDanger,
                                  ),
                                  SizedBox(width: 1.w),
                                  Text(
                                    '${_controller.cashChange.value.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                        fontSize: 15.sp,
                                        color:
                                            _controller.isCashPositive.value
                                                ? kSuccess
                                                : kDanger,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  SizedBox(width: 1.w),
                                  Text('vs last month',
                                      style: TextStyle(
                                          fontSize: 13.sp, color: kSubText)),
                                ],
                              ),
                            ),
                          ],
                        )),
                  ),
                ),
                Container(
                  width: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        kBorder.withOpacity(0),
                        kBorder,
                        kBorder.withOpacity(0)
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [kWarning.withOpacity(0.08), kCardBg],
                      ),
                      border: Border.all(color: kBorder.withOpacity(0.7)),
                    ),
                    child: Obx(() => Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('Outstanding',
                                    style: TextStyle(
                                        fontSize: 13.sp,
                                        color: kSubText,
                                        fontWeight: FontWeight.w600)),
                                SizedBox(width: 1.5.w),
                                Iconify(Mdi.receipt_outline,
                                    size: 4.5.w, color: kWarning),
                              ],
                            ),
                            SizedBox(height: 1.2.h),
                            Text(
                              _controller.outstandingFormatted.value,
                              style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w800,
                                  color: kWarning,
                                  letterSpacing: -0.5),
                            ),
                            SizedBox(height: 1.h),
                            TextButton.icon(
                              onPressed: () =>
                                  setState(() => _currentTab = 2),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2.w, vertical: 0.5.h),
                                foregroundColor: kPrimary,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              icon: Iconify(Mdi.arrow_right, size: 3.8.w),
                              label: Text('View invoices',
                                  style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ],
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Obx(() {
      if (_controller.recentTransactions.isEmpty) {
        return const SizedBox.shrink();
      }
      final recent = _controller.recentTransactions.take(4).toList();
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(5.w),
          border: Border.all(color: kBorder.withOpacity(0.85)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 14,
                offset: const Offset(0, 6))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(4.w, 3.w, 3.w, 0),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                        color: kPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(2.5.w)),
                    child: Iconify(Mdi.receipt, color: kPrimary, size: 5.w),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Recent activity',
                            style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w800,
                                color: kText,
                                letterSpacing: -0.3)),
                        Text('Latest cash movements',
                            style:
                                TextStyle(fontSize: 13.sp, color: kSubText)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _currentTab = 1),
                    child: Text('See all',
                        style: TextStyle(
                            fontSize: 15.sp,
                            color: kPrimary,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 1.5.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: Column(
                children: recent.asMap().entries.map((e) {
                  final transaction = e.value;
                  final isLast = e.key == recent.length - 1;
                  final date = transaction['date'] is DateTime
                      ? transaction['date']
                      : DateTime.parse(transaction['date']);
                  final type = transaction['type'];
                  final amount = (transaction['amount'] ?? 0).toDouble();
                  final title = transaction['title'] ?? '';
                  final iconName = transaction['icon'] ?? 'circle';
                  final amountColor =
                      type == 'income' ? kSuccess : kDanger;

                  return Column(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => setState(() => _currentTab = 1),
                          borderRadius: BorderRadius.circular(3.w),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 1.4.h),
                            child: Row(
                              children: [
                                Container(
                                  width: 11.w,
                                  height: 11.w,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        amountColor.withOpacity(0.18),
                                        amountColor.withOpacity(0.06)
                                      ],
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(3.2.w),
                                    border: Border.all(
                                        color: amountColor.withOpacity(0.2)),
                                  ),
                                  child: Iconify(
                                      _getTransactionIcon(iconName),
                                      color: amountColor,
                                      size: 5.w),
                                ),
                                SizedBox(width: 3.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(title,
                                          style: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w700,
                                              color: kText),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                      SizedBox(height: 0.3.h),
                                      Text(
                                          DateFormat('dd MMM yyyy')
                                              .format(date),
                                          style: TextStyle(
                                              fontSize: 13.sp,
                                              color: kSubText)),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${type == 'income' ? '+' : '-'} ₨ ${NumberFormat('#,##0').format(amount)}',
                                      style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w800,
                                          color: amountColor,
                                          letterSpacing: -0.2),
                                    ),
                                    SizedBox(height: 0.2.h),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 1.5.w,
                                          vertical: 0.2.h),
                                      decoration: BoxDecoration(
                                        color: amountColor.withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        type == 'income'
                                            ? 'Income'
                                            : 'Expense',
                                        style: TextStyle(
                                            fontSize: 13.sp,
                                            color: amountColor,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (!isLast)
                        Padding(
                          padding: EdgeInsets.only(left: 16.w),
                          child: Divider(
                              height: 1,
                              thickness: 1,
                              color: kBorder.withOpacity(0.7)),
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 1.h),
          ],
        ),
      );
    });
  }

  String _getTransactionIcon(String iconName) {
    switch (iconName) {
      case 'income':
        return Mdi.cash;
      case 'expense':
        return Mdi.cash_minus;
      case 'invoice':
        return Mdi.receipt;
      case 'payment':
        return Mdi.credit_card;
      default:
        return Mdi.circle;
    }
  }

  Widget _buildQuickActions() {
    return Obx(() {
      if (_controller.quickActions.isEmpty) return const SizedBox.shrink();
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kCardBg, kPrimary.withOpacity(0.04)],
          ),
          borderRadius: BorderRadius.circular(5.w),
          border: Border.all(color: kBorder.withOpacity(0.9)),
          boxShadow: [
            BoxShadow(
                color: kPrimary.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 8))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Shortcuts',
                    style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: kText,
                        letterSpacing: -0.3)),
                SizedBox(width: 2.w),
                Expanded(
                    child: Container(height: 1, color: kBorder.withOpacity(0.8))),
              ],
            ),
            SizedBox(height: 0.5.h),
            Text('Common tasks',
                style: TextStyle(fontSize: 13.sp, color: kSubText)),
            SizedBox(height: 2.h),
            Row(
              children: _controller.quickActions.map((action) {
                final label = action['label'] ?? '';
                final iconName = action['icon'] ?? 'circle';
                final colorHex = action['color'] ?? '#3498DB';
                final color = _controller.getColorFromHex(colorHex);
                return _buildQuickActionButton(
                  label,
                  _getQuickActionIcon(iconName),
                  color,
                  () {
                    switch (label) {
                      case 'Income':
                        Get.to(() => const IncomeScreen());
                        break;
                      case 'Expense':
                        Get.to(() => const ExpenseScreen());
                        break;
                      case 'Invoice':
                        setState(() => _currentTab = 2);
                        break;
                      case 'Customer':
                        Get.to(CustomersScreen());
                        break;
                      default:
                        Get.snackbar(label, '$label module coming soon',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: kPrimary,
                            colorText: Colors.white);
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      );
    });
  }

  String _getQuickActionIcon(String iconName) {
    switch (iconName) {
      case 'income':
        return Mdi.cash;
      case 'expense':
        return Mdi.cash_minus;
      case 'invoice':
        return Mdi.receipt;
      case 'customer':
        return Mdi.account;
      default:
        return Mdi.circle;
    }
  }

  Widget _buildQuickActionButton(
      String label, String icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4.w),
          child: Ink(
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(4.w),
              border: Border.all(color: color.withOpacity(0.35)),
              boxShadow: [
                BoxShadow(
                    color: color.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Padding(
              padding:
                  EdgeInsets.symmetric(vertical: 1.8.h, horizontal: 1.w),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.2.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [
                        color.withOpacity(0.2),
                        color.withOpacity(0.08)
                      ]),
                    ),
                    child: Iconify(icon, color: color, size: 5.5.w),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: kText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ✅ FIX 3: Bottom nav — tab 4 directly opens drawer via _scaffoldKey
  Widget _buildBottomNav() {
    final items = [
      {
        'icon': Mdi.view_dashboard_outline,
        'activeIcon': Mdi.view_dashboard,
        'label': 'Dashboard'
      },
      {
        'icon': Mdi.swap_horizontal,
        'activeIcon': Mdi.swap_horizontal,
        'label': 'Transactions'
      },
      {
        'icon': Mdi.receipt_outline,
        'activeIcon': Mdi.receipt,
        'label': 'Invoices'
      },
      {
        'icon': Mdi.menu,
        'activeIcon': Mdi.menu,
        'label': 'Menu'
      },
    
    ];

    return Container(
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 20,
              offset: const Offset(0, -4)),
          BoxShadow(
              color: kPrimary.withOpacity(0.04),
              blurRadius: 0,
              offset: Offset.zero),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 1.2.h, horizontal: 1.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              // ✅ FIX 3: For tab 4, _currentTab stays where it was — just open drawer
              final isActive = (i == 3) ? false : _currentTab == i;

              return InkWell(
                onTap: () {
                  if (i == 3) {
                    // ✅ Direct drawer open — no setState, no addPostFrameCallback
                    _scaffoldKey.currentState?.openDrawer();
                    return;
                  }
                  setState(() => _currentTab = i);
                },
                borderRadius: BorderRadius.circular(3.w),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.6.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.all(isActive ? 1.8.w : 1.2.w),
                        decoration: BoxDecoration(
                          color: isActive
                              ? kPrimary.withOpacity(0.12)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Iconify(
                          isActive
                              ? item['activeIcon'] as String
                              : item['icon'] as String,
                          color: isActive ? kPrimary : kSubText,
                          size: isActive ? 6.w : 5.5.w,
                        ),
                      ),
                      SizedBox(height: 0.6.h),
                      Text(
                        item['label'] as String,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: isActive ? kPrimary : kSubText,
                          fontWeight: isActive
                              ? FontWeight.w800
                              : FontWeight.w500,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      width: 85.w,
      child: Column(
        children: [
          _buildEnhancedDrawerHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              // ✅ FIX 4: addAutomaticKeepAlives false — less memory pressure on many sections
              addAutomaticKeepAlives: false,
              children: [
                _buildExpandableSection('LedgerPro Core', Mdi.account_circle,
                    ['Chart of Accounts', 'Journal Entries', 'General Ledger', 'Trial Balance', 'Bank Accounts', 'Income', 'Expense']),
                _buildExpandableSection('Receivables & Payables', Mdi.swap_horizontal,
                    ['Accounts Receivable', 'Accounts Payable', 'Customers', 'bills', 'Vendors / Suppliers', 'Payments Received', 'Payments Made', 'Credit Notes']),
                _buildExpandableSection('Assets & Liabilities', Mdi.business,
                    ['Fixed Assets', 'Loans & Borrowings', 'Capital / Equity']),
                _buildExpandableSection('Financial Reports', Mdi.chart_line,
                    ['Profit & Loss Statement', 'Balance Sheet', 'Cash Flow Statement', 'Aged Receivables']),
                Divider(height: 1, thickness: 1, color: kBorder),
                _buildExpandableSection('My Account', Mdi.account,
                    ['My Profile', 'Change Password']),
                // _buildExpandableSection('Data Management', Mdi.database,
                //     ['Backup & Restore']),
                _buildExpandableSection('Help & Support', Mdi.help_circle,
                    ['User Guide', 'Contact Support', 'Report an Issue']),
                _buildExpandableSection('Feedback', Mdi.feedback, ['Feedback']),
                _buildExpandableSection('Subscription', Mdi.crown, ['subscription']),
                _buildExpandableSection('About', Mdi.information,
                    ['About App', 'Terms of Service', 'Privacy Policy',]),
                Divider(height: 1, thickness: 1, color: kBorder),
                _buildLogoutButton(),
                SizedBox(height: 2.h),
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    child: Text('Version 1.0.0',
                        style: TextStyle(fontSize: 13.sp, color: kSubText)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

Widget _buildEnhancedDrawerHeader() {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
    decoration: const BoxDecoration(
      gradient: LinearGradient(colors: [kPrimary, kPrimaryDark]),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white,
              child: Iconify(Mdi.business, size: 28, color: kPrimary),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => Text(
                        _controller.companyName.value.isEmpty
                            ? 'Company'
                            : _controller.companyName.value,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      )),
                  Obx(() => Text(
                        _controller.userEmail.value.isEmpty
                            ? 'Your Business Name'
                            : _controller.userEmail.value,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13.sp,
                        ),
                        overflow: TextOverflow.ellipsis,
                      )),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 1.5.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(2.w),
          ),
          child: Row(
            children: [
              Iconify(Mdi.shield_account, size: 3.5.w, color: Colors.white70),
              SizedBox(width: 2.w),
              Text('Plan',
                  style: TextStyle(fontSize: 13.sp, color: Colors.white70)),
              const Spacer(),
              Obx(() => Text(
                    _subscriptionController.hasActiveSubscription.value
                        ? 'Premium Plan'
                        : _subscriptionController.isTrialActive.value
                            ? 'Trial Active'
                            : 'Expired',
                    style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  )),
            ],
          ),
        ),
      ],
    ),
  );
}  Widget _buildLogoutButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showLogoutDialog(),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.8.h),
          child: Row(
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: kDanger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2.w),
                ),
                child: Iconify(Mdi.logout, size: 4.5.w, color: kDanger),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text('Logout',
                    style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: kDanger)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProfileDialog() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Profile',
                    style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: kText)),
                IconButton(
                  icon: Iconify(Mdi.close, size: 5.w),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            Divider(color: kBorder),
            SizedBox(height: 2.h),
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: kPrimary.withOpacity(0.1),
                child: Iconify(Mdi.account, size: 10.w, color: kPrimary),
              ),
            ),
            SizedBox(height: 1.5.h),
            Text('Ahmed Khan',
                style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: kText)),
            Text('ahmed@zolatech.com',
                style: TextStyle(fontSize: 13.sp, color: kSubText)),
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: kSuccess.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: Text('Admin',
                  style: TextStyle(
                      fontSize: 13.sp,
                      color: kSuccess,
                      fontWeight: FontWeight.w600)),
            ),
            SizedBox(height: 2.h),
            ElevatedButton(
              onPressed: () {
                Get.back();
                _showEditProfileDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
              ),
              child: Text('Edit Profile',
                  style: TextStyle(fontSize: 13.sp, color: Colors.white)),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Edit Profile',
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(
                  labelText: 'Name', border: OutlineInputBorder()),
            ),
            SizedBox(height: 2.h),
            const TextField(
              decoration: InputDecoration(
                  labelText: 'Email', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar('Success', 'Profile updated successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: kSuccess,
                  colorText: Colors.white);
            },
            style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Logout',
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800)),
        content: Text('Are you sure you want to logout?',
            style: TextStyle(fontSize: 13.sp)),
        actions: [
          TextButton(
              onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              SharedPreferences.getInstance().then((prefs) => prefs.clear());
              Get.offAll(() => const LoginScreen());
              Get.snackbar('Success', 'Logged out successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: kSuccess,
                  colorText: Colors.white);
            },
            style: ElevatedButton.styleFrom(backgroundColor: kDanger),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSection(
      String title, String icon, List<String> items) {
    return ExpandableSection(title: title, iconName: icon, items: items);
  }
}

// ============================================================
// ExpandableSection — unchanged logic, Get.back() fix applied
// ============================================================
class ExpandableSection extends StatefulWidget {
  final String title;
  final String iconName;
  final List<String> items;
  const ExpandableSection(
      {super.key,
      required this.title,
      required this.iconName,
      required this.items});

  @override
  State<ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.8.h),
              child: Row(
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: kPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                    child: Iconify(widget.iconName, size: 4.5.w, color: kPrimary),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: kText),
                    ),
                  ),
                  Iconify(
                    _isExpanded ? Mdi.chevron_up : Mdi.chevron_down,
                    size: 5.w,
                    color: kSubText,
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: _isExpanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Container(
            color: kBg.withOpacity(0.3),
            child: Column(
              children: widget.items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Column(
                  children: [
                    _buildMenuItem(item),
                    if (index < widget.items.length - 1)
                      Divider(
                        height: 1,
                        indent: 12.w,
                        endIndent: 5.w,
                        color: kBorder.withOpacity(0.5),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildMenuItem(String item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // ✅ FIX 4: Get.back() is faster than Navigator.pop(context)
          Get.back();
          _navigateToScreen(item);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 1.5.h),
          child: Row(
            children: [
              SizedBox(
                width: 5.w,
                height: 5.w,
                child: Iconify(
                  _getIconForMenuItem(item),
                  size: 4.w,
                  color: kSubText,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  item,
                  style: TextStyle(
                      fontSize: 15.sp,
                      color: kText,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToScreen(String item) {
    switch (item) {
      case 'Terms of Service': Get.to(() => const TermsOfServiceScreen());
        break;
        case 'Privacy Policy' : Get.to(()=> PrivacyPolicyScreen());
        // case 'Licenses' : Get
      case 'About App':
        Get.to(() => const AboutAppScreen());
        break;
      case 'Change Password':
        Get.to(() => ChangePasswordScreen());
        break;
      case 'My Profile':
        Get.to(() => ProfileScreen());
        break;
      case 'Income':
        Get.to(() => const IncomeScreen());
        break;
      case 'Expense':
        Get.to(() => const ExpenseScreen());
        break;
      case 'Profit & Loss Statement':
        Get.to(() => const ProfitLossStatementScreen());
        break;
      case 'Balance Sheet':
        Get.to(() => const BalanceSheetScreen());
        break;
      case 'Cash Flow Statement':
        Get.to(() => const CashFlowStatementScreen());
        break;
      case 'Aged Receivables':
        Get.to(() => const AgedReceivablesScreen());
        break;
      case 'Chart of Accounts':
        Get.to(() => const ChartOfAccountsScreen());
        break;
      case 'Journal Entries':
        Get.to(() => const JournalEntriesScreen());
        break;
      case 'General Ledger':
        Get.to(() => const GeneralLedgerScreen());
        break;
      case 'Trial Balance':
        Get.to(() => const TrialBalanceScreen());
        break;
      case 'Bank Accounts':
        Get.to(() => const BankAccountsScreen());
        break;
      case 'Accounts Receivable':
        Get.to(() => const AccountsReceivableScreen());
        break;
      case 'Accounts Payable':
        Get.to(() => const AccountsPayableScreen());
        break;
      case 'Customers':
        Get.to(() => const CustomersScreen());
        break;
      case 'bills':
        Get.to(() => const BillsScreen());
        break;
      case 'Vendors / Suppliers':
        Get.to(() => const VendorsScreen());
        break;
      case 'Payments Received':
        Get.to(() => const PaymentsReceivedScreen());
        break;
      case 'Payments Made':
        Get.to(() => const PaymentsMadeScreen());
        break;
      case 'Credit Notes':
        Get.to(() => const CreditNotesScreen());
        break;
      case 'Fixed Assets':
        Get.to(() => const FixedAssetsScreen());
        break;
      case 'Loans & Borrowings':
        Get.to(() => const LoansBorrowingsScreen());
        break;
      case 'Capital / Equity':
        Get.to(() => const CapitalEquityScreen());
        break;
      case 'Contact Support':
        Get.to(() => const ContactScreen());
        break;
      case 'Report an Issue':
        Get.to(() => const ReportIssueScreen());
        break;
      case 'subscription':
        Get.to(() => const SelectPlanScreen());
      case 'User Guide':
        Get.to(() => const UserGuideScreen());
        break;
      case 'Feedback':
        Get.to(() => const FeedbackScreen());
        break;
      default:
        Get.snackbar(item, '$item module coming soon',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: kPrimary,
            colorText: Colors.white);
    }
  }

  String _getIconForMenuItem(String item) {
    switch (item) {
      case 'Feedback': return Mdi.feedback;
      case 'Chart of Accounts':        return Mdi.chart_tree;
      case 'Journal Entries':          return Mdi.book_open_page_variant;
      case 'General Ledger':           return Mdi.book_open_blank_variant;
      case 'Trial Balance':            return Mdi.scale_balance;
      case 'Bank Accounts':            return Mdi.bank;
      case 'Accounts Receivable':      return Mdi.cash_plus;
      case 'Accounts Payable':         return Mdi.cash_minus;
      case 'Income':                   return Mdi.trending_up;
      case 'Expense':                  return Mdi.trending_down;
      case 'bills':                    return Mdi.file_document_outline;
      case 'Profit & Loss Statement':  return Mdi.chart_line;
      case 'Balance Sheet':            return Mdi.clipboard_list_outline;
      case 'Cash Flow Statement':      return Mdi.cash;
      case 'Aged Receivables':         return Mdi.account_clock;
      case 'Customers':                return Mdi.account_group;
      case 'Vendors / Suppliers':      return Mdi.truck_delivery_outline;
      case 'Payments Received':        return Mdi.credit_card_outline;
      case 'Payments Made':            return Mdi.cash_check;
      case 'Credit Notes':             return Mdi.file_undo_outline;
      case 'Fixed Assets':             return Mdi.office_building_outline;
      case 'Loans & Borrowings':       return Mdi.hand_coin_outline;
      case 'Capital / Equity':         return Mdi.chart_donut;
      case 'subscription':             return Mdi.crown;
      case 'My Profile':               return Mdi.account_circle_outline;
      case 'Change Password':          return Mdi.lock_reset;
      case 'Backup & Restore':         return Mdi.database_export_outline;
      case 'Help Center':              return Mdi.help_circle_outline;
      case 'User Guide':               return Mdi.book_information_variant;
      case 'Contact Support':          return Mdi.headset;
      case 'Report an Issue':          return Mdi.bug_outline;
      case 'About App':                return Mdi.information_outline;
      case 'Terms of Service':         return Mdi.file_sign;
      case 'Privacy Policy':           return Mdi.shield_lock_outline;
      default:                         return Mdi.circle_outline;
    }
  }
}