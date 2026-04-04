import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/core/changepassword/controller/change_password_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ChangePasswordController controller = Get.put(ChangePasswordController());

    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(),
      body: _buildBody(controller),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Change Password',
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

  Widget _buildBody(ChangePasswordController controller) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          SizedBox(height: 2.h),
          _buildHeader(),
          SizedBox(height: 4.h),
          _buildForm(controller),
          SizedBox(height: 4.h),
          _buildChangeButton(controller),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
            child: Iconify(
              Mdi.lock_reset,
              color: Colors.white,
              size: 12.w,
            ),
          ),
          SizedBox(height: 1.5.h),
          Text(
            'Change Password',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Secure your account with a new password',
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

  Widget _buildForm(ChangePasswordController controller) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(4.w),
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
          ),
          
          SizedBox(height: 2.h),
          
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
          ),
          
          SizedBox(height: 2.h),
          
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
          ),
          
          SizedBox(height: 2.h),
          
          // Password requirements
          _buildPasswordRequirements(),
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
  }) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Iconify(icon, size: 4.w, color: kPrimary),
            SizedBox(width: 2.w),
            Text(
              label,
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
          controller: controller,
          obscureText: !isVisible.value,
          onChanged: onChanged,
          style: TextStyle(
            fontSize: 13.sp,
            color: kText,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[400],
            ),
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
            suffixIcon: IconButton(
              icon: Iconify(
                isVisible.value ? Mdi.eye : Mdi.eye_off,
                size: 5.w,
                color: kSubText,
              ),
              onPressed: onToggle,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 3.w,
              vertical: 1.5.h,
            ),
          ),
        ),
        if (error.value.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 0.8.h, left: 2.w),
            child: Row(
              children: [
                Iconify(Mdi.alert_circle, size: 3.w, color: kDanger),
                SizedBox(width: 1.5.w),
                Expanded(
                  child: Text(
                    error.value,
                    style: TextStyle(
                      fontSize: 10.sp,
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

  Widget _buildPasswordRequirements() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: kBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(color: kBorder.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Iconify(Mdi.shield_check, size: 4.w, color: kSuccess),
              SizedBox(width: 2.w),
              Text(
                'Password Requirements:',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: kText,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          _buildRequirementItem('Minimum 6 characters'),
          _buildRequirementItem('Cannot be same as current password'),
          _buildRequirementItem('Should be different from previous passwords'),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.8.h, left: 4.w),
      child: Row(
        children: [
          Iconify(Mdi.check_circle, size: 3.w, color: kSuccess),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 10.sp,
                color: kSubText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeButton(ChangePasswordController controller) {
    return Obx(() => SizedBox(
      width: double.infinity,
      height: 7.h,
      child: ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.changePassword,
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
                'Change Password',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    ));
  }
}