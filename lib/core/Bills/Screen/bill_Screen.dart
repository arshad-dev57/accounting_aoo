import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/Utils/responsive_utils.dart';
import 'package:LedgerPro_app/core/bills/controller/bills_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';

class BillsScreen extends StatelessWidget {
  final String? vendorId;
  
  const BillsScreen({super.key, this.vendorId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BillsController());
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (vendorId != null && vendorId!.isNotEmpty && controller.vendors.isNotEmpty) {
        bool vendorExists = controller.vendors.any((v) => v['_id'].toString() == vendorId);
        if (vendorExists) {
          controller.filterByVendor(vendorId!);
        } else {
          controller.filterByVendor('');
        }
      }
    });
    
    return Container(
      color: kBg,
      child: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: LoadingAnimationWidget.waveDots(
              color: kPrimary,
              size: ResponsiveUtils.isWeb(context) ? 60 : 40,
            ),
          );
        }

        // Single ScrollView that scrolls everything together
        return SingleChildScrollView(
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(controller, context),
              _buildSummaryCards(controller, context),
              _buildFilterBar(controller, context),
              _buildBillsList(controller, context),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  // Custom Header without AppBar
  Widget _buildHeader(BillsController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final isMobile = ResponsiveUtils.isMobile(context);
    
    return Container(
      padding: EdgeInsets.fromLTRB(
        isWeb ? 24 : 16,
        isWeb ? 20 : 16,
        isWeb ? 24 : 16,
        isWeb ? 16 : 12,
      ),
      decoration: BoxDecoration(
        color: kPrimary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bills',
                  style: TextStyle(
                    fontSize: isWeb ? 20 : 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage all your bills',
                  style: TextStyle(
                    fontSize: isWeb ? 13 : 11,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          // Filter Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.filter_alt_outlined, color: Colors.white, size: isWeb ? 22 : 20),
              onPressed: () => _showFilterDialog(controller, context),
            ),
          ),
          if (!isMobile) const SizedBox(width: 8),
          // Export Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.download_outlined, color: Colors.white, size: isWeb ? 22 : 20),
              onPressed: () => controller.exportBills(),
            ),
          ),
          if (!isMobile) const SizedBox(width: 8),
          if (!isMobile)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(Icons.add, color: kPrimary, size: isWeb ? 22 : 20),
                onPressed: () => _showAddBillDialog(controller, context),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BillsController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Obx(() => Container(
      padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 16 : 12),
      child: Row(
        children: [
          _buildSummaryCard(
            'Total Amount',
            _formatAmount(controller.totalAmount.value),
            kPrimary,
            Icons.receipt,
            context,
          ),
          SizedBox(width: isWeb ? 16 : 12),
          _buildSummaryCard(
            'Paid',
            _formatAmount(controller.totalPaid.value),
            kSuccess,
            Icons.check_circle,
            context,
          ),
          SizedBox(width: isWeb ? 16 : 12),
          _buildSummaryCard(
            'Outstanding',
            _formatAmount(controller.totalOutstanding.value),
            kDanger,
            Icons.payment,
            context,
          ),
        ],
      ),
    ));
  }

  Widget _buildSummaryCard(String title, String amount, Color color, IconData icon, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(isWeb ? 16 : 12),
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                Icon(icon, size: isWeb ? 24 : 20, color: color),
                SizedBox(width: isWeb ? 8 : 6),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: isWeb ? 12 : 11,
                      color: kSubText,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: isWeb ? 8 : 6),
            Text(
              amount,
              style: TextStyle(
                fontSize: isWeb ? 18 : 14,
                fontWeight: FontWeight.w800,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar(BillsController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 12 : 10),
      color: kCardBg,
      child: Row(
        children: [
          // Status Filter
          Expanded(
            child: Container(
              height: isWeb ? 45 : 40,
              padding: EdgeInsets.symmetric(horizontal: isWeb ? 16 : 12),
              decoration: BoxDecoration(
                color: kBg,
                borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
                border: Border.all(color: kBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: Obx(() => DropdownButton<String>(
                  value: controller.selectedFilter.value,
                  icon: Icon(Icons.arrow_drop_down, size: isWeb ? 24 : 20),
                  isExpanded: true,
                  style: TextStyle(fontSize: isWeb ? 13 : 12, color: kText),
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All')),
                    DropdownMenuItem(value: 'Unpaid', child: Text('Unpaid')),
                    DropdownMenuItem(value: 'Paid', child: Text('Paid')),
                    DropdownMenuItem(value: 'Overdue', child: Text('Overdue')),
                    DropdownMenuItem(value: 'Partial', child: Text('Partial')),
                  ],
                  onChanged: (value) {
                    if (value != null) controller.changeFilter(value);
                  },
                )),
              ),
            ),
          ),
          SizedBox(width: isWeb ? 16 : 12),
          // Vendor Filter
          Expanded(
            child: Container(
              height: isWeb ? 45 : 40,
              padding: EdgeInsets.symmetric(horizontal: isWeb ? 16 : 12),
              decoration: BoxDecoration(
                color: kBg,
                borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
                border: Border.all(color: kBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: Obx(() {
                  if (controller.vendors.isEmpty) {
                    return Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Loading vendors...',
                        style: TextStyle(fontSize: isWeb ? 13 : 12, color: kSubText),
                      ),
                    );
                  }
                  
                  String? currentValue = controller.selectedVendorId.value.isEmpty 
                      ? null 
                      : controller.selectedVendorId.value;
                  
                  if (currentValue != null && currentValue.isNotEmpty) {
                    bool exists = controller.vendors.any((v) => v['_id'] == currentValue);
                    if (!exists) {
                      currentValue = null;
                    }
                  }
                  
                  return DropdownButton<String>(
                    value: currentValue,
                    icon: Icon(Icons.arrow_drop_down, size: isWeb ? 24 : 20),
                    isExpanded: true,
                    hint: Text('All Vendors', style: TextStyle(fontSize: isWeb ? 13 : 12, color: kSubText)),
                    style: TextStyle(fontSize: isWeb ? 13 : 12, color: kText),
                    items: [
                      const DropdownMenuItem(value: '', child: Text('All Vendors')),
                      ...controller.vendors.map((vendor) {
                        return DropdownMenuItem<String>(
                          value: vendor['_id'].toString(),
                          child: Text(vendor['name'], overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        controller.filterByVendor(value);
                      }
                    },
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillsList(BillsController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Obx(() {
      final bills = controller.bills;

      if (bills.isEmpty) {
        return Padding(
          padding: EdgeInsets.all(isWeb ? 40 : 20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_outlined, size: isWeb ? 80 : 64, color: kSubText.withOpacity(0.5)),
                SizedBox(height: isWeb ? 20 : 16),
                Text(
                  'No bills found',
                  style: TextStyle(fontSize: isWeb ? 18 : 16, color: kSubText),
                ),
                SizedBox(height: isWeb ? 20 : 16),
                ElevatedButton(
                  onPressed: () => _showAddBillDialog(controller, context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 12 : 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
                    ),
                  ),
                  child: Text(
                    'Add Bill',
                    style: TextStyle(fontSize: isWeb ? 14 : 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 12 : 8),
            child: Text(
              'Bills',
              style: TextStyle(
                fontSize: isWeb ? 18 : 16,
                fontWeight: FontWeight.w700,
                color: kText,
              ),
            ),
          ),
          ...bills.map((bill) => Padding(
            padding: EdgeInsets.symmetric(horizontal: isWeb ? 20 : 12, vertical: isWeb ? 8 : 6),
            child: _buildBillCard(bill, controller, context),
          )).toList(),
        ],
      );
    });
  }

  Widget _buildBillCard(Bill bill, BillsController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final isMobile = ResponsiveUtils.isMobile(context);
    
    Color statusColor = bill.status == 'Paid' ? kSuccess :
                        bill.status == 'Overdue' ? kDanger :
                        bill.status == 'Partial' ? kWarning : kPrimary;

    return Container(
      margin: EdgeInsets.only(bottom: isWeb ? 12 : 8),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showBillDetails(bill, controller, context),
          borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
          child: Padding(
            padding: EdgeInsets.all(isWeb ? 16 : 12),
            child: isMobile
                ? _buildMobileBillCard(bill, controller, statusColor, context)
                : _buildDesktopBillCard(bill, controller, statusColor, context),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopBillCard(Bill bill, BillsController controller, Color statusColor, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: isWeb ? 50 : 44,
              height: isWeb ? 50 : 44,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
              ),
              child: Icon(Icons.receipt, size: isWeb ? 24 : 20, color: statusColor),
            ),
            SizedBox(width: isWeb ? 16 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        bill.billNumber,
                        style: TextStyle(
                          fontSize: isWeb ? 15 : 13,
                          fontWeight: FontWeight.w800,
                          color: kText,
                        ),
                      ),
                      SizedBox(width: isWeb ? 8 : 6),
                      _statusBadge(bill.status, statusColor, isWeb),
                    ],
                  ),
                  SizedBox(height: isWeb ? 4 : 2),
                  Text(
                    bill.vendorName,
                    style: TextStyle(fontSize: isWeb ? 12 : 11, color: kSubText),
                  ),
                  Text(
                    'Due: ${DateFormat('dd MMM yyyy').format(bill.dueDate)}',
                    style: TextStyle(
                      fontSize: isWeb ? 12 : 11,
                      color: bill.isOverdue ? kDanger : kSubText,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatAmount(bill.totalAmount),
                  style: TextStyle(fontSize: isWeb ? 16 : 14, fontWeight: FontWeight.w800, color: kText),
                ),
                SizedBox(height: isWeb ? 4 : 2),
                Text(
                  'Paid: ${_formatAmount(bill.paidAmount)}',
                  style: TextStyle(fontSize: isWeb ? 12 : 11, color: kSuccess),
                ),
                if (bill.outstanding > 0)
                  Text(
                    'Due: ${_formatAmount(bill.outstanding)}',
                    style: TextStyle(fontSize: isWeb ? 12 : 11, color: kDanger),
                  ),
              ],
            ),
          ],
        ),
        SizedBox(height: isWeb ? 16 : 12),
        if (bill.items.isNotEmpty)
          _buildBillItemsPreview(bill.items, isWeb),
        SizedBox(height: isWeb ? 16 : 12),
        Row(
          children: [
            if (bill.status != 'Paid')
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _recordBillPayment(bill, controller, context),
                  icon: Icon(Icons.payment, size: isWeb ? 18 : 14, color: Colors.white),
                  label: Text('Pay Now', style: TextStyle(fontSize: isWeb ? 12 : 10)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kSuccess,
                    padding: EdgeInsets.symmetric(vertical: isWeb ? 10 : 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isWeb ? 8 : 6),
                    ),
                  ),
                ),
              ),
            if (bill.status != 'Paid') SizedBox(width: isWeb ? 12 : 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _printBill(bill, context),
                icon: Icon(Icons.print, size: isWeb ? 18 : 14),
                label: Text('Print', style: TextStyle(fontSize: isWeb ? 12 : 10)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kPrimary,
                  side: BorderSide(color: kPrimary, width: 1),
                  padding: EdgeInsets.symmetric(vertical: isWeb ? 10 : 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isWeb ? 8 : 6),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileBillCard(Bill bill, BillsController controller, Color statusColor, BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.receipt, size: 20, color: statusColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          bill.billNumber,
                          style:  TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: kText,
                          ),
                        ),
                      ),
                      _statusBadge(bill.status, statusColor, false),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    bill.vendorName,
                    style:  TextStyle(fontSize: 11, color: kSubText),
                  ),
                  Text(
                    'Due: ${DateFormat('dd MMM yyyy').format(bill.dueDate)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: bill.isOverdue ? kDanger : kSubText,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatAmount(bill.totalAmount),
                  style:  TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: kText),
                ),
                Text(
                  'Paid: ${_formatAmount(bill.paidAmount)}',
                  style: const TextStyle(fontSize: 10, color: kSuccess),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (bill.items.isNotEmpty)
          _buildMobileBillItemsPreview(bill.items),
        const SizedBox(height: 12),
        Row(
          children: [
            if (bill.status != 'Paid')
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _recordBillPayment(bill, controller, context),
                  icon: Icon(Icons.payment, size: 14, color: Colors.white),
                  label: const Text('Pay Now', style: TextStyle(fontSize: 9)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kSuccess,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            if (bill.status != 'Paid') const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _printBill(bill, context),
                icon: Icon(Icons.print, size: 14),
                label: const Text('Print', style: TextStyle(fontSize: 9)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kPrimary,
                  side: const BorderSide(color: kPrimary, width: 1),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBillItemsPreview(List<BillItem> items, bool isWeb) {
    if (items.isEmpty) return const SizedBox.shrink();
    
    return Column(
      children: items.take(2).map((item) {
        return Padding(
          padding: EdgeInsets.only(bottom: isWeb ? 8 : 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  item.description,
                  style: TextStyle(fontSize: isWeb ? 12 : 11, color: kSubText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${item.quantity} x ${_formatAmount(item.unitPrice)}',
                style: TextStyle(fontSize: isWeb ? 12 : 11, color: kSubText),
              ),
              SizedBox(width: isWeb ? 12 : 8),
              Text(
                _formatAmount(item.amount),
                style: TextStyle(fontSize: isWeb ? 12 : 11, fontWeight: FontWeight.w600, color: kText),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMobileBillItemsPreview(List<BillItem> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    
    return Column(
      children: items.take(2).map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  item.description,
                  style:  TextStyle(fontSize: 10, color: kSubText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${item.quantity} x ${_formatAmount(item.unitPrice)}',
                style:  TextStyle(fontSize: 9, color: kSubText),
              ),
              const SizedBox(width: 6),
              Text(
                _formatAmount(item.amount),
                style:  TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: kText),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _statusBadge(String status, Color color, bool isWeb) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWeb ? 8 : 6, vertical: isWeb ? 4 : 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(isWeb ? 6 : 4)),
      child: Text(
        status,
        style: TextStyle(
          fontSize: isWeb ? 11 : 9,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showAddBillDialog(BillsController controller, BuildContext ctx) {
    final isWeb = ResponsiveUtils.isWeb(ctx);
    final formKey = GlobalKey<FormState>();
    String selectedVendorId = '';
    DateTime selectedDate = DateTime.now();
    DateTime selectedDueDate = DateTime.now().add(const Duration(days: 30));
    List<Map<String, dynamic>> items = [];
    double discount = 0;
    String notes = '';

    void addItem() {
      items.add({'description': '', 'quantity': 1, 'unitPrice': 0.0, 'taxRate': 0.0});
    }
    addItem();

    showDialog(
      context: ctx,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          double calculateTotal() {
            double subtotal = 0;
            for (var item in items) {
              subtotal += (item['quantity'] * item['unitPrice']);
            }
            return subtotal - discount;
          }

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              width: isWeb ? 600 : double.infinity,
              constraints: BoxConstraints(maxHeight: isWeb ? 700 : 600),
              padding: EdgeInsets.all(isWeb ? 24 : 20),
              child: Column(
                children: [
                  Text('Add Bill', style: TextStyle(fontSize: isWeb ? 20 : 18, fontWeight: FontWeight.w800)),
                  SizedBox(height: isWeb ? 20 : 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            DropdownButtonFormField<String>(
                              value: selectedVendorId.isEmpty ? null : selectedVendorId,
                              decoration: _inputDecoration('Vendor *', isWeb),
                              style: TextStyle(fontSize: isWeb ? 13 : 12),
                              items: controller.vendors.map((v) {
                                return DropdownMenuItem<String>(
                                  value: v['_id'].toString(),
                                  child: Text(v['name'], style: TextStyle(color: Colors.black)),
                                );
                              }).toList(),
                              onChanged: (v) => selectedVendorId = v!,
                              validator: (v) => v == null ? 'Vendor required' : null,
                            ),
                            SizedBox(height: isWeb ? 16 : 12),
                            Row(
                              children: [
                                Expanded(child: _dateTile('Bill Date', selectedDate, (d) => selectedDate = d, isWeb, ctx)),
                                SizedBox(width: isWeb ? 16 : 12),
                                Expanded(child: _dateTile('Due Date', selectedDueDate, (d) => selectedDueDate = d, isWeb, ctx)),
                              ],
                            ),
                            SizedBox(height: isWeb ? 16 : 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Items', style: TextStyle(fontSize: isWeb ? 14 : 12, fontWeight: FontWeight.w700)),
                                TextButton.icon(
                                  onPressed: () => setState(() => addItem()),
                                  icon: Icon(Icons.add, size: isWeb ? 20 : 16),
                                  label: Text('Add Item', style: TextStyle(fontSize: isWeb ? 12 : 11)),
                                ),
                              ],
                            ),
                            ...items.asMap().entries.map((entry) {
                              int index = entry.key;
                              var item = entry.value;
                              return Container(
                                margin: EdgeInsets.only(bottom: isWeb ? 16 : 12),
                                padding: EdgeInsets.all(isWeb ? 12 : 10),
                                decoration: BoxDecoration(
                                  color: kBg,
                                  borderRadius: BorderRadius.circular(isWeb ? 10 : 8),
                                  border: Border.all(color: kBorder),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            decoration: _inputDecoration('Description', isWeb),
                                            style: TextStyle(fontSize: isWeb ? 13 : 12),
                                            onChanged: (v) => item['description'] = v,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete, size: isWeb ? 20 : 16, color: kDanger),
                                          onPressed: () => setState(() => items.removeAt(index)),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: isWeb ? 8 : 6),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            decoration: _inputDecoration('Qty', isWeb),
                                            keyboardType: TextInputType.number,
                                            style: TextStyle(fontSize: isWeb ? 13 : 12),
                                            onChanged: (v) {
                                              item['quantity'] = int.tryParse(v) ?? 1;
                                              setState(() {});
                                            },
                                          ),
                                        ),
                                        SizedBox(width: isWeb ? 12 : 8),
                                        Expanded(
                                          flex: 2,
                                          child: TextFormField(
                                            decoration: _inputDecoration('Unit Price', isWeb, prefix: '₨ '),
                                            keyboardType: TextInputType.number,
                                            style: TextStyle(fontSize: isWeb ? 13 : 12),
                                            onChanged: (v) {
                                              item['unitPrice'] = double.tryParse(v) ?? 0;
                                              setState(() {});
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            SizedBox(height: isWeb ? 16 : 12),
                            TextFormField(
                              decoration: _inputDecoration('Discount', isWeb, prefix: '₨ '),
                              keyboardType: TextInputType.number,
                              style: TextStyle(fontSize: isWeb ? 13 : 12),
                              onChanged: (v) => discount = double.tryParse(v) ?? 0,
                            ),
                            SizedBox(height: isWeb ? 16 : 12),
                            TextFormField(
                              decoration: _inputDecoration('Notes', isWeb),
                              maxLines: 2,
                              style: TextStyle(fontSize: isWeb ? 13 : 12),
                              onChanged: (v) => notes = v,
                            ),
                            Container(
                              padding: EdgeInsets.all(isWeb ? 16 : 12),
                              decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(isWeb ? 10 : 8)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Total Amount', style: TextStyle(fontSize: isWeb ? 14 : 12, fontWeight: FontWeight.w600)),
                                  Text(_formatAmount(calculateTotal()), style: TextStyle(fontSize: isWeb ? 16 : 14, fontWeight: FontWeight.w800, color: kPrimary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isWeb ? 20 : 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          child: Text('Cancel', style: TextStyle(fontSize: isWeb ? 14 : 12)),
                        ),
                      ),
                      SizedBox(width: isWeb ? 16 : 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate() && selectedVendorId.isNotEmpty) {
                              Get.back();
                              await controller.createBill({
                                'vendorId': selectedVendorId,
                                'date': selectedDate.toIso8601String(),
                                'dueDate': selectedDueDate.toIso8601String(),
                                'items': items.map((item) => ({
                                  'description': item['description'],
                                  'quantity': item['quantity'],
                                  'unitPrice': item['unitPrice'],
                                  'taxRate': item['taxRate'],
                                })).toList(),
                                'discount': discount,
                                'notes': notes,
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                          child: Text('Create Bill', style: TextStyle(fontSize: isWeb ? 14 : 12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _recordBillPayment(Bill bill, BillsController controller, BuildContext ctx) {
    final isWeb = ResponsiveUtils.isWeb(ctx);
    final formKey = GlobalKey<FormState>();
    double amount = bill.outstanding;
    DateTime paymentDate = DateTime.now();
    String paymentMethod = 'Bank Transfer';
    String reference = '';
    String selectedBankAccountId = '';

    showDialog(
      context: ctx,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Pay Bill - ${bill.billNumber}', style: TextStyle(fontSize: isWeb ? 18 : 14, fontWeight: FontWeight.w800)),
            content: SizedBox(
              width: isWeb ? 400 : 280,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(isWeb ? 16 : 12),
                      decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(isWeb ? 10 : 8)),
                      child: Column(
                        children: [
                          _detailRow('Vendor', bill.vendorName, isWeb),
                          _detailRow('Bill Date', DateFormat('dd MMM yyyy').format(bill.date), isWeb),
                          _detailRow('Due Date', DateFormat('dd MMM yyyy').format(bill.dueDate), isWeb),
                          _detailRow('Total Amount', _formatAmount(bill.totalAmount), isWeb),
                          _detailRow('Outstanding', _formatAmount(bill.outstanding), isWeb, isImportant: true),
                        ],
                      ),
                    ),
                    SizedBox(height: isWeb ? 16 : 12),
                    TextFormField(
                      initialValue: amount.toString(),
                      decoration: _inputDecoration('Payment Amount *', isWeb, prefix: '₨ '),
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: isWeb ? 13 : 12),
                      onChanged: (v) => amount = double.tryParse(v) ?? 0,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Amount required';
                        final val = double.tryParse(v);
                        if (val == null || val <= 0) return 'Invalid amount';
                        if (val > bill.outstanding) return 'Amount exceeds outstanding';
                        return null;
                      },
                    ),
                    SizedBox(height: isWeb ? 16 : 12),
                    _dateTile('Payment Date', paymentDate, (d) => paymentDate = d, isWeb, ctx),
                    SizedBox(height: isWeb ? 16 : 12),
                    DropdownButtonFormField<String>(
                      value: paymentMethod,
                      decoration: _inputDecoration('Payment Method', isWeb),
                      style: TextStyle(fontSize: isWeb ? 13 : 12),
                      items: const [
                        DropdownMenuItem(value: 'Bank Transfer', child: Text('Bank Transfer')),
                        DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                        DropdownMenuItem(value: 'Cheque', child: Text('Cheque')),
                      ],
                      onChanged: (v) => paymentMethod = v!,
                    ),
                    SizedBox(height: isWeb ? 16 : 12),
                    TextFormField(
                      decoration: _inputDecoration('Reference Number', isWeb),
                      style: TextStyle(fontSize: isWeb ? 13 : 12),
                      onChanged: (v) => reference = v,
                    ),
                    if (paymentMethod == 'Bank Transfer') ...[
                      SizedBox(height: isWeb ? 16 : 12),
                      Obx(() => DropdownButtonFormField<String>(
                        value: selectedBankAccountId.isEmpty ? null : selectedBankAccountId,
                        decoration: _inputDecoration('Bank Account *', isWeb),
                        style: TextStyle(fontSize: isWeb ? 13 : 12),
                        items: controller.bankAccounts.map((acc) {
                          return DropdownMenuItem<String>(
                            value: acc['_id'].toString(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(acc['accountName'], style: TextStyle(fontSize: isWeb ? 13 : 12, fontWeight: FontWeight.w600)),
                                Text('Balance: ${_formatAmount(acc['currentBalance'])}', style: TextStyle(fontSize: isWeb ? 11 : 10, color: kSubText)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (v) => selectedBankAccountId = v!,
                        validator: (v) => v == null ? 'Bank account required' : null,
                      )),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Get.back(), child: Text('Cancel', style: TextStyle(fontSize: isWeb ? 14 : 12))),
              Obx(() => ElevatedButton(
                onPressed: controller.isProcessing.value
                    ? null
                    : () {
                        if (formKey.currentState!.validate()) {
                          if (paymentMethod == 'Bank Transfer' && selectedBankAccountId.isEmpty) {
                            Get.snackbar('Error', 'Please select a bank account');
                            return;
                          }
                          Get.back();
                          controller.recordPayment(
                            billId: bill.id,
                            amount: amount,
                            paymentDate: paymentDate,
                            paymentMethod: paymentMethod,
                            reference: reference,
                            bankAccountId: selectedBankAccountId,
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(backgroundColor: kSuccess),
                child: controller.isProcessing.value
                    ? SizedBox(width: isWeb ? 24 : 20, height: isWeb ? 24 : 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('Record Payment', style: TextStyle(fontSize: isWeb ? 14 : 12)),
              )),
            ],
          );
        },
      ),
    );
  }

  void _showBillDetails(Bill bill, BillsController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    if (isWeb) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            child: _buildBillDetailsContent(bill, controller, ctx),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(maxHeight: 85.
          h),
          child: _buildBillDetailsContent(bill, controller, ctx),
        ),
      );
    }
  }

  Widget _buildBillDetailsContent(Bill bill, BillsController controller, BuildContext ctx) {
    final isWeb = ResponsiveUtils.isWeb(ctx);
    Color statusColor = bill.status == 'Paid' ? kSuccess :
                        bill.status == 'Overdue' ? kDanger :
                        bill.status == 'Partial' ? kWarning : kPrimary;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: isWeb ? 60 : 50,
              height: isWeb ? 60 : 50,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isWeb ? 14 : 10),
              ),
              child: Icon(Icons.receipt, size: isWeb ? 28 : 24, color: statusColor),
            ),
            SizedBox(width: isWeb ? 16 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bill.billNumber, style: TextStyle(fontSize: isWeb ? 18 : 16, fontWeight: FontWeight.w800)),
                  Text(bill.vendorName, style: TextStyle(fontSize: isWeb ? 13 : 12, color: kSubText)),
                ],
              ),
            ),
            _statusBadge(bill.status, statusColor, isWeb),
          ],
        ),
        SizedBox(height: isWeb ? 20 : 16),
        Container(
          padding: EdgeInsets.all(isWeb ? 16 : 12),
          decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(isWeb ? 12 : 10)),
          child: Column(
            children: [
              _detailRow('Bill Date', DateFormat('dd MMM yyyy').format(bill.date), isWeb),
              _detailRow('Due Date', DateFormat('dd MMM yyyy').format(bill.dueDate), isWeb),
              _detailRow('Subtotal', _formatAmount(bill.subtotal), isWeb),
              if (bill.taxTotal > 0) _detailRow('Tax', _formatAmount(bill.taxTotal), isWeb),
              if (bill.discount > 0) _detailRow('Discount', _formatAmount(bill.discount), isWeb),
              Divider(color: kBorder, height: isWeb ? 16 : 12),
              _detailRow('Total Amount', _formatAmount(bill.totalAmount), isWeb, isBold: true),
              _detailRow('Paid Amount', _formatAmount(bill.paidAmount), isWeb, color: kSuccess),
              _detailRow('Outstanding', _formatAmount(bill.outstanding), isWeb, color: kDanger, isBold: true),
            ],
          ),
        ),
        SizedBox(height: isWeb ? 20 : 16),
        Text('Items', style: TextStyle(fontSize: isWeb ? 16 : 14, fontWeight: FontWeight.w700)),
        SizedBox(height: isWeb ? 12 : 8),
        ...bill.items.map((item) => Container(
          margin: EdgeInsets.only(bottom: isWeb ? 12 : 8),
          padding: EdgeInsets.all(isWeb ? 12 : 10),
          decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(isWeb ? 10 : 8)),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.description, style: TextStyle(fontSize: isWeb ? 13 : 12, fontWeight: FontWeight.w600)),
                    Text('${item.quantity} x ${_formatAmount(item.unitPrice)}', style: TextStyle(fontSize: isWeb ? 11 : 10, color: kSubText)),
                  ],
                ),
              ),
              Text(_formatAmount(item.amount), style: TextStyle(fontSize: isWeb ? 14 : 12, fontWeight: FontWeight.w700)),
            ],
          ),
        )).toList(),
        if (bill.notes.isNotEmpty) ...[
          SizedBox(height: isWeb ? 20 : 16),
          Text('Notes', style: TextStyle(fontSize: isWeb ? 16 : 14, fontWeight: FontWeight.w700)),
          SizedBox(height: isWeb ? 8 : 6),
          Text(bill.notes, style: TextStyle(fontSize: isWeb ? 13 : 12, color: kSubText)),
        ],
        SizedBox(height: isWeb ? 20 : 16),
        if (bill.status != 'Paid')
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _recordBillPayment(bill, controller, ctx);
              },
              icon: Icon(Icons.payment, size: isWeb ? 20 : 18),
              label: Text('Pay Now', style: TextStyle(fontSize: isWeb ? 14 : 12)),
              style: ElevatedButton.styleFrom(backgroundColor: kSuccess, padding: EdgeInsets.symmetric(vertical: isWeb ? 12 : 10)),
            ),
          ),
      ],
    );
  }

  void _showFilterDialog(BillsController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter Bills', style: TextStyle(fontSize: isWeb ? 18 : 14, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.calendar_today, size: isWeb ? 24 : 20),
              title: Text('Date Range', style: TextStyle(fontSize: isWeb ? 14 : 12)),
              trailing: Icon(Icons.arrow_forward_ios, size: isWeb ? 20 : 16),
              onTap: () async {
                Navigator.pop(context);
                final start = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (start != null) {
                  final end = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: start,
                    lastDate: DateTime.now(),
                  );
                  if (end != null) controller.setDateRange(start, end);
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.clear, size: isWeb ? 24 : 20),
              title: Text('Clear Filters', style: TextStyle(fontSize: isWeb ? 14 : 12)),
              onTap: () {
                Navigator.pop(context);
                controller.clearFilters();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(fontSize: isWeb ? 14 : 12)),
          ),
        ],
      ),
    );
  }

  void _printBill(Bill bill, BuildContext context) {
    Get.snackbar('Print', 'Printing ${bill.billNumber}...');
  }

  InputDecoration _inputDecoration(String label, bool isWeb, {String? prefix}) {
    return InputDecoration(
      labelText: label,
      prefixText: prefix,
      labelStyle: TextStyle(fontSize: isWeb ? 12 : 11),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(isWeb ? 10 : 8)),
      contentPadding: EdgeInsets.symmetric(horizontal: isWeb ? 16 : 12, vertical: isWeb ? 12 : 10),
    );
  }

  Widget _dateTile(String label, DateTime date, Function(DateTime) onChanged, bool isWeb, BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isWeb ? 16 : 12, vertical: isWeb ? 12 : 10),
        decoration: BoxDecoration(
          color: kBg,
          borderRadius: BorderRadius.circular(isWeb ? 10 : 8),
          border: Border.all(color: kBorder),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: isWeb ? 20 : 16, color: kPrimary),
            SizedBox(width: isWeb ? 12 : 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: isWeb ? 11 : 10, color: kSubText)),
                  Text(DateFormat('dd MMM yyyy').format(date), style: TextStyle(fontSize: isWeb ? 13 : 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, bool isWeb, {bool isImportant = false, bool isBold = false, Color? color}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isWeb ? 12 : 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isWeb ? 13 : 11, color: kSubText)),
          Text(
            value,
            style: TextStyle(
              fontSize: isWeb ? 13 : 12,
              fontWeight: isBold ? FontWeight.w800 : (isImportant ? FontWeight.w700 : FontWeight.w600),
              color: color ?? (isImportant ? kDanger : kText),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '₨ ${formatter.format(amount)}';
  }
}