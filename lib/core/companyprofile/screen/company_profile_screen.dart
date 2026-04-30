import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/Utils/responsive_utils.dart';
import 'package:LedgerPro_app/core/companyprofile/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.put(ProfileController());
    final isWeb = ResponsiveUtils.isWeb(context);
    final isTablet = ResponsiveUtils.isTablet(context);
    final isMobile = ResponsiveUtils.isMobile(context);

    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(controller, context),
      body: _buildBody(controller, context),
    );
  }

  PreferredSizeWidget _buildAppBar(ProfileController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final isMobile = ResponsiveUtils.isMobile(context);
    
    return AppBar(
      title: Text(
        'Profile',
        style: TextStyle(
          fontSize: ResponsiveUtils.getHeadingFontSize(context),
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -0.3,
        ),
      ),
      backgroundColor: kPrimary,
      elevation: 0,
      centerTitle: isMobile,
      actions: [
        Obx(() {
          if (!controller.isEditing.value && !controller.isLoading.value) {
            return TextButton(
              onPressed: controller.toggleEdit,
              child: Text(
                'Edit',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getSubheadingFontSize(context),
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
                  fontSize: ResponsiveUtils.getSubheadingFontSize(context),
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
        SizedBox(width: isWeb ? 16 : 8),
      ],
    );
  }

  Widget _buildBody(ProfileController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final isTablet = ResponsiveUtils.isTablet(context);
    
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
              SizedBox(height: ResponsiveUtils.getButtonHeight(context) / 3),
              Text(
                'Loading profile...',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getSubheadingFontSize(context),
                  color: kSubText,
                ),
              ),
            ],
          ),
        );
      }
      
      return SingleChildScrollView(
        padding: ResponsiveUtils.getScreenPadding(context),
        child: Center(
          child: SizedBox(
            width: ResponsiveUtils.getFormWidth(context),
            child: Column(
              children: [
                SizedBox(height: ResponsiveUtils.isMobile(context) ? 8 : 16),
                _buildProfileHeader(controller, context),
                SizedBox(height: ResponsiveUtils.isMobile(context) ? 24 : 32),
                _buildProfileForm(controller, context),
                SizedBox(height: ResponsiveUtils.isMobile(context) ? 24 : 32),
                if (controller.isEditing.value) _buildSaveButton(controller, context),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildProfileHeader(ProfileController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final isTablet = ResponsiveUtils.isTablet(context);
    final isMobile = ResponsiveUtils.isMobile(context);
    
    return Obx(() => Container(
      padding: EdgeInsets.all(isWeb ? 24 : isTablet ? 20 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimary, kPrimaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isWeb ? 16 : isTablet ? 14 : 12),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.3),
            blurRadius: isWeb ? 20 : 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Container(
                padding: EdgeInsets.all(isWeb ? 20 : isTablet ? 16 : 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Iconify(
                  Mdi.account_circle,
                  color: kPrimary,
                  size: isWeb ? 80 : isTablet ? 60 : 50,
                ),
              ),
              SizedBox(height: isWeb ? 16 : isTablet ? 12 : 10),
              Text(
                controller.organizationName.value.isEmpty 
                    ? 'Your Organization' 
                    : controller.organizationName.value,
                style: TextStyle(
                  fontSize: isWeb ? 20 : isTablet ? 18 : 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isWeb ? 8 : isTablet ? 6 : 4),
              Text(
                controller.personName.value.isEmpty 
                    ? 'Profile' 
                    : controller.personName.value,
                style: TextStyle(
                  fontSize: isWeb ? 14 : isTablet ? 13 : 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  Widget _buildProfileForm(ProfileController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final isTablet = ResponsiveUtils.isTablet(context);
    final isMobile = ResponsiveUtils.isMobile(context);
    
    return Container(
      padding: EdgeInsets.all(isWeb ? 24 : isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(isWeb ? 16 : isTablet ? 14 : 12),
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
              fontSize: isWeb ? 18 : isTablet ? 16 : 14,
              fontWeight: FontWeight.w800,
              color: kText,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: isWeb ? 24 : isTablet ? 20 : 16),
          
          // Organization Name
          _buildTextField(
            label: 'Organization Name',
            hint: 'Enter your organization name',
            icon: Mdi.domain,
            controller: controller.orgNameController,
            enabled: controller.isEditing.value,
            context: context,
          ),
          
          SizedBox(height: isWeb ? 20 : isTablet ? 16 : 12),
          
          // Person Name
          _buildTextField(
            label: 'Person Name',
            hint: 'Enter person name',
            icon: Mdi.account,
            controller: controller.personNameController,
            enabled: controller.isEditing.value,
            context: context,
          ),
          
          SizedBox(height: isWeb ? 20 : isTablet ? 16 : 12),
          
          // Address
          _buildTextField(
            label: 'Address',
            hint: 'Enter your address',
            icon: Mdi.map_marker,
            controller: controller.addressController,
            enabled: controller.isEditing.value,
            maxLines: 2,
            context: context,
          ),
          
          SizedBox(height: isWeb ? 20 : isTablet ? 16 : 12),
          
          // Email Id
          _buildTextField(
            label: 'Email Id',
            hint: 'Enter email address',
            icon: Mdi.email,
            controller: controller.emailController,
            enabled: controller.isEditing.value,
            keyboardType: TextInputType.emailAddress,
            context: context,
          ),
          
          SizedBox(height: isWeb ? 20 : isTablet ? 16 : 12),
          
          // Contact No
          _buildTextField(
            label: 'Contact No',
            hint: 'Enter contact number',
            icon: Mdi.phone,
            controller: controller.contactNoController,
            enabled: controller.isEditing.value,
            keyboardType: TextInputType.phone,
            context: context,
          ),
          
          SizedBox(height: isWeb ? 20 : isTablet ? 16 : 12),
          
          // Website Link
          _buildTextField(
            label: 'Website Link',
            hint: 'Enter website URL',
            icon: Mdi.web,
            controller: controller.websiteController,
            enabled: controller.isEditing.value,
            keyboardType: TextInputType.url,
            context: context,
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
    required BuildContext context,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final isTablet = ResponsiveUtils.isTablet(context);
    final isMobile = ResponsiveUtils.isMobile(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Iconify(icon, size: isWeb ? 20 : isTablet ? 18 : 16, color: kPrimary),
            SizedBox(width: isWeb ? 8 : isTablet ? 6 : 4),
            Text(
              label,
              style: TextStyle(
                fontSize: isWeb ? 13 : isTablet ? 12 : 11,
                fontWeight: FontWeight.w600,
                color: kSubText,
              ),
            ),
          ],
        ),
        SizedBox(height: isWeb ? 8 : isTablet ? 6 : 4),
        TextFormField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: isWeb ? 14 : isTablet ? 13 : 12,
            color: kText,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: isWeb ? 13 : isTablet ? 12 : 11,
              color: Colors.grey[400],
            ),
            filled: true,
            fillColor: enabled ? Colors.white : kBg.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isWeb ? 12 : isTablet ? 10 : 8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isWeb ? 12 : isTablet ? 10 : 8),
              borderSide: BorderSide(color: kBorder.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isWeb ? 12 : isTablet ? 10 : 8),
              borderSide: const BorderSide(color: kPrimary, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isWeb ? 16 : isTablet ? 14 : 12,
              vertical: maxLines > 1 ? (isWeb ? 16 : isTablet ? 14 : 12) : (isWeb ? 14 : isTablet ? 12 : 10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(ProfileController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final isTablet = ResponsiveUtils.isTablet(context);
    
    return Obx(() => SizedBox(
      width: double.infinity,
      height: ResponsiveUtils.getButtonHeight(context),
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
            borderRadius: BorderRadius.circular(isWeb ? 12 : isTablet ? 10 : 8),
          ),
        ),
        child: controller.isSaving.value
            ? SizedBox(
                height: isWeb ? 24 : isTablet ? 20 : 18,
                width: isWeb ? 24 : isTablet ? 20 : 18,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: isWeb ? 16 : isTablet ? 15 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    ));
  }
}


