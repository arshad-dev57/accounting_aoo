import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1AB4F5),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildLastUpdated(),
            const SizedBox(height: 20),
            _buildIntroduction(),
            const SizedBox(height: 20),
            _buildSection(
              title: '1. Information We Collect',
              icon: Icons.data_usage,
              content: 'We collect the following types of information:\n\n• Personal Information: Name, email address, phone number, and billing information\n• Financial Data: Income, expenses, invoices, bank account details\n• Usage Data: How you interact with the App, features used, and time spent\n• Device Information: Device model, operating system, and unique device identifiers',
            ),
            _buildSection(
              title: '2. How We Use Your Information',
              icon: Icons.analytics,
              content: 'We use your information to:\n\n• Provide and maintain the App\'s core functionality\n• Process your transactions and manage your account\n• Generate financial reports and insights\n• Send important notifications and updates\n• Improve and optimize the App performance\n• Respond to your support requests',
            ),
            _buildSection(
              title: '3. Data Storage and Security',
              icon: Icons.security,
              content: '• All your data is encrypted using industry-standard encryption (AES-256)\n• Data is stored on secure cloud servers with regular backups\n• We implement firewalls and intrusion detection systems\n• Access to your data is restricted to authorized personnel only\n• We conduct regular security audits and penetration testing',
            ),
            _buildSection(
              title: '4. Data Sharing and Disclosure',
              icon: Icons.share,
              content: 'We do not sell your personal information. We may share your data only in the following circumstances:\n\n• With your explicit consent\n• To comply with legal obligations\n• To protect our rights and prevent fraud\n• With service providers who assist us (subject to confidentiality agreements)',
            ),
            _buildSection(
              title: '5. Third-Party Services',
              icon: Icons.apps,
              content: 'The App may integrate with third-party services such as:\n\n• Payment processors for subscription billing\n• Cloud storage providers for backups\n• Analytics services to improve the App\n\nThese services have their own privacy policies, and we encourage you to review them.',
            ),
            _buildSection(
              title: '6. Your Rights and Choices',
              icon: Icons.gavel,
              content: 'You have the right to:\n\n• Access and download your personal data\n• Request correction of inaccurate data\n• Request deletion of your data (subject to legal requirements)\n• Opt-out of marketing communications\n• Export your financial data in standard formats',
            ),
            _buildSection(
              title: '7. Data Retention',
              icon: Icons.history,
              content: 'We retain your data as long as your account is active. If you delete your account, we will delete your personal data within 30 days, except where we are required to retain it for legal or legitimate business purposes.',
            ),
            _buildSection(
              title: '8. Children\'s Privacy',
              icon: Icons.child_care,
              content: 'The App is not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13. If you believe we have collected such information, please contact us immediately.',
            ),
            _buildSection(
              title: '9. International Data Transfers',
              icon: Icons.public,
              content: 'Your information may be transferred to and processed in countries other than your own. We ensure appropriate safeguards are in place to protect your data in accordance with this Privacy Policy.',
            ),
            _buildSection(
              title: '10. Cookies and Tracking',
              icon: Icons.cookie,
              content: 'We use cookies and similar tracking technologies to:\n\n• Remember your login session\n• Understand how you use the App\n• Improve user experience\n\nYou can control cookie preferences through your device settings.',
            ),
            _buildSection(
              title: '11. Changes to This Privacy Policy',
              icon: Icons.update,
              content: 'We may update this Privacy Policy from time to time. We will notify you of any material changes by:\n\n• Sending an email to your registered address\n• Displaying a notice within the App\n• Updating the "Last Updated" date at the top of this policy',
            ),
            _buildSection(
              title: '12. Contact Us',
              icon: Icons.contact_support,
              content: 'If you have questions about this Privacy Policy or our data practices, please contact us:\n\n📧 privacy@LedgerPro.com\n📞 +92 300 1234567\n📍 Zoltech Solutions, Lahore, Pakistan',
            ),
            _buildDataProtectionBadge(),
            const SizedBox(height: 20),
            _buildAcceptButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLastUpdated() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1AB4F5).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1AB4F5).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.update, color: Color(0xFF1AB4F5), size: 16),
          const SizedBox(width: 8),
          Text(
            'Effective Date: April 04, 2026 | Last Updated: April 04, 2026',
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF1AB4F5),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroduction() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.privacy_tip, color: Color(0xFF1AB4F5), size: 28),
              const SizedBox(width: 12),
              Text(
                'Your Privacy Matters',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'At LedgerPro Pro, we are committed to protecting your privacy and securing your financial data. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.',
            style: TextStyle(
              fontSize: 13,
              color: const Color(0xFF7A8FA6),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1AB4F5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF1AB4F5), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              color: const Color(0xFF7A8FA6),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataProtectionBadge() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1AB4F5), Color(0xFF0D8BC0)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Data is Protected',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'We use bank-level encryption to secure your financial information',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          Get.back();
          Get.snackbar(
            'Accepted',
            'You have accepted the Privacy Policy',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1AB4F5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'I Accept the Privacy Policy',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}