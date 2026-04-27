import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/Utils/responsive_utils.dart';
import 'package:LedgerPro_app/core/changepassword/controller/change_password_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ChangePasswordController controller = Get.put(ChangePasswordController());

    return Scaffold(
      backgroundColor: kBg,
      body: ResponsiveUtils.isWeb(context)
          ? _buildWebLayout(context, controller)
          : _buildMobileTabletLayout(context, controller),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // WEB LAYOUT
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildWebLayout(BuildContext context, ChangePasswordController controller) {
    final screenH = MediaQuery.of(context).size.height;

    return Row(
      children: [
        // LEFT PANEL - Image Section
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
                // Decorative circles
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
                // Content
                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: screenH - 56),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Security Icon
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.35), width: 1.5),
                            ),
                            child: const Iconify(Mdi.shield_account, color: Colors.white, size: 42),
                          ),
                          const SizedBox(height: 16),
                          // Title
                          const Text(
                            'Password Security',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Protect your account with a strong password',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.85),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 28),
                          // Security Tips Card
                          _buildSecurityTipsCard(),
                          const SizedBox(height: 24),
                          // Security Features
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            children: [
                              _featureChip(Mdi.shield_check, '256-bit Encryption'),
                              _featureChip(Mdi.shield_lock, 'Secure Storage'),
                              _featureChip(Mdi.two_factor_authentication, '2FA Ready'),
                              _featureChip(Mdi.shield_half_full, 'Bank Grade'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // RIGHT PANEL - Change Password Form
        Expanded(
          flex: 1,
          child: SizedBox(
            height: screenH,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Header for web
                      _buildWebHeader(),
                      const SizedBox(height: 32),
                      Container(
                        width: double.infinity,
                        child: _buildForm(controller, context),
                      ),
                      const SizedBox(height: 32),
                      _buildChangeButton(controller, context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // MOBILE & TABLET LAYOUT
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildMobileTabletLayout(BuildContext context, ChangePasswordController controller) {
    final isTablet = ResponsiveUtils.isTablet(context);
    
    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildMobileAppBar(context),
      body: SingleChildScrollView(
        padding: ResponsiveUtils.getScreenPadding(context),
        child: Center(
          child: SizedBox(
            width: ResponsiveUtils.getFormWidth(context),
            child: Column(
              children: [
                SizedBox(height: isTablet ? 16 : 8),
                _buildMobileHeader(context),
                SizedBox(height: isTablet ? 32 : 24),
                _buildForm(controller, context),
                SizedBox(height: isTablet ? 32 : 24),
                _buildChangeButton(controller, context),
                SizedBox(height: isTablet ? 24 : 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // WEB HEADER
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildWebHeader() {
    return Column(
      children: [
        Text(
          'Change Password',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A2E),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Secure your account with a new password',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // MOBILE APP BAR
  // ═══════════════════════════════════════════════════════════════════
  PreferredSizeWidget _buildMobileAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'Change Password',
        style: TextStyle(
          fontSize: ResponsiveUtils.getHeadingFontSize(context),
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -0.3,
        ),
      ),
      backgroundColor: kPrimary,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // MOBILE HEADER
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildMobileHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.isTablet(context) ? 32 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimary, kPrimaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ResponsiveUtils.isTablet(context) ? 24 : 20),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.isTablet(context) ? 20 : 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Iconify(
              Mdi.lock_reset,
              color: Colors.white,
              size: ResponsiveUtils.isTablet(context) ? 48 : 40,
            ),
          ),
          SizedBox(height: ResponsiveUtils.isTablet(context) ? 20 : 16),
          Text(
            'Change Password',
            style: TextStyle(
              fontSize: ResponsiveUtils.isTablet(context) ? 22 : 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Secure your account with a new password',
            style: TextStyle(
              fontSize: ResponsiveUtils.isTablet(context) ? 14 : 12,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // SECURITY TIPS CARD (WEB ONLY)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildSecurityTipsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Iconify(Mdi.shield_check, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text(
                'Security Tips',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _tipItem('Use at least 8 characters'),
          const SizedBox(height: 8),
          _tipItem('Include numbers & special characters'),
          const SizedBox(height: 8),
          _tipItem('Avoid using common words'),
          const SizedBox(height: 8),
          _tipItem('Don\'t reuse old passwords'),
        ],
      ),
    );
  }

  Widget _tipItem(String text) {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: Colors.white70, size: 14),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // FORM
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildForm(ChangePasswordController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Container(
      padding: EdgeInsets.all(isWeb ? 24 : 20),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(isWeb ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Old Password
          _buildPasswordField(
            label: 'Current Password',
            hint: 'Enter your current password',
            icon: Mdi.lock_outline,
            controller: controller.oldPasswordController,
            error: controller.oldPasswordError,
            isVisible: controller.isOldPasswordVisible,
            onToggle: controller.toggleOldPasswordVisibility,
            onChanged: (_) => controller.clearOldPasswordError(),
            context: context,
          ),
          
          SizedBox(height: isWeb ? 20 : 16),
          
          // New Password
          _buildPasswordField(
            label: 'New Password',
            hint: 'Enter new password',
            icon: Mdi.lock_plus_outline,
            controller: controller.newPasswordController,
            error: controller.newPasswordError,
            isVisible: controller.isNewPasswordVisible,
            onToggle: controller.toggleNewPasswordVisibility,
            onChanged: (_) => controller.clearNewPasswordError(),
            context: context,
          ),
          
          SizedBox(height: isWeb ? 20 : 16),
          
          // Confirm Password
          _buildPasswordField(
            label: 'Confirm Password',
            hint: 'Confirm your new password',
            icon: Mdi.lock_check_outline,
            controller: controller.confirmPasswordController,
            error: controller.confirmPasswordError,
            isVisible: controller.isConfirmPasswordVisible,
            onToggle: controller.toggleConfirmPasswordVisibility,
            onChanged: (_) => controller.clearConfirmPasswordError(),
            context: context,
          ),
          
          SizedBox(height: isWeb ? 20 : 16),
          
          // Password requirements
          _buildPasswordRequirements(context),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required String icon,
    required TextEditingController controller,
    required RxString error,
    required RxBool isVisible,
    required VoidCallback onToggle,
    required Function(String) onChanged,
    required BuildContext context,
  }) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Iconify(icon, size: isWeb ? 20 : 18, color: kPrimary),
            SizedBox(width: isWeb ? 10 : 8),
            Text(
              label,
              style: TextStyle(
                fontSize: isWeb ? 14 : 13,
                fontWeight: FontWeight.w600,
                color: kSubText,
              ),
            ),
          ],
        ),
        SizedBox(height: isWeb ? 10 : 8),
        TextFormField(
          controller: controller,
          obscureText: !isVisible.value,
          onChanged: onChanged,
          style: TextStyle(
            fontSize: isWeb ? 14 : 13,
            color: kText,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: isWeb ? 13 : 12,
              color: Colors.grey[400],
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
              borderSide: BorderSide(color: kBorder.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
              borderSide: const BorderSide(color: kPrimary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
              borderSide: const BorderSide(color: kDanger, width: 1),
            ),
            suffixIcon: IconButton(
              icon: Iconify(
                isVisible.value ? Mdi.eye : Mdi.eye_off,
                size: isWeb ? 22 : 20,
                color: kSubText,
              ),
              onPressed: onToggle,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isWeb ? 16 : 14,
              vertical: isWeb ? 16 : 14,
            ),
          ),
        ),
        if (error.value.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: isWeb ? 8 : 6, left: isWeb ? 8 : 6),
            child: Row(
              children: [
                Iconify(Mdi.alert_circle, size: isWeb ? 14 : 12, color: kDanger),
                SizedBox(width: isWeb ? 8 : 6),
                Expanded(
                  child: Text(
                    error.value,
                    style: TextStyle(
                      fontSize: isWeb ? 11 : 10,
                      color: kDanger,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    ));
  }

  Widget _buildPasswordRequirements(BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Container(
      padding: EdgeInsets.all(isWeb ? 16 : 14),
      decoration: BoxDecoration(
        color: kBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
        border: Border.all(color: kBorder.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Iconify(Mdi.shield_check, size: isWeb ? 18 : 16, color: kSuccess),
              SizedBox(width: isWeb ? 10 : 8),
              Text(
                'Password Requirements:',
                style: TextStyle(
                  fontSize: isWeb ? 13 : 12,
                  fontWeight: FontWeight.w700,
                  color: kText,
                ),
              ),
            ],
          ),
          SizedBox(height: isWeb ? 12 : 10),
          _buildRequirementItem('Minimum 6 characters', context),
          _buildRequirementItem('Cannot be same as current password', context),
          _buildRequirementItem('Should be different from previous passwords', context),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Padding(
      padding: EdgeInsets.only(bottom: isWeb ? 8 : 6, left: isWeb ? 24 : 20),
      child: Row(
        children: [
          Iconify(Mdi.check_circle, size: isWeb ? 14 : 12, color: kSuccess),
          SizedBox(width: isWeb ? 10 : 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: isWeb ? 11 : 10,
                color: kSubText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeButton(ChangePasswordController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Obx(() => SizedBox(
      width: double.infinity,
      height: ResponsiveUtils.getButtonHeight(context),
      child: ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.changePassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
          ),
        ),
        child: controller.isLoading.value
            ? SizedBox(
                height: isWeb ? 22 : 20,
                width: isWeb ? 22 : 20,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Change Password',
                style: TextStyle(
                  fontSize: isWeb ? 15 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    ));
  }

  // ═══════════════════════════════════════════════════════════════════
  // HELPER WIDGETS
  // ═══════════════════════════════════════════════════════════════════
  Widget _bgCircle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  Widget _featureChip(String icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Iconify(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}