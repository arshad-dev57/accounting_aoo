import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/core/Customers/controllers/customer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CustomerController());

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

  PreferredSizeWidget _buildAppBar(CustomerController controller) {
    return AppBar(
      title: Text(
        'Customers',
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
          icon: Icon(Icons.search, color: Colors.white, size: 5.w),
          onPressed: () => _showSearchDialog(controller),
        ),
        IconButton(
          icon: Icon(Icons.filter_alt_outlined, color: Colors.white, size: 5.w),
          onPressed: () => _showFilterDialog(controller),
        ),
        IconButton(
          icon: Icon(Icons.download_outlined, color: Colors.white, size: 5.w),
  onPressed: () => controller.exportCustomers(),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(CustomerController controller) {
    return Obx(() => Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildSummaryCard(
              'Total Customers',
              controller.totalCustomers.value.toString(),
              kPrimary,
              Icons.people,
              28.w,
              isNumber: true,
            ),
            SizedBox(width: 2.w),
            _buildSummaryCard(
              'Active',
              controller.activeCustomers.value.toString(),
              kSuccess,
              Icons.check_circle,
              25.w,
              isNumber: true,
            ),
            SizedBox(width: 2.w),
            _buildSummaryCard(
              'Total Outstanding',
              _formatAmount(controller.totalOutstanding.value),
              kDanger,
              Icons.payment,
              30.w,
            ),
            SizedBox(width: 2.w),
            _buildSummaryCard(
              'Total Sales',
              _formatAmount(controller.totalSales.value),
              kPrimary,
              Icons.trending_up,
              28.w,
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

  Widget _buildFilterBar(CustomerController controller) {
    final List<String> filterOptions = ['All', 'Active', 'Inactive', 'With Balance'];

    return Container(
      width: 100.w,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      color: kCardBg,
      child: Row(
        children: [
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
                  items: filterOptions.map((filter) {
                    return DropdownMenuItem(
                      value: filter,
                      child: Text(filter, style: TextStyle(fontSize: 12.sp)),
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

  Widget _buildCustomersList(CustomerController controller) {
    return Obx(() {
      final customers = controller.getFilteredCustomers();

      if (customers.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 15.w, color: kSubText.withOpacity(0.5)),
              SizedBox(height: 2.h),
              Text(
                'No customers found',
                style: TextStyle(fontSize: 14.sp, color: kSubText),
              ),
              SizedBox(height: 2.h),
              ElevatedButton(
                onPressed: () => _showAddCustomerDialog(controller),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Add Customer',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
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

  Widget _buildCustomerCard(Customer customer, CustomerController controller) {
    bool hasOutstanding = customer.outstandingAmount > 0;
    
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
          onTap: () => _showCustomerDetails(customer, controller),
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
                        color: kPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          customer.name[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 14.sp,
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
                          Row(
                            children: [
                              Text(
                                customer.name,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: kText,
                                ),
                              ),
                              if (!customer.isActive)
                                Container(
                                  margin: EdgeInsets.only(left: 2.w),
                                  padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.3.h),
                                  decoration: BoxDecoration(
                                    color: kDanger.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Inactive',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: kDanger,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            customer.email,
                            style: TextStyle(fontSize: 12.sp, color: kSubText),
                          ),
                          Text(
                            customer.phone,
                            style: TextStyle(fontSize: 12.sp, color: kSubText),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (hasOutstanding) ...[
                          Text(
                            'Outstanding',
                            style: TextStyle(fontSize: 12.sp, color: kSubText),
                          ),
                          Text(
                            _formatAmount(customer.outstandingAmount),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: kDanger,
                            ),
                          ),
                        ] else ...[
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: kSuccess.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle, size: 3.w, color: kSuccess),
                                SizedBox(width: 1.w),
                                Text(
                                  'Paid',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: kSuccess,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem('Invoices', customer.invoiceCount.toString(), Icons.receipt),
                    ),
                    Container(width: 1, height: 4.h, color: kBorder),
                    Expanded(
                      child: _buildStatItem('Total', _formatAmount(customer.totalAmount), Icons.attach_money),
                    ),
                    Container(width: 1, height: 4.h, color: kBorder),
                    Expanded(
                      child: _buildStatItem('Paid', _formatAmount(customer.paidAmount), Icons.check_circle),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _viewInvoices(customer, controller),
                        icon: Icon(Icons.receipt, size: 4.w),
                        label: Text('Invoices', style: TextStyle(fontSize: 12.sp)),
                        style: _buttonStyle(kPrimary),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    if (hasOutstanding)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _recordPayment(customer, controller),
                          icon: Icon(Icons.payment, size: 4.w, color: Colors.white),
                          label: Text('Record Payment', style: TextStyle(fontSize: 12.sp)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kSuccess,
                            padding: EdgeInsets.symmetric(vertical: 1.2.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    if (!hasOutstanding)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _editCustomer(customer, controller),
                          icon: Icon(Icons.edit, size: 4.w),
                          label: Text('Edit', style: TextStyle(fontSize: 12.sp)),
                          style: _buttonStyle(kPrimary),
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

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 4.w, color: kSubText),
        SizedBox(height: 0.5.h),
        Text(value, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: kText)),
        Text(label, style: TextStyle(fontSize: 12.sp, color: kSubText)),
      ],
    );
  }

  ButtonStyle _buttonStyle(Color color) {
    return OutlinedButton.styleFrom(
      foregroundColor: color,
      side: BorderSide(color: color),
      padding: EdgeInsets.symmetric(vertical: 1.2.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _buildFAB(CustomerController controller) {
    return FloatingActionButton(
      onPressed: () => _showAddCustomerDialog(controller),
      backgroundColor: kPrimary,
      child: Icon(Icons.add, color: Colors.white, size: 6.w),
    );
  }

  void _showAddCustomerDialog(CustomerController controller) {
    final formKey = GlobalKey<FormState>();
    String name = '', email = '', phone = '', address = '', taxId = '', paymentTerms = 'Net 30';

    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: Text('Add Customer', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800)),
        content: SizedBox(
          width: 80.w,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  _buildTextField('Customer Name *', (v) => name = v, validator: true),
                  SizedBox(height: 2.h),
                  _buildTextField('Email', (v) => email = v),
                  SizedBox(height: 2.h),
                  _buildTextField('Phone *', (v) => phone = v, validator: true),
                  SizedBox(height: 2.h),
                  _buildTextField('Address', (v) => address = v, maxLines: 2),
                  SizedBox(height: 2.h),
                  _buildTextField('Tax ID', (v) => taxId = v),
                  SizedBox(height: 2.h),
                  DropdownButtonFormField<String>(
                    value: paymentTerms,
                    decoration: _inputDecoration('Payment Terms'),
                    style: TextStyle(fontSize: 12.sp),
                    items:  [
                      DropdownMenuItem(value: 'Due on Receipt', child: Text('Due on Receipt',style: TextStyle(color: Colors.black),)),
                      DropdownMenuItem(value: 'Net 7', child: Text('Net 7 days',style: TextStyle(color: Colors.black),)),
                      DropdownMenuItem(value: 'Net 15', child: Text('Net 15 days',style: TextStyle(color: Colors.black),)),
                      DropdownMenuItem(value: 'Net 30', child: Text('Net 30 days',style: TextStyle(color: Colors.black),)),
                      DropdownMenuItem(value: 'Net 45', child: Text('Net 45 days',style: TextStyle(color: Colors.black),)),
                      DropdownMenuItem(value: 'Net 60', child: Text('Net 60 days',style: TextStyle(color: Colors.black),)),
                    ],
                    onChanged: (value) => paymentTerms = value!,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(fontSize: 12.sp)),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Get.back();
                controller.createCustomer({
                  'name': name,
                  'email': email,
                  'phone': phone,
                  'address': address,
                  'taxId': taxId,
                  'paymentTerms': paymentTerms,
                });
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
            child: Text('Add Customer', style: TextStyle(fontSize: 12.sp)),
          ),
        ],
      ),
    );
  }

  void _editCustomer(Customer customer, CustomerController controller) {
    final formKey = GlobalKey<FormState>();
    String name = customer.name;
    String email = customer.email;
    String phone = customer.phone;
    String address = customer.address;
    String taxId = customer.taxId;
    String paymentTerms = customer.paymentTerms;
    bool isActive = customer.isActive;

    showDialog(
      context: Get.context!,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Edit Customer', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800)),
            content: SizedBox(
              width: 80.w,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      _buildTextField('Customer Name *', (v) => name = v, initialValue: name, validator: true),
                      SizedBox(height: 2.h),
                      _buildTextField('Email', (v) => email = v, initialValue: email),
                      SizedBox(height: 2.h),
                      _buildTextField('Phone *', (v) => phone = v, initialValue: phone, validator: true),
                      SizedBox(height: 2.h),
                      _buildTextField('Address', (v) => address = v, initialValue: address, maxLines: 2),
                      SizedBox(height: 2.h),
                      _buildTextField('Tax ID', (v) => taxId = v, initialValue: taxId),
                      SizedBox(height: 2.h),
                      DropdownButtonFormField<String>(
                        value: paymentTerms,
                        decoration: _inputDecoration('Payment Terms'),
                        style: TextStyle(fontSize: 12.sp),
                        items: const [
                          DropdownMenuItem(value: 'Due on Receipt', child: Text('Due on Receipt')),
                          DropdownMenuItem(value: 'Net 7', child: Text('Net 7 days')),
                          DropdownMenuItem(value: 'Net 15', child: Text('Net 15 days')),
                          DropdownMenuItem(value: 'Net 30', child: Text('Net 30 days')),
                          DropdownMenuItem(value: 'Net 45', child: Text('Net 45 days')),
                          DropdownMenuItem(value: 'Net 60', child: Text('Net 60 days')),
                        ],
                        onChanged: (value) => paymentTerms = value!,
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Text('Active', style: TextStyle(fontSize: 12.sp)),
                          Spacer(),
                          Switch(
                            value: isActive,
                            onChanged: (value) => setState(() => isActive = value),
                            activeColor: kSuccess,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text('Cancel', style: TextStyle(fontSize: 12.sp)),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Get.back();
                    controller.updateCustomer(customer.id, {
                      'name': name,
                      'email': email,
                      'phone': phone,
                      'address': address,
                      'taxId': taxId,
                      'paymentTerms': paymentTerms,
                      'isActive': isActive,
                    });
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                child: Text('Update Customer', style: TextStyle(fontSize: 12.sp)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCustomerDetails(Customer customer, CustomerController controller) {
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(5.w),
        constraints: BoxConstraints(maxHeight: 80.h),
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
                    color: kPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      customer.name[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 14.sp,
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
                      Text(customer.name, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800)),
                      Text(customer.email, style: TextStyle(fontSize: 12.sp, color: kSubText)),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                  decoration: BoxDecoration(
                    color: customer.isActive ? kSuccess.withOpacity(0.1) : kDanger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    customer.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(fontSize: 12.sp, color: customer.isActive ? kSuccess : kDanger),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            _detailRow('Phone', customer.phone),
            _detailRow('Address', customer.address),
            _detailRow('Tax ID', customer.taxId),
            _detailRow('Payment Terms', customer.paymentTerms),
            _detailRow('Total Invoices', customer.invoiceCount.toString()),
            _detailRow('Total Amount', _formatAmount(customer.totalAmount)),
            _detailRow('Paid Amount', _formatAmount(customer.paidAmount)),
            _detailRow('Outstanding', _formatAmount(customer.outstandingAmount), isImportant: true),
            if (customer.lastPaymentDate != null)
              _detailRow('Last Payment', DateFormat('dd MMM yyyy').format(customer.lastPaymentDate!)),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _viewInvoices(customer, controller);
                    },
                    icon: Icon(Icons.receipt, size: 4.w),
                    label: Text('View Invoices', style: TextStyle(fontSize: 12.sp)),
                    style: _buttonStyle(kPrimary),
                  ),
                ),
                SizedBox(width: 3.w),
                if (customer.outstandingAmount > 0)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _recordPayment(customer, controller);
                      },
                      icon: Icon(Icons.payment, size: 4.w),
                      label: Text('Record Payment', style: TextStyle(fontSize: 12.sp)),
                      style: ElevatedButton.styleFrom(backgroundColor: kSuccess),
                    ),
                  ),
                if (customer.outstandingAmount == 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _editCustomer(customer, controller);
                      },
                      icon: Icon(Icons.edit, size: 4.w),
                      label: Text('Edit', style: TextStyle(fontSize: 12.sp)),
                      style: _buttonStyle(kPrimary),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TextFormField _buildTextField(
    String label,
    Function(String) onChanged, {
    String? initialValue,
    bool validator = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 12.sp),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
      ),
      style: TextStyle(fontSize: 12.sp),
      maxLines: maxLines,
      onChanged: onChanged,
      validator: validator ? (v) => v == null || v.isEmpty ? '$label required' : null : null,
    );
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

  Widget _detailRow(String label, String value, {bool isImportant = false}) {
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
              fontWeight: isImportant ? FontWeight.w700 : FontWeight.w600,
              color: isImportant ? kDanger : kText,
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(CustomerController controller) {
    TextEditingController searchController = TextEditingController();
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: Text('Search Customers', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter name, email, or phone',
            hintStyle: TextStyle(fontSize: 12.sp),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            prefixIcon: Icon(Icons.search),
          ),
          style: TextStyle(fontSize: 12.sp),
          onSubmitted: (value) {
            controller.searchCustomers(value);
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(fontSize: 12.sp)),
          ),
          TextButton(
            onPressed: () {
              controller.searchCustomers(searchController.text);
              Navigator.pop(context);
            },
            child: Text('Search', style: TextStyle(fontSize: 12.sp)),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(CustomerController controller) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: Text('Filter Customers', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.people, size: 5.w),
              title: Text('Show Active Only', style: TextStyle(fontSize: 12.sp)),
              trailing: Obx(() => Switch(
                value: controller.selectedFilter.value == 'Active',
                onChanged: (value) {
                  Navigator.pop(context);
                  controller.changeFilter(value ? 'Active' : 'All');
                },
                activeColor: kSuccess,
              )),
            ),
            ListTile(
              leading: Icon(Icons.payment, size: 5.w),
              title: Text('Show With Balance Only', style: TextStyle(fontSize: 12.sp)),
              trailing: Obx(() => Switch(
                value: controller.selectedFilter.value == 'With Balance',
                onChanged: (value) {
                  Navigator.pop(context);
                  controller.changeFilter(value ? 'With Balance' : 'All');
                },
                activeColor: kPrimary,
              )),
            ),
            Divider(color: kBorder),
            ListTile(
              leading: Icon(Icons.clear, size: 5.w),
              title: Text('Clear Filters', style: TextStyle(fontSize: 12.sp)),
              onTap: () {
                Navigator.pop(context);
                controller.changeFilter('All');
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

  void _viewInvoices(Customer customer, CustomerController controller) {
    Get.toNamed('/invoices', arguments: {'customerId': customer.id});
  }

  void _recordPayment(Customer customer, CustomerController controller) {
    Get.toNamed('/payments-received', arguments: {'customerId': customer.id});
  }

  void _exportCustomers() {
    Get.snackbar(
      'Export',
      'Exporting customers to Excel...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: kPrimary,
      colorText: Colors.white,
    );
  }

  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '₨ ${formatter.format(amount)}';
  }
}