import 'package:LedgerPro_app/Utils/responsive_utils.dart';
import 'package:LedgerPro_app/core/Register/Views/register_screen.dart';
import 'package:LedgerPro_app/core/dashboard/Screens/dashbaord_screen.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';
import '../controller/login_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.put(LoginController());
    return Scaffold(
      backgroundColor: Colors.white,
      body: ResponsiveUtils.isWeb(context)
          ? _buildWebLayout(context, controller)
          : _buildMobileTabletLayout(context, controller),
    );
  }

  // ══════════════════════════════════════════════════
  // WEB LAYOUT — fills full screen height, no overflow
  // ══════════════════════════════════════════════════
  Widget _buildWebLayout(BuildContext context, LoginController controller) {
    final screenH = MediaQuery.of(context).size.height;

    return Row(
      children: [
        // ── LEFT PANEL ──────────────────────────────
        Expanded(
          flex: 1,
          child: Container(
            height: screenH,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0A7FA8), Color(0xFF1AB4F5), Color(0xFF4ECEF7)],
              ),
            ),
            child: Stack(
              children: [
                // Decorative circles — clipped so they never cause overflow
                Positioned(
                  top: -80,
                  left: -60,
                  child: _bgCircle(300, Colors.white.withOpacity(0.05)),
                ),
                Positioned(
                  bottom: -60,
                  right: -40,
                  child: _bgCircle(250, Colors.white.withOpacity(0.05)),
                ),
                Positioned(
                  top: screenH * 0.35,
                  right: -50,
                  child: _bgCircle(160, Colors.white.withOpacity(0.07)),
                ),

                // Content — scrollable so it NEVER clips
                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 28),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: screenH - 56),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo icon
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.35),
                                  width: 1.5),
                            ),
                            child: const Icon(Icons.account_balance,
                                color: Colors.white, size: 36),
                          ),
                          const SizedBox(height: 16),

                          // App name
                          const Text(
                            'LedgerPro',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Professional Accounting Made Simple',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.85),
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Accounting illustration
                          const _AccountingIllustration(),

                          const SizedBox(height: 24),

                          // Feature chips in a 2×2 grid so they never wrap awkwardly
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            children: [
                              _featureChip(
                                  Icons.cloud_sync_rounded, 'Cloud Sync'),
                              _featureChip(
                                  Icons.security_rounded, 'Bank Security'),
                              _featureChip(
                                  Icons.analytics_rounded, 'Analytics'),
                              _featureChip(
                                  Icons.bar_chart_rounded, 'Reports'),
                            ],
                          ),

                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── RIGHT PANEL ──────────────────────────────
        Expanded(
          flex: 1,
          child: SizedBox(
            height: screenH,
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: _buildLoginForm(context, controller),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════
  // MOBILE & TABLET LAYOUT
  // ══════════════════════════════════════════════════
  Widget _buildMobileTabletLayout(
      BuildContext context, LoginController controller) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: ResponsiveUtils.getScreenPadding(context),
        child: Center(
          child: SizedBox(
            width: ResponsiveUtils.getFormWidth(context),
            child: _buildLoginForm(context, controller),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════
  // SHARED LOGIN FORM
  // ══════════════════════════════════════════════════
  Widget _buildLoginForm(BuildContext context, LoginController controller) {
    final bool isMobile = ResponsiveUtils.isMobile(context);
    final bool isTablet = ResponsiveUtils.isTablet(context);
    final bool isWeb = ResponsiveUtils.isWeb(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back button — mobile/tablet only
        if (!isWeb)
          IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(Icons.arrow_back,
                color: const Color(0xFF1AB4F5),
                size: isMobile ? 24 : 20),
            onPressed: () => Get.back(),
          ),
        if (!isWeb) const SizedBox(height: 16),

        // Logo + app name — mobile/tablet only
        if (!isWeb)
          Center(
            child: Column(
              children: [
                Container(
                  width: ResponsiveUtils.getLogoSize(context),
                  height: ResponsiveUtils.getLogoSize(context),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1AB4F5), Color(0xFF0D8CBF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(
                        ResponsiveUtils.getLogoSize(context) * 0.22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1AB4F5).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: Icon(Icons.account_balance,
                      color: Colors.white,
                      size: ResponsiveUtils.getLogoSize(context) * 0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'LedgerPro',
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1AB4F5),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

        // Welcome heading
        Center(
          child: Column(
            children: [
              Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getHeadingFontSize(context),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Sign in to continue to your account',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getSubheadingFontSize(context),
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Email
        _fieldLabel('Email Address', context),
        const SizedBox(height: 8),
        Obx(() => _buildTextField(
              controller: controller.emailController,
              onChanged: (_) => controller.clearEmailError(),
              keyboardType: TextInputType.emailAddress,
              hint: 'you@example.com',
              prefixIcon: Icons.email_outlined,
              errorText: controller.emailError.value.isEmpty
                  ? null
                  : controller.emailError.value,
              context: context,
            )),

        const SizedBox(height: 20),

        // Password
        _fieldLabel('Password', context),
        const SizedBox(height: 8),
        Obx(() => _buildTextField(
              controller: controller.passwordController,
              onChanged: (_) => controller.clearPasswordError(),
              obscureText: !controller.isPasswordVisible.value,
              hint: 'Enter your password',
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.isPasswordVisible.value
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.grey[400],
                  size: 22,
                ),
                onPressed: () => controller.isPasswordVisible.toggle(),
              ),
              errorText: controller.passwordError.value.isEmpty
                  ? null
                  : controller.passwordError.value,
              context: context,
            )),

        // Forgot password
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => controller.forgotPassword(),
            style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 8)),
            child: Text(
              'Forgot Password?',
              style: TextStyle(
                color: const Color(0xFF1AB4F5),
                fontWeight: FontWeight.w600,
                fontSize: ResponsiveUtils.getSubheadingFontSize(context),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Sign In button
        Obx(() => SizedBox(
              width: double.infinity,
              height: ResponsiveUtils.getButtonHeight(context),
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () async {
                        bool success = await controller.login();
                        if (success) {
                          Get.offAll(() => const DashboardScreen());
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1AB4F5),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Text(
                        'Sign In',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            )),

        const SizedBox(height: 24),

        // Divider
        Row(
          children: [
            Expanded(
                child: Divider(color: Colors.grey[300], thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('OR',
                  style: TextStyle(
                      color: Colors.grey[500], fontSize: 12)),
            ),
            Expanded(
                child: Divider(color: Colors.grey[300], thickness: 1)),
          ],
        ),

        const SizedBox(height: 24),

        // Sign Up
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account? ",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: ResponsiveUtils.getSubheadingFontSize(context),
              ),
            ),
            GestureDetector(
              onTap: () => Get.to(() => const RegistrationScreen()),
              child: Text(
                'Sign Up',
                style: TextStyle(
                  color: const Color(0xFF1AB4F5),
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveUtils.getSubheadingFontSize(context),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────

  Widget _bgCircle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  Widget _featureChip(IconData icon, String label) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        border:
            Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label, BuildContext context) => Text(
        label,
        style: TextStyle(
          fontSize: ResponsiveUtils.getSubheadingFontSize(context),
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1A1A2E),
        ),
      );

  Widget _buildTextField({
    required TextEditingController controller,
    required void Function(String) onChanged,
    required String hint,
    required IconData prefixIcon,
    required BuildContext context,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? errorText,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        prefixIcon: Icon(prefixIcon, color: Colors.grey[400], size: 22),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF5F8FC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF1AB4F5), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Colors.red, width: 2),
        ),
        errorText: errorText,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 16),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  ACCOUNTING ILLUSTRATION  — pure Flutter, fixed pixel sizes
// ════════════════════════════════════════════════════════════════════

class _AccountingIllustration extends StatelessWidget {
  const _AccountingIllustration();

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder so the card adapts to whatever width it gets
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth.clamp(0.0, 380.0);
        return Container(
          width: w,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: Colors.white.withOpacity(0.25), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,   // ← key: don't expand
            children: [
              // Window title bar
              Row(
                children: [
                  _dot(const Color(0xFFFF5F57)),
                  const SizedBox(width: 5),
                  _dot(const Color(0xFFFFBD2E)),
                  const SizedBox(width: 5),
                  _dot(const Color(0xFF28CA41)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Section title
              const Text(
                'General Ledger — Q4 2024',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),

              const SizedBox(height: 8),

              // Table header
              _tableRow('Description', 'Debit', 'Credit',
                  isHeader: true),
              const SizedBox(height: 4),
              _hLine(),
              const SizedBox(height: 4),

              // Rows
              _tableRow('Sales Revenue', '\$8,200', '—'),
              _tableRow('Office Supplies', '—', '\$1,300'),
              _tableRow('Payroll Expense', '—', '\$2,100'),
              _tableRow('Consulting Fee', '\$600', '—'),

              const SizedBox(height: 4),
              _hLine(),
              const SizedBox(height: 6),

              // Net balance
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Net Balance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFF28CA41).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: const Color(0xFF28CA41)
                              .withOpacity(0.5),
                          width: 1),
                    ),
                    child: const Text(
                      '+ \$5,400',
                      style: TextStyle(
                        color: Color(0xFF28CA41),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Bar chart label
              Text(
                'Monthly Revenue',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              // Bar chart — fixed height 60px
              const SizedBox(height: 60, child: _MiniBarChart()),

              const SizedBox(height: 12),

              // KPI row
              IntrinsicHeight(
                child: Row(
                  children: [
                    _kpiChip('ROI', '24.5%', Colors.cyanAccent),
                    const SizedBox(width: 6),
                    _kpiChip('Tax', '18%', Colors.orangeAccent),
                    const SizedBox(width: 6),
                    _kpiChip('Profit', '32%',
                        const Color(0xFF28CA41)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dot(Color color) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  Widget _hLine() => Container(
        height: 1,
        color: Colors.white.withOpacity(0.2),
      );

  Widget _tableRow(String description, String debit, String credit,
      {bool isHeader = false}) {
    final color =
        isHeader ? Colors.white : Colors.white.withOpacity(0.8);
    final fw =
        isHeader ? FontWeight.w700 : FontWeight.normal;
    const fs = 10.0;

    final debitColor = isHeader
        ? Colors.white
        : (debit == '—'
            ? Colors.white.withOpacity(0.25)
            : Colors.greenAccent.shade100);
    final creditColor = isHeader
        ? Colors.white
        : (credit == '—'
            ? Colors.white.withOpacity(0.25)
            : Colors.red.shade200);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(description,
                style: TextStyle(
                    color: color, fontSize: fs, fontWeight: fw)),
          ),
          SizedBox(
            width: 60,
            child: Text(debit,
                textAlign: TextAlign.end,
                style: TextStyle(
                    color: debitColor,
                    fontSize: fs,
                    fontWeight: fw)),
          ),
          SizedBox(
            width: 60,
            child: Text(credit,
                textAlign: TextAlign.end,
                style: TextStyle(
                    color: creditColor,
                    fontSize: fs,
                    fontWeight: fw)),
          ),
        ],
      ),
    );
  }

  Widget _kpiChip(String label, String value, Color accent) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: accent.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
          border:
              Border.all(color: accent.withOpacity(0.35), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value,
                style: TextStyle(
                    color: accent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  MINI BAR CHART  — fixed pixel heights, no .h usage
// ════════════════════════════════════════════════════════════════════

class _MiniBarChart extends StatelessWidget {
  const _MiniBarChart();

  @override
  Widget build(BuildContext context) {
    const data = [
      (0.50, 'Jul'),
      (0.68, 'Aug'),
      (0.42, 'Sep'),
      (0.80, 'Oct'),
      (0.63, 'Nov'),
      (1.00, 'Dec'),
    ];

    // Parent SizedBox fixes height at 60px
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.map((d) {
        final isHighest = d.$1 == 1.0;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 14,
              // 60px total area, leave 16px for label row
              height: 44 * d.$1,
              decoration: BoxDecoration(
                color: isHighest
                    ? Colors.white
                    : Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              d.$2,
              style: TextStyle(
                color: Colors.white.withOpacity(0.65),
                fontSize: 9,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}