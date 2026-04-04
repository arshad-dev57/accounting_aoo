import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/core/dashboard/Screens/dashbaord_screen.dart';
import 'package:flutter/material.dart';

class PurchaseOrderScreen extends StatefulWidget {
  const PurchaseOrderScreen({super.key});

  @override
  State<PurchaseOrderScreen> createState() => _PurchaseOrderScreenState();
}

class _PurchaseOrderScreenState extends State<PurchaseOrderScreen> {
  final List<Map<String, dynamic>> _items = [];
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _attentionController = TextEditingController();
  final TextEditingController _instructionController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  DateTime _deliveryDate = DateTime.now().add(const Duration(days: 7));
  String _taxType = 'Tax exclusive';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  // ════════════════════════════════════════════
  //  APP BAR WITH SAVE BUTTON
  // ════════════════════════════════════════════
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon:  Icon(Icons.arrow_back, color: kText),
        onPressed: () => Navigator.pop(context),
      ),
      title:Text(
        'Purchase Order',
        style: TextStyle(
          color: kText,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
      actions: [
        TextButton(
          onPressed: _savePurchaseOrder,
          style: TextButton.styleFrom(
            foregroundColor: kPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child:Text(
            'Save',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
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
          // Who is it for section
          _buildCustomerSection(),
          const SizedBox(height: 12),
          
          // Date and delivery section
          _buildDateAndDeliverySection(),
          const SizedBox(height: 12),
          
          // Tax section
          _buildTaxSection(),
          const SizedBox(height: 12),
          
          // Items section
          _buildItemsSection(),
          const SizedBox(height: 12),
          
          // Total section
          _buildTotalSection(),
          const SizedBox(height: 12),
          
          // Delivery Details section
          _buildDeliveryDetailsSection(),
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
         Text(
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
                hintText: 'Search or select a vendor',
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
  //  DATE AND DELIVERY SECTION
  // ════════════════════════════════════════════
  Widget _buildDateAndDeliverySection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectDate(context, isDelivery: false),
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
                  onTap: () => _selectDate(context, isDelivery: true),
                  child: _buildInfoRow(
                    label: 'Delivery date',
                    value: _formatDate(_deliveryDate),
                    icon: Icons.local_shipping_outlined,
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
  //  TAX SECTION
  // ════════════════════════════════════════════
  Widget _buildTaxSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: _showTaxTypeDialog,
        child: _buildInfoRow(
          label: 'Tax exclusive',
          value: _taxType,
          icon: Icons.receipt_outlined,
          showIcon: false,
        ),
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
                style:  TextStyle(
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
         Text(
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
              physics:  NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              separatorBuilder: (_, __) =>  Divider(color: kBorder),
              itemBuilder: (context, index) {
                return _buildItemTile(_items[index], index);
              },
            ),
          ],
          
          const SizedBox(height: 12),
          
          // Add item button
          OutlinedButton.icon(
            onPressed: _showAddItemDialog,
            icon: Icon(Icons.add, size: 18),
            label:Text(
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
                  style:  TextStyle(
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
            style:  TextStyle(
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
        title:Text('Add Item'),
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
            child:Text('Add'),
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
         Text(
            'TOTAL',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: kText,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            '${total.toStringAsFixed(2)}',
            style:  TextStyle(
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
  //  DELIVERY DETAILS SECTION
  // ════════════════════════════════════════════
  Widget _buildDeliveryDetailsSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         Text(
            'Delivery Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: kText,
            ),
          ),
          const SizedBox(height: 16),
          
          // Email address
          _buildDeliveryField(
            label: 'Email address',
            icon: Icons.email_outlined,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          
          // Contact number
          _buildDeliveryField(
            label: 'Contact number',
            icon: Icons.phone_outlined,
            controller: _phoneController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          
          // Attention
          _buildDeliveryField(
            label: 'Attention',
            icon: Icons.person_outline,
            controller: _attentionController,
          ),
          const SizedBox(height: 16),
          
          // Instruction
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: kSubText),
                  const SizedBox(width: 8),
                  Text(
                    'Instruction',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: kBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBorder),
                ),
                child: TextField(
                  controller: _instructionController,
                  maxLines: 4,
                  minLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Add any special instructions for delivery...',
                    hintStyle: TextStyle(color: kSubText.withOpacity(0.5), fontSize: 13),
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

  Widget _buildDeliveryField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: kSubText),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: kBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kBorder),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: 'Enter $label',
              hintStyle: TextStyle(color: kSubText.withOpacity(0.5), fontSize: 13),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════
  //  HELPER METHODS
  // ════════════════════════════════════════════
  Future<void> _selectDate(BuildContext context, {required bool isDelivery}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDelivery ? _deliveryDate : _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isDelivery) {
          _deliveryDate = picked;
        } else {
          _selectedDate = picked;
        }
      });
    }
  }

  void _showTaxTypeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:Text('Select Tax Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title:Text('Tax exclusive'),
              onTap: () {
                setState(() => _taxType = 'Tax exclusive');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title:Text('Tax inclusive'),
              onTap: () {
                setState(() => _taxType = 'Tax inclusive');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title:Text('No tax'),
              onTap: () {
                setState(() => _taxType = 'No tax');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _savePurchaseOrder() {
    // Validate required fields
    if (_searchController.text.isEmpty) {
      _showErrorSnackBar('Please select a vendor');
      return;
    }
    
    if (_items.isEmpty) {
      _showErrorSnackBar('Please add at least one item');
      return;
    }

    // Here you would typically save the purchase order
    // For now, show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Purchase Order saved successfully'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
    
    Navigator.pop(context);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
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
    _searchController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _attentionController.dispose();
    _instructionController.dispose();
    super.dispose();
  }
}