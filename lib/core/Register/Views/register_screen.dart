import 'package:accounting_app/core/plans/views/Subscription_plans.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

// ─────────────────────────────────────────────
//  Theme constants — same as your project
// ─────────────────────────────────────────────
const Color kPrimary = Color(0xFF1AB4F5);
const Color kPrimaryDark = Color(0xFF0FA3E0);
const Color kBg = Colors.white;
const Color kText = Color(0xFF1A1A2E);
const Color kSubText = Color(0xFF7A8FA6);
const Color kBorder = Color(0xFFDDE4EE);
const Color kFieldBg = Color(0xFFF5F8FC);

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  int _currentStep = 0;
  bool _agreeToTerms = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final List<String> countries = [
    'Pakistan', 'United States', 'United Kingdom', 'Canada',
    'Australia', 'India', 'Bangladesh', 'Sri Lanka', 'Nepal', 'UAE',
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ── step labels & icons ──────────────────────
  final _stepLabels = ['Personal', 'Contact', 'Password'];
  final _stepIcons = [
    Icons.person_outline,
    Icons.phone_outlined,
    Icons.lock_outline,
    Icons.check_circle_outline,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          // ── Blue header ─────────────────────
          _buildHeader(),

          // ── Step tabs ───────────────────────
          _buildStepTabs(),

          // ── Form content (scrollable) ────────
          Expanded(
            child: _buildCurrentStep(),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════
  //  HEADER
  // ════════════════════════════════════════════
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimary, kPrimaryDark],
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
                onPressed: () => Navigator.maybePop(context),
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
              const SizedBox(width: 48), // balance
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════
  //  STEP TABS
  // ════════════════════════════════════════════
  Widget _buildStepTabs() {
    return Container(
      color: kBg,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: List.generate(_stepLabels.length, (i) {
          final isActive = _currentStep >= i;
          final isDone = _currentStep > i;
          final isLast = i == _stepLabels.length - 1;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (i <= _currentStep + 1) {
                        setState(() => _currentStep = i);
                      }
                    },
                    child: Column(
                      children: [
                        // Circle
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: isDone
                                ? kPrimary
                                : isActive
                                    ? kPrimary.withOpacity(0.12)
                                    : kFieldBg,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isActive ? kPrimary : kBorder,
                              width: isActive ? 2 : 1.5,
                            ),
                          ),
                          child: Icon(
                            isDone ? Icons.check : _stepIcons[i],
                            color: isDone
                                ? Colors.white
                                : isActive
                                    ? kPrimary
                                    : kSubText,
                            size: 18,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _stepLabels[i],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                            color: isActive ? kPrimary : kSubText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Connector line
                if (!isLast)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: _currentStep > i ? kPrimary : kBorder,
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

  // ════════════════════════════════════════════
  //  CURRENT STEP ROUTER
  // ════════════════════════════════════════════
  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0: return _buildPersonalStep();
      case 1: return _buildContactStep();
      case 2: return _buildPasswordStep();
      case 3: return _buildSuccessStep();
      default: return _buildPersonalStep();
    }
  }

  // ════════════════════════════════════════════
  //  STEP 1 — Personal Info
  // ════════════════════════════════════════════
  Widget _buildPersonalStep() {
    return _stepScaffold(
      title: 'Personal Information',
      subtitle: 'Please provide your personal details',
      fields: [
        _fieldLabel('First Name'),
        _inputField(
          controller: _firstNameController,
          hint: 'Enter your first name',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 20),
        _fieldLabel('Last Name'),
        _inputField(
          controller: _lastNameController,
          hint: 'Enter your last name',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 20),
        _fieldLabel('Country'),
        _dropdownField(),
      ],
      buttonLabel: 'Next',
      onNext: _firstNameController.text.isNotEmpty &&
              _lastNameController.text.isNotEmpty &&
              _countryController.text.isNotEmpty
          ? () => setState(() => _currentStep = 1)
          : null,
    );
  }

  // ════════════════════════════════════════════
  //  STEP 2 — Contact
  // ════════════════════════════════════════════
  Widget _buildContactStep() {
    return _stepScaffold(
      title: 'Contact Information',
      subtitle: 'How can we reach you?',
      fields: [
        _fieldLabel("What's your phone number?"),
        _inputField(
          controller: _phoneController,
          hint: '+92 300 1234567',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 20),
        _fieldLabel("What's your email?"),
        _inputField(
          controller: _emailController,
          hint: 'you@example.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        _termsCheckbox(),
      ],
      buttonLabel: 'Next',
      onNext: _phoneController.text.isNotEmpty &&
              _emailController.text.contains('@') &&
              _agreeToTerms
          ? () => setState(() => _currentStep = 2)
          : null,
    );
  }

  // ════════════════════════════════════════════
  //  STEP 3 — Password
  // ════════════════════════════════════════════
  Widget _buildPasswordStep() {
    return _stepScaffold(
      title: 'Create Password',
      subtitle: 'Choose a strong password for your account',
      fields: [
        _fieldLabel('Password'),
        _inputField(
          controller: _passwordController,
          hint: 'Enter your password',
          icon: Icons.lock_outline,
          obscure: !_passwordVisible,
          suffix: IconButton(
            icon: Icon(
              _passwordVisible ? Icons.visibility : Icons.visibility_off,
              color: kSubText, size: 20,
            ),
            onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
          ),
          onChanged: (_) => setState(() {}),
        ),
        if (_passwordController.text.isNotEmpty) ...[
          const SizedBox(height: 10),
          _passwordStrength(),
        ],
        const SizedBox(height: 20),
        _fieldLabel('Confirm Password'),
        _inputField(
          controller: _confirmPasswordController,
          hint: 'Re-enter your password',
          icon: Icons.lock_outline,
          obscure: !_confirmPasswordVisible,
          suffix: IconButton(
            icon: Icon(
              _confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: kSubText, size: 20,
            ),
            onPressed: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible),
          ),
        ),
      ],
      buttonLabel: 'Create Account',
      onNext: _passwordController.text.length >= 6 &&
              _passwordController.text == _confirmPasswordController.text
          ? () => setState(() => _currentStep = 3)
          : null,
    );
  }

  // ════════════════════════════════════════════
  //  STEP 4 — Success
  // ════════════════════════════════════════════
  Widget _buildSuccessStep() {
    return _stepScaffold(
      title: '',
      subtitle: '',
      fields: [
        const SizedBox(height: 8),
        // Big tick
        Center(
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [kPrimary, kPrimaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: kPrimary.withOpacity(0.35),
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
          child: Text(
            'Account Activated!',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: kText,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Welcome, ${_firstNameController.text}! 🎉',
            style: const TextStyle(fontSize: 15, color: kSubText),
          ),
        ),
        const SizedBox(height: 28),
        // Info card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kFieldBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kBorder),
          ),
          child: Column(
            children: [
              _infoRow(Icons.person, 'Name',
                  '${_firstNameController.text} ${_lastNameController.text}'),
              _divider(),
              _infoRow(Icons.public, 'Country', _countryController.text),
              _divider(),
              _infoRow(Icons.phone, 'Phone', _phoneController.text),
              _divider(),
              _infoRow(Icons.email, 'Email', _emailController.text),
            ],
          ),
        ),
      ],
      buttonLabel: 'Get Started',
      onNext: () {
     Get.to(SelectPlanScreen());
      },
    );
  }

  Widget _stepScaffold({
    required String title,
    required String subtitle,
    required List<Widget> fields,
    required String buttonLabel,
    required VoidCallback? onNext,
  }) {
    return Column(
      children: [
        // Scrollable content
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
                        color: kText,
                      )),
                  const SizedBox(height: 6),
                  Text(subtitle,
                      style: const TextStyle(fontSize: 14, color: kSubText)),
                  const SizedBox(height: 28),
                ],
                ...fields,
              ],
            ),
          ),
        ),

        // ── Sticky bottom button ──────────────
        Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          decoration: BoxDecoration(
            color: kBg,
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
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: onNext != null ? kPrimary : kBorder,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
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
          color: kText,
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
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      onChanged: onChanged ?? (_) => setState(() {}),
      style: const TextStyle(fontSize: 14, color: kText),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: kSubText, fontSize: 14),
        filled: true,
        fillColor: kFieldBg,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kPrimary, width: 2),
        ),
        prefixIcon: Icon(icon, color: kSubText, size: 20),
        suffixIcon: suffix,
      ),
    );
  }

  Widget _dropdownField() {
    return Container(
      decoration: BoxDecoration(
        color: kFieldBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder, width: 1.5),
      ),
      child: DropdownButtonFormField<String>(
        value: _countryController.text.isEmpty ? null : _countryController.text,
        hint: const Text('Select your country',
            style: TextStyle(color: kSubText, fontSize: 14)),
        icon: const Icon(Icons.keyboard_arrow_down, color: kSubText),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          prefixIcon: Icon(Icons.public, color: kSubText, size: 20),
        ),
        items: countries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
        onChanged: (v) => setState(() => _countryController.text = v ?? ''),
      ),
    );
  }

  Widget _termsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.scale(
          scale: 1.1,
          child: Checkbox(
            value: _agreeToTerms,
            onChanged: (v) => setState(() => _agreeToTerms = v ?? false),
            activeColor: kPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            side: const BorderSide(color: kBorder, width: 1.5),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _agreeToTerms = !_agreeToTerms),
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: RichText(
                text: TextSpan(
                  text: 'By continuing, you agree to our ',
                  style: const TextStyle(color: kSubText, fontSize: 13, height: 1.5),
                  children: [
                    TextSpan(
                      text: 'Terms of Service',
                      style: const TextStyle(
                          color: kPrimary, fontWeight: FontWeight.w600),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: const TextStyle(
                          color: kPrimary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _passwordStrength() {
    final p = _passwordController.text;
    double s = 0;
    if (p.length >= 8) s += 0.3;
    if (p.contains(RegExp(r'[A-Z]'))) s += 0.2;
    if (p.contains(RegExp(r'[0-9]'))) s += 0.2;
    if (p.contains(RegExp(r'[!@#\$%^&*]'))) s += 0.3;
    s = s.clamp(0.0, 1.0);

    final label = s >= 0.7 ? 'Strong' : s >= 0.4 ? 'Medium' : 'Weak';
    final color = s >= 0.7 ? const Color(0xFF2ECC71) : s >= 0.4 ? Colors.orange : Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Password strength: ',
                style: TextStyle(fontSize: 12, color: kSubText)),
            Text(label,
                style: TextStyle(
                    fontSize: 12, color: color, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: s,
            minHeight: 5,
            backgroundColor: kBorder,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: kPrimary, size: 16),
          ),
          const SizedBox(width: 12),
          Text('$label:',
              style: const TextStyle(fontSize: 13, color: kSubText)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: kText),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(color: kBorder, height: 1);
}