import 'package:accounting_app/core/dashboard/Screens/dashbaord_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/utils.dart';

class PlanData {
  final String name;
  final String price;
  final String unit;
  final String originalPrice;
  final String saveText;
  final String includesTitle;
  final List<String> includes;
  final String? sectionTitle;
  final List<String>? sectionItems;
  final String footerText;
  final Color saveBadgeColor;

  const PlanData({
    required this.name,
    required this.price,
    required this.unit,
    required this.originalPrice,
    required this.saveText,
    required this.includesTitle,
    required this.includes,
    this.sectionTitle,
    this.sectionItems,
    required this.footerText,
    required this.saveBadgeColor,
  });
}

class SelectPlanScreen extends StatefulWidget {
  const SelectPlanScreen({super.key});

  @override
  State<SelectPlanScreen> createState() => _SelectPlanScreenState();
}

class _SelectPlanScreenState extends State<SelectPlanScreen> {
  int _selectedTab = 0;

  final List<String> _tabs = ['Starter', 'Standard', 'Premium'];

  final List<PlanData> _plans = const [
    PlanData(
      name: 'Starter',
      price: 'Rs 820',
      unit: 'PKR/mo',
      originalPrice: 'Rs 8,200/mo',
      saveText: 'Save PKR7,380.00 over 1 month',
      includesTitle: 'Starter includes',
      includes: [
        'Send quotes and 20 invoices*',
        'Enter 5 bills',
        'Reconcile bank transactions',
      ],
      sectionTitle: 'On your computer',
      sectionItems: [
        'Capture bills and receipts with Hubdoc',
        'Short-term cash flow and business snapshot',
      ],
      footerText:
          '1 month Rs 820/month, then Rs 8,200/mo. Add-ons and more plan options are available on xero.com.',
      saveBadgeColor: Color(0xFFD4F5E2),
    ),
    PlanData(
      name: 'Standard',
      price: 'Rs 1,150',
      unit: 'PKR/mo',
      originalPrice: 'Rs 11,500/mo',
      saveText: 'Save PKR10,350.00 over 1 month',
      includesTitle: 'Standard includes',
      includes: [
        'Send unlimited quotes and invoices',
        'Enter unlimited bills',
        'Reconcile bank transactions',
        'Bulk reconcile transactions',
      ],
      sectionTitle: 'On your computer',
      sectionItems: [
        'Capture bills and receipts with Hubdoc',
        'Short-term cash flow and business snapshot',
        'Analytics and insights',
      ],
      footerText:
          '1 month Rs 1,150/month, then Rs 11,500/mo. Add-ons and more plan options are available on xero.com.',
      saveBadgeColor: Color(0xFFD4F5E2),
    ),
    PlanData(
      name: 'Premium',
      price: 'Rs 1,640',
      unit: 'PKR/mo',
      originalPrice: 'Rs 16,400/mo',
      saveText: 'Save PKR14,760.00 over 1 month',
      includesTitle: 'Premium includes',
      includes: [
        'Send unlimited quotes and invoices',
        'Enter unlimited bills',
        'Reconcile bank transactions',
        'Bulk reconcile transactions',
        'Use multiple currencies',
      ],
      sectionTitle: 'On your computer',
      sectionItems: [
        'Capture bills and receipts with Hubdoc',
        'Short-term cash flow and business snapshot',
        'Analytics and insights',
        'Projects and expenses',
      ],
      footerText:
          '1 month Rs 1,640/month, then Rs 16,400/mo. Add-ons and more plan options are available on xero.com.',
      saveBadgeColor: Color(0xFFD4F5E2),
    ),
  ];

  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() => _selectedTab = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1AB4F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Select a plan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // Tab selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(
                  _tabs.length,
                  (index) => GestureDetector(
                    onTap: () => _onTabTapped(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedTab == index
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        _tabs[index],
                        style: TextStyle(
                          color: _selectedTab == index
                              ? const Color(0xFF1AB4F5)
                              : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Plan cards - PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() => _selectedTab = page);
                },
                itemCount: _plans.length,
                itemBuilder: (context, index) {
                  return _buildPlanCard(_plans[index]);
                },
              ),
            ),

            // Bottom section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Pricing plan and offer terms',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Icon(Icons.info_outline,
                            size: 12, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                      children: [
                        TextSpan(text: 'Join over 4.6 million\nsubscribers'),
                        WidgetSpan(
                          child: Padding(
                            padding: EdgeInsets.only(left: 6, bottom: 4),
                            child: Icon(Icons.auto_awesome,
                                color: Color(0xFF7DDFF5), size: 22),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(PlanData plan) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plan name
              Text(
                plan.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 10),

              // Price row
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    plan.price,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A2E),
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      plan.unit,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      plan.originalPrice,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[400],
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Save badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: plan.saveBadgeColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  plan.saveText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF1A6B45),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Divider
              Divider(color: Colors.grey[200], height: 1),
              const SizedBox(height: 16),

              // Includes section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    plan.includesTitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_up,
                      color: const Color(0xFF1AB4F5), size: 22),
                ],
              ),
              const SizedBox(height: 12),

              // Include bullets
              ...plan.includes.map((item) => _buildBullet(item)),

              if (plan.sectionTitle != null) ...[
                const SizedBox(height: 16),
                Text(
                  plan.sectionTitle!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 10),
                ...plan.sectionItems!.map((item) => _buildBullet(item)),
              ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Get.offAll(DashboardScreen(
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Buy now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Footer text
              Text(
                plan.footerText,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF1A1A2E),
              height: 1.5,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF1A1A2E),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}