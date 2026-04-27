import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/Utils/responsive_utils.dart';
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
  Widget _buildHeader(AccountsReceivableController controller, BuildContext context) {
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
                  'Accounts Receivable',
                  style: TextStyle(
                    fontSize: isWeb ? 20 : 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Track customer payments and outstanding amounts',
                  style: TextStyle(
                    fontSize: isWeb ? 13 : 11,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          // Export Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.download_outlined, color: Colors.white, size: isWeb ? 22 : 20),
              onPressed: () => controller.exportReport(),
            ),
          ),
          if (!isMobile) const SizedBox(width: 8),
          // Print Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.print_outlined, color: Colors.white, size: isWeb ? 22 : 20),
              onPressed: () => controller.printReport(),
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
                onPressed: () => _showAddCustomerDialog(Get.context!, controller, context),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(AccountsReceivableController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Obx(() => Container(
      padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 16 : 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildSummaryCard(
              'Total Outstanding',
              _formatAmount(controller.totalOutstanding.value),
              kDanger,
              Icons.receipt,
              context,
              width: isWeb ? 220 : 160,
            ),
            SizedBox(width: isWeb ? 16 : 12),
            _buildSummaryCard(
              'Overdue',
              _formatAmount(controller.totalOverdue.value),
              kWarning,
              Icons.warning,
              context,
              width: isWeb ? 220 : 160,
            ),
            SizedBox(width: isWeb ? 16 : 12),
            _buildSummaryCard(
              'Due This Week',
              _formatAmount(controller.totalDueThisWeek.value),
              kPrimary,
              Icons.view_week,
              context,
              width: isWeb ? 220 : 160,
            ),
            SizedBox(width: isWeb ? 16 : 12),
            _buildSummaryCard(
              'Due This Month',
              _formatAmount(controller.totalDueThisMonth.value),
              kPrimary,
              Icons.calendar_month,
              context,
              width: isWeb ? 220 : 160,
            ),
            SizedBox(width: isWeb ? 16 : 12),
            _buildSummaryCard(
              'Active Customers',
              controller.activeCustomers.value.toString(),
              kSuccess,
              Icons.people,
              context,
              width: isWeb ? 220 : 160,
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

  Widget _buildFilterBar(AccountsReceivableController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final List<String> filterOptions = [
      'All',
      'Overdue',
      'Due This Week',
      'Due This Month',
      'Paid'
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 12 : 10),
      color: kCardBg,
      child: Row(
        children: [
          Expanded(
            flex: isWeb ? 3 : 2,
            child: Container(
              height: isWeb ? 45 : 40,
              decoration: BoxDecoration(
                color: kBg,
                borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
                border: Border.all(color: kBorder),
              ),
              child: TextField(
                onChanged: (value) => controller.searchCustomers(value),
                style: TextStyle(fontSize: isWeb ? 14 : 12),
                decoration: InputDecoration(
                  hintText: isWeb ? 'Search by name, email, or phone...' : 'Search...',
                  hintStyle: TextStyle(fontSize: isWeb ? 12 : 11, color: kSubText),
                  prefixIcon: Icon(Icons.search, size: isWeb ? 20 : 18),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: isWeb ? 12 : 10),
                ),
              ),
            ),
          ),
          SizedBox(width: isWeb ? 16 : 12),
          Expanded(
            flex: isWeb ? 2 : 1,
            child: Container(
              height: isWeb ? 45 : 40,
              decoration: BoxDecoration(
                color: kBg,
                borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
                border: Border.all(color: kBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: Obx(() => DropdownButton<String>(
                  value: controller.selectedFilter.value,
                  icon: Icon(Icons.arrow_drop_down, size: isWeb ? 24 : 20),
                  padding: EdgeInsets.symmetric(horizontal: isWeb ? 16 : 12),
                  isExpanded: true,
                  style: TextStyle(fontSize: isWeb ? 13 : 12, color: kText),
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

  Widget _buildCustomersList(AccountsReceivableController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Obx(() {
      final customers = controller.customers;

      if (customers.isEmpty) {
        return Padding(
          padding: EdgeInsets.all(isWeb ? 40 : 20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: isWeb ? 80 : 64,
                  color: kSubText.withOpacity(0.5),
                ),
                SizedBox(height: isWeb ? 20 : 16),
                Text(
                  'No customers found',
                  style: TextStyle(
                    fontSize: isWeb ? 18 : 16,
                    color: kSubText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: isWeb ? 20 : 16),
                ElevatedButton(
                  onPressed: () => _showAddCustomerDialog(Get.context!, controller, context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 12 : 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
                    ),
                  ),
                  child: Text(
                    'Add Customer',
                    style: TextStyle(
                      fontSize: isWeb ? 14 : 12,
                      fontWeight: FontWeight.w600,
                    ),
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

  Widget _buildCustomerCard(Customer customer, AccountsReceivableController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final isMobile = ResponsiveUtils.isMobile(context);
    
    int overdueCount = customer.invoices.where((inv) => inv.status == 'Overdue').length;
    int dueSoonCount = customer.invoices.where((inv) => _isDueSoon(inv.dueDate)).length;
    
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
                ? _buildMobileCustomerCard(customer, controller, overdueCount, dueSoonCount, context)
                : _buildDesktopCustomerCard(customer, controller, overdueCount, dueSoonCount, context),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopCustomerCard(Customer customer, AccountsReceivableController controller, int overdueCount, int dueSoonCount, BuildContext context) {
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
                  Text(
                    customer.name,
                    style: TextStyle(
                      fontSize: isWeb ? 15 : 13,
                      fontWeight: FontWeight.w800,
                      color: kText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isWeb ? 4 : 2),
                  Text(
                    customer.email,
                    style: TextStyle(
                      fontSize: isWeb ? 12 : 11,
                      color: kSubText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isWeb ? 4 : 2),
                  Text(
                    customer.phone,
                    style: TextStyle(
                      fontSize: isWeb ? 12 : 11,
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
                    fontSize: isWeb ? 11 : 10,
                    color: kSubText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: isWeb ? 4 : 2),
                Text(
                  _formatAmount(customer.outstandingAmount),
                  style: TextStyle(
                    fontSize: isWeb ? 16 : 14,
                    fontWeight: FontWeight.w800,
                    color: kDanger,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: isWeb ? 16 : 12),
        Container(
          padding: EdgeInsets.symmetric(vertical: isWeb ? 10 : 8),
          child: Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Invoices',
                  customer.totalInvoices.toString(),
                  Icons.receipt,
                  kPrimary,
                  isWeb,
                ),
              ),
              Container(
                width: 1,
                height: isWeb ? 32 : 24,
                color: kBorder,
              ),
              Expanded(
                child: _buildStatItem(
                  'Total Amount',
                  _formatAmount(customer.totalAmount),
                  Icons.attach_money,
                  kPrimary,
                  isWeb,
                ),
              ),
              Container(
                width: 1,
                height: isWeb ? 32 : 24,
                color: kBorder,
              ),
              Expanded(
                child: _buildStatItem(
                  'Paid',
                  _formatAmount(customer.paidAmount),
                  Icons.check_circle,
                  kSuccess,
                  isWeb,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isWeb ? 8 : 6),
        if (overdueCount > 0 || dueSoonCount > 0)
          Wrap(
            spacing: isWeb ? 12 : 8,
            runSpacing: isWeb ? 8 : 6,
            children: [
              if (overdueCount > 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: isWeb ? 8 : 6, vertical: isWeb ? 4 : 2),
                  decoration: BoxDecoration(
                    color: kDanger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isWeb ? 6 : 4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning, size: isWeb ? 16 : 12, color: kDanger),
                      SizedBox(width: isWeb ? 4 : 2),
                      Text(
                        '$overdueCount Overdue Invoice${overdueCount > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: isWeb ? 11 : 10,
                          color: kDanger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              if (dueSoonCount > 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: isWeb ? 8 : 6, vertical: isWeb ? 4 : 2),
                  decoration: BoxDecoration(
                    color: kWarning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isWeb ? 6 : 4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule, size: isWeb ? 16 : 12, color: kWarning),
                      SizedBox(width: isWeb ? 4 : 2),
                      Text(
                        '$dueSoonCount Due Soon',
                        style: TextStyle(
                          fontSize: isWeb ? 11 : 10,
                          color: kWarning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        SizedBox(height: isWeb ? 16 : 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => controller.viewInvoices(customer),
                icon: Icon(Icons.receipt, size: isWeb ? 18 : 14),
                label: Text(
                  'View Invoices',
                  style: TextStyle(fontSize: isWeb ? 12 : 10),
                ),
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
            SizedBox(width: isWeb ? 12 : 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showPaymentDialog(customer, controller, context),
                icon: Icon(Icons.payment, size: isWeb ? 18 : 14, color: Colors.white),
                label: Text(
                  'Record Payment',
                  style: TextStyle(fontSize: isWeb ? 12 : 10),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kSuccess,
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

  Widget _buildMobileCustomerCard(Customer customer, AccountsReceivableController controller, int overdueCount, int dueSoonCount, BuildContext context) {
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
                  Text(
                    customer.name,
                    style:  TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: kText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    customer.email,
                    style:  TextStyle(
                      fontSize: 10,
                      color: kSubText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    customer.phone,
                    style:  TextStyle(
                      fontSize: 10,
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
                    fontSize: 9,
                    color: kSubText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
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
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'Total Invoices',
                customer.totalInvoices.toString(),
                Icons.receipt,
                kPrimary,
                false,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                'Total Amount',
                _formatAmount(customer.totalAmount),
                Icons.attach_money,
                kPrimary,
                false,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                'Paid',
                _formatAmount(customer.paidAmount),
                Icons.check_circle,
                kSuccess,
                false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (overdueCount > 0 || dueSoonCount > 0)
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              if (overdueCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: kDanger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning, size: 12, color: kDanger),
                      const SizedBox(width: 2),
                      Text(
                        '$overdueCount Overdue',
                        style: TextStyle(
                          fontSize: 9,
                          color: kDanger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              if (dueSoonCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: kWarning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule, size: 12, color: kWarning),
                      const SizedBox(width: 2),
                      Text(
                        '$dueSoonCount Due Soon',
                        style: TextStyle(
                          fontSize: 9,
                          color: kWarning,
                          fontWeight: FontWeight.w600,
                        ),
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
              child: OutlinedButton.icon(
                onPressed: () => controller.viewInvoices(customer),
                icon: Icon(Icons.receipt, size: 14),
                label: const Text(
                  'View Invoices',
                  style: TextStyle(fontSize: 9),
                ),
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
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showPaymentDialog(customer, controller, context),
                icon: Icon(Icons.payment, size: 14, color: Colors.white),
                label: const Text(
                  'Record Payment',
                  style: TextStyle(fontSize: 9),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kSuccess,
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

  Widget _buildStatItem(String label, String value, IconData icon, Color color, bool isWeb) {
    return Column(
      children: [
        Icon(icon, size: isWeb ? 20 : 16, color: color),
        SizedBox(height: isWeb ? 4 : 2),
        Text(
          value,
          style: TextStyle(
            fontSize: isWeb ? 13 : 11,
            fontWeight: FontWeight.w700,
            color: kText,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: isWeb ? 10 : 8,
            color: kSubText,
          ),
        ),
      ],
    );
  }

  void _showAddCustomerDialog(BuildContext context, AccountsReceivableController controller, BuildContext ctx) {
    final isWeb = ResponsiveUtils.isWeb(ctx);
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
              width: isWeb ? 500 : double.infinity,
              constraints: BoxConstraints(maxHeight: isWeb ? 600 : 500),
              padding: EdgeInsets.all(isWeb ? 24 : 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Add New Customer',
                    style: TextStyle(
                      fontSize: isWeb ? 20 : 18,
                      fontWeight: FontWeight.w800,
                      color: kText,
                    ),
                  ),
                  SizedBox(height: isWeb ? 20 : 16),
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
                                labelStyle: TextStyle(fontSize: isWeb ? 12 : 11),
                              ),
                              style: TextStyle(fontSize: isWeb ? 13 : 12),
                              onChanged: (value) => name = value,
                              validator: (value) => value == null || value.isEmpty ? 'Name required' : null,
                            ),
                            SizedBox(height: isWeb ? 16 : 12),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelStyle: TextStyle(fontSize: isWeb ? 12 : 11),
                              ),
                              style: TextStyle(fontSize: isWeb ? 13 : 12),
                              onChanged: (value) => email = value,
                            ),
                            SizedBox(height: isWeb ? 16 : 12),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Phone *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelStyle: TextStyle(fontSize: isWeb ? 12 : 11),
                              ),
                              style: TextStyle(fontSize: isWeb ? 13 : 12),
                              onChanged: (value) => phone = value,
                              validator: (value) => value == null || value.isEmpty ? 'Phone required' : null,
                            ),
                            SizedBox(height: isWeb ? 16 : 12),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Address',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelStyle: TextStyle(fontSize: isWeb ? 12 : 11),
                              ),
                              style: TextStyle(fontSize: isWeb ? 13 : 12),
                              maxLines: 2,
                              onChanged: (value) => address = value,
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
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: isWeb ? 12 : 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('Cancel', style: TextStyle(fontSize: isWeb ? 14 : 12)),
                        ),
                      ),
                      SizedBox(width: isWeb ? 16 : 12),
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
                            padding: EdgeInsets.symmetric(vertical: isWeb ? 12 : 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('Add Customer', style: TextStyle(fontSize: isWeb ? 14 : 12)),
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

  void _showCustomerDetails(Customer customer, AccountsReceivableController controller, BuildContext context) {
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

  Widget _buildCustomerDetailsContent(Customer customer, AccountsReceivableController controller, BuildContext ctx) {
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
                  Text(
                    customer.name,
                    style: TextStyle(
                      fontSize: isWeb ? 18 : 16,
                      fontWeight: FontWeight.w800,
                      color: kText,
                    ),
                  ),
                  Text(
                    customer.email,
                    style: TextStyle(
                      fontSize: isWeb ? 13 : 12,
                      color: kSubText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: isWeb ? 20 : 16),
        Container(
          padding: EdgeInsets.all(isWeb ? 16 : 12),
          decoration: BoxDecoration(
            color: kBg,
            borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
          ),
          child: Column(
            children: [
              _buildDetailRow('Phone', customer.phone, isWeb),
              _buildDetailRow('Total Invoices', customer.totalInvoices.toString(), isWeb),
              _buildDetailRow('Total Amount', _formatAmount(customer.totalAmount), isWeb),
              _buildDetailRow('Paid Amount', _formatAmount(customer.paidAmount), isWeb),
              _buildDetailRow('Outstanding', _formatAmount(customer.outstandingAmount), isWeb),
              if (customer.lastPaymentDate != null)
                _buildDetailRow(
                  'Last Payment',
                  DateFormat('dd MMM yyyy').format(customer.lastPaymentDate!),
                  isWeb,
                ),
            ],
          ),
        ),
        SizedBox(height: isWeb ? 20 : 16),
        Text(
          'Recent Invoices',
          style: TextStyle(
            fontSize: isWeb ? 16 : 14,
            fontWeight: FontWeight.w700,
            color: kText,
          ),
        ),
        SizedBox(height: isWeb ? 12 : 8),
        ...customer.invoices.take(3).map((invoice) => _buildInvoiceItem(invoice, isWeb)),
        SizedBox(height: isWeb ? 20 : 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  controller.viewInvoices(customer);
                },
                icon: Icon(Icons.receipt, size: isWeb ? 20 : 16),
                label: Text('All Invoices', style: TextStyle(fontSize: isWeb ? 14 : 12)),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: isWeb ? 12 : 10),
                ),
              ),
            ),
            SizedBox(width: isWeb ? 12 : 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _showPaymentDialog(customer, controller, ctx);
                },
                icon: Icon(Icons.payment, size: isWeb ? 20 : 16),
                label: Text('Record Payment', style: TextStyle(fontSize: isWeb ? 14 : 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kSuccess,
                  padding: EdgeInsets.symmetric(vertical: isWeb ? 12 : 10),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showPaymentDialog(Customer customer, AccountsReceivableController controller, BuildContext context) {
    // For demo purposes, show a simple dialog
    // In production, this should be a full payment form
    Get.defaultDialog(
      title: 'Record Payment',
      content: Column(
        children: [
          Text('Customer: ${customer.name}'),
          SizedBox(height: 10),
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

  Widget _buildDetailRow(String label, String value, bool isWeb) {
    return Padding(
      padding: EdgeInsets.only(bottom: isWeb ? 12 : 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isWeb ? 13 : 11,
              color: kSubText,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isWeb ? 13 : 12,
              color: kText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceItem(Invoice invoice, bool isWeb) {
    Color statusColor = invoice.status == 'Paid' ? kSuccess : 
                        invoice.status == 'Overdue' ? kDanger : kWarning;
    double outstanding = invoice.amount - invoice.paidAmount;
    
    return Container(
      margin: EdgeInsets.only(bottom: isWeb ? 8 : 6),
      padding: EdgeInsets.all(isWeb ? 12 : 10),
      decoration: BoxDecoration(
        color: kBg,
        borderRadius: BorderRadius.circular(isWeb ? 10 : 8),
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
                    fontSize: isWeb ? 12 : 11,
                    fontWeight: FontWeight.w600,
                    color: kText,
                  ),
                ),
                Text(
                  DateFormat('dd MMM yyyy').format(invoice.date),
                  style: TextStyle(
                    fontSize: isWeb ? 10 : 9,
                    color: kSubText,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatAmount(outstanding),
            style: TextStyle(
              fontSize: isWeb ? 13 : 11,
              fontWeight: FontWeight.w700,
              color: statusColor,
            ),
          ),
          SizedBox(width: isWeb ? 8 : 6),
          Container(
            padding: EdgeInsets.symmetric(horizontal: isWeb ? 8 : 6, vertical: isWeb ? 4 : 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(isWeb ? 6 : 4),
            ),
            child: Text(
              invoice.status,
              style: TextStyle(
                fontSize: isWeb ? 10 : 9,
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