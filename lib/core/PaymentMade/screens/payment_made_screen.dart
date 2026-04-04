import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/core/PaymentMade/controller/paymentmade_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';

class PaymentsMadeScreen extends StatelessWidget {
  const PaymentsMadeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PaymentMadeController());
    
    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(controller),
      body: Obx(() {
        if (controller.isLoading.value && controller.payments.isEmpty) {
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
              child: _buildPaymentsList(controller),
            ),
          ],
        );
      }),
      floatingActionButton: _buildFAB(controller),
    );
  }

  PreferredSizeWidget _buildAppBar(PaymentMadeController controller) {
    return AppBar(
      title: Text(
        'Payments Made',
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
          icon: Icon(Icons.calendar_today_outlined, color: Colors.white, size: 5.w),
          onPressed: () => controller.selectDateRange(),
        ),
        IconButton(
          icon: Icon(Icons.download_outlined, color: Colors.white, size: 5.w),
          onPressed: () => controller.exportPayments(),
        ),
      
      ],
    );
  }

  Widget _buildSummaryCards(PaymentMadeController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Obx(() => _buildSummaryCard(
              'Total Paid',
              controller.formatAmount(controller.totalPaid.value),
              kDanger,
              Icons.payment,
              28.w,
            )),
            SizedBox(width: 2.w),
            Obx(() => _buildSummaryCard(
              'This Month',
              controller.formatAmount(controller.thisMonthTotal.value),
              kPrimary,
              Icons.calendar_month,
              28.w,
            )),
            SizedBox(width: 2.w),
            Obx(() => _buildSummaryCard(
              'This Week',
              controller.formatAmount(controller.thisWeekTotal.value),
              kPrimary,
              Icons.view_week,
              28.w,
            )),
            SizedBox(width: 2.w),
            Obx(() => _buildSummaryCard(
              'Today',
              controller.formatAmount(controller.todayTotal.value),
              kPrimary,
              Icons.today,
              28.w,
            )),
            SizedBox(width: 2.w),
            Obx(() => _buildSummaryCard(
              'Pending',
              controller.pendingCount.value.toString(),
              kWarning,
              Icons.pending,
              25.w,
              isNumber: true,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String amount, Color color, IconData icon, double width, {bool isNumber = false}) {
    return Container(
      width: width,
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
            isNumber ? amount : amount,
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
    );
  }

  Widget _buildFilterBar(PaymentMadeController controller) {
    return Container(
      width: 100.w,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      color: kCardBg,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: kBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kBorder),
                  ),
                  child: TextField(
                    controller: controller.searchController,
                    style: TextStyle(fontSize: 14.sp, color: kText),
                    decoration: InputDecoration(
                      hintText: 'Search by payment ID, vendor, bill, reference...',
                      hintStyle: TextStyle(fontSize: 12.sp, color: kSubText),
                      prefixIcon: Icon(Icons.search, size: 5.w, color: kSubText),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 1.8.h),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                flex: 2,
                child: Container(
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: kBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kBorder),
                  ),
                  child: Obx(() => DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedFilter.value,
                      icon: Icon(Icons.arrow_drop_down, size: 5.w, color: kText),
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      isExpanded: true,
                      style: TextStyle(fontSize: 14.sp, color: kText),
                      dropdownColor: kCardBg,
                      items: controller.filterOptions.map((filter) {
                        return DropdownMenuItem(
                          value: filter,
                          child: Text(filter, style: TextStyle(color: kText)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.applyDateFilter(value);
                        }
                      },
                    ),
                  )),
                ),
              ),
            ],
          ),
          Obx(() {
            if (controller.selectedDateRange.value != null) {
              return Padding(
                padding: EdgeInsets.only(top: 1.5.h),
                child: Container(
                  width: 100.w,
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.date_range, size: 5.w, color: kPrimary),
                          SizedBox(width: 2.w),
                          Text(
                            '${DateFormat('dd MMM yyyy').format(controller.selectedDateRange.value!.start)} - ${DateFormat('dd MMM yyyy').format(controller.selectedDateRange.value!.end)}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: kPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => controller.clearDateRange(),
                        child: Icon(Icons.close, size: 5.w, color: kPrimary),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildPaymentsList(PaymentMadeController controller) {
    if (controller.payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment_outlined, size: 15.w, color: kSubText.withOpacity(0.5)),
            SizedBox(height: 2.h),
            Text(
              'No payments found',
              style: TextStyle(
                fontSize: 14.sp,
                color: kSubText,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 2.h),
            ElevatedButton(
              onPressed: () => _showRecordPaymentDialog(controller),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Record Payment',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: controller.payments.length,
      itemBuilder: (context, index) {
        final payment = controller.payments[index];
        return _buildPaymentCard(controller, payment);
      },
    );
  }

  Widget _buildPaymentCard(PaymentMadeController controller, PaymentMade payment) {
    Color statusColor = payment.status == 'Cleared' ? kSuccess : kWarning;
    IconData statusIcon = payment.status == 'Cleared' ? Icons.check_circle : Icons.pending;
    
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showPaymentDetails(controller, payment),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 14.w,
                      height: 14.w,
                      decoration: BoxDecoration(
                        color: kDanger.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.payment,
                        size: 7.w,
                        color: kDanger,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                payment.paymentNumber,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w800,
                                  color: kText,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(statusIcon, size: 3.w, color: statusColor),
                                    SizedBox(width: 1.w),
                                    Text(
                                      payment.status,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: statusColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            DateFormat('EEEE, dd MMM yyyy').format(payment.paymentDate),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: kSubText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Amount',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: kSubText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          controller.formatAmount(payment.amount),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: kDanger,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 1.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          'Vendor',
                          payment.vendorName,
                          Icons.business,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 4.h,
                        color: kBorder,
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          'Bill',
                          payment.billNumber,
                          Icons.receipt,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 4.h,
                        color: kBorder,
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          'Bill Amount',
                          controller.formatAmount(payment.billAmount),
                          Icons.attach_money,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 1.h),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 1.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          'Payment Method',
                          payment.paymentMethod,
                          Icons.credit_card,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 4.h,
                        color: kBorder,
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          'Reference',
                          payment.reference.isEmpty ? '-' : payment.reference,
                          Icons.receipt_long,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 4.h,
                        color: kBorder,
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          'Bank Account',
                          payment.bankAccountName.isEmpty ? '-' : payment.bankAccountName,
                          Icons.account_balance,
                        ),
                      ),
                    ],
                  ),
                ),
                if (payment.notes.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 1.h),
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: kBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.note, size: 4.w, color: kSubText),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              payment.notes,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: kSubText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => controller.viewBill(payment),
                        icon: Icon(Icons.receipt, size: 4.w, color: kPrimary),
                        label: Text(
                          'View Bill',
                          style: TextStyle(fontSize: 12.sp, color: kPrimary),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: kPrimary, width: 1),
                          padding: EdgeInsets.symmetric(vertical: 1.2.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => controller.printVoucher(payment),
                        icon: Icon(Icons.print, size: 4.w, color: Colors.white),
                        label: Text(
                          'Print Voucher',
                          style: TextStyle(fontSize: 12.sp, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
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

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 3.5.w, color: kSubText),
        SizedBox(width: 1.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 9.sp,
                  color: kSubText,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: kText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFAB(PaymentMadeController controller) {
    return FloatingActionButton(
      onPressed: () => _showRecordPaymentDialog(controller),
      backgroundColor: kPrimary,
      child: Icon(Icons.add, color: Colors.white, size: 6.w),
      elevation: 3,
    );
  }

  void _showRecordPaymentDialog(PaymentMadeController controller) {
    final formKey = GlobalKey<FormState>();
    String selectedVendorId = '';
    String selectedBillId = '';
    double amount = 0;
    String paymentMethod = 'Bank Transfer';
    String reference = '';
    String bankAccountId = '';
    String notes = '';
    DateTime paymentDate = DateTime.now();

    showDialog(
      context: Get.context!,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              width: 90.w,
              constraints: BoxConstraints(maxHeight: 85.h),
              padding: EdgeInsets.all(5.w),
              child: Column(
                children: [
                  Text(
                    'Record Payment Made',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: kText,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            // Payment Date
                            ListTile(
                              title: Text('Payment Date', style: TextStyle(fontSize: 12.sp)),
                              subtitle: Text(
                                DateFormat('dd MMM yyyy').format(paymentDate),
                                style: TextStyle(fontSize: 14.sp, color: kText),
                              ),
                              trailing: Icon(Icons.calendar_today, color: kPrimary),
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: paymentDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  setState(() {
                                    paymentDate = picked;
                                  });
                                }
                              },
                            ),
                            // Vendor Selection
                            Obx(() => DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Select Vendor *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelStyle: TextStyle(fontSize: 12.sp),
                              ),
                              style: TextStyle(fontSize: 14.sp, color: kText),
                              dropdownColor: kCardBg,
                              value: selectedVendorId.isEmpty ? null : selectedVendorId,
                              items: controller.vendors.map((vendor) {
                                return DropdownMenuItem(
                                  value: vendor.id,
                                  child: Text(vendor.name, style: TextStyle(color: kText)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedVendorId = value!;
                                  selectedBillId = '';
                                  amount = 0;
                                });
                              },
                              validator: (value) => value == null ? 'Vendor required' : null,
                            )),
                            SizedBox(height: 2.h),
                            
                            // Bill Selection
                         FutureBuilder<List<BillForPayment>>(
  future: selectedVendorId.isNotEmpty
      ? controller.getUnpaidBills(selectedVendorId)
      : Future.value([]),
  builder: (context, snapshot) {
    if (selectedVendorId.isEmpty) {
      return const SizedBox.shrink();
    }

    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    }

    final bills = snapshot.data ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Select Bill *',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            labelStyle: TextStyle(fontSize: 12.sp),
          ),
          style: TextStyle(fontSize: 14.sp, color: kText),
          dropdownColor: kCardBg,
          value: selectedBillId.isEmpty ? null : selectedBillId,

          // ✅ FIX: single-line compact item (NO Column)
          items: bills.map((bill) {
            return DropdownMenuItem<String>(
              value: bill.id,
              child: Text(
                '${bill.billNumber} • ${controller.formatAmount(bill.outstanding)}',
                overflow: TextOverflow.ellipsis, // ✅ prevent overflow
                maxLines: 1,
                style: TextStyle(color: kText),
              ),
            );
          }).toList(),

          onChanged: (value) {
            setState(() {
              selectedBillId = value!;
              final bill = bills.firstWhere((b) => b.id == value);
              amount = bill.outstanding;
            });
          },
          validator: (value) => value == null ? 'Bill required' : null,
        ),

        SizedBox(height: 1.h),

        // ✅ EXTRA: show full details BELOW dropdown (safe place)
        if (selectedBillId.isNotEmpty)
          Builder(
            builder: (_) {
              final bill = bills.firstWhere((b) => b.id == selectedBillId);

              return Container(
                width: double.infinity,
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: kCardBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bill: ${bill.billNumber}',
                      style: TextStyle(color: kText, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Total: ${controller.formatAmount(bill.totalAmount)}',
                      style: TextStyle(fontSize: 12.sp, color: kSubText),
                    ),
                    Text(
                      'Outstanding: ${controller.formatAmount(bill.outstanding)}',
                      style: TextStyle(fontSize: 12.sp, color: kSubText),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  },
),                           SizedBox(height: 2.h),
                            
                            // Amount
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Amount *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelStyle: TextStyle(fontSize: 12.sp),
                                prefixText: '₨ ',
                              ),
                              style: TextStyle(fontSize: 14.sp, color: kText),
                              keyboardType: TextInputType.number,
                              initialValue: amount > 0 ? amount.toString() : '',
                              onChanged: (value) => amount = double.tryParse(value) ?? 0,
                              validator: (value) => value == null || value.isEmpty ? 'Amount required' : null,
                            ),
                            SizedBox(height: 2.h),
                            
                            // Payment Method
                            DropdownButtonFormField<String>(
                              value: paymentMethod,
                              decoration: InputDecoration(
                                labelText: 'Payment Method *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelStyle: TextStyle(fontSize: 12.sp),
                              ),
                              style: TextStyle(fontSize: 14.sp, color: kText),
                              dropdownColor: kCardBg,
                              items: const [
                                DropdownMenuItem(value: 'Bank Transfer', child: Text('Bank Transfer')),
                                DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                                DropdownMenuItem(value: 'Cheque', child: Text('Cheque')),
                                DropdownMenuItem(value: 'Credit Card', child: Text('Credit Card')),
                              ],
                              onChanged: (value) => setState(() => paymentMethod = value!),
                            ),
                            SizedBox(height: 2.h),
                            
                            // Reference
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Reference Number',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelStyle: TextStyle(fontSize: 12.sp),
                              ),
                              style: TextStyle(fontSize: 14.sp, color: kText),
                              onChanged: (value) => reference = value,
                            ),
                            SizedBox(height: 2.h),
                            
                            // Notes
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Notes',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelStyle: TextStyle(fontSize: 12.sp),
                              ),
                              style: TextStyle(fontSize: 14.sp, color: kText),
                              maxLines: 2,
                              onChanged: (value) => notes = value,
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
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              Navigator.pop(context);
                              controller.recordPayment(
                                vendorId: selectedVendorId,
                                billId: selectedBillId,
                                amount: amount,
                                paymentDate: paymentDate,
                                paymentMethod: paymentMethod,
                                reference: reference,
                                bankAccountId: bankAccountId,
                                notes: notes,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimary,
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('Record Payment', style: TextStyle(fontSize: 14.sp, color: Colors.white)),
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

  void _showPaymentDetails(PaymentMadeController controller, PaymentMade payment) {
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(5.w),
        constraints: BoxConstraints(
          maxHeight: 85.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 14.w,
                  height: 14.w,
                  decoration: BoxDecoration(
                    color: kDanger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.payment, size: 7.w, color: kDanger),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.paymentNumber,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: kText,
                        ),
                      ),
                      Text(
                        DateFormat('EEEE, dd MMM yyyy').format(payment.paymentDate),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: kSubText,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                  decoration: BoxDecoration(
                    color: payment.status == 'Cleared' ? kSuccess.withOpacity(0.1) : kWarning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    payment.status,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: payment.status == 'Cleared' ? kSuccess : kWarning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            _buildDetailRow('Vendor', payment.vendorName),
            _buildDetailRow('Bill', payment.billNumber),
            _buildDetailRow('Bill Amount', controller.formatAmount(payment.billAmount)),
            _buildDetailRow('Payment Amount', controller.formatAmount(payment.amount)),
            _buildDetailRow('Payment Method', payment.paymentMethod),
            _buildDetailRow('Reference', payment.reference.isEmpty ? '-' : payment.reference),
            _buildDetailRow('Bank Account', payment.bankAccountName.isEmpty ? '-' : payment.bankAccountName),
            _buildDetailRow('Created At', DateFormat('dd MMM yyyy, hh:mm a').format(payment.createdAt)),
            if (payment.notes.isNotEmpty) _buildDetailRow('Notes', payment.notes),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      controller.viewBill(payment);
                    },
                    icon: Icon(Icons.receipt, size: 4.5.w),
                    label: Text('View Bill', style: TextStyle(fontSize: 12.sp)),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      controller.printVoucher(payment);
                    },
                    icon: Icon(Icons.print, size: 4.5.w),
                    label: Text('Print Voucher', style: TextStyle(fontSize: 12.sp)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: kSubText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                color: kText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}