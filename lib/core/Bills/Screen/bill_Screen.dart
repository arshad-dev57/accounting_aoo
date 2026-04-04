import 'package:LedgerPro_app/Utils/colors.dart';
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
        // Check if vendor exists in list
        bool vendorExists = controller.vendors.any((v) => v['_id'].toString() == vendorId);
        if (vendorExists) {
          controller.filterByVendor(vendorId!);
        } else {
          // Vendor not found, clear filter
          controller.filterByVendor('');
        }
      }
    });
    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(controller),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child:LoadingAnimationWidget.waveDots(
                    color: kPrimary,
                    size: 10.w,
                  )
          );
        }

        return Column(
          children: [
            _buildSummaryCards(controller),
            _buildFilterBar(controller),
            Expanded(
              child: _buildBillsList(controller),
            ),
          ],
        );
      }),
      floatingActionButton: _buildFAB(controller),
    );
  }

  PreferredSizeWidget _buildAppBar(BillsController controller) {
    return AppBar(
      title: Text(
        'Bills',
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      backgroundColor: kPrimary,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(Icons.filter_alt_outlined, color: Colors.white, size: 5.w),
          onPressed: () => _showFilterDialog(controller),
        ),
        IconButton(
          icon: Icon(Icons.download_outlined, color: Colors.white, size: 5.w),
          onPressed: () => controller.exportBills(),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(BillsController controller) {
    return Obx(() => Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
      child: Row(
        children: [
          _buildSummaryCard(
            'Total Amount',
            _formatAmount(controller.totalAmount.value),
            kPrimary,
            Icons.receipt,
          ),
          SizedBox(width: 3.w),
          _buildSummaryCard(
            'Paid',
            _formatAmount(controller.totalPaid.value),
            kSuccess,
            Icons.check_circle,
          ),
          SizedBox(width: 3.w),
          _buildSummaryCard(
            'Outstanding',
            _formatAmount(controller.totalOutstanding.value),
            kDanger,
            Icons.payment,
          ),
        ],
      ),
    ));
  }

  Widget _buildSummaryCard(String title, String amount, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(2.5.w),
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(16),
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
                Icon(icon, size: 4.5.w, color: color),
                SizedBox(width: 1.5.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: kSubText,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              amount,
              style: TextStyle(
                fontSize: 14.sp,
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
Widget _buildFilterBar(BillsController controller) {
  return Container(
    width: 100.w,
    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
    color: kCardBg,
    child: Row(
      children: [
        // Status Filter
        Expanded(
          child: Container(
            height: 6.h,
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            decoration: BoxDecoration(
              color: kBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorder),
            ),
            child: DropdownButtonHideUnderline(
              child: Obx(() => DropdownButton<String>(
                value: controller.selectedFilter.value,
                icon: Icon(Icons.arrow_drop_down, size: 5.w),
                isExpanded: true,
                style: TextStyle(fontSize: 12.sp, color: kText),
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
        SizedBox(width: 3.w),
        // Vendor Filter - FIXED
        Expanded(
          child: Container(
            height: 6.h,
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            decoration: BoxDecoration(
              color: kBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorder),
            ),
            child: DropdownButtonHideUnderline(
              child: Obx(() {
                // CRITICAL FIX: Only show dropdown when vendors are loaded
                if (controller.vendors.isEmpty) {
                  return Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(horizontal: 3.w),
                    child: Text(
                      'Loading vendors...',
                      style: TextStyle(fontSize: 12.sp, color: kSubText),
                    ),
                  );
                }
                
                // Get current value
                String? currentValue = controller.selectedVendorId.value.isEmpty 
                    ? null 
                    : controller.selectedVendorId.value;
                
                // Validate current value exists in vendors list
                if (currentValue != null && currentValue.isNotEmpty) {
                  bool exists = controller.vendors.any((v) => v['_id'] == currentValue);
                  if (!exists) {
                    currentValue = null;
                  }
                }
                
                return DropdownButton<String>(
                  value: currentValue,
                  icon: Icon(Icons.arrow_drop_down, size: 5.w),
                  isExpanded: true,
                  hint: Text('All Vendors', style: TextStyle(fontSize: 12.sp, color: kSubText)),
                  style: TextStyle(fontSize: 12.sp, color: kText),
                  items: [
                    const DropdownMenuItem(value: '', child: Text('All Vendors')),
                    ...controller.vendors.map((vendor) {
                      return DropdownMenuItem<String>(
                        value: vendor['_id'].toString(),
                        child: Text(vendor['name']),
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
}  Widget _buildBillsList(BillsController controller) {
    return Obx(() {
      final bills = controller.bills;

      if (bills.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_outlined, size: 15.w, color: kSubText.withOpacity(0.5)),
              SizedBox(height: 2.h),
              Text(
                'No bills found',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: kSubText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              ElevatedButton(
                onPressed: () => _showAddBillDialog(controller),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Add Bill',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(4.w),
        itemCount: bills.length,
        itemBuilder: (context, index) {
          final bill = bills[index];
          return _buildBillCard(bill, controller);
        },
      );
    });
  }

  Widget _buildBillCard(Bill bill, BillsController controller) {
    Color statusColor = bill.status == 'Paid' ? kSuccess :
                        bill.status == 'Overdue' ? kDanger :
                        bill.status == 'Partial' ? kWarning : kPrimary;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
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
          onTap: () => _showBillDetails(bill, controller),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.receipt, size: 6.w, color: statusColor),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                bill.billNumber,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w800,
                                  color: kText,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              _statusBadge(bill.status, statusColor),
                            ],
                          ),
                          Text(
                            bill.vendorName,
                            style: TextStyle(fontSize: 12.sp, color: kSubText),
                          ),
                          Text(
                            'Due: ${DateFormat('dd MMM yyyy').format(bill.dueDate)}',
                            style: TextStyle(
                              fontSize: 12.sp,
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
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: kText),
                        ),
                        Text(
                          'Paid: ${_formatAmount(bill.paidAmount)}',
                          style: TextStyle(fontSize: 12.sp, color: kSuccess),
                        ),
                        if (bill.outstanding > 0)
                          Text(
                            'Due: ${_formatAmount(bill.outstanding)}',
                            style: TextStyle(fontSize: 12.sp, color: kDanger),
                          ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                _buildBillItemsPreview(bill.items),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    if (bill.status != 'Paid')
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _recordBillPayment(bill, controller),
                          icon: Icon(Icons.payment, size: 4.w, color: Colors.white),
                          label: Text('Pay Now', style: TextStyle(fontSize: 12.sp)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kSuccess,
                            padding: EdgeInsets.symmetric(vertical: 1.2.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    if (bill.status != 'Paid') SizedBox(width: 3.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _printBill(bill),
                        icon: Icon(Icons.print, size: 4.w),
                        label: Text('Print', style: TextStyle(fontSize: 12.sp)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kPrimary,
                          side: BorderSide(color: kPrimary, width: 1),
                          padding: EdgeInsets.symmetric(vertical: 1.2.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBillItemsPreview(List<BillItem> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    
    return Column(
      children: items.take(2).map((item) {
        return Padding(
          padding: EdgeInsets.only(bottom: 1.h),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  item.description,
                  style: TextStyle(fontSize: 12.sp, color: kSubText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${item.quantity} x ${_formatAmount(item.unitPrice)}',
                style: TextStyle(fontSize: 12.sp, color: kSubText),
              ),
              SizedBox(width: 2.w),
              Text(
                _formatAmount(item.amount),
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: kText),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _statusBadge(String status, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(status, style: TextStyle(fontSize: 12.sp, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildFAB(BillsController controller) {
    return FloatingActionButton(
      onPressed: () => _showAddBillDialog(controller),
      backgroundColor: kPrimary,
      child: Icon(Icons.add, color: Colors.white, size: 6.w),
    );
  }

  void _showAddBillDialog(BillsController controller) {
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
      context: Get.context!,
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
              width: 90.w,
              constraints: BoxConstraints(maxHeight: 85.h),
              padding: EdgeInsets.all(5.w),
              child: Column(
                children: [
                  Text('Add Bill', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800)),
                  SizedBox(height: 2.h),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            DropdownButtonFormField<String>(
                              value: selectedVendorId.isEmpty ? null : selectedVendorId,
                              decoration: _inputDecoration('Vendor *'),
                              style: TextStyle(fontSize: 12.sp),
                              items: controller.vendors.map((v) {
                                return DropdownMenuItem<String>(
                                  value: v['_id'].toString(),
                                  child: Text(v['name']),
                                );
                              }).toList(),
                              onChanged: (v) => selectedVendorId = v!,
                              validator: (v) => v == null ? 'Vendor required' : null,
                            ),
                            SizedBox(height: 2.h),
                            Row(
                              children: [
                                Expanded(child: _dateTile('Bill Date', selectedDate, (d) => selectedDate = d)),
                                SizedBox(width: 3.w),
                                Expanded(child: _dateTile('Due Date', selectedDueDate, (d) => selectedDueDate = d)),
                              ],
                            ),
                            SizedBox(height: 2.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Items', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700)),
                                TextButton.icon(
                                  onPressed: () => setState(() => addItem()),
                                  icon: Icon(Icons.add, size: 4.w),
                                  label: Text('Add Item', style: TextStyle(fontSize: 12.sp)),
                                ),
                              ],
                            ),
                            ...items.asMap().entries.map((entry) {
                              int index = entry.key;
                              var item = entry.value;
                              return Container(
                                margin: EdgeInsets.only(bottom: 2.h),
                                padding: EdgeInsets.all(2.w),
                                decoration: BoxDecoration(
                                  color: kBg,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: kBorder),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            decoration: _inputDecoration('Description'),
                                            style: TextStyle(fontSize: 12.sp),
                                            onChanged: (v) => item['description'] = v,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete, size: 4.w, color: kDanger),
                                          onPressed: () => setState(() => items.removeAt(index)),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 1.h),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            decoration: _inputDecoration('Qty'),
                                            keyboardType: TextInputType.number,
                                            style: TextStyle(fontSize: 12.sp),
                                            onChanged: (v) {
                                              item['quantity'] = int.tryParse(v) ?? 1;
                                              setState(() {});
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 2.w),
                                        Expanded(
                                          flex: 2,
                                          child: TextFormField(
                                            decoration: _inputDecoration('Unit Price', prefix: '₨ '),
                                            keyboardType: TextInputType.number,
                                            style: TextStyle(fontSize: 12.sp),
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
                            SizedBox(height: 2.h),
                            TextFormField(
                              decoration: _inputDecoration('Discount', prefix: '₨ '),
                              keyboardType: TextInputType.number,
                              style: TextStyle(fontSize: 12.sp),
                              onChanged: (v) => discount = double.tryParse(v) ?? 0,
                            ),
                            SizedBox(height: 2.h),
                            TextFormField(
                              decoration: _inputDecoration('Notes'),
                              maxLines: 2,
                              style: TextStyle(fontSize: 12.sp),
                              onChanged: (v) => notes = v,
                            ),
                            Container(
                              padding: EdgeInsets.all(2.w),
                              decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Total Amount', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
                                  Text(_formatAmount(calculateTotal()), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: kPrimary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          child: Text('Cancel', style: TextStyle(fontSize: 12.sp)),
                        ),
                      ),
                      SizedBox(width: 3.w),
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
                          child: Text('Create Bill', style: TextStyle(fontSize: 12.sp)),
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

  void _recordBillPayment(Bill bill, BillsController controller) {
    final formKey = GlobalKey<FormState>();
    double amount = bill.outstanding;
    DateTime paymentDate = DateTime.now();
    String paymentMethod = 'Bank Transfer';
    String reference = '';
    String selectedBankAccountId = '';

    showDialog(
      context: Get.context!,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Pay Bill - ${bill.billNumber}', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800)),
            content: SizedBox(
              width: 80.w,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        children: [
                          _detailRow('Vendor', bill.vendorName),
                          _detailRow('Bill Date', DateFormat('dd MMM yyyy').format(bill.date)),
                          _detailRow('Due Date', DateFormat('dd MMM yyyy').format(bill.dueDate)),
                          _detailRow('Total Amount', _formatAmount(bill.totalAmount)),
                          _detailRow('Outstanding', _formatAmount(bill.outstanding), isImportant: true),
                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),
                    TextFormField(
                      initialValue: amount.toString(),
                      decoration: _inputDecoration('Payment Amount *', prefix: '₨ '),
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: 12.sp),
                      onChanged: (v) => amount = double.tryParse(v) ?? 0,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Amount required';
                        final val = double.tryParse(v);
                        if (val == null || val <= 0) return 'Invalid amount';
                        if (val > bill.outstanding) return 'Amount exceeds outstanding';
                        return null;
                      },
                    ),
                    SizedBox(height: 2.h),
                    _dateTile('Payment Date', paymentDate, (d) => paymentDate = d),
                    SizedBox(height: 2.h),
                    DropdownButtonFormField<String>(
                      value: paymentMethod,
                      decoration: _inputDecoration('Payment Method'),
                      style: TextStyle(fontSize: 12.sp),
                      items: const [
                        DropdownMenuItem(value: 'Bank Transfer', child: Text('Bank Transfer')),
                        DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                        DropdownMenuItem(value: 'Cheque', child: Text('Cheque')),
                      ],
                      onChanged: (v) => paymentMethod = v!,
                    ),
                    SizedBox(height: 2.h),
                    TextFormField(
                      decoration: _inputDecoration('Reference Number'),
                      style: TextStyle(fontSize: 12.sp),
                      onChanged: (v) => reference = v,
                    ),
                    if (paymentMethod == 'Bank Transfer') ...[
                      SizedBox(height: 2.h),
                      Obx(() => DropdownButtonFormField<String>(
                        value: selectedBankAccountId.isEmpty ? null : selectedBankAccountId,
                        decoration: _inputDecoration('Bank Account *'),
                        style: TextStyle(fontSize: 12.sp),
                        items: controller.bankAccounts.map((acc) {
                          return DropdownMenuItem<String>(
                            value: acc['_id'].toString(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(acc['accountName'], style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
                                Text('Balance: ${_formatAmount(acc['currentBalance'])}', style: TextStyle(fontSize: 10.sp, color: kSubText)),
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
              TextButton(onPressed: () => Get.back(), child: Text('Cancel', style: TextStyle(fontSize: 12.sp))),
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
                    ? SizedBox(width: 5.w, height: 5.w, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('Record Payment', style: TextStyle(fontSize: 12.sp)),
              )),
            ],
          );
        },
      ),
    );
  }

  void _showBillDetails(Bill bill, BillsController controller) {
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(5.w),
        constraints: BoxConstraints(maxHeight: 85.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: (bill.status == 'Paid' ? kSuccess : kPrimary).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.receipt, size: 6.w, color: bill.status == 'Paid' ? kSuccess : kPrimary),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(bill.billNumber, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800)),
                      Text(bill.vendorName, style: TextStyle(fontSize: 12.sp, color: kSubText)),
                    ],
                  ),
                ),
                _statusBadge(bill.status, bill.status == 'Paid' ? kSuccess : bill.status == 'Overdue' ? kDanger : kPrimary),
              ],
            ),
            SizedBox(height: 2.h),
            _detailRow('Bill Date', DateFormat('dd MMM yyyy').format(bill.date)),
            _detailRow('Due Date', DateFormat('dd MMM yyyy').format(bill.dueDate)),
            _detailRow('Subtotal', _formatAmount(bill.subtotal)),
            if (bill.taxTotal > 0) _detailRow('Tax', _formatAmount(bill.taxTotal)),
            if (bill.discount > 0) _detailRow('Discount', _formatAmount(bill.discount)),
            Divider(color: kBorder, height: 2.h),
            _detailRow('Total Amount', _formatAmount(bill.totalAmount), isBold: true),
            _detailRow('Paid Amount', _formatAmount(bill.paidAmount), color: kSuccess),
            _detailRow('Outstanding', _formatAmount(bill.outstanding), color: kDanger, isBold: true),
            SizedBox(height: 2.h),
            Text('Items', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700)),
            SizedBox(height: 1.h),
            ...bill.items.map((item) => Container(
              margin: EdgeInsets.only(bottom: 1.h),
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.description, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
                        Text('${item.quantity} x ${_formatAmount(item.unitPrice)}', style: TextStyle(fontSize: 10.sp, color: kSubText)),
                      ],
                    ),
                  ),
                  Text(_formatAmount(item.amount), style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700)),
                ],
              ),
            )).toList(),
            if (bill.notes.isNotEmpty) ...[
              SizedBox(height: 2.h),
              Text('Notes', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700)),
              SizedBox(height: 0.5.h),
              Text(bill.notes, style: TextStyle(fontSize: 12.sp, color: kSubText)),
            ],
            SizedBox(height: 2.h),
            if (bill.status != 'Paid')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _recordBillPayment(bill, controller);
                  },
                  icon: Icon(Icons.payment, size: 4.w),
                  label: Text('Pay Now', style: TextStyle(fontSize: 12.sp)),
                  style: ElevatedButton.styleFrom(backgroundColor: kSuccess, padding: EdgeInsets.symmetric(vertical: 1.5.h)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(BillsController controller) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: Text('Filter Bills', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Date Range', style: TextStyle(fontSize: 12.sp)),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () async {
                Navigator.pop(context);
                final start = await showDatePicker(
                  context: Get.context!,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (start != null) {
                  final end = await showDatePicker(
                    context: Get.context!,
                    initialDate: DateTime.now(),
                    firstDate: start,
                    lastDate: DateTime.now(),
                  );
                  if (end != null) controller.setDateRange(start, end);
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.clear),
              title: Text('Clear Filters', style: TextStyle(fontSize: 12.sp)),
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
            child: Text('Close', style: TextStyle(fontSize: 12.sp)),
          ),
        ],
      ),
    );
  }

  void _printBill(Bill bill) {
    Get.snackbar('Print', 'Printing ${bill.billNumber}...');
  }

  void _exportBills() {
    Get.snackbar('Export', 'Exporting bills to Excel...');
  }

  InputDecoration _inputDecoration(String label, {String? prefix}) {
    return InputDecoration(
      labelText: label,
      prefixText: prefix,
      labelStyle: TextStyle(fontSize: 12.sp),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
    );
  }

  Widget _dateTile(String label, DateTime date, Function(DateTime) onChanged) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: Get.context!,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: kBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kBorder),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 4.w, color: kPrimary),
            SizedBox(width: 2.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 10.sp, color: kSubText)),
                  Text(DateFormat('dd MMM yyyy').format(date), style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool isImportant = false, bool isBold = false, Color? color}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12.sp, color: kSubText)),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
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