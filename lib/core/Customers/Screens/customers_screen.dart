import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/Utils/responsive_utils.dart';
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
              _buildCustomersList(controller, context),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  // Custom Header without AppBar
  Widget _buildHeader(CustomerController controller, BuildContext context) {
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
                  'Customers',
                  style: TextStyle(
                    fontSize: isWeb ? 20 : 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage all your customers',
                  style: TextStyle(
                    fontSize: isWeb ? 13 : 11,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          // Search Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.search, color: Colors.white, size: isWeb ? 22 : 20),
              onPressed: () => _showSearchDialog(controller, context),
            ),
          ),
          const SizedBox(width: 8),
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
          const SizedBox(width: 8),
          // Export Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.download_outlined, color: Colors.white, size: isWeb ? 22 : 20),
              onPressed: () => controller.exportCustomers(),
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
                onPressed: () => _showAddCustomerDialog(controller, context),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(CustomerController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Obx(() => Container(
      padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 16 : 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildSummaryCard(
              'Total Customers',
              controller.totalCustomers.value.toString(),
              kPrimary,
              Icons.people,
              context,
              width: isWeb ? 220 : 160,
              isNumber: true,
            ),
            SizedBox(width: isWeb ? 16 : 12),
            _buildSummaryCard(
              'Active',
              controller.activeCustomers.value.toString(),
              kSuccess,
              Icons.check_circle,
              context,
              width: isWeb ? 200 : 150,
              isNumber: true,
            ),
            SizedBox(width: isWeb ? 16 : 12),
            _buildSummaryCard(
              'Total Outstanding',
              _formatAmount(controller.totalOutstanding.value),
              kDanger,
              Icons.payment,
              context,
              width: isWeb ? 230 : 170,
            ),
            SizedBox(width: isWeb ? 16 : 12),
            _buildSummaryCard(
              'Total Sales',
              _formatAmount(controller.totalSales.value),
              kPrimary,
              Icons.trending_up,
              context,
              width: isWeb ? 220 : 160,
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
    BuildContext context, {
    double width = 160,
    bool isNumber = false,
  }) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Container(
      width: width,
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
            isNumber ? amount : amount,
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
    );
  }

  Widget _buildFilterBar(CustomerController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final List<String> filterOptions = ['All', 'Active', 'Inactive', 'With Balance'];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 12 : 10),
      color: kCardBg,
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
            items: filterOptions.map((filter) {
              return DropdownMenuItem(
                value: filter,
                child: Text(filter, style: TextStyle(fontSize: isWeb ? 13 : 12)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) controller.changeFilter(value);
            },
          )),
        ),
      ),
    );
  }

  Widget _buildCustomersList(CustomerController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Obx(() {
      final customers = controller.getFilteredCustomers();

      if (customers.isEmpty) {
        return Padding(
          padding: EdgeInsets.all(isWeb ? 40 : 20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: isWeb ? 80 : 64, color: kSubText.withOpacity(0.5)),
                SizedBox(height: isWeb ? 20 : 16),
                Text(
                  'No customers found',
                  style: TextStyle(fontSize: isWeb ? 18 : 16, color: kSubText),
                ),
                SizedBox(height: isWeb ? 20 : 16),
                ElevatedButton(
                  onPressed: () => _showAddCustomerDialog(controller, context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 12 : 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
                    ),
                  ),
                  child: Text(
                    'Add Customer',
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
              'Customers',
              style: TextStyle(
                fontSize: isWeb ? 18 : 16,
                fontWeight: FontWeight.w700,
                color: kText,
              ),
            ),
          ),
          ...customers.map((customer) => Padding(
            padding: EdgeInsets.symmetric(horizontal: isWeb ? 20 : 12, vertical: isWeb ? 8 : 6),
            child: _buildCustomerCard(customer, controller, context),
          )).toList(),
        ],
      );
    });
  }

  Widget _buildCustomerCard(Customer customer, CustomerController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final isMobile = ResponsiveUtils.isMobile(context);
    
    bool hasOutstanding = customer.outstandingAmount > 0;
    
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
          onTap: () => _showCustomerDetails(customer, controller, context),
          borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
          child: Padding(
            padding: EdgeInsets.all(isWeb ? 16 : 12),
            child: isMobile
                ? _buildMobileCustomerCard(customer, controller, hasOutstanding, context)
                : _buildDesktopCustomerCard(customer, controller, hasOutstanding, context),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopCustomerCard(Customer customer, CustomerController controller, bool hasOutstanding, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: isWeb ? 50 : 44,
              height: isWeb ? 50 : 44,
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
              ),
              child: Center(
                child: Text(
                  customer.name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: isWeb ? 20 : 16,
                    fontWeight: FontWeight.w800,
                    color: kPrimary,
                  ),
                ),
              ),
            ),
            SizedBox(width: isWeb ? 16 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        customer.name,
                        style: TextStyle(
                          fontSize: isWeb ? 15 : 13,
                          fontWeight: FontWeight.w700,
                          color: kText,
                        ),
                      ),
                      if (!customer.isActive)
                        Container(
                          margin: EdgeInsets.only(left: isWeb ? 8 : 6),
                          padding: EdgeInsets.symmetric(horizontal: isWeb ? 8 : 6, vertical: isWeb ? 4 : 2),
                          decoration: BoxDecoration(
                            color: kDanger.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Inactive',
                            style: TextStyle(
                              fontSize: isWeb ? 11 : 10,
                              color: kDanger,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: isWeb ? 4 : 2),
                  Text(
                    customer.email,
                    style: TextStyle(fontSize: isWeb ? 12 : 11, color: kSubText),
                  ),
                  Text(
                    customer.phone,
                    style: TextStyle(fontSize: isWeb ? 12 : 11, color: kSubText),
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
                    style: TextStyle(fontSize: isWeb ? 11 : 10, color: kSubText),
                  ),
                  Text(
                    _formatAmount(customer.outstandingAmount),
                    style: TextStyle(
                      fontSize: isWeb ? 16 : 14,
                      fontWeight: FontWeight.w800,
                      color: kDanger,
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: isWeb ? 8 : 6, vertical: isWeb ? 4 : 2),
                    decoration: BoxDecoration(
                      color: kSuccess.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: isWeb ? 16 : 12, color: kSuccess),
                        SizedBox(width: isWeb ? 4 : 2),
                        Text(
                          'Paid',
                          style: TextStyle(
                            fontSize: isWeb ? 11 : 10,
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
        SizedBox(height: isWeb ? 16 : 12),
        Row(
          children: [
            Expanded(
              child: _buildStatItem('Invoices', customer.invoiceCount.toString(), Icons.receipt, isWeb),
            ),
            Container(width: 1, height: isWeb ? 32 : 24, color: kBorder),
            Expanded(
              child: _buildStatItem('Total', _formatAmount(customer.totalAmount), Icons.attach_money, isWeb),
            ),
            Container(width: 1, height: isWeb ? 32 : 24, color: kBorder),
            Expanded(
              child: _buildStatItem('Paid', _formatAmount(customer.paidAmount), Icons.check_circle, isWeb),
            ),
          ],
        ),
        SizedBox(height: isWeb ? 16 : 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _viewInvoices(customer, controller, context),
                icon: Icon(Icons.receipt, size: isWeb ? 18 : 14),
                label: Text('Invoices', style: TextStyle(fontSize: isWeb ? 12 : 10)),
                style: _buttonStyle(kPrimary, isWeb),
              ),
            ),
            SizedBox(width: isWeb ? 12 : 8),
            if (hasOutstanding)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _recordPayment(customer, controller, context),
                  icon: Icon(Icons.payment, size: isWeb ? 18 : 14, color: Colors.white),
                  label: Text('Record Payment', style: TextStyle(fontSize: isWeb ? 12 : 10)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kSuccess,
                    padding: EdgeInsets.symmetric(vertical: isWeb ? 10 : 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isWeb ? 8 : 6),
                    ),
                  ),
                ),
              ),
            if (!hasOutstanding)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _editCustomer(customer, controller, context),
                  icon: Icon(Icons.edit, size: isWeb ? 18 : 14),
                  label: Text('Edit', style: TextStyle(fontSize: isWeb ? 12 : 10)),
                  style: _buttonStyle(kPrimary, isWeb),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileCustomerCard(Customer customer, CustomerController controller, bool hasOutstanding, BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  customer.name[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: kPrimary,
                  ),
                ),
              ),
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
                          customer.name,
                          style:  TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: kText,
                          ),
                        ),
                      ),
                      if (!customer.isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: kDanger.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Inactive',
                            style: TextStyle(
                              fontSize: 9,
                              color: kDanger,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    customer.email,
                    style:  TextStyle(fontSize: 10, color: kSubText),
                  ),
                  Text(
                    customer.phone,
                    style:  TextStyle(fontSize: 10, color: kSubText),
                  ),
                ],
              ),
            ),
            if (hasOutstanding)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                   Text(
                    'Outstanding',
                    style: TextStyle(fontSize: 9, color: kSubText),
                  ),
                  Text(
                    _formatAmount(customer.outstandingAmount),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: kDanger,
                    ),
                  ),
                ],
              ),
            if (!hasOutstanding)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: kSuccess.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 12, color: kSuccess),
                    const SizedBox(width: 2),
                    const Text(
                      'Paid',
                      style: TextStyle(fontSize: 9, color: kSuccess, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatItem('Invoices', customer.invoiceCount.toString(), Icons.receipt, false),
            ),
            Expanded(
              child: _buildStatItem('Total', _formatAmount(customer.totalAmount), Icons.attach_money, false),
            ),
            Expanded(
              child: _buildStatItem('Paid', _formatAmount(customer.paidAmount), Icons.check_circle, false),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _viewInvoices(customer, controller, context),
                icon: Icon(Icons.receipt, size: 14),
                label: const Text('Invoices', style: TextStyle(fontSize: 9)),
                style: _buttonStyle(kPrimary, false),
              ),
            ),
            const SizedBox(width: 8),
            if (hasOutstanding)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _recordPayment(customer, controller, context),
                  icon: Icon(Icons.payment, size: 14, color: Colors.white),
                  label: const Text('Record Payment', style: TextStyle(fontSize: 9)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kSuccess,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            if (!hasOutstanding)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _editCustomer(customer, controller, context),
                  icon: Icon(Icons.edit, size: 14),
                  label: const Text('Edit', style: TextStyle(fontSize: 9)),
                  style: _buttonStyle(kPrimary, false),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, bool isWeb) {
    return Column(
      children: [
        Icon(icon, size: isWeb ? 20 : 16, color: kSubText),
        SizedBox(height: isWeb ? 4 : 2),
        Text(value, style: TextStyle(fontSize: isWeb ? 12 : 11, fontWeight: FontWeight.w700, color: kText)),
        Text(label, style: TextStyle(fontSize: isWeb ? 11 : 9, color: kSubText)),
      ],
    );
  }

  ButtonStyle _buttonStyle(Color color, bool isWeb) {
    return OutlinedButton.styleFrom(
      foregroundColor: color,
      side: BorderSide(color: color),
      padding: EdgeInsets.symmetric(vertical: isWeb ? 10 : 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isWeb ? 8 : 6)),
    );
  }

  void _showAddCustomerDialog(CustomerController controller, BuildContext ctx) {
    final isWeb = ResponsiveUtils.isWeb(ctx);
    final formKey = GlobalKey<FormState>();
    String name = '', email = '', phone = '', address = '', taxId = '', paymentTerms = 'Net 30';

    showDialog(
      context: ctx,
      builder: (context) => AlertDialog(
        title: Text('Add Customer', style: TextStyle(fontSize: isWeb ? 18 : 14, fontWeight: FontWeight.w800)),
        content: SizedBox(
          width: isWeb ? 400 : 280,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  _buildTextField('Customer Name *', (v) => name = v, isWeb: isWeb, validator: true),
                  SizedBox(height: isWeb ? 16 : 12),
                  _buildTextField('Email', (v) => email = v, isWeb: isWeb),
                  SizedBox(height: isWeb ? 16 : 12),
                  _buildTextField('Phone *', (v) => phone = v, isWeb: isWeb, validator: true),
                  SizedBox(height: isWeb ? 16 : 12),
                  _buildTextField('Address', (v) => address = v, isWeb: isWeb, maxLines: 2),
                  SizedBox(height: isWeb ? 16 : 12),
                  _buildTextField('Tax ID', (v) => taxId = v, isWeb: isWeb),
                  SizedBox(height: isWeb ? 16 : 12),
                  DropdownButtonFormField<String>(
                    value: paymentTerms,
                    decoration: _inputDecoration('Payment Terms', isWeb),
                    style: TextStyle(fontSize: isWeb ? 13 : 12),
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
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(fontSize: isWeb ? 14 : 12)),
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
            child: Text('Add Customer', style: TextStyle(fontSize: isWeb ? 14 : 12)),
          ),
        ],
      ),
    );
  }

  void _editCustomer(Customer customer, CustomerController controller, BuildContext ctx) {
    final isWeb = ResponsiveUtils.isWeb(ctx);
    final formKey = GlobalKey<FormState>();
    String name = customer.name;
    String email = customer.email;
    String phone = customer.phone;
    String address = customer.address;
    String taxId = customer.taxId;
    String paymentTerms = customer.paymentTerms;
    bool isActive = customer.isActive;

    showDialog(
      context: ctx,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Edit Customer', style: TextStyle(fontSize: isWeb ? 18 : 14, fontWeight: FontWeight.w800)),
            content: SizedBox(
              width: isWeb ? 400 : 280,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      _buildTextField('Customer Name *', (v) => name = v, isWeb: isWeb, initialValue: name, validator: true),
                      SizedBox(height: isWeb ? 16 : 12),
                      _buildTextField('Email', (v) => email = v, isWeb: isWeb, initialValue: email),
                      SizedBox(height: isWeb ? 16 : 12),
                      _buildTextField('Phone *', (v) => phone = v, isWeb: isWeb, initialValue: phone, validator: true),
                      SizedBox(height: isWeb ? 16 : 12),
                      _buildTextField('Address', (v) => address = v, isWeb: isWeb, initialValue: address, maxLines: 2),
                      SizedBox(height: isWeb ? 16 : 12),
                      _buildTextField('Tax ID', (v) => taxId = v, isWeb: isWeb, initialValue: taxId),
                      SizedBox(height: isWeb ? 16 : 12),
                      DropdownButtonFormField<String>(
                        value: paymentTerms,
                        decoration: _inputDecoration('Payment Terms', isWeb),
                        style: TextStyle(fontSize: isWeb ? 13 : 12),
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
                      SizedBox(height: isWeb ? 16 : 12),
                      Row(
                        children: [
                          Text('Active', style: TextStyle(fontSize: isWeb ? 13 : 12)),
                          const Spacer(),
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
                child: Text('Cancel', style: TextStyle(fontSize: isWeb ? 14 : 12)),
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
                child: Text('Update Customer', style: TextStyle(fontSize: isWeb ? 14 : 12)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCustomerDetails(Customer customer, CustomerController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    if (isWeb) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            child: _buildCustomerDetailsContent(customer, controller, ctx),
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
          constraints: BoxConstraints(maxHeight: 85.h),
          child: _buildCustomerDetailsContent(customer, controller, ctx),
        ),
      );
    }
  }

  Widget _buildCustomerDetailsContent(Customer customer, CustomerController controller, BuildContext ctx) {
    final isWeb = ResponsiveUtils.isWeb(ctx);
    
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
                color: kPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isWeb ? 14 : 10),
              ),
              child: Center(
                child: Text(
                  customer.name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: isWeb ? 24 : 18,
                    fontWeight: FontWeight.w800,
                    color: kPrimary,
                  ),
                ),
              ),
            ),
            SizedBox(width: isWeb ? 16 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(customer.name, style: TextStyle(fontSize: isWeb ? 18 : 16, fontWeight: FontWeight.w800)),
                  Text(customer.email, style: TextStyle(fontSize: isWeb ? 13 : 12, color: kSubText)),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: isWeb ? 12 : 10, vertical: isWeb ? 6 : 4),
              decoration: BoxDecoration(
                color: customer.isActive ? kSuccess.withOpacity(0.1) : kDanger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isWeb ? 8 : 6),
              ),
              child: Text(
                customer.isActive ? 'Active' : 'Inactive',
                style: TextStyle(fontSize: isWeb ? 13 : 12, color: customer.isActive ? kSuccess : kDanger),
              ),
            ),
          ],
        ),
        SizedBox(height: isWeb ? 20 : 16),
        Container(
          padding: EdgeInsets.all(isWeb ? 16 : 12),
          decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(isWeb ? 12 : 10)),
          child: Column(
            children: [
              _detailRow('Phone', customer.phone, isWeb),
              _detailRow('Address', customer.address, isWeb),
              _detailRow('Tax ID', customer.taxId, isWeb),
              _detailRow('Payment Terms', customer.paymentTerms, isWeb),
              _detailRow('Total Invoices', customer.invoiceCount.toString(), isWeb),
              _detailRow('Total Amount', _formatAmount(customer.totalAmount), isWeb),
              _detailRow('Paid Amount', _formatAmount(customer.paidAmount), isWeb),
              _detailRow('Outstanding', _formatAmount(customer.outstandingAmount), isWeb, isImportant: true),
              if (customer.lastPaymentDate != null)
                _detailRow('Last Payment', DateFormat('dd MMM yyyy').format(customer.lastPaymentDate!), isWeb),
            ],
          ),
        ),
        SizedBox(height: isWeb ? 20 : 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _viewInvoices(customer, controller, ctx);
                },
                icon: Icon(Icons.receipt, size: isWeb ? 20 : 16),
                label: Text('View Invoices', style: TextStyle(fontSize: isWeb ? 14 : 12)),
                style: _buttonStyle(kPrimary, isWeb),
              ),
            ),
            SizedBox(width: isWeb ? 12 : 8),
            if (customer.outstandingAmount > 0)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _recordPayment(customer, controller, ctx);
                  },
                  icon: Icon(Icons.payment, size: isWeb ? 20 : 16),
                  label: Text('Record Payment', style: TextStyle(fontSize: isWeb ? 14 : 12)),
                  style: ElevatedButton.styleFrom(backgroundColor: kSuccess),
                ),
              ),
            if (customer.outstandingAmount == 0)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _editCustomer(customer, controller, ctx);
                  },
                  icon: Icon(Icons.edit, size: isWeb ? 20 : 16),
                  label: Text('Edit', style: TextStyle(fontSize: isWeb ? 14 : 12)),
                  style: _buttonStyle(kPrimary, isWeb),
                ),
              ),
          ],
        ),
      ],
    );
  }

  TextFormField _buildTextField(
    String label,
    Function(String) onChanged, {
    bool isWeb = false,
    String? initialValue,
    bool validator = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: isWeb ? 12 : 11),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(isWeb ? 10 : 8)),
        contentPadding: EdgeInsets.symmetric(horizontal: isWeb ? 16 : 12, vertical: isWeb ? 12 : 10),
      ),
      style: TextStyle(fontSize: isWeb ? 13 : 12),
      maxLines: maxLines,
      onChanged: onChanged,
      validator: validator ? (v) => v == null || v.isEmpty ? '$label required' : null : null,
    );
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

  Widget _detailRow(String label, String value, bool isWeb, {bool isImportant = false}) {
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
              fontWeight: isImportant ? FontWeight.w700 : FontWeight.w600,
              color: isImportant ? kDanger : kText,
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(CustomerController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    TextEditingController searchController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Search Customers', style: TextStyle(fontSize: isWeb ? 18 : 14, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter name, email, or phone',
            hintStyle: TextStyle(fontSize: isWeb ? 12 : 11),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(isWeb ? 10 : 8)),
            prefixIcon: Icon(Icons.search),
          ),
          style: TextStyle(fontSize: isWeb ? 13 : 12),
          onSubmitted: (value) {
            controller.searchCustomers(value);
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(fontSize: isWeb ? 14 : 12)),
          ),
          TextButton(
            onPressed: () {
              controller.searchCustomers(searchController.text);
              Navigator.pop(context);
            },
            child: Text('Search', style: TextStyle(fontSize: isWeb ? 14 : 12)),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(CustomerController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter Customers', style: TextStyle(fontSize: isWeb ? 18 : 14, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.people, size: isWeb ? 24 : 20),
              title: Text('Show Active Only', style: TextStyle(fontSize: isWeb ? 14 : 12)),
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
              leading: Icon(Icons.payment, size: isWeb ? 24 : 20),
              title: Text('Show With Balance Only', style: TextStyle(fontSize: isWeb ? 14 : 12)),
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
              leading: Icon(Icons.clear, size: isWeb ? 24 : 20),
              title: Text('Clear Filters', style: TextStyle(fontSize: isWeb ? 14 : 12)),
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
            child: Text('Close', style: TextStyle(fontSize: isWeb ? 14 : 12)),
          ),
        ],
      ),
    );
  }

  void _viewInvoices(Customer customer, CustomerController controller, BuildContext context) {
    Get.toNamed('/invoices', arguments: {'customerId': customer.id});
  }

  void _recordPayment(Customer customer, CustomerController controller, BuildContext context) {
    Get.toNamed('/payments-received', arguments: {'customerId': customer.id});
  }

  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '₨ ${formatter.format(amount)}';
  }
}