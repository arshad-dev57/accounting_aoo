import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      appBar: AppBar(
        title: const Text(
          'About App',
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
        child: Column(
          children: [
            // App Logo & Name
            _buildAppHeader(),
            
            // App Description
            _buildAppDescription(),
            
            // Features List
            _buildFeaturesList(),
            
            // Version Info
            _buildVersionInfo(),
            
            // // Developer Info
            // _buildDeveloperInfo(),
            
            // Social Links
            _buildSocialLinks(),
            
            // Legal Links
            // _buildLegalLinks(),
            
            // Copyright
            _buildCopyright(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1AB4F5), Color(0xFF0D8BC0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.account_balance,
              size: 60,
              color: Color(0xFF1AB4F5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'LedgerPro Pro',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Smart LedgerPro Solution',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppDescription() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Color(0xFF1AB4F5),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'About This App',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'LedgerPro Pro is a comprehensive financial management solution designed to help businesses of all sizes track their finances, manage invoices, generate reports, and make informed business decisions.',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF7A8FA6),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Whether you are a small business owner, freelancer, or accountant, LedgerPro Pro provides all the tools you need to manage your finances efficiently and accurately.',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF7A8FA6),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      {'icon': Icons.trending_up, 'title': 'Income & Expense Tracking', 'color': const Color(0xFF2ECC71)},
      {'icon': Icons.receipt, 'title': 'Invoice & Bill Management', 'color': const Color(0xFF3498DB)},
      {'icon': Icons.account_balance, 'title': 'Bank Account Management', 'color': const Color(0xFF9B59B6)},
      {'icon': Icons.assessment, 'title': 'Financial Reports', 'color': const Color(0xFF1ABC9C)},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '✨ Key Features',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: features.map((feature) {
              return Container(
                padding: const EdgeInsets.all(12),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: feature['color']!.toString().contains('#') 
                            ? Color(int.parse(feature['color']!.toString().replaceFirst('#', '0xFF')))
                            : Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(feature['icon'] as IconData, color: feature['color'] as Color, size: 28),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      feature['title'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildInfoRow(Icons.code, 'Version', '1.0.0'),
            const Divider(height: 24),
            _buildInfoRow(Icons.calendar_today, 'Release Date', 'April 2026'),
            const Divider(height: 24),
            _buildInfoRow(Icons.android, 'Platform', 'Android & iOS'),
            const Divider(height: 24),
            _buildInfoRow(Icons.update, 'Last Updated', 'April 04, 2026'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1AB4F5).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF1AB4F5), size: 20),
        ),
        const SizedBox(width: 16),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xFF7A8FA6),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }

  Widget _buildDeveloperInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1AB4F5), Color(0xFF0D8BC0)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const Icon(Icons.developer_mode, color: Colors.white, size: 40),
            const SizedBox(height: 12),
            Text(
              'Developed by',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            Text(
              'Zoltech Solutions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '© 2026 All Rights Reserved',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLinks() {
    final socialLinks = [
      {'icon': Icons.web, 'label': 'Website', 'url': 'https://zoltech.com', 'color': const Color(0xFF1AB4F5)},
      {'icon': Icons.facebook, 'label': 'Facebook', 'url': 'https://facebook.com/zoltech', 'color': const Color(0xFF1877F2)},
      {'icon': Icons.link, 'label': 'LinkedIn', 'url': 'https://linkedin.com/company/zoltech', 'color': const Color(0xFF0A66C2)},
      {'icon': Icons.alternate_email, 'label': 'Twitter', 'url': 'https://twitter.com/zoltech', 'color': const Color(0xFF1DA1F2)},
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connect With Us',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: socialLinks.map((social) {
                return GestureDetector(
                  onTap: () async {
                    final Uri url = Uri.parse(social['url']! as String);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: social['color']!.toString().contains('#') 
                          ? Color(int.parse(social['color']!.toString().replaceFirst('#', '0xFF'))).withOpacity(0.1)
                          : Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: social['color']!.toString().contains('#') 
                          ? Color(int.parse(social['color']!.toString().replaceFirst('#', '0xFF'))).withOpacity(0.3)
                          : Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(social['icon'] as IconData, color: social['color'] as Color, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          social['label'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: social['color'] as Color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalLinks() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                // TODO: Open Privacy Policy
                Get.snackbar('Privacy Policy', 'Coming soon...',
                    snackPosition: SnackPosition.BOTTOM);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1AB4F5),
                side: const BorderSide(color: Color(0xFF1AB4F5)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Privacy Policy'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                // TODO: Open Terms of Service
                Get.snackbar('Terms of Service', 'Coming soon...',
                    snackPosition: SnackPosition.BOTTOM);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1AB4F5),
                side: const BorderSide(color: Color(0xFF1AB4F5)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Terms of Service'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyright() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Made with ❤️ in Pakistan',
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF7A8FA6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This app uses industry-standard security practices to protect your data.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: const Color(0xFFB0BEC5),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}