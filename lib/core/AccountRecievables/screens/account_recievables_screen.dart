import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/core/AccountRecievables/controllers/account_recievables_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';

class AccountsReceivableScreen extends StatelessWidget {
  const AccountsReceivableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AccountsReceivableController());

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
              child: _buildCustomersList(controller),
            ),
          ],
        );
      }),
      floatingActionButton: _buildFAB(controller),
    );
  }

  PreferredSizeWidget _buildAppBar(AccountsReceivableController controller) {
    return AppBar(
      title: Text(
        'Accounts Receivable',
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
          icon: Icon(Icons.download_outlined, color: Colors.white, size: 5.w),
          onPressed: () => controller.exportReport(),
        ),
        IconButton(
          icon: Icon(Icons.print_outlined, color: Colors.white, size: 5.w),
          onPressed: () => controller.printReport(),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(AccountsReceivableController controller) {
    return Obx(() => Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildSummaryCard(
              'Total Outstanding',
              _formatAmount(controller.totalOutstanding.value),
              kDanger,
              Icons.receipt,
              28.w,
            ),
            SizedBox(width: 2.w),
            _buildSummaryCard(
              'Overdue',
              _formatAmount(controller.totalOverdue.value),
              kWarning,
              Icons.warning,
              28.w,
            ),
            SizedBox(width: 2.w),
            _buildSummaryCard(
              'Due This Week',
              _formatAmount(controller.totalDueThisWeek.value),
              kPrimary,
              Icons.view_week,
              28.w,
            ),
            SizedBox(width: 2.w),
            _buildSummaryCard(
              'Due This Month',
              _formatAmount(controller.totalDueThisMonth.value),
              kPrimary,
              Icons.calendar_month,
              28.w,
            ),
            SizedBox(width: 2.w),
            _buildSummaryCard(
              'Active Customers',
              controller.activeCustomers.value.toString(),
              kSuccess,
              Icons.people,
              28.w,
              isNumber: true,
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildSummaryCard(
    String title,
    String amount,
    Color color,
    IconData icon,
    double width, {
    bool isNumber = false,
  }) {
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

  Widget _buildFilterBar(AccountsReceivableController controller) {
    final List<String> filterOptions = [
      'All',
      'Overdue',
      'Due This Week',
      'Due This Month',
      'Paid'
    ];

    return Container(
      width: 100.w,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      color: kCardBg,
      child: Row(
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
                onChanged: (value) => controller.searchCustomers(value),
                style: TextStyle(fontSize: 14.sp),
                decoration: InputDecoration(
                  hintText: 'Search by name, email, or phone...',
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
                  style: TextStyle(fontSize: 14.sp, color: kText),
                  items: filterOptions.map((filter) {
                    return DropdownMenuItem(
                      value: filter,
                      child: Text(filter),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) controller.changeFilter(value);
                  },
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomersList(AccountsReceivableController controller) {
    return Obx(() {
      final customers = controller.customers;

      if (customers.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 15.w,
                color: kSubText.withOpacity(0.5),
              ),
              SizedBox(height: 2.h),
              Text(
                'No customers found',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: kSubText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              ElevatedButton(
                onPressed: () => _showAddCustomerDialog(Get.context!, controller),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Add Customer',
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
        itemCount: customers.length,
        itemBuilder: (context, index) {
          final customer = customers[index];
          return _buildCustomerCard(customer, controller);
        },
      );
    });
  }

  Widget _buildCustomerCard(Customer customer, AccountsReceivableController controller) {
    int overdueCount = customer.invoices.where((inv) => inv.status == 'Overdue').length;
    int dueSoonCount = customer.invoices.where((inv) => _isDueSoon(inv.dueDate)).length;
    
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
          onTap: () => _showCustomerDetails(customer, controller),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 14.w,
                      height: 14.w,
                      decoration: BoxDecoration(
                        color: kPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          customer.name[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: kPrimary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.name,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: kText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            customer.email,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: kSubText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            customer.phone,
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
                          'Outstanding',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: kSubText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          _formatAmount(customer.outstandingAmount),
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
                        child: _buildStatItem(
                          'Total Invoices',
                          customer.totalInvoices.toString(),
                          Icons.receipt,
                          kPrimary,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 4.h,
                        color: kBorder,
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Total Amount',
                          _formatAmount(customer.totalAmount),
                          Icons.attach_money,
                          kPrimary,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 4.h,
                        color: kBorder,
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Paid',
                          _formatAmount(customer.paidAmount),
                          Icons.check_circle,
                          kSuccess,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 1.h),
                if (overdueCount > 0 || dueSoonCount > 0)
                  Wrap(
                    spacing: 2.w,
                    runSpacing: 1.h,
                    children: [
                      if (overdueCount > 0)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: kDanger.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.warning, size: 3.5.w, color: kDanger),
                              SizedBox(width: 1.w),
                              Text(
                                '$overdueCount Overdue Invoice${overdueCount > 1 ? 's' : ''}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: kDanger,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (dueSoonCount > 0)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: kWarning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.schedule, size: 3.5.w, color: kWarning),
                              SizedBox(width: 1.w),
                              Text(
                                '$dueSoonCount Due Soon',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: kWarning,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => controller.viewInvoices(customer),
                        icon: Icon(Icons.receipt, size: 4.w),
                        label: Text(
                          'View Invoices',
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
                        onPressed: () => _showPaymentDialog(customer, controller),
                        icon: Icon(Icons.payment, size: 4.w, color: Colors.white),
                        label: Text(
                          'Record Payment',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kSuccess,
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

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 4.w, color: color),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: kText,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: kSubText,
          ),
        ),
      ],
    );
  }

  Widget _buildFAB(AccountsReceivableController controller) {
    return FloatingActionButton(
      onPressed: () => _showAddCustomerDialog(Get.context!, controller),
      backgroundColor: kPrimary,
      child: Icon(Icons.add, color: Colors.white, size: 6.w),
      elevation: 3,
    );
  }

  void _showAddCustomerDialog(BuildContext context, AccountsReceivableController controller) {
    final formKey = GlobalKey<FormState>();
    String name = '';
    String email = '';
    String phone = '';
    String address = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              width: 90.w,
              constraints: BoxConstraints(maxHeight: 80.h),
              padding: EdgeInsets.all(5.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Add New Customer',
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
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Customer Name *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelStyle: TextStyle(fontSize: 12.sp),
                              ),
                              style: TextStyle(fontSize: 14.sp),
                              onChanged: (value) => name = value,
                              validator: (value) => value == null || value.isEmpty ? 'Name required' : null,
                            ),
                            SizedBox(height: 2.h),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelStyle: TextStyle(fontSize: 12.sp),
                              ),
                              style: TextStyle(fontSize: 14.sp),
                              onChanged: (value) => email = value,
                            ),
                            SizedBox(height: 2.h),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Phone *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelStyle: TextStyle(fontSize: 12.sp),
                              ),
                              style: TextStyle(fontSize: 14.sp),
                              onChanged: (value) => phone = value,
                              validator: (value) => value == null || value.isEmpty ? 'Phone required' : null,
                            ),
                            SizedBox(height: 2.h),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Address',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelStyle: TextStyle(fontSize: 12.sp),
                              ),
                              style: TextStyle(fontSize: 14.sp),
                              maxLines: 2,
                              onChanged: (value) => address = value,
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
                              controller.createCustomer({
                                'name': name,
                                'email': email,
                                'phone': phone,
                                'address': address,
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimary,
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('Add Customer', style: TextStyle(fontSize: 14.sp)),
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

  void _showCustomerDetails(Customer customer, AccountsReceivableController controller) {
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
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
                  width: 14.w,
                  height: 14.w,
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      customer.name[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: kPrimary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: kText,
                        ),
                      ),
                      Text(
                        customer.email,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: kSubText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            _buildDetailRow('Phone', customer.phone),
            _buildDetailRow('Total Invoices', customer.totalInvoices.toString()),
            _buildDetailRow('Total Amount', _formatAmount(customer.totalAmount)),
            _buildDetailRow('Paid Amount', _formatAmount(customer.paidAmount)),
            _buildDetailRow('Outstanding', _formatAmount(customer.outstandingAmount)),
            if (customer.lastPaymentDate != null)
              _buildDetailRow(
                'Last Payment',
                DateFormat('dd MMM yyyy').format(customer.lastPaymentDate!),
              ),
            SizedBox(height: 2.h),
            Text(
              'Recent Invoices',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: kText,
              ),
            ),
            SizedBox(height: 1.h),
            ...customer.invoices.take(3).map((invoice) => _buildInvoiceItem(invoice)),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      controller.viewInvoices(customer);
                    },
                    icon: Icon(Icons.receipt, size: 4.5.w),
                    label: Text('All Invoices', style: TextStyle(fontSize: 12.sp)),
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
                      _showPaymentDialog(customer, controller);
                    },
                    icon: Icon(Icons.payment, size: 4.5.w),
                    label: Text('Record Payment', style: TextStyle(fontSize: 12.sp)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kSuccess,
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

  void _showPaymentDialog(Customer customer, AccountsReceivableController controller) {
    // For demo purposes, show a simple dialog
    // In production, this should be a full payment form
    Get.defaultDialog(
      title: 'Record Payment',
      content: Column(
        children: [
          Text('Customer: ${customer.name}'),
          SizedBox(height: 1.h),
          Text('Outstanding: ${_formatAmount(customer.outstandingAmount)}'),
        ],
      ),
      textConfirm: 'OK',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        controller.showRecordPayment(customer);
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: kSubText,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: kText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceItem(Invoice invoice) {
    Color statusColor = invoice.status == 'Paid' ? kSuccess : 
                        invoice.status == 'Overdue' ? kDanger : kWarning;
    double outstanding = invoice.amount - invoice.paidAmount;
    
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: kBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoice.id,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: kText,
                  ),
                ),
                Text(
                  DateFormat('dd MMM yyyy').format(invoice.date),
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: kSubText,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatAmount(outstanding),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: statusColor,
            ),
          ),
          SizedBox(width: 2.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.3.h),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              invoice.status,
              style: TextStyle(
                fontSize: 10.sp,
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isDueSoon(DateTime dueDate) {
    final now = DateTime.now();
    final daysUntilDue = dueDate.difference(now).inDays;
    return daysUntilDue >= 0 && daysUntilDue <= 7;
  }

  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '₨ ${formatter.format(amount)}';
  }
}