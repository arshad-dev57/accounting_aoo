import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/Utils/responsive_utils.dart';
import 'package:LedgerPro_app/core/changepassword/controller/Otp_controller.dart';
import 'package:LedgerPro_app/core/changepassword/screen/change_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:pinput/pinput.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OTPController controller = Get.put(OTPController());

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
  Widget _buildWebLayout(BuildContext context, OTPController controller) {
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
                            child: const Iconify(Mdi.shield_key, color: Colors.white, size: 42),
                          ),
                          const SizedBox(height: 16),
                          // Title
                          const Text(
                            'Account Recovery',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Reset your password securely',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.85),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 28),
                          // Recovery Steps Card
                          _buildRecoveryStepsCard(),
                          const SizedBox(height: 24),
                          // Security Features
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            children: [
                              _featureChip(Mdi.shield_check, 'Secure Process'),
                              _featureChip(Mdi.clock_fast, 'Quick Recovery'),
                              _featureChip(Mdi.email_check, 'Email Verified'),
                              _featureChip(Mdi.lock_reset, 'Reset Access'),
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
        // RIGHT PANEL - OTP Form
        Expanded(
          flex: 1,
          child: SizedBox(
            height: screenH,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Obx(() {
                    // Agar OTP verify ho gaya to ChangePasswordScreen par le jao
                    if (controller.isOtpVerified.value) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Get.off(() => const ChangePasswordScreen());
                      });
                      return const SizedBox.shrink();
                    }
                    
                    if (!controller.isOtpSent.value) {
                      return _buildEmailContent(controller, context);
                    } else {
                      return _buildOTPContent(controller, context);
                    }
                  }),
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
  Widget _buildMobileTabletLayout(BuildContext context, OTPController controller) {
    final isTablet = ResponsiveUtils.isTablet(context);
    
    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildMobileAppBar(context),
      body: Obx(() {
        // Agar OTP verify ho gaya to ChangePasswordScreen par le jao
        if (controller.isOtpVerified.value) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.off(() => const ChangePasswordScreen());
          });
          return const SizedBox.shrink();
        }
        
        return SingleChildScrollView(
          padding: ResponsiveUtils.getScreenPadding(context),
          child: Center(
            child: SizedBox(
              width: ResponsiveUtils.getFormWidth(context),
              child: Column(
                children: [
                  SizedBox(height: isTablet ? 16 : 8),
                  if (!controller.isOtpSent.value)
                    _buildEmailScreen(controller, context)
                  else
                    _buildOTPScreen(controller, context),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // WEB CONTENT
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildEmailContent(OTPController controller, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildWebHeader('Reset Password', 'Enter your email address'),
        const SizedBox(height: 32),
        _buildEmailField(controller, context),
        const SizedBox(height: 32),
        _buildSendButton(controller, context),
      ],
    );
  }

  Widget _buildOTPContent(OTPController controller, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildWebHeader('Verify OTP', 'Please enter the 6-digit OTP sent to ${controller.email.value}'),
        const SizedBox(height: 32),
        _buildOTPField(controller, context),
        const SizedBox(height: 20),
        _buildTimerButton(controller, context),
        const SizedBox(height: 32),
        _buildVerifyButton(controller, context),
      ],
    );
  }

  Widget _buildWebHeader(String title, String subtitle) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A2E),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
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
        'Forgot Password',
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
  // RECOVERY STEPS CARD (WEB ONLY)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildRecoveryStepsCard() {
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
              Iconify(Mdi.information_outline, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text(
                'Recovery Steps',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _stepItem('1', 'Enter your registered email'),
          const SizedBox(height: 8),
          _stepItem('2', 'Receive OTP on your email'),
          const SizedBox(height: 8),
          _stepItem('3', 'Enter the 6-digit OTP'),
          const SizedBox(height: 8),
          _stepItem('4', 'Create new password'),
        ],
      ),
    );
  }

  Widget _stepItem(String step, String text) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Center(
            child: Text(
              step,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
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
  // EMAIL SCREEN (MOBILE)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildEmailScreen(OTPController controller, BuildContext context) {
    return Column(
      children: [
        _buildMobileHeader('Reset Password', Mdi.lock_reset,
            'Enter your email address and we\'ll send you an OTP to reset your password', context),
        SizedBox(height: ResponsiveUtils.isTablet(context) ? 32 : 24),
        _buildEmailField(controller, context),
        SizedBox(height: ResponsiveUtils.isTablet(context) ? 32 : 24),
        _buildSendButton(controller, context),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // OTP SCREEN (MOBILE)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildOTPScreen(OTPController controller, BuildContext context) {
    return Column(
      children: [
        _buildMobileHeader('Verify OTP', Mdi.shield_key,
            'Please enter the 6-digit OTP sent to ${controller.email.value}', context),
        SizedBox(height: ResponsiveUtils.isTablet(context) ? 32 : 24),
        _buildOTPField(controller, context),
        SizedBox(height: ResponsiveUtils.isTablet(context) ? 20 : 16),
        _buildTimerButton(controller, context),
        SizedBox(height: ResponsiveUtils.isTablet(context) ? 32 : 24),
        _buildVerifyButton(controller, context),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // MOBILE HEADER
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildMobileHeader(String title, String icon, String subtitle, BuildContext context) {
    final isTablet = ResponsiveUtils.isTablet(context);
    
    return Container(
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimary, kPrimaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
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
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Iconify(
              icon,
              color: Colors.white,
              size: isTablet ? 48 : 40,
            ),
          ),
          SizedBox(height: isTablet ? 20 : 16),
          Text(
            title,
            style: TextStyle(
              fontSize: isTablet ? 22 : 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // EMAIL FIELD
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildEmailField(OTPController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Iconify(Mdi.email, size: isWeb ? 20 : 18, color: kPrimary),
            SizedBox(width: isWeb ? 10 : 8),
            Text(
              'Email Address',
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
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) => controller.emailError.value = '',
          style: TextStyle(
            fontSize: isWeb ? 14 : 13,
            color: kText,
          ),
          decoration: InputDecoration(
            hintText: 'Enter your email address',
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
            contentPadding: EdgeInsets.symmetric(
              horizontal: isWeb ? 16 : 14,
              vertical: isWeb ? 16 : 14,
            ),
          ),
        ),
        if (controller.emailError.value.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: isWeb ? 8 : 6, left: isWeb ? 8 : 6),
            child: Text(
              controller.emailError.value,
              style: TextStyle(
                fontSize: isWeb ? 11 : 10,
                color: kDanger,
              ),
            ),
          ),
      ],
    ));
  }

  // ═══════════════════════════════════════════════════════════════════
  // OTP FIELD
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildOTPField(OTPController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final pinWidth = isWeb ? 60.0 : (ResponsiveUtils.isTablet(context) ? 55.0 : 45.0);
    
    final defaultPinTheme = PinTheme(
      width: pinWidth,
      height: pinWidth,
      textStyle: TextStyle(
        fontSize: isWeb ? 20 : 18,
        fontWeight: FontWeight.w600,
        color: kText,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
        border: Border.all(color: kBorder),
      ),
    );

    return Column(
      children: [
        Row(
          children: [
            Iconify(Mdi.shield_key, size: isWeb ? 20 : 18, color: kPrimary),
            SizedBox(width: isWeb ? 10 : 8),
            Text(
              'Enter OTP',
              style: TextStyle(
                fontSize: isWeb ? 14 : 13,
                fontWeight: FontWeight.w600,
                color: kSubText,
              ),
            ),
          ],
        ),
        SizedBox(height: isWeb ? 10 : 8),
        Pinput(
          length: 6,
          controller: controller.otpController,
          onChanged: (_) => controller.otpError.value = '',
          defaultPinTheme: defaultPinTheme,
          focusedPinTheme: defaultPinTheme.copyWith(
            decoration: defaultPinTheme.decoration!.copyWith(
              border: Border.all(color: kPrimary, width: 2),
            ),
          ),
          errorPinTheme: defaultPinTheme.copyWith(
            decoration: defaultPinTheme.decoration!.copyWith(
              border: Border.all(color: kDanger, width: 1),
            ),
          ),
        ),
        if (controller.otpError.value.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: isWeb ? 8 : 6),
            child: Text(
              controller.otpError.value,
              style: TextStyle(
                fontSize: isWeb ? 11 : 10,
                color: kDanger,
              ),
            ),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // TIMER BUTTON
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildTimerButton(OTPController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          controller.timerText,
          style: TextStyle(
            fontSize: isWeb ? 13 : 12,
            color: controller.timerSeconds.value == 0 ? kPrimary : kSubText,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (controller.timerSeconds.value == 0)
          TextButton(
            onPressed: controller.resendOTP,
            child: Text(
              'Resend',
              style: TextStyle(
                fontSize: isWeb ? 13 : 12,
                color: kPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    ));
  }

  // ═══════════════════════════════════════════════════════════════════
  // SEND BUTTON
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildSendButton(OTPController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Obx(() => SizedBox(
      width: double.infinity,
      height: ResponsiveUtils.getButtonHeight(context),
      child: ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.sendOTP,
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
                'Send OTP',
                style: TextStyle(
                  fontSize: isWeb ? 15 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    ));
  }

  // ═══════════════════════════════════════════════════════════════════
  // VERIFY BUTTON
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildVerifyButton(OTPController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Obx(() => SizedBox(
      width: double.infinity,
      height: ResponsiveUtils.getButtonHeight(context),
      child: ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.verifyOTP,
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
                'Verify OTP',
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