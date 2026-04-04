import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/core/companyprofile/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(controller),
      body: _buildBody(controller),
    );
  }

  PreferredSizeWidget _buildAppBar(ProfileController controller) {
    return AppBar(
      title: Text(
        'Profile',
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
      actions: [
        Obx(() {
          if (!controller.isEditing.value && !controller.isLoading.value) {
            return TextButton(
              onPressed: controller.toggleEdit,
              child: Text(
                'Edit',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            );
          }
          if (controller.isEditing.value) {
            return TextButton(
              onPressed: controller.toggleEdit,
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
        SizedBox(width: 2.w),
      ],
    );
  }

  Widget _buildBody(ProfileController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: kPrimary,
                strokeWidth: 3,
              ),
              SizedBox(height: 2.h),
              Text(
                'Loading profile...',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: kSubText,
                ),
              ),
            ],
          ),
        );
      }
      
      return SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            SizedBox(height: 2.h),
            _buildProfileHeader(controller),
            SizedBox(height: 4.h),
            _buildProfileForm(controller),
            SizedBox(height: 4.h),
            if (controller.isEditing.value) _buildSaveButton(controller),
          ],
        ),
      );
    });
  }

  Widget _buildProfileHeader(ProfileController controller) {
    return Obx(() => Container(
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
              Mdi.account_circle,
              color: Colors.white,
              size: 12.w,
            ),
          ),
          SizedBox(height: 1.5.h),
          Text(
            controller.organizationName.value.isEmpty 
                ? 'Your Organization' 
                : controller.organizationName.value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 0.5.h),
          Text(
            controller.personName.value.isEmpty 
                ? 'Profile' 
                : controller.personName.value,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildProfileForm(ProfileController controller) {
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
          Text(
            'Organization Information',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: kText,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 2.h),
          
          // Organization Name
          _buildTextField(
            label: 'Organization Name',
            hint: 'Enter your organization name',
            icon: Mdi.domain,
            controller: controller.orgNameController,
            enabled: controller.isEditing.value,
          ),
          
          SizedBox(height: 2.h),
          
          // Person Name
          _buildTextField(
            label: 'Person Name',
            hint: 'Enter person name',
            icon: Mdi.account,
            controller: controller.personNameController,
            enabled: controller.isEditing.value,
          ),
          
          SizedBox(height: 2.h),
          
          // Address
          _buildTextField(
            label: 'Address',
            hint: 'Enter your address',
            icon: Mdi.map_marker,
            controller: controller.addressController,
            enabled: controller.isEditing.value,
            maxLines: 2,
          ),
          
          SizedBox(height: 2.h),
          
          // Email Id
          _buildTextField(
            label: 'Email Id',
            hint: 'Enter email address',
            icon: Mdi.email,
            controller: controller.emailController,
            enabled: controller.isEditing.value,
            keyboardType: TextInputType.emailAddress,
          ),
          
          SizedBox(height: 2.h),
          
          // Contact No
          _buildTextField(
            label: 'Contact No',
            hint: 'Enter contact number',
            icon: Mdi.phone,
            controller: controller.contactNoController,
            enabled: controller.isEditing.value,
            keyboardType: TextInputType.phone,
          ),
          
          SizedBox(height: 2.h),
          
          // Website Link
          _buildTextField(
            label: 'Website Link',
            hint: 'Enter website URL',
            icon: Mdi.web,
            controller: controller.websiteController,
            enabled: controller.isEditing.value,
            keyboardType: TextInputType.url,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required String icon,
    required TextEditingController controller,
    required bool enabled,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
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
          enabled: enabled,
          maxLines: maxLines,
          keyboardType: keyboardType,
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
            fillColor: enabled ? Colors.white : kBg.withOpacity(0.5),
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
            contentPadding: EdgeInsets.symmetric(
              horizontal: 3.w,
              vertical: maxLines > 1 ? 2.h : 1.5.h,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(ProfileController controller) {
    return Obx(() => SizedBox(
      width: double.infinity,
      height: 7.h,
      child: ElevatedButton(
        onPressed: controller.isSaving.value 
            ? null 
            : () {
                if (controller.validateForm()) {
                  controller.saveProfile();
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.w),
          ),
        ),
        child: controller.isSaving.value
            ? SizedBox(
                height: 4.w,
                width: 4.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    ));
  }
}