import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/core/changepassword/controller/Otp_controller.dart';
import 'package:LedgerPro_app/core/changepassword/screen/change_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
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
      appBar: _buildAppBar(),
      body: Obx(() {
        // ✅ Agar OTP verify ho gaya to ForgotPasswordScreen par le jao
        if (controller.isOtpVerified.value) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.off(() => const ChangePasswordScreen());
          });
          return const SizedBox.shrink();
        }
        
        if (!controller.isOtpSent.value) {
          return _buildEmailScreen(controller);
        } else {
          return _buildOTPScreen(controller);
        }
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Forgot Password',
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -0.3,
        ),
      ),
      backgroundColor: kPrimary,
      elevation: 0,
      centerTitle: false,
    );
  }

  Widget _buildEmailScreen(OTPController controller) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          SizedBox(height: 4.h),
          _buildHeader('Reset Password', Mdi.lock_reset,
              'Enter your email address and we\'ll send you an OTP to reset your password'),
          SizedBox(height: 4.h),
          _buildEmailField(controller),
          SizedBox(height: 4.h),
          _buildSendButton(controller),
        ],
      ),
    );
  }

  Widget _buildOTPScreen(OTPController controller) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          SizedBox(height: 4.h),
          _buildHeader('Verify OTP', Mdi.shield_key,
              'Please enter the 6-digit OTP sent to ${controller.email.value}'),
          SizedBox(height: 4.h),
          _buildOTPField(controller),
          SizedBox(height: 2.h),
          _buildTimerButton(controller),
          SizedBox(height: 4.h),
          _buildVerifyButton(controller),
        ],
      ),
    );
  }

  Widget _buildHeader(String title, String icon, String subtitle) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimary, kPrimaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(4.w),
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
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Iconify(icon, color: Colors.white, size: 12.w),
          ),
          SizedBox(height: 1.5.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField(OTPController controller) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Iconify(Mdi.email, size: 4.w, color: kPrimary),
            SizedBox(width: 2.w),
            Text(
              'Email Address',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: kSubText,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) => controller.emailError.value = '',
          style: TextStyle(fontSize: 13.sp, color: kText),
          decoration: InputDecoration(
            hintText: 'Enter your email address',
            hintStyle: TextStyle(fontSize: 12.sp, color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2.w),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2.w),
              borderSide: BorderSide(color: kBorder.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2.w),
              borderSide: const BorderSide(color: kPrimary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2.w),
              borderSide: const BorderSide(color: kDanger, width: 1),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
          ),
        ),
        if (controller.emailError.value.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 0.8.h, left: 2.w),
            child: Text(
              controller.emailError.value,
              style: TextStyle(fontSize: 10.sp, color: kDanger),
            ),
          ),
      ],
    ));
  }

  Widget _buildOTPField(OTPController controller) {
    final defaultPinTheme = PinTheme(
      width: 12.w,
      height: 12.w,
      textStyle: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: kText),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(color: kBorder),
      ),
    );

    return Column(
      children: [
        Row(
          children: [
            Iconify(Mdi.shield_key, size: 4.w, color: kPrimary),
            SizedBox(width: 2.w),
            Text(
              'Enter OTP',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: kSubText,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
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
            padding: EdgeInsets.only(top: 0.8.h),
            child: Text(
              controller.otpError.value,
              style: TextStyle(fontSize: 10.sp, color: kDanger),
            ),
          ),
      ],
    );
  }

  Widget _buildTimerButton(OTPController controller) {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          controller.timerText,
          style: TextStyle(
            fontSize: 12.sp,
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
                fontSize: 12.sp,
                color: kPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    ));
  }

  Widget _buildSendButton(OTPController controller) {
    return Obx(() => SizedBox(
      width: double.infinity,
      height: 7.h,
      child: ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.sendOTP,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.w),
          ),
        ),
        child: controller.isLoading.value
            ? SizedBox(
                height: 4.w,
                width: 4.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Send OTP',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
      ),
    ));
  }

  Widget _buildVerifyButton(OTPController controller) {
    return Obx(() => SizedBox(
      width: double.infinity,
      height: 7.h,
      child: ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.verifyOTP,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.w),
          ),
        ),
        child: controller.isLoading.value
            ? SizedBox(
                height: 4.w,
                width: 4.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Verify OTP',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
      ),
    ));
  }
}