import 'package:flutter/material.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final List<Map<String, dynamic>> _items = [];
  final TextEditingController _searchController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ════════════════════════════════════════════
  //  APP BAR
  // ════════════════════════════════════════════
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: kText),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Invoice',
        style: TextStyle(
          color: kText,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: kText),
          onPressed: () {},
        ),
      ],
    );
  }

  // ════════════════════════════════════════════
  //  BODY
  // ════════════════════════════════════════════
  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Search/Customer selection
          _buildCustomerSection(),
          const SizedBox(height: 12),
          
          // Date and tax section
          _buildDateAndTaxSection(),
          const SizedBox(height: 12),
          
          // Items section
          _buildItemsSection(),
          const SizedBox(height: 12),
          
          // Total section
          _buildTotalSection(),
          const SizedBox(height: 12),
          
          // Attach files section
          _buildAttachFilesSection(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════
  //  CUSTOMER SECTION
  // ════════════════════════════════════════════
  Widget _buildCustomerSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Who is it for?',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: kText,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: kBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorder),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search or select a customer',
                hintStyle: TextStyle(color: kSubText.withOpacity(0.5), fontSize: 14),
                prefixIcon: Icon(Icons.search, color: kSubText, size: 20),
                suffixIcon: Icon(Icons.arrow_drop_down, color: kSubText),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════
  //  DATE AND TAX SECTION
  // ════════════════════════════════════════════
  Widget _buildDateAndTaxSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Date row
          Row(
            children: [
              Expanded(
                child: _buildInfoRow(
                  label: 'Dated today',
                  value: 'Today, 19 Mar',
                  icon: Icons.calendar_today_outlined,
                ),
              ),
              Container(
                height: 40,
                width: 1,
                color: kBorder,
              ),
              Expanded(
                child: _buildInfoRow(
                  label: 'Due today',
                  value: 'Today, 19 Mar',
                  icon: Icons.event_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Tax row
          Row(
            children: [
              Expanded(
                child: _buildInfoRow(
                  label: 'Tax exclusive',
                  value: 'Tax exclusive',
                  icon: Icons.receipt_outlined,
                  showIcon: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    IconData? icon,
    bool showIcon = true,
  }) {
    return Row(
      children: [
        if (showIcon && icon != null) ...[
          Icon(icon, size: 18, color: kSubText),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: kSubText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kText,
                ),
              ),
            ],
          ),
        ),
        if (!showIcon)
          Icon(Icons.arrow_drop_down, color: kSubText),
      ],
    );
  }

  // ════════════════════════════════════════════
  //  ITEMS SECTION
  // ════════════════════════════════════════════
  Widget _buildItemsSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Items',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: kText,
            ),
          ),
          const SizedBox(height: 12),
          
          // Items list
          if (_items.isEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                border: Border.all(color: kBorder, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 48, color: kSubText.withOpacity(0.3)),
                    const SizedBox(height: 8),
                    Text(
                      'No items added',
                      style: TextStyle(color: kSubText, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const Divider(color: kBorder),
              itemBuilder: (context, index) {
                return _buildItemTile(_items[index], index);
              },
            ),
          ],
          
          const SizedBox(height: 12),
          
          // Add item button
          OutlinedButton.icon(
            onPressed: _showAddItemDialog,
            icon: const Icon(Icons.add, size: 18),
            label: const Text(
              'ADD AN ITEM',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: kPrimary,
              side: BorderSide(color: kPrimary, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemTile(Map<String, dynamic> item, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: kText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item['quantity']} x ${item['rate']}',
                  style: TextStyle(
                    fontSize: 13,
                    color: kSubText,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${item['amount']}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: kText,
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 18, color: kSubText),
            onPressed: () {
              setState(() {
                _items.removeAt(index);
              });
            },
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog() {
    final nameController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final rateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Item name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: quantityController,
                    decoration: InputDecoration(
                      labelText: 'Qty',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: rateController,
                    decoration: InputDecoration(
                      labelText: 'Rate',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: kSubText)),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  quantityController.text.isNotEmpty &&
                  rateController.text.isNotEmpty) {
                final quantity = double.parse(quantityController.text);
                final rate = double.parse(rateController.text);
                final amount = quantity * rate;
                
                setState(() {
                  _items.add({
                    'name': nameController.text,
                    'quantity': quantity.toString(),
                    'rate': '\$${rate.toStringAsFixed(2)}',
                    'amount': '\$${amount.toStringAsFixed(2)}',
                  });
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════
  //  TOTAL SECTION
  // ════════════════════════════════════════════
  Widget _buildTotalSection() {
    double total = 0;
    for (var item in _items) {
      final amountStr = item['amount']?.toString().replaceAll('\$', '') ?? '0';
      total += double.tryParse(amountStr) ?? 0;
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: kText,
            ),
          ),
          Text(
            '${total.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: kPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════
  //  ATTACH FILES SECTION
  // ════════════════════════════════════════════
  Widget _buildAttachFilesSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: OutlinedButton.icon(
        onPressed: () {
          // Handle file attachment
        },
        icon: Icon(Icons.attach_file, size: 18, color: kPrimary),
        label: const Text(
          '+ ATTACH FILES',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: kPrimary,
          side: BorderSide(color: kPrimary, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          minimumSize: const Size(double.infinity, 48),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════
  //  BOTTOM BAR
  // ════════════════════════════════════════════
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // Save as draft
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: kText,
                  side: BorderSide(color: kBorder, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Save as draft',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Email invoice
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// Add the color constants if they're not already defined elsewhere
const Color kPrimary = Color(0xFF1AB4F5);
const Color kPrimaryDark = Color(0xFF0FA3E0);
const Color kBg = Color(0xFFF0F4F8);
const Color kCardBg = Colors.white;
const Color kText = Color(0xFF1A1A2E);
const Color kSubText = Color(0xFF7A8FA6);
const Color kBorder = Color(0xFFDDE4EE);