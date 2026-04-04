import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/core/paymentRecieved/controller/payment_recieved_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';

class PaymentsReceivedScreen extends StatefulWidget {
  const PaymentsReceivedScreen({super.key});

  @override
  State<PaymentsReceivedScreen> createState() => _PaymentsReceivedScreenState();
}

class _PaymentsReceivedScreenState extends State<PaymentsReceivedScreen> {
  final PaymentReceivedController controller = Get.put(PaymentReceivedController());
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filterOptions = ['All', 'Today', 'This Week', 'This Month', 'Custom Range'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      controller.searchPayments(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(),
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
            _buildSummaryCards(),
            _buildFilterBar(),
            Expanded(
              child: _buildPaymentsList(),
            ),
          ],
        );
      }),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Payments Received',
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
          onPressed: () => _selectDateRange(),
        ),
        IconButton(
          icon: Icon(Icons.download_outlined, color: Colors.white, size: 5.w),
          onPressed: () => controller.exportPayments(),
        ),
      
      ],
    );
  }

  Widget _buildSummaryCards() {
    return Obx(() => Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildSummaryCard('Total Received', _formatAmount(controller.totalReceived.value), kSuccess, Icons.attach_money, 28.w),
            SizedBox(width: 2.w),
            _buildSummaryCard('This Month', _formatAmount(controller.thisMonth.value), kPrimary, Icons.calendar_month, 28.w),
            SizedBox(width: 2.w),
            _buildSummaryCard('This Week', _formatAmount(controller.thisWeek.value), kPrimary, Icons.view_week, 28.w),
            SizedBox(width: 2.w),
            _buildSummaryCard('Today', _formatAmount(controller.today.value), kPrimary, Icons.today, 28.w),
            SizedBox(width: 2.w),
            _buildSummaryCard('Pending', controller.pendingCount.value.toString(), kWarning, Icons.pending, 25.w, isNumber: true),
          ],
        ),
      ),
    ));
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

  Widget _buildFilterBar() {
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
                    controller: _searchController,
                    onChanged: (value) => controller.searchPayments(value),
                    style: TextStyle(fontSize: 12.sp),
                    decoration: InputDecoration(
                      hintText: 'Search by payment ID, customer, invoice, reference...',
                      hintStyle: TextStyle(fontSize: 12.sp, color: kSubText),
                      prefixIcon: Icon(Icons.search, size: 5.w),
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
                  child: DropdownButtonHideUnderline(
                    child: Obx(() => DropdownButton<String>(
                      value: controller.selectedFilter.value,
                      icon: Icon(Icons.arrow_drop_down, size: 5.w),
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      isExpanded: true,
                      style: TextStyle(fontSize: 12.sp, color: kText),
                      items: _filterOptions.map((filter) {
                        return DropdownMenuItem(
                          value: filter,
                          child: Text(filter),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          if (value == 'Custom Range') {
                            _selectDateRange();
                          } else {
                            controller.changeFilter(value);
                          }
                        }
                      },
                    )),
                  ),
                ),
              ),
            ],
          ),
          Obx(() {
            if (controller.selectedDateRange.value != null) {
              final range = controller.selectedDateRange.value!;
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
                            '${DateFormat('dd MMM yyyy').format(range.start)} - ${DateFormat('dd MMM yyyy').format(range.end)}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: kPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => controller.setDateRange(null),
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

  Widget _buildPaymentsList() {
    return Obx(() {
      final payments = controller.payments;

      if (payments.isEmpty) {
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
                onPressed: () => _showRecordPaymentDialog(),
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
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(4.w),
        itemCount: payments.length,
        itemBuilder: (context, index) {
          final payment = payments[index];
          return _buildPaymentCard(payment);
        },
      );
    });
  }

  Widget _buildPaymentCard(Payment payment) {
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
          onTap: () => _showPaymentDetails(payment),
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
                        color: kSuccess.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.payment,
                        size: 7.w,
                        color: kSuccess,
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
                          _formatAmount(payment.amount),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: kSuccess,
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
                          'Customer',
                          payment.customerName,
                          Icons.person,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 4.h,
                        color: kBorder,
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          'Invoice',
                          payment.invoiceNumber,
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
                          'Invoice Amount',
                          _formatAmount(payment.invoiceAmount),
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
                        onPressed: () => controller.viewInvoice(payment),
                        icon: Icon(Icons.receipt, size: 4.w),
                        label: Text(
                          'View Invoice',
                          style: TextStyle(fontSize: 12.sp),
                        ),
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
                    SizedBox(width: 3.w),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => controller.printReceipt(payment),
                        icon: Icon(Icons.print, size: 4.w, color: Colors.white),
                        label: Text(
                          'Print Receipt',
                          style: TextStyle(fontSize: 12.sp),
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
                  fontSize: 12.sp,
                  color: kSubText,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12.sp,
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

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () => _showRecordPaymentDialog(),
      backgroundColor: kPrimary,
      child: Icon(Icons.add, color: Colors.white, size: 6.w),
      elevation: 3,
    );
  }
void _showRecordPaymentDialog() {
  final formKey = GlobalKey<FormState>();
  String selectedCustomerId = '';
  String selectedInvoiceId = '';
  double amount = 0;
  String paymentMethod = 'Bank Transfer';
  String reference = '';
  String selectedBankAccountId = '';
  String notes = '';

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
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: kSuccess.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.payment, size: 6.w, color: kSuccess),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          'Record Payment Received',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: kText,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Icon(Icons.close, size: 5.w, color: kSubText),
                      ),
                    ],
                  ),
                ),
                Divider(color: kBorder, height: 1),
                SizedBox(height: 2.h),
                
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          // Customer Selection
                          Container(
                            decoration: BoxDecoration(
                              color: kBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: kBorder),
                            ),
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Select Customer *',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
                                labelStyle: TextStyle(fontSize: 12.sp, color: kSubText),
                              ),
                              style: TextStyle(fontSize: 12.sp, color: kText),
                              icon: Icon(Icons.arrow_drop_down, size: 5.w, color: kSubText),
                              value: selectedCustomerId.isEmpty ? null : selectedCustomerId,
                              items: controller.customers.map((customer) {
                                return DropdownMenuItem(
                                  value: customer.id,
                                  child: Text(
                                    customer.name,
                                    style: TextStyle(fontSize: 12.sp, color: kText),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) async {
                                selectedCustomerId = value!;
                                await controller.fetchUnpaidInvoices(selectedCustomerId);
                                selectedInvoiceId = '';
                                amount = 0;
                                setState(() {});
                              },
                              validator: (value) => value == null ? 'Customer required' : null,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          
                          // Invoice Selection (with conditional message if no invoices)
                          Obx(() {
                            if (selectedCustomerId.isNotEmpty && controller.unpaidInvoices.isEmpty) {
                              return Container(
                                padding: EdgeInsets.all(3.w),
                                decoration: BoxDecoration(
                                  color: kWarning.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: kWarning.withOpacity(0.3)),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.info_outline, size: 5.w, color: kWarning),
                                    SizedBox(height: 1.h),
                                    Text(
                                      'No unpaid invoices found for this customer.',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: kWarning,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 1.h),
                                    TextButton(
                                      onPressed: () {
                                        Get.back();
                                        Get.toNamed('/invoices/create', 
                                          arguments: {'customerId': selectedCustomerId});
                                      },
                                      child: Text(
                                        'Create Invoice First',
                                        style: TextStyle(fontSize: 12.sp, color: kPrimary),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            
                            return Container(
                              decoration: BoxDecoration(
                                color: kBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: kBorder),
                              ),
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Select Invoice *',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
                                  labelStyle: TextStyle(fontSize: 12.sp, color: kSubText),
                                ),
                                style: TextStyle(fontSize: 12.sp, color: kText),
                                icon: Icon(Icons.arrow_drop_down, size: 5.w, color: kSubText),
                                value: selectedInvoiceId.isEmpty ? null : selectedInvoiceId,
                                items: controller.unpaidInvoices.map((invoice) {
                                  return DropdownMenuItem(
                                    value: invoice.id,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          invoice.invoiceNumber,
                                          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: kText),
                                        ),
                                        Text(
                                          'Amount: ${_formatAmount(invoice.outstanding)} • Due: ${DateFormat('dd MMM yyyy').format(invoice.dueDate)}',
                                          style: TextStyle(fontSize: 10.sp, color: kSubText),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  selectedInvoiceId = value!;
                                  final invoice = controller.unpaidInvoices.firstWhere((inv) => inv.id == value);
                                  amount = invoice.outstanding;
                                  setState(() {});
                                },
                                validator: (value) => value == null ? 'Invoice required' : null,
                              ),
                            );
                          }),
                          SizedBox(height: 2.h),
                          
                          // Amount
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Payment Amount *',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: kBorder),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: kBorder),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: kPrimary, width: 1.5),
                              ),
                              prefixText: '₨ ',
                              labelStyle: TextStyle(fontSize: 12.sp, color: kSubText),
                            ),
                            style: TextStyle(fontSize: 12.sp, color: kText),
                            keyboardType: TextInputType.number,
                            initialValue: amount > 0 ? amount.toString() : '',
                            onChanged: (value) => amount = double.tryParse(value) ?? 0,
                            validator: (value) => value == null || value.isEmpty ? 'Amount required' : null,
                          ),
                          SizedBox(height: 2.h),
                          
                          // Payment Method
                          Container(
                            decoration: BoxDecoration(
                              color: kBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: kBorder),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: paymentMethod,
                              decoration: InputDecoration(
                                labelText: 'Payment Method *',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
                                labelStyle: TextStyle(fontSize: 12.sp, color: kSubText),
                              ),
                              style: TextStyle(fontSize: 12.sp, color: kText),
                              icon: Icon(Icons.arrow_drop_down, size: 5.w, color: kSubText),
                              items: const [
                                DropdownMenuItem(value: 'Bank Transfer', child: Text('Bank Transfer')),
                                DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                                DropdownMenuItem(value: 'Cheque', child: Text('Cheque')),
                                DropdownMenuItem(value: 'Credit Card', child: Text('Credit Card')),
                              ],
                              onChanged: (value) => paymentMethod = value!,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          
                          // Reference
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Reference Number',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: kBorder),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: kBorder),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: kPrimary, width: 1.5),
                              ),
                              hintText: 'e.g., TRX-001, CHQ-123',
                              labelStyle: TextStyle(fontSize: 12.sp, color: kSubText),
                            ),
                            style: TextStyle(fontSize: 12.sp, color: kText),
                            onChanged: (value) => reference = value,
                          ),
                          SizedBox(height: 2.h),
                          
                          // Bank Account (only for Bank Transfer)
                          if (paymentMethod == 'Bank Transfer')
                            Obx(() => Container(
                              decoration: BoxDecoration(
                                color: kBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: kBorder),
                              ),
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Deposit To',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
                                  labelStyle: TextStyle(fontSize: 12.sp, color: kSubText),
                                ),
                                style: TextStyle(fontSize: 12.sp, color: kText),
                                icon: Icon(Icons.arrow_drop_down, size: 5.w, color: kSubText),
                                value: selectedBankAccountId.isEmpty ? null : selectedBankAccountId,
                                items: controller.bankAccounts.map((account) {
                                  return DropdownMenuItem(
                                    value: account.id,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          account.name,
                                          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: kText),
                                        ),
                                        Text(
                                          '${account.number} • Balance: ${_formatAmount(account.balance)}',
                                          style: TextStyle(fontSize: 10.sp, color: kSubText),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) => selectedBankAccountId = value!,
                              ),
                            )),
                          SizedBox(height: 2.h),
                          
                          // Notes
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Notes',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: kBorder),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: kBorder),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: kPrimary, width: 1.5),
                              ),
                              labelStyle: TextStyle(fontSize: 12.sp, color: kSubText),
                            ),
                            style: TextStyle(fontSize: 12.sp, color: kText),
                            maxLines: 2,
                            onChanged: (value) => notes = value,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 2.h),
                Divider(color: kBorder, height: 1),
                SizedBox(height: 2.h),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kSubText,
                          side: BorderSide(color: kBorder),
                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Cancel', style: TextStyle(fontSize: 12.sp)),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Obx(() => ElevatedButton(
                        onPressed: controller.isRecording.value
                            ? null
                            : () async {
                                if (formKey.currentState!.validate()) {
                                  if (selectedCustomerId.isEmpty) {
                                    Get.snackbar('Error', 'Please select a customer');
                                    return;
                                  }
                                  if (selectedInvoiceId.isEmpty && controller.unpaidInvoices.isNotEmpty) {
                                    Get.snackbar('Error', 'Please select an invoice');
                                    return;
                                  }
                                  if (paymentMethod == 'Bank Transfer' && selectedBankAccountId.isEmpty) {
                                    Get.snackbar('Error', 'Please select a bank account');
                                    return;
                                  }
                                  
                                  Get.back();
                                  await controller.recordPayment(
                                    customerId: selectedCustomerId,
                                    invoiceId: selectedInvoiceId,
                                    amount: amount,
                                    paymentDate: DateTime.now(),
                                    paymentMethod: paymentMethod,
                                    reference: reference,
                                    bankAccountId: selectedBankAccountId,
                                    notes: notes,
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kSuccess,
                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: controller.isRecording.value
                            ? SizedBox(
                                width: 5.w,
                                height: 5.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.w,
                                  color: Colors.white,
                                ),
                              )
                            : Text('Record Payment', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
                      )),
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
  void _showPaymentDetails(Payment payment) {
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
                    color: kSuccess.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.payment, size: 7.w, color: kSuccess),
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
            _buildDetailRow('Customer', payment.customerName),
            _buildDetailRow('Invoice', payment.invoiceNumber),
            _buildDetailRow('Invoice Amount', _formatAmount(payment.invoiceAmount)),
            _buildDetailRow('Payment Amount', _formatAmount(payment.amount)),
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
                      controller.viewInvoice(payment);
                    },
                    icon: Icon(Icons.receipt, size: 4.5.w),
                    label: Text('View Invoice', style: TextStyle(fontSize: 12.sp)),
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
                      controller.printReceipt(payment);
                    },
                    icon: Icon(Icons.print, size: 4.5.w),
                    label: Text('Print Receipt', style: TextStyle(fontSize: 12.sp)),
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
                fontSize: 12.sp,
                color: kText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: Get.context!,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: controller.selectedDateRange.value,
    );
    if (picked != null) {
      controller.setDateRange(picked);
    }
  }

  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '₨ ${formatter.format(amount)}';
  }
}