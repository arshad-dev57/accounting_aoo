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
      body: Column(
        children: [
          _buildHeader(),
          // ✅ FIX: Obx wrap kiya taake step change hone par UI update ho
          Obx(() => _buildStepTabs(auth)),
          Expanded(
            child: Obx(() {
              switch (auth.currentStep.value) {
                case 0: return _buildPersonalStep(auth);
                case 1: return _buildContactStep(auth);
                case 2: return _buildPasswordStep(auth);
                case 3: return _buildSuccessStep(auth);
                default: return _buildPersonalStep(auth);
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 24),
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
                    fontSize: 20,
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

  // ✅ FIX: Obx hataya yahaan se — upar parent mein hai
  Widget _buildStepTabs(AuthController auth) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: List.generate(4, (i) {
          // ✅ FIX: .value directly use kar rahe hain — Obx parent mein hai
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
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            // ✅ FIX: isDone aur isActive sahi calculate ho rahe hain
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
                            // ✅ FIX: isDone hone par check icon show hoga
                            isDone
                                ? Icons.check
                                : auth.getStepIcon(i),
                            color: isDone
                                ? Colors.white
                                : isActive
                                    ? const Color(0xFF1AB4F5)
                                    : const Color(0xFF7A8FA6),
                            size: 18,
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
                            fontSize: 10,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isActive
                                ? const Color(0xFF1AB4F5)
                                : const Color(0xFF7A8FA6),
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
                        // ✅ FIX: Line bhi fill hogi jab step done ho
                        color: isDone
                            ? const Color(0xFF1AB4F5)
                            : const Color(0xFFDDE4EE),
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

  Widget _buildPersonalStep(AuthController auth) {
    return _stepScaffold(
      auth: auth,
      title: 'Personal Information',
      subtitle: 'Please provide your personal details',
      fields: [
        _fieldLabel('First Name'),
        _inputField(
          controller: auth.firstNameController,
          hint: 'Enter your first name',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 20),
        _fieldLabel('Last Name'),
        _inputField(
          controller: auth.lastNameController,
          hint: 'Enter your last name',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 20),
        _fieldLabel('Country'),
        _dropdownField(auth),
      ],
      buttonLabel: 'Next',
    );
  }

  Widget _buildContactStep(AuthController auth) {
    return _stepScaffold(
      auth: auth,
      title: 'Contact & Business Information',
      subtitle: 'Tell us about your business',
      fields: [
        _fieldLabel("What's your phone number?"),
        _inputField(
          controller: auth.phoneController,
          hint: '+92 300 1234567',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 20),
        _fieldLabel("What's your email?"),
        _inputField(
          controller: auth.emailController,
          hint: 'you@example.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        _fieldLabel("Company / Organization Name (Optional)"),
        _inputField(
          controller: auth.organizationNameController,
          hint: 'Your company name',
          icon: Icons.business_outlined,
        ),
        const SizedBox(height: 20),
        _fieldLabel("Address (Optional)"),
        _inputField(
          controller: auth.addressController,
          hint: 'Street, City, Postal Code',
          icon: Icons.location_on_outlined,
          maxLines: 2,
        ),
        const SizedBox(height: 20),
        _termsCheckbox(auth),
      ],
      buttonLabel: 'Next',
    );
  }

  Widget _buildPasswordStep(AuthController auth) {
  return _stepScaffold(
    auth: auth,
    title: 'Create Password',
    subtitle: 'Choose a strong password for your account',
    fields: [
      _fieldLabel('Password'),
      // ✅ FIX: Ek Obx mein dono cheezein — password field + strength
      Obx(() {
        final isVisible = auth.isPasswordVisible.value;
        // ✅ passwordStrength.value observe karo — text.isNotEmpty ki jagah
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
                onPressed: () =>
                    auth.isPasswordVisible.value = !auth.isPasswordVisible.value,
              ),
            ),
            if (showStrength) ...[
              const SizedBox(height: 8),
              _passwordStrength(auth),
            ],
          ],
        );
      }),

      const SizedBox(height: 20),
      _fieldLabel('Confirm Password'),

      // ✅ FIX: Sirf isConfirmPasswordVisible observe karo
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
            onPressed: () => auth.isConfirmPasswordVisible.value =
                !auth.isConfirmPasswordVisible.value,
          ),
        );
      }),
    ],
    buttonLabel: 'Create Account',
  );
}

  Widget _buildSuccessStep(AuthController auth) {
    return _stepScaffold(
      auth: auth,
      title: '',
      subtitle: '',
      fields: [
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: 110,
            height: 110,
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
        ),
        const SizedBox(height: 28),
        Center(
          child: const Text(
            'Account Activated!',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Welcome, ${auth.firstNameController.text}! 🎉',
            style: const TextStyle(fontSize: 15, color: Color(0xFF7A8FA6)),
          ),
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
              _infoRow(
                  Icons.location_on, 'Address', auth.addressController.text),
            ],
          ),
        ),
      ],
      buttonLabel: 'Get Started',
      isSuccessStep: true,
    );
  }

  Widget _stepScaffold({
    required AuthController auth,
    required String title,
    required String subtitle,
    required List<Widget> fields,
    required String buttonLabel,
    bool isSuccessStep = false,
  }) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title.isNotEmpty) ...[
                  Text(title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A2E),
                      )),
                  const SizedBox(height: 6),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF7A8FA6))),
                  const SizedBox(height: 28),
                ],
                ...fields,
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: Obx(() => ElevatedButton(
                  onPressed: auth.isLoading.value
                      ? null
                      : isSuccessStep
                          ? () => auth.resetForm()
                          : () => auth.nextStep(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1AB4F5),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: auth.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          buttonLabel,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                )),
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A2E),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
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
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFFDDE4EE), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFF1AB4F5), width: 2),
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF7A8FA6), size: 20),
        suffixIcon: suffix,
      ),
    );
  }

  Widget _dropdownField(AuthController auth) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDDE4EE), width: 1.5),
      ),
      child: DropdownButtonFormField<String>(
        value: auth.countryController.text.isEmpty
            ? null
            : auth.countryController.text,
        hint: const Text('Select your country',
            style: TextStyle(color: Color(0xFF7A8FA6), fontSize: 14)),
        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF7A8FA6)),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          prefixIcon:
              Icon(Icons.public, color: Color(0xFF7A8FA6), size: 20),
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

  Widget _termsCheckbox(AuthController auth) {
    return Obx(() => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Transform.scale(
              scale: 1.1,
              child: Checkbox(
                value: auth.agreeToTerms.value,
                onChanged: (v) => auth.agreeToTerms.value = v ?? false,
                activeColor: const Color(0xFF1AB4F5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                side: const BorderSide(
                    color: Color(0xFFDDE4EE), width: 1.5),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: GestureDetector(
                onTap: () =>
                    auth.agreeToTerms.value = !auth.agreeToTerms.value,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: RichText(
                    text: TextSpan(
                      text: 'By continuing, you agree to our ',
                      style: const TextStyle(
                          color: Color(0xFF7A8FA6),
                          fontSize: 13,
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

  Widget _passwordStrength(AuthController auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('Password strength: ',
                style: TextStyle(fontSize: 12, color: Color(0xFF7A8FA6))),
            Obx(() => Text(
                  auth.passwordStrengthText.value,
                  style: TextStyle(
                    fontSize: 12,
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
                valueColor: AlwaysStoppedAnimation<Color>(
                    auth.passwordStrengthColor.value),
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
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF7A8FA6))),
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
}