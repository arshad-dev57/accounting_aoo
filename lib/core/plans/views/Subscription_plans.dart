import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/core/dashboard/Screens/dashbaord_screen.dart';
import 'package:LedgerPro_app/core/plans/controllers/subscription_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class SelectPlanScreen extends StatefulWidget {
  const SelectPlanScreen({super.key});

  @override
  State<SelectPlanScreen> createState() => _SelectPlanScreenState();
}

class _SelectPlanScreenState extends State<SelectPlanScreen>
    with SingleTickerProviderStateMixin {
  final SubscriptionController _subCtrl = Get.find<SubscriptionController>();

  // Currently selected plan id from backend (e.g. 'monthly' or 'yearly')
  String _selectedPlanId = 'monthly';
  bool _isProcessing = false;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    // Load plans from backend if not already loaded
    if (_subCtrl.plans.isEmpty) {
      _subCtrl.loadPlans().then((_) {
        // Auto-select first plan after load
        if (_subCtrl.plans.isNotEmpty && mounted) {
          setState(() {
            _selectedPlanId = _subCtrl.plans[0]['id'] ?? 'monthly';
          });
        }
      });
    } else {
      _selectedPlanId = _subCtrl.plans[0]['id'] ?? 'monthly';
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── Get selected plan map from backend data ──
  Map<String, dynamic> get _selectedPlan {
    return _subCtrl.plans.firstWhere(
      (p) => (p['id'] ?? '') == _selectedPlanId,
      orElse: () => _subCtrl.plans.isNotEmpty ? _subCtrl.plans[0] : {},
    );
  }

  // ── Subscribe handler ──
  Future<void> _handleSubscription() async {
    if (_selectedPlan.isEmpty) return;

    setState(() => _isProcessing = true);

    final planId = _selectedPlan['id'] as String;
    final amount = (_selectedPlan['price'] as num).toDouble();

    _showLoadingDialog();
    final success = await _subCtrl.subscribe(planId, amount);
    if (mounted) Navigator.pop(context);

    if (success) {
      Get.offAll(() => const DashboardScreen());
    }
    if (mounted) setState(() => _isProcessing = false);
  }

  // ── Upgrade from trial handler ──
  Future<void> _handleUpgradeFromTrial() async {
    // Get first paid plan (monthly or yearly)
    if (_subCtrl.plans.isEmpty) {
      await _subCtrl.loadPlans();
    }
    
    final paidPlan = _subCtrl.plans.firstWhere(
      (p) => p['id'] != 'trial',
      orElse: () => {},
    );
    
    if (paidPlan.isEmpty) return;
    
    setState(() => _isProcessing = true);
    
    final planId = paidPlan['id'] as String;
    final amount = (paidPlan['price'] as num).toDouble();
    
    _showLoadingDialog();
    final success = await _subCtrl.subscribe(planId, amount);
    if (mounted) Navigator.pop(context);
    
    if (success) {
      Get.offAll(() => const DashboardScreen());
    }
    if (mounted) setState(() => _isProcessing = false);
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Container(
          padding: EdgeInsets.all(5.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.w),
          ),
          child: CircularProgressIndicator(color: kPrimary, strokeWidth: 3),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimary,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Obx(() {
            return Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: _subCtrl.hasAccess
                      ? _buildActiveSubscriptionView()
                      : _buildPlansView(),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          SizedBox(width: 3.w),
          Text(
            _subCtrl.hasAccess ? 'My Subscription' : 'Select a Plan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSubscriptionView() {
    final plan = _subCtrl.subscriptionPlan.value;
    final status = _subCtrl.subscriptionStatus.value;
    final isTrial = _subCtrl.isTrialActive.value;
    final daysLeft = _subCtrl.remainingDays;
    final totalDays = isTrial ? 30 : (plan == 'yearly' ? 365 : 30);
    final progress =
        daysLeft <= 0 ? 1.0 : (daysLeft / totalDays).clamp(0.0, 1.0);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: [
          SizedBox(height: 1.h),

          // ── Hero card ──
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(5.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isTrial
                    ? [const Color(0xFF1565C0), const Color(0xFF1E88E5)]
                    : [const Color(0xFF0D7C3D), const Color(0xFF1AB45A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(5.w),
              boxShadow: [
                BoxShadow(
                  color: (isTrial
                          ? const Color(0xFF1565C0)
                          : const Color(0xFF0D7C3D))
                      .withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 3.w, vertical: 0.6.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10.w),
                  ),
                  child: Text(
                    isTrial ? '🎯 Free Trial' : '⭐ Premium Active',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 2.h),

                // Plan name
                Text(
                  _getPlanDisplayName(plan, isTrial),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                SizedBox(height: 0.8.h),

                // Status dot
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF76FF9A),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 1.5.w),
                    Text(
                      _capitalize(status),
                      style: TextStyle(
                        color: const Color(0xFFB2FFD0),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 3.h),

                // Days + progress bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$daysLeft days remaining',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$totalDays day plan',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white.withOpacity(0.25),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF76FF9A)),
                  ),
                ),

                // End date
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        color: Colors.white.withOpacity(0.7), size: 14),
                    SizedBox(width: 1.5.w),
                    Text(
                      isTrial
                          ? 'Trial ends: ${_formatDate(_subCtrl.trialEndDate.value)}'
                          : 'Renews: ${_formatDate(_subCtrl.subscriptionEndDate.value)}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 2.5.h),

          // ── Trial upgrade nudge (WITH WORKING BUTTON) ──
          if (isTrial) ...[
            _buildUpgradeNudge(),
            SizedBox(height: 2.h),
          ],
          _buildActivePlanFeaturesCard(plan),

          SizedBox(height: 2.5.h),
          if (!isTrial)
            GestureDetector(
              onTap: _showCancelDialog,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(3.w),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.2), width: 1),
                ),
                child: Text(
                  'Cancel Subscription',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

          SizedBox(height: 3.h),
        ],
      ),
    );
  }

  /// Backend plans list se plan ka naam lao
  String _getPlanDisplayName(String planId, bool isTrial) {
    if (isTrial) return 'LedgerPro Pro — Trial';
    final match = _subCtrl.plans.firstWhere(
      (p) => (p['id'] ?? '') == planId,
      orElse: () => {},
    );
    if (match.isNotEmpty) return match['name'] ?? 'LedgerPro Pro';
    return 'LedgerPro Pro — ${_capitalize(planId)}';
  }

  // ✅ FIXED: Working Upgrade Button
  Widget _buildUpgradeNudge() {
    final days = _subCtrl.trialDaysRemaining.value;
    final isUrgent = days <= 5;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isUrgent
            ? const Color(0xFFFFF3E0)
            : Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(
          color: isUrgent
              ? const Color(0xFFFFB74D)
              : Colors.white.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Text(isUrgent ? '⚠️' : '💡', style: const TextStyle(fontSize: 22)),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUrgent
                      ? 'Trial ends in $days days!'
                      : 'Enjoying your trial?',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isUrgent
                        ? const Color(0xFFE65100)
                        : const Color(0xFF1A1A2E),
                  ),
                ),
                SizedBox(height: 0.4.h),
                Text(
                  'Subscribe now to keep all premium features.',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          SizedBox(width: 2.w),
          // ✅ WORKING BUTTON - InkWell with onTap
          InkWell(
            onTap: _handleUpgradeFromTrial,
            borderRadius: BorderRadius.circular(2.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: kPrimary,
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: Text(
                'Upgrade',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Active subscription features — backend plan se match karke dikhao
  Widget _buildActivePlanFeaturesCard(String planId) {
    final match = _subCtrl.plans.firstWhere(
      (p) => (p['id'] ?? '') == planId,
      orElse: () => {},
    );

    // Backend se features, fallback agar plans load na hoon
    final List<String> features = match.isNotEmpty
        ? List<String>.from(match['features'] ?? [])
        : [
            'Full access to all features',
            'Unlimited transactions',
            'All financial reports',
            'Export to Excel/PDF',
            'Email support',
            'Data backup',
          ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.workspace_premium_rounded,
                  color: kPrimary, size: 5.w),
              SizedBox(width: 2.w),
              Text(
                'Your Plan Includes',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ...features.map((f) => _buildFeatureTile(f)),
        ],
      ),
    );
  }

  void _showCancelDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.w)),
        title: const Text('Cancel Subscription',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
            'Are you sure? You will lose access at the end of your billing period.'),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: const Text('Keep Plan')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Get.back();
              _subCtrl.cancelSubscription();
            },
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // VIEW 2 — PLANS LIST (no active subscription)
  // ═══════════════════════════════════════════════════

  Widget _buildPlansView() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: [
          SizedBox(height: 1.h),

          // Trial banner
          if (_subCtrl.trialDaysRemaining.value > 0) ...[
            _buildTrialBanner(),
            SizedBox(height: 1.5.h),
          ],

          // Loading spinner
          if (_subCtrl.isLoading.value && _subCtrl.plans.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            )

          // Error / empty state with retry
          else if (_subCtrl.plans.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 6.h),
              child: Column(
                children: [
                  Icon(Icons.wifi_off_rounded,
                      color: Colors.white54, size: 12.w),
                  SizedBox(height: 2.h),
                  Text(
                    'Could not load plans.\nPlease check your connection.',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: Colors.white70, fontSize: 13.sp),
                  ),
                  SizedBox(height: 2.h),
                  ElevatedButton(
                    onPressed: () => _subCtrl.loadPlans(),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white),
                    child: Text('Retry',
                        style: TextStyle(color: kPrimary)),
                  ),
                ],
              ),
            )

          // Plans loaded
          else ...[
            // Tab selector
            _buildPlanTabs(),
            SizedBox(height: 2.h),

            // Selected plan detail card
            _buildSelectedPlanCard(),
            SizedBox(height: 2.h),

            // Footer
            _buildFooter(),
          ],

          SizedBox(height: 3.h),
        ],
      ),
    );
  }

  Widget _buildTrialBanner() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(3.w),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: Icon(Icons.celebration, color: kPrimary, size: 6.w),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🎉 ${_subCtrl.trialDaysRemaining.value} Days Free Trial Active!',
                  style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: kPrimary),
                ),
                SizedBox(height: 0.4.h),
                Text(
                  'Subscribe now to continue after trial ends',
                  style: TextStyle(
                      fontSize: 10.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Plan tabs — backend `plans` list se dynamically banao
  Widget _buildPlanTabs() {
    return Container(
      padding: EdgeInsets.all(1.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8.w),
      ),
      child: Row(
        children: _subCtrl.plans.map((plan) {
          final id = plan['id'] as String? ?? '';
          final name = plan['name'] as String? ?? id;
          final isSelected = _selectedPlanId == id;
          final isPopular = plan['isPopular'] == true;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPlanId = id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: EdgeInsets.symmetric(
                    horizontal: 2.w, vertical: 1.2.h),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(6.w),
                ),
                child: Column(
                  children: [
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? kPrimary : Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isPopular) ...[
                      SizedBox(height: 0.3.h),
                      Text(
                        '⭐ Popular',
                        style: TextStyle(
                          fontSize: 8.sp,
                          color: isSelected
                              ? Colors.orange
                              : Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Selected plan detail card — 100% backend data
  Widget _buildSelectedPlanCard() {
    final plan = _selectedPlan;
    if (plan.isEmpty) return const SizedBox.shrink();

    final name = plan['name'] as String? ?? 'Plan';
    final price = plan['price'] as num? ?? 0;
    final currency = plan['currency'] as String? ?? 'PKR';
    final duration = plan['duration'] as String? ?? '';
    final features = List<String>.from(plan['features'] ?? []);
    final savings = plan['savings'] as String?;
    final isPopular = plan['isPopular'] == true;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan name + popular badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                ),
                if (isPopular)
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 2.5.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE5B4),
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                    child: Text(
                      '⭐ Most Popular',
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: const Color(0xFF8B6914),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: 2.h),

            // Price
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$currency ${_formatPrice(price)}',
                  style: TextStyle(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1A2E),
                    height: 1,
                  ),
                ),
                SizedBox(width: 2.w),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(
                    '/ $duration',
                    style: TextStyle(
                        fontSize: 11.sp, color: Colors.grey[500]),
                  ),
                ),
              ],
            ),

            // Savings badge
            if (savings != null) ...[
              SizedBox(height: 1.2.h),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 3.w, vertical: 0.7.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4F5E2),
                  borderRadius: BorderRadius.circular(2.w),
                ),
                child: Text(
                  savings,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: const Color(0xFF1A6B45),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],

            SizedBox(height: 3.h),
            Divider(color: Colors.grey[100]),
            SizedBox(height: 2.h),

            // Features header
            Row(
              children: [
                Icon(Icons.check_circle, color: kPrimary, size: 5.w),
                SizedBox(width: 2.w),
                Text(
                  'Plan includes',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.5.h),

            // Features list — directly from backend
            ...features.map((f) => _buildFeatureTile(f)),

            SizedBox(height: 2.h),

            // Subscribe button
            SizedBox(
              width: double.infinity,
              height: 7.h,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _handleSubscription,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.w),
                  ),
                ),
                child: _isProcessing
                    ? SizedBox(
                        height: 4.w,
                        width: 4.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Start $name — $currency ${_formatPrice(price)}',
                        style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600),
                      ),
              ),
            ),

            SizedBox(height: 1.5.h),
            Text(
              'Cancel anytime. Add-ons available upon request.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 9.sp, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Shared Widgets
  // ─────────────────────────────────────────────

  Widget _buildFeatureTile(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: kPrimary, size: 11),
          ),
          SizedBox(width: 2.5.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF3D3D5C),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Pricing plan and offer terms',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(width: 1.5.w),
            Container(
              width: 4.w,
              height: 4.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Icon(Icons.info_outline,
                  size: 10, color: Colors.white),
            ),
          ],
        ),
        SizedBox(height: 1.5.h),
         RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
            children: [
              TextSpan(text: 'Join over 4.6 million\nsubscribers'),
              WidgetSpan(
                child: Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 2),
                  child: Icon(Icons.auto_awesome,
                      color: Color(0xFF7DDFF5), size: 18),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _formatPrice(num price) {
    return price
        .toInt()
        .toString()
        .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }
}