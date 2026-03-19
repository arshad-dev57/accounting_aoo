import 'package:accounting_app/core/Bills/Screena/bill_Screen.dart';
import 'package:accounting_app/core/Contact/Screens/Contact_Screen.dart';
import 'package:accounting_app/core/Invoice/Screens/Invoice_Screen.dart';
import 'package:accounting_app/core/Quote/Screens/Quote_screen.dart';
import 'package:accounting_app/core/Reciept/Screens/reciept_screen.dart';
import 'package:accounting_app/core/purchaseOrder/Screen/Purchase_order_Screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';

const Color kPrimary = Color(0xFF1AB4F5);
const Color kPrimaryDark = Color(0xFF0FA3E0);
const Color kBg = Color(0xFFF0F4F8);
const Color kCardBg = Colors.white;
const Color kText = Color(0xFF1A1A2E);
const Color kSubText = Color(0xFF7A8FA6);
const Color kBorder = Color(0xFFDDE4EE);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _bottomIndex = 0;
  bool _fabMenuOpen = false;
  bool _isMenuOpen = false;

  final PageController _setupController = PageController();
  int _setupPage = 0;

  final List<Map<String, dynamic>> _fabItems = [
    {'label': 'Invoice', 'icon': Icons.receipt_long_outlined},
    {'label': 'Quote', 'icon': Icons.request_quote_outlined},
    {'label': 'Bill', 'icon': Icons.description_outlined},
    {'label': 'Purchase order', 'icon': Icons.shopping_bag_outlined},
    {'label': 'Receipt', 'icon': Icons.point_of_sale_outlined},
    {'label': 'Contact', 'icon': Icons.person_outline},
    {'label': 'Upload file', 'icon': Icons.upload_file_outlined},
  ];

  final List<Map<String, dynamic>> _setupCards = [
    {
      'title': 'Connect your bank',
      'subtitle': 'Link your bank account to auto-import transactions',
      'image': 'https://cdn-icons-png.flaticon.com/128/2830/2830284.png',
      'done': false,
    },
    {
      'title': 'Create your first invoice',
      'subtitle': 'You\'re all set up. Add your first invoice now.',
      'image': 'https://cdn-icons-png.flaticon.com/128/3135/3135715.png',
      'done': true,
    },
    {
      'title': 'Add a contact',
      'subtitle': 'Start building your contact list for easy billing.',
      'image': 'https://cdn-icons-png.flaticon.com/128/1077/1077114.png',
      'done': false,
    },
  ];

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  void _closeMenu() {
    if (_isMenuOpen) {
      setState(() {
        _isMenuOpen = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _closeMenu,
      child: Scaffold(
        backgroundColor: kBg,
        body: Stack(
          children: [
            Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: _buildBody(),
                ),
              ],
            ),

            if (_isMenuOpen) _buildAppBarDropdown(),
            if (_fabMenuOpen) _buildFabOverlay(),
            Positioned(
              bottom: 70,
              left: 20,
              child: _buildFab(),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimary, kPrimaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Text(
                'Zolatech',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.more_vert,
                        color: Colors.white, size: 22),
                    onPressed: _toggleMenu,
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {},
                child: const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarDropdown() {
    return Positioned(
      top: 80, 
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _fabItems.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final isLast = i == _fabItems.length - 1;
              return GestureDetector(
                onTap: () {
               if (item['label'] == 'Invoice') {
    Get.to(() => const InvoiceScreen()); 
  } else if (item['label'] == 'Quote') {
    Get.to(() => const QuoteScreen());
  } else if (item['label'] == 'Bill') {
    Get.to(() => const BillScreen());
  } else if (item['label'] == 'Purchase order') {
    Get.to(() => const PurchaseOrderScreen());
  } else if (item['label'] == 'Receipt') {
    Get.to(() => const ReceiptScreen());
  } else if (item['label'] == 'Contact') {
    // Navigate to Contact screen
    Get.to(() => const ContactScreen());
  } else if (item['label'] == 'Upload file') {
    // Navigate to Upload File screen
    // Get.to(() => const UploadFileScreen());
  }
  },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: isLast
                        ? null
                        : Border(
                            bottom: BorderSide(color: kBorder, width: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Icon(item['icon'], size: 18, color: kSubText),
                      const SizedBox(width: 12),
                      Text(
                        item['label'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: kText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        _buildSetupGuide(),
        const SizedBox(height: 12),

        _buildBankAccounts(),
        const SizedBox(height: 12),

        _buildOutstandingSection(
          title: 'Outstanding invoices',
          emptyText: 'You have no outstanding invoices',
          buttonLabel: 'Add invoice',
          onTap: () => _openFabMenu(),
        ),
        const SizedBox(height: 12),

        _buildOutstandingSection(
          title: 'Outstanding bills',
          emptyText: 'You have no outstanding bills',
          buttonLabel: 'Add bill',
          onTap: () => _openFabMenu(),
        ),
        const SizedBox(height: 12),
        _buildProfitLoss(),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSetupGuide() {
    return Container(
      color: kCardBg,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Setup guide',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: kText,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: PageView.builder(
              controller: _setupController,
              onPageChanged: (p) => setState(() => _setupPage = p),
              itemCount: _setupCards.length,
              itemBuilder: (context, i) => _buildSetupCard(_setupCards[i]),
            ),
          ),
          const SizedBox(height: 10),
          // Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_setupCards.length, (i) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _setupPage == i ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _setupPage == i ? kPrimary : kBorder,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupCard(Map<String, dynamic> card) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  card['title'],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  card['subtitle'],
                  style: const TextStyle(
                    fontSize: 11,
                    color: kSubText,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: card['done'] ? const Color(0xFFE8F8F0) : kPrimary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    card['done'] ? '✓ Done' : 'Get started',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: card['done'] ? const Color(0xFF1A6B45) : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Stack(
            children: [
              Image.network(
                card['image'],
                width: 72,
                height: 72,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.image, color: kPrimary, size: 36),
                ),
              ),
              if (card['done'])
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2ECC71),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 13),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════
  //  BANK ACCOUNTS
  // ════════════════════════════════════════════
  Widget _buildBankAccounts() {
    return Container(
      color: kCardBg,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bank accounts',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: kText,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: kPrimary,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Manage',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Log in to Xero on a computer to connect your bank.',
            style: TextStyle(fontSize: 13, color: kSubText, height: 1.4),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add bank account'),
            style: OutlinedButton.styleFrom(
              foregroundColor: kPrimary,
              side: const BorderSide(color: kPrimary, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              textStyle: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════
  //  OUTSTANDING SECTION (invoices / bills)
  // ════════════════════════════════════════════
  Widget _buildOutstandingSection({
    required String title,
    required String emptyText,
    required String buttonLabel,
    required VoidCallback onTap,
  }) {
    return Container(
      color: kCardBg,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: kText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            emptyText,
            style: const TextStyle(fontSize: 13, color: kSubText),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: kPrimary,
                side: const BorderSide(color: kPrimary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: kPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════
  //  PROFIT AND LOSS
  // ════════════════════════════════════════════
  Widget _buildProfitLoss() {
    return Container(
      color: kCardBg,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Profit and loss',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: kText,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: kPrimary,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                ),
                child: const Text('View report',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                const Text(
                  '0.00',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: kPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text('This month',
                    style: TextStyle(fontSize: 13, color: kSubText)),
                const SizedBox(height: 2),
                Text('Mar 2026',
                    style: TextStyle(
                        fontSize: 12,
                        color: kSubText,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Mini bar chart placeholder
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _bar(0.2, 'Oct'),
              _bar(0.4, 'Nov'),
              _bar(0.3, 'Dec'),
              _bar(0.6, 'Jan'),
              _bar(0.5, 'Feb'),
              _bar(0.0, 'Mar', isActive: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bar(double height, String label, {bool isActive = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          width: 28,
          height: height == 0 ? 4 : height * 60,
          decoration: BoxDecoration(
            color: isActive ? kPrimary : kPrimary.withOpacity(0.25),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: TextStyle(
                fontSize: 10,
                color: isActive ? kPrimary : kSubText,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.normal)),
      ],
    );
  }

  void _openFabMenu() => setState(() => _fabMenuOpen = true);

  Widget _buildFab() {
    return GestureDetector(
      onTap: () => setState(() => _fabMenuOpen = !_fabMenuOpen),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: _fabMenuOpen ? kText : const Color(0xFF2ECC71),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          _fabMenuOpen ? Icons.close : Icons.more_horiz,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildFabOverlay() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _fabMenuOpen = false),
        child: Container(
          color: Colors.black.withOpacity(0.08),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 128),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 210,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _fabItems.asMap().entries.map((entry) {
                      final i = entry.key;
                      final item = entry.value;
                      final isLast = i == _fabItems.length - 1;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _fabMenuOpen = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Create ${item['label']}'),
                              backgroundColor: kPrimary,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 1),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          decoration: BoxDecoration(
                            border: isLast
                                ? null
                                : Border(
                                    bottom: BorderSide(
                                        color: kBorder, width: 0.8)),
                          ),
                          child: Row(
                            children: [
                              Icon(item['icon'],
                                  size: 18, color: kSubText),
                              const SizedBox(width: 14),
                              Text(
                                item['label'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: kText,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_outlined, 'activeIcon': Icons.home, 'label': 'Home'},
      {'icon': Icons.receipt_long_outlined, 'activeIcon': Icons.receipt_long, 'label': 'Invoices'},
      {'icon': Icons.description_outlined, 'activeIcon': Icons.description, 'label': 'Bills'},
      {'icon': Icons.bar_chart_outlined, 'activeIcon': Icons.bar_chart, 'label': 'Reports'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final isActive = _bottomIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _bottomIndex = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isActive
                            ? item['activeIcon'] as IconData
                            : item['icon'] as IconData,
                        color: isActive ? kPrimary : kSubText,
                        size: 24,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          color: isActive ? kPrimary : kSubText,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}