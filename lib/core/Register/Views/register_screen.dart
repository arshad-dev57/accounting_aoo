import 'package:LedgerPro_app/Utils/responsive_utils.dart';
import 'package:LedgerPro_app/core/Register/controller/registercontroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController auth = Get.put(AuthController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: ResponsiveUtils.isWeb(context)
          ? _buildWebLayout(context, auth)
          : _buildMobileTabletLayout(context, auth),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // WEB LAYOUT
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildWebLayout(BuildContext context, AuthController auth) {
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
                          // Logo
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.35), width: 1.5),
                            ),
                            child: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 36),
                          ),
                          const SizedBox(height: 16),
                          // Title
                          const Text(
                            'Join LedgerPro',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Start your professional accounting journey',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.85),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 28),
                          // Illustration
                          const _RegisterIllustration(),
                          const SizedBox(height: 24),
                          // Features
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            children: [
                              _featureChip(Icons.verified_user_rounded, 'Secure'),
                              _featureChip(Icons.sync_rounded, 'Cloud Sync'),
                              _featureChip(Icons.analytics_rounded, 'Analytics'),
                              _featureChip(Icons.support_agent_rounded, '24/7 Support'),
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
        // RIGHT PANEL - Registration Form
        Expanded(
          flex: 1,
          child: SizedBox(
            height: screenH,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Obx(() => _buildStepContent(auth, context)),
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
  Widget _buildMobileTabletLayout(BuildContext context, AuthController auth) {
    return SafeArea(
      child: Column(
        children: [
          _buildMobileHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: ResponsiveUtils.getScreenPadding(context),
              child: Center(
                child: SizedBox(
                  width: ResponsiveUtils.getFormWidth(context),
                  child: Obx(() => _buildStepContent(auth, context)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // MOBILE HEADER
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildMobileHeader(BuildContext context) {
    final isTablet = ResponsiveUtils.isTablet(context);
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1AB4F5), Color(0xFF0FA3E0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding:  EdgeInsets.fromLTRB(8, 8, 16, isTablet ? 32 : 24),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Get.back(),
              ),
              const Expanded(
                child: Text(
                  'Create Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // STEP CONTENT (Common for all platforms)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildStepContent(AuthController auth, BuildContext context) {
    switch (auth.currentStep.value) {
      case 0:
        return _buildPersonalStep(auth, context);
      case 1:
        return _buildContactStep(auth, context);
      case 2:
        return _buildPasswordStep(auth, context);
      case 3:
        return _buildSuccessStep(auth, context);
      default:
        return _buildPersonalStep(auth, context);
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // STEP TABS
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildStepTabs(AuthController auth, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        isWeb ? 0 : 16,
        isWeb ? 24 : 20,
        isWeb ? 0 : 16,
        isWeb ? 24 : 8,
      ),
      child: Row(
        children: List.generate(4, (i) {
          final isActive = auth.currentStep.value >= i;
          final isDone = auth.currentStep.value > i;
          final isLast = i == 3;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => auth.goToStep(i),
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: isWeb ? 40 : 42,
                          height: isWeb ? 40 : 42,
                          decoration: BoxDecoration(
                            color: isDone
                                ? const Color(0xFF1AB4F5)
                                : isActive
                                    ? const Color(0xFF1AB4F5).withOpacity(0.12)
                                    : const Color(0xFFF5F8FC),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isActive
                                  ? const Color(0xFF1AB4F5)
                                  : const Color(0xFFDDE4EE),
                              width: isActive ? 2 : 1.5,
                            ),
                          ),
                          child: Icon(
                            isDone ? Icons.check : auth.getStepIcon(i),
                            color: isDone
                                ? Colors.white
                                : isActive
                                    ? const Color(0xFF1AB4F5)
                                    : const Color(0xFF7A8FA6),
                            size: isWeb ? 18 : 18,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          i == 0
                              ? 'Personal'
                              : i == 1
                                  ? 'Contact'
                                  : i == 2
                                      ? 'Password'
                                      : 'Done',
                          style: TextStyle(
                            fontSize: isWeb ? 10 : 10,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                            color: isActive ? const Color(0xFF1AB4F5) : const Color(0xFF7A8FA6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: isDone ? const Color(0xFF1AB4F5) : const Color(0xFFDDE4EE),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // PERSONAL STEP
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildPersonalStep(AuthController auth, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isWeb) _buildStepTabs(auth, context),
        SizedBox(height: isWeb ? 0 : 16),
        Text(
          'Personal Information',
          style: TextStyle(
            fontSize: ResponsiveUtils.getHeadingFontSize(context),
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Please provide your personal details',
          style: TextStyle(
            fontSize: ResponsiveUtils.getSubheadingFontSize(context),
            color: const Color(0xFF7A8FA6),
          ),
        ),
        const SizedBox(height: 28),
        _fieldLabel('First Name', context),
        const SizedBox(height: 8),
        _inputField(
          controller: auth.firstNameController,
          hint: 'Enter your first name',
          icon: Icons.person_outline,
          context: context,
        ),
        const SizedBox(height: 20),
        _fieldLabel('Last Name', context),
        const SizedBox(height: 8),
        _inputField(
          controller: auth.lastNameController,
          hint: 'Enter your last name',
          icon: Icons.person_outline,
          context: context,
        ),
        const SizedBox(height: 20),
        _fieldLabel('Country', context),
        const SizedBox(height: 8),
        _dropdownField(auth, context),
        const SizedBox(height: 32),
        _buildNextButton(auth, 'Next', context),
        const SizedBox(height: 20),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // CONTACT STEP
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildContactStep(AuthController auth, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isWeb) _buildStepTabs(auth, context),
        SizedBox(height: isWeb ? 0 : 16),
        Text(
          'Contact & Business Information',
          style: TextStyle(
            fontSize: ResponsiveUtils.getHeadingFontSize(context),
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Tell us about your business',
          style: TextStyle(
            fontSize: ResponsiveUtils.getSubheadingFontSize(context),
            color: const Color(0xFF7A8FA6),
          ),
        ),
        const SizedBox(height: 28),
        _fieldLabel("Phone Number", context),
        const SizedBox(height: 8),
        _inputField(
          controller: auth.phoneController,
          hint: '+92 300 1234567',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          context: context,
        ),
        const SizedBox(height: 20),
        _fieldLabel("Email Address", context),
        const SizedBox(height: 8),
        _inputField(
          controller: auth.emailController,
          hint: 'you@example.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          context: context,
        ),
        const SizedBox(height: 20),
        _fieldLabel("Company Name (Optional)", context),
        const SizedBox(height: 8),
        _inputField(
          controller: auth.organizationNameController,
          hint: 'Your company name',
          icon: Icons.business_outlined,
          context: context,
        ),
        const SizedBox(height: 20),
        _fieldLabel("Address (Optional)", context),
        const SizedBox(height: 8),
        _inputField(
          controller: auth.addressController,
          hint: 'Street, City, Postal Code',
          icon: Icons.location_on_outlined,
          maxLines: 2,
          context: context,
        ),
        const SizedBox(height: 20),
        _termsCheckbox(auth, context),
        const SizedBox(height: 32),
        _buildNextButton(auth, 'Next', context),
        const SizedBox(height: 20),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // PASSWORD STEP
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildPasswordStep(AuthController auth, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isWeb) _buildStepTabs(auth, context),
        SizedBox(height: isWeb ? 0 : 16),
        Text(
          'Create Password',
          style: TextStyle(
            fontSize: ResponsiveUtils.getHeadingFontSize(context),
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Choose a strong password for your account',
          style: TextStyle(
            fontSize: ResponsiveUtils.getSubheadingFontSize(context),
            color: const Color(0xFF7A8FA6),
          ),
        ),
        const SizedBox(height: 28),
        _fieldLabel('Password', context),
        const SizedBox(height: 8),
        Obx(() {
          final isVisible = auth.isPasswordVisible.value;
          final showStrength = auth.passwordStrength.value > 0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _inputField(
                controller: auth.passwordController,
                hint: 'Enter your password',
                icon: Icons.lock_outline,
                obscure: !isVisible,
                suffix: IconButton(
                  icon: Icon(
                    isVisible ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xFF7A8FA6),
                    size: 20,
                  ),
                  onPressed: () => auth.isPasswordVisible.value = !auth.isPasswordVisible.value,
                ),
                context: context,
              ),
              if (showStrength) ...[
                const SizedBox(height: 8),
                _passwordStrength(auth, context),
              ],
            ],
          );
        }),
        const SizedBox(height: 20),
        _fieldLabel('Confirm Password', context),
        const SizedBox(height: 8),
        Obx(() {
          final isVisible = auth.isConfirmPasswordVisible.value;
          return _inputField(
            controller: auth.confirmPasswordController,
            hint: 'Re-enter your password',
            icon: Icons.lock_outline,
            obscure: !isVisible,
            suffix: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: const Color(0xFF7A8FA6),
                size: 20,
              ),
              onPressed: () => auth.isConfirmPasswordVisible.value = !auth.isConfirmPasswordVisible.value,
            ),
            context: context,
          );
        }),
        const SizedBox(height: 32),
        _buildNextButton(auth, 'Create Account', context),
        const SizedBox(height: 20),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // SUCCESS STEP
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildSuccessStep(AuthController auth, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isWeb) _buildStepTabs(auth, context),
        SizedBox(height: isWeb ? 0 : 16),
        Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: isWeb ? 100 : 110,
                height: isWeb ? 100 : 110,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1AB4F5), Color(0xFF0FA3E0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1AB4F5).withOpacity(0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 56),
              ),
              const SizedBox(height: 28),
              const Text(
                'Account Activated!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Welcome, ${auth.firstNameController.text}! 🎉',
                style: const TextStyle(fontSize: 15, color: Color(0xFF7A8FA6)),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F8FC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFDDE4EE)),
                ),
                child: Column(
                  children: [
                    _infoRow(Icons.person, 'Name',
                        '${auth.firstNameController.text} ${auth.lastNameController.text}'),
                    _divider(),
                    _infoRow(Icons.public, 'Country', auth.countryController.text),
                    _divider(),
                    _infoRow(Icons.phone, 'Phone', auth.phoneController.text),
                    _divider(),
                    _infoRow(Icons.email, 'Email', auth.emailController.text),
                    _divider(),
                    _infoRow(Icons.business, 'Organization',
                        auth.organizationNameController.text),
                    _divider(),
                    _infoRow(Icons.location_on, 'Address', auth.addressController.text),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildNextButton(auth, 'Get Started', context),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // COMMON WIDGETS
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildNextButton(AuthController auth, String label, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: ResponsiveUtils.getButtonHeight(context),
      child: ElevatedButton(
        onPressed: auth.isLoading.value
            ? null
            : label == 'Get Started'
                ? () => auth.resetForm()
                : () => auth.nextStep(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1AB4F5),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: auth.isLoading.value
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }

  Widget _fieldLabel(String label, BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: ResponsiveUtils.getSubheadingFontSize(context),
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1A1A2E),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required BuildContext context,
    bool obscure = false,
    Widget? suffix,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF7A8FA6), fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF5F8FC),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDDE4EE), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF1AB4F5), width: 2),
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF7A8FA6), size: 20),
        suffixIcon: suffix,
      ),
    );
  }

  Widget _dropdownField(AuthController auth, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDDE4EE), width: 1.5),
      ),
      child: DropdownButtonFormField<String>(
        value: auth.countryController.text.isEmpty ? null : auth.countryController.text,
        hint: const Text('Select your country',
            style: TextStyle(color: Color(0xFF7A8FA6), fontSize: 14)),
        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF7A8FA6)),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          prefixIcon: Icon(Icons.public, color: Color(0xFF7A8FA6), size: 20),
        ),
        items: auth.countries
            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
            .toList(),
        onChanged: (v) {
          auth.countryController.text = v ?? '';
          auth.country.value = v ?? '';
        },
      ),
    );
  }

  Widget _termsCheckbox(AuthController auth, BuildContext context) {
    return Obx(() => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Transform.scale(
              scale: 1.1,
              child: Checkbox(
                value: auth.agreeToTerms.value,
                onChanged: (v) => auth.agreeToTerms.value = v ?? false,
                activeColor: const Color(0xFF1AB4F5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                side: const BorderSide(color: Color(0xFFDDE4EE), width: 1.5),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: GestureDetector(
                onTap: () => auth.agreeToTerms.value = !auth.agreeToTerms.value,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: RichText(
                    text: TextSpan(
                      text: 'By continuing, you agree to our ',
                      style: TextStyle(
                          color: const Color(0xFF7A8FA6),
                          fontSize: ResponsiveUtils.getSubheadingFontSize(context),
                          height: 1.5),
                      children: const [
                        TextSpan(
                          text: 'Terms of Service',
                          style: TextStyle(
                              color: Color(0xFF1AB4F5),
                              fontWeight: FontWeight.w600),
                        ),
                        TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                              color: Color(0xFF1AB4F5),
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Widget _passwordStrength(AuthController auth, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Password strength: ',
                style: TextStyle(fontSize: ResponsiveUtils.getSubheadingFontSize(context), 
                    color: const Color(0xFF7A8FA6))),
            Obx(() => Text(
                  auth.passwordStrengthText.value,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getSubheadingFontSize(context),
                    color: auth.passwordStrengthColor.value,
                    fontWeight: FontWeight.w700,
                  ),
                )),
          ],
        ),
        const SizedBox(height: 6),
        Obx(() => ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: auth.passwordStrength.value,
                minHeight: 5,
                backgroundColor: const Color(0xFFDDE4EE),
                valueColor: AlwaysStoppedAnimation<Color>(auth.passwordStrengthColor.value),
              ),
            )),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF1AB4F5).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF1AB4F5), size: 16),
          ),
          const SizedBox(width: 12),
          Text('$label:',
              style: const TextStyle(fontSize: 13, color: Color(0xFF7A8FA6))),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(color: Color(0xFFDDE4EE), height: 1);
  
  Widget _bgCircle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  Widget _featureChip(IconData icon, String label) {
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
          Icon(icon, color: Colors.white, size: 18),
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

// ═══════════════════════════════════════════════════════════════════
// REGISTER ILLUSTRATION
// ═══════════════════════════════════════════════════════════════════
class _RegisterIllustration extends StatelessWidget {
  const _RegisterIllustration();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth.clamp(0.0, 380.0);
        return Container(
          width: w,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
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
              const SizedBox(height: 16),
              // Form preview
              _formField('Full Name', 'John Doe'),
              const SizedBox(height: 12),
              _formField('Email', 'john@example.com'),
              const SizedBox(height: 12),
              _formField('Password', '••••••••'),
              const SizedBox(height: 16),
              // Button preview
              Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'Create Account',
                    style: TextStyle(
                      color: Color(0xFF1AB4F5),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Social login preview
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialIcon(Icons.g_mobiledata),
                  const SizedBox(width: 12),
                  _socialIcon(Icons.facebook),
                  const SizedBox(width: 12),
                  _socialIcon(Icons.apple),
                ],
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

  Widget _formField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _socialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }
}