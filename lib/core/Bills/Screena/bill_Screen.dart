import 'package:accounting_app/core/dashboard/Screens/dashbaord_screen.dart';
import 'package:flutter/material.dart';

class BillScreen extends StatefulWidget {
  const BillScreen({super.key});

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  final List<Map<String, dynamic>> _items = [];
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _forController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  Map<String, dynamic>? _selectedCategory;

  final List<Map<String, dynamic>> _categories = [
    // Expense Categories
    {'name': 'Expenses', 'code': '500', 'type': 'expense', 'children': [
      {'name': 'Office Supplies', 'code': '501', 'type': 'expense'},
      {'name': 'Travel Expenses', 'code': '502', 'type': 'expense'},
      {'name': 'Meals & Entertainment', 'code': '503', 'type': 'expense'},
      {'name': 'Utilities', 'code': '504', 'type': 'expense'},
      {'name': 'Rent', 'code': '505', 'type': 'expense'},
      {'name': 'Insurance', 'code': '506', 'type': 'expense'},
      {'name': 'Professional Fees', 'code': '507', 'type': 'expense'},
      {'name': 'Maintenance & Repairs', 'code': '508', 'type': 'expense'},
    ]},
    
    // Cost of Goods Sold
    {'name': 'Cost of Goods Sold', 'code': '301', 'type': 'cogs', 'children': [
      {'name': '301 - Cost of Goods Sold', 'code': '301', 'type': 'cogs'},
      {'name': 'Inventory Purchases', 'code': '302', 'type': 'cogs'},
      {'name': 'Freight & Shipping', 'code': '303', 'type': 'cogs'},
      {'name': 'Direct Labor', 'code': '304', 'type': 'cogs'},
      {'name': 'Raw Materials', 'code': '305', 'type': 'cogs'},
    ]},
    
    // Advertising Categories
    {'name': 'Advertising', 'code': '400', 'type': 'advertising', 'children': [
      {'name': '400 - Advertising', 'code': '400', 'type': 'advertising'},
      {'name': 'Digital Marketing', 'code': '401', 'type': 'advertising'},
      {'name': 'Print Advertising', 'code': '402', 'type': 'advertising'},
      {'name': 'Social Media Ads', 'code': '403', 'type': 'advertising'},
      {'name': 'Google Ads', 'code': '404', 'type': 'advertising'},
      {'name': 'Facebook Ads', 'code': '405', 'type': 'advertising'},
      {'name': 'Billboard Advertising', 'code': '406', 'type': 'advertising'},
      {'name': 'Radio Advertising', 'code': '407', 'type': 'advertising'},
      {'name': 'TV Advertising', 'code': '408', 'type': 'advertising'},
    ]},
    
    // Office Expenses
    {'name': 'Office Expenses', 'code': '600', 'type': 'office', 'children': [
      {'name': 'Office Rent', 'code': '601', 'type': 'office'},
      {'name': 'Office Supplies', 'code': '602', 'type': 'office'},
      {'name': 'Office Equipment', 'code': '603', 'type': 'office'},
      {'name': 'Printing & Stationery', 'code': '604', 'type': 'office'},
    ]},
    
    // Professional Services
    {'name': 'Professional Services', 'code': '700', 'type': 'professional', 'children': [
      {'name': 'Accounting Fees', 'code': '701', 'type': 'professional'},
      {'name': 'Legal Fees', 'code': '702', 'type': 'professional'},
      {'name': 'Consulting Fees', 'code': '703', 'type': 'professional'},
    ]},
    
    // Travel & Entertainment
    {'name': 'Travel & Entertainment', 'code': '800', 'type': 'travel', 'children': [
      {'name': 'Airfare', 'code': '801', 'type': 'travel'},
      {'name': 'Hotel Accommodation', 'code': '802', 'type': 'travel'},
      {'name': 'Meals', 'code': '803', 'type': 'travel'},
      {'name': 'Client Entertainment', 'code': '804', 'type': 'travel'},
    ]},
    
    // Technology
    {'name': 'Technology', 'code': '900', 'type': 'tech', 'children': [
      {'name': 'Software Subscriptions', 'code': '901', 'type': 'tech'},
      {'name': 'Hardware Purchases', 'code': '902', 'type': 'tech'},
      {'name': 'Cloud Services', 'code': '903', 'type': 'tech'},
      {'name': 'Website Hosting', 'code': '904', 'type': 'tech'},
    ]},
    
    // Utilities
    {'name': 'Utilities', 'code': '1000', 'type': 'utilities', 'children': [
      {'name': 'Electricity', 'code': '1001', 'type': 'utilities'},
      {'name': 'Water', 'code': '1002', 'type': 'utilities'},
      {'name': 'Gas', 'code': '1003', 'type': 'utilities'},
      {'name': 'Internet', 'code': '1004', 'type': 'utilities'},
      {'name': 'Telephone', 'code': '1005', 'type': 'utilities'},
    ]},
    
    // Other Categories
    {'name': 'Other', 'code': '2000', 'type': 'other', 'children': [
      {'name': 'Miscellaneous', 'code': '2001', 'type': 'other'},
      {'name': 'Bank Fees', 'code': '2002', 'type': 'other'},
      {'name': 'Interest Expense', 'code': '2003', 'type': 'other'},
      {'name': 'Taxes & Licenses', 'code': '2004', 'type': 'other'},
    ]},
  ];

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
        'Bill',
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
          // From and For section
          _buildFromAndForSection(),
          const SizedBox(height: 12),
          
          // Date section
          _buildDateSection(),
          const SizedBox(height: 12),
          
          // Category section
          _buildCategorySection(),
          const SizedBox(height: 12),
          
          // Items section
          _buildItemsSection(),
          const SizedBox(height: 12),
          
          // Total section
          _buildTotalSection(),
          const SizedBox(height: 12),
          
          // Attach files button
          _buildAttachFilesButton(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════
  //  FROM AND FOR SECTION
  // ════════════════════════════════════════════
  Widget _buildFromAndForSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // What was it from?
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'What was it from?',
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
                  controller: _fromController,
                  decoration: InputDecoration(
                    hintText: 'Vendor or supplier name',
                    hintStyle: TextStyle(color: kSubText.withOpacity(0.5), fontSize: 14),
                    prefixIcon: Icon(Icons.business, color: kSubText, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // What was it for?
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'What was it for?',
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
                  controller: _forController,
                  maxLines: 3,
                  minLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Description of the bill',
                    hintStyle: TextStyle(color: kSubText.withOpacity(0.5), fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════
  //  DATE SECTION
  // ════════════════════════════════════════════
  Widget _buildDateSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectDate(context, isDue: false),
                  child: _buildInfoRow(
                    label: 'Dated today',
                    value: _formatDate(_selectedDate),
                    icon: Icons.calendar_today_outlined,
                  ),
                ),
              ),
              Container(
                height: 40,
                width: 1,
                color: kBorder,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectDate(context, isDue: true),
                  child: _buildInfoRow(
                    label: 'Due today',
                    value: _formatDate(_dueDate),
                    icon: Icons.event_outlined,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════
  //  CATEGORY SECTION
  // ════════════════════════════════════════════
  Widget _buildCategorySection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Categories to an account',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: kText,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _showCategoryBottomSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: kBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kBorder),
              ),
              child: Row(
                children: [
                  Icon(Icons.category_outlined, size: 20, color: kSubText),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedCategory != null 
                          ? '${_selectedCategory!['code']} - ${_selectedCategory!['name']}'
                          : 'Select a category',
                      style: TextStyle(
                        fontSize: 14,
                        color: _selectedCategory != null ? kText : kSubText,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: kSubText),
                ],
              ),
            ),
          ),
          if (_selectedCategory != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Selected: ${_selectedCategory!['type']}',
                style: TextStyle(
                  fontSize: 12,
                  color: kPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    IconData? icon,
  }) {
    return Row(
      children: [
        if (icon != null) ...[
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
      ],
    );
  }

  // ════════════════════════════════════════════
  //  CATEGORY BOTTOM SHEET
  // ════════════════════════════════════════════
  void _showCategoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: kBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Select Category',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: kText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search categories...',
                      prefixIcon: Icon(Icons.search, color: kSubText),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: kBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: kBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: kPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        return _buildCategoryExpansionTile(category);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryExpansionTile(Map<String, dynamic> category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: kBorder),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getCategoryColor(category['type']).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getCategoryIcon(category['type']),
              color: _getCategoryColor(category['type']),
              size: 18,
            ),
          ),
          title: Text(
            '${category['name']}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: kText,
            ),
          ),
          subtitle: Text(
            'Code: ${category['code']}',
            style: TextStyle(
              fontSize: 12,
              color: kSubText,
            ),
          ),
          children: (category['children'] as List).map((child) {
            return ListTile(
              leading: Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: kSubText,
                  shape: BoxShape.circle,
                ),
              ),
              title: Text(
                child['name'],
                style: const TextStyle(
                  fontSize: 14,
                  color: kText,
                ),
              ),
              trailing: Text(
                child['code'],
                style: TextStyle(
                  fontSize: 12,
                  color: kSubText,
                ),
              ),
              onTap: () {
                setState(() {
                  _selectedCategory = child;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getCategoryColor(String type) {
    switch (type) {
      case 'expense':
        return Colors.orange;
      case 'cogs':
        return Colors.blue;
      case 'advertising':
        return Colors.purple;
      case 'office':
        return Colors.green;
      case 'professional':
        return Colors.teal;
      case 'travel':
        return Colors.pink;
      case 'tech':
        return Colors.indigo;
      case 'utilities':
        return Colors.brown;
      default:
        return kPrimary;
    }
  }

  IconData _getCategoryIcon(String type) {
    switch (type) {
      case 'expense':
        return Icons.receipt_outlined;
      case 'cogs':
        return Icons.inventory_2_outlined;
      case 'advertising':
        return Icons.campaign_outlined;
      case 'office':
        return Icons.business_center_outlined;
      case 'professional':
        return Icons.work_outline;
      case 'travel':
        return Icons.flight_outlined;
      case 'tech':
        return Icons.computer_outlined;
      case 'utilities':
        return Icons.electrical_services_outlined;
      default:
        return Icons.category_outlined;
    }
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
            '\$${total.toStringAsFixed(2)}',
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
  //  ATTACH FILES BUTTON
  // ════════════════════════════════════════════
  Widget _buildAttachFilesButton() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: OutlinedButton.icon(
        onPressed: _showAttachFilesBottomSheet,
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

  void _showAttachFilesBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: kBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Attach Files',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: kText,
                ),
              ),
              const SizedBox(height: 20),
              _buildAttachmentOption(
                icon: Icons.photo_library_outlined,
                label: 'Gallery',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _buildAttachmentOption(
                icon: Icons.camera_alt_outlined,
                label: 'Camera',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _buildAttachmentOption(
                icon: Icons.insert_drive_file_outlined,
                label: 'Document',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: kSubText, fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: kPrimary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: kPrimary),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: kText,
        ),
      ),
      onTap: onTap,
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
                  // Save bill
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
                  'Save',
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

  // ════════════════════════════════════════════
  //  HELPER METHODS
  // ════════════════════════════════════════════
  Future<void> _selectDate(BuildContext context, {required bool isDue}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDue ? _dueDate : _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isDue) {
          _dueDate = picked;
        } else {
          _selectedDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${_getMonth(date.month)} ${date.day}, ${date.year}';
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  @override
  void dispose() {
    _fromController.dispose();
    _forController.dispose();
    super.dispose();
  }
}