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

    // ✅ Scaffold for Material context
    return Scaffold(
      backgroundColor: kBg,
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: LoadingAnimationWidget.waveDots(
              color: kPrimary,
              size: ResponsiveUtils.isWeb(context) ? 60 : 40,
            ),
          );
        }

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

  // ==================== HEADER ====================
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
      decoration: const BoxDecoration(
        color: kPrimary,
        borderRadius: BorderRadius.only(
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
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _headerIconBtn(
            icon: Icons.download_outlined,
            size: isWeb ? 22 : 20,
            onTap: () => controller.exportReport(),
          ),
          if (!isMobile) const SizedBox(width: 8),
          if (!isMobile)
            _headerIconBtn(
              icon: Icons.add,
              size: isWeb ? 22 : 20,
              onTap: () => _showAddCustomerDialog(Get.context!, controller, context),
              isWhiteBg: true,
              iconColor: kPrimary,
            ),
        ],
      ),
    );
  }

  Widget _headerIconBtn({
    required IconData icon,
    required double size,
    required VoidCallback onTap,
    bool isWhiteBg = false,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isWhiteBg ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor ?? Colors.white, size: size),
      ),
    );
  }

  // ==================== SUMMARY CARDS ====================
  Widget _buildSummaryCards(AccountsReceivableController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Obx(() => Container(
      padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 16 : 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildSummaryCard('Total Outstanding', _formatAmount(controller.totalOutstanding.value), kDanger, Icons.receipt, context, width: isWeb ? 220 : 160),
            SizedBox(width: isWeb ? 16 : 12),
            _buildSummaryCard('Overdue', _formatAmount(controller.totalOverdue.value), kWarning, Icons.warning, context, width: isWeb ? 220 : 160),
            SizedBox(width: isWeb ? 16 : 12),
            _buildSummaryCard('Due This Week', _formatAmount(controller.totalDueThisWeek.value), kPrimary, Icons.view_week, context, width: isWeb ? 220 : 160),
            SizedBox(width: isWeb ? 16 : 12),
            _buildSummaryCard('Due This Month', _formatAmount(controller.totalDueThisMonth.value), kPrimary, Icons.calendar_month, context, width: isWeb ? 220 : 160),
            SizedBox(width: isWeb ? 16 : 12),
            _buildSummaryCard('Active Customers', controller.activeCustomers.value.toString(), kSuccess, Icons.people, context, width: isWeb ? 220 : 160, isNumber: true),
          ],
        ),
      ),
    ));
  }

  Widget _buildSummaryCard(String title, String amount, Color color, IconData icon, BuildContext context, {double width = 160, bool isNumber = false}) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Container(
      width: width,
      padding: EdgeInsets.all(isWeb ? 16 : 12),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: isWeb ? 24 : 20, color: color),
              SizedBox(width: isWeb ? 8 : 6),
              Expanded(child: Text(title, style: TextStyle(fontSize: isWeb ? 12 : 11, color: kSubText, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
            ],
          ),
          SizedBox(height: isWeb ? 8 : 6),
          Text(isNumber ? amount : amount, style: TextStyle(fontSize: isWeb ? 18 : 14, fontWeight: FontWeight.w800, color: color), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  // ==================== FILTER BAR ====================
  Widget _buildFilterBar(AccountsReceivableController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final List<String> filterOptions = ['All', 'Overdue', 'Due This Week', 'Due This Month', 'Paid'];

    return Material(
      color: kCardBg,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 12 : 10),
        child: Row(
          children: [
            Expanded(
              flex: isWeb ? 3 : 2,
              child: Container(
                height: isWeb ? 45 : 40,
                decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(isWeb ? 12 : 10), border: Border.all(color: kBorder)),
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
            SizedBox(
              width: isWeb ? 150 : 120,
              height: isWeb ? 45 : 40,
              child: Container(
                decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(isWeb ? 12 : 10), border: Border.all(color: kBorder)),
                child: DropdownButtonHideUnderline(
                  child: Obx(() => DropdownButton<String>(
                    value: controller.selectedFilter.value,
                    icon: Icon(Icons.arrow_drop_down, size: isWeb ? 24 : 20),
                    padding: EdgeInsets.symmetric(horizontal: isWeb ? 12 : 8),
                    isExpanded: true,
                    style: TextStyle(fontSize: isWeb ? 13 : 12, color: kText),
                    items: filterOptions.map((filter) {
                      return DropdownMenuItem(value: filter, child: Text(filter, overflow: TextOverflow.ellipsis));
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
      ),
    );
  }

  // ==================== CUSTOMERS LIST ====================
  Widget _buildCustomersList(AccountsReceivableController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);

    return Obx(() {
      final customers = controller.displayCustomers;

      if (customers.isEmpty) {
        return Padding(
          padding: EdgeInsets.all(isWeb ? 40 : 20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: isWeb ? 80 : 64, color: kSubText.withOpacity(0.5)),
                SizedBox(height: isWeb ? 20 : 16),
                Text('No customers found', style: TextStyle(fontSize: isWeb ? 18 : 16, color: kSubText, fontWeight: FontWeight.w500)),
                SizedBox(height: isWeb ? 20 : 16),
                ElevatedButton(
                  onPressed: () => _showAddCustomerDialog(Get.context!, controller, context),
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                  child: Text('Add Customer', style: TextStyle(fontSize: isWeb ? 14 : 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 12 : 8),
            child: Row(
              children: [
                Text('Customers', style: TextStyle(fontSize: isWeb ? 18 : 16, fontWeight: FontWeight.w700, color: kText)),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text('${customers.length} customers', style: TextStyle(fontSize: isWeb ? 12 : 11, color: kPrimary, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          if (isWeb)
            _buildWebCustomersTable(customers, controller, context)
          else
            _buildMobileCustomersList(customers, controller, context),
        ],
      );
    });
  }

  // ==================== WEB TABLE ====================
  Widget _buildWebCustomersTable(
    List<Customer> customers,
    AccountsReceivableController controller,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Container(
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: [
                // Header - Fixed widths
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  color: kPrimary.withOpacity(0.06),
                  child: Row(
                    children: [
                      Container(width: 60, child: const Text('', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 200, child: const Text('Customer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 180, child: const Text('Contact', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 80, child: const Text('Invoices', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 150, child: const Text('Total Amount', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 150, child: const Text('Paid', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 150, child: const Text('Outstanding', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 120, child: const Text('Alerts', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    ],
                  ),
                ),
                ...customers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final customer = entry.value;
                  final isEven = index.isEven;
                  final overdueCount = customer.invoices.where((inv) => inv.status == 'Overdue').length;
                  final dueSoonCount = customer.invoices.where((inv) => _isDueSoon(inv.dueDate)).length;

                  return InkWell(
                    onTap: () => _showCustomerDetails(customer, controller, context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: isEven ? Colors.transparent : kPrimary.withOpacity(0.01),
                        border: Border(top: BorderSide(color: kBorder.withOpacity(0.5))),
                      ),
                      child: Row(
                        children: [
                          // Avatar
                         // Customer name + email
                          Container(
                            width: 200,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(customer.name, style:  TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kText), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 3),
                                Text(customer.email.isEmpty ? '-' : customer.email, style:  TextStyle(fontSize: 11, color: kSubText), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          // Phone
                          Container(
                            width: 180,
                            child: Text(customer.phone.isEmpty ? '-' : customer.phone, style:  TextStyle(fontSize: 13, color: kSubText), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                          // Invoice count
                          Container(
                            width: 80,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: kPrimary.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
                                child: Text('${customer.totalInvoices}', style: const TextStyle(fontSize: 12, color: kPrimary, fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ),
                          // Total Amount
                          Container(
                            width: 150,
                            child: Text(_formatAmount(customer.totalAmount), textAlign: TextAlign.right, style:  TextStyle(fontSize: 13, color: kSubText, fontWeight: FontWeight.w500)),
                          ),
                          // Paid
                          Container(
                            width: 150,
                            child: Text(_formatAmount(customer.paidAmount), textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, color: kSuccess, fontWeight: FontWeight.w600)),
                          ),
                          // Outstanding
                          Container(
                            width: 150,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(color: kDanger.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                                child: Text(_formatAmount(customer.outstandingAmount), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDanger)),
                              ),
                            ),
                          ),
                          // Alerts
                          Container(
                            width: 120,
                            child: Center(
                              child: Wrap(
                                spacing: 4,
                                alignment: WrapAlignment.center,
                                children: [
                                  if (overdueCount > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(color: kDanger.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                                        Icon(Icons.warning, size: 10, color: kDanger),
                                        const SizedBox(width: 3),
                                        Text('$overdueCount OD', style: TextStyle(fontSize: 10, color: kDanger, fontWeight: FontWeight.w600)),
                                      ]),
                                    ),
                                  if (dueSoonCount > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(color: kWarning.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                                        Icon(Icons.schedule, size: 10, color: kWarning),
                                        const SizedBox(width: 3),
                                        Text('$dueSoonCount DS', style: TextStyle(fontSize: 10, color: kWarning, fontWeight: FontWeight.w600)),
                                      ]),
                                    ),
                                  if (overdueCount == 0 && dueSoonCount == 0)
                                    Text('-', style: TextStyle(fontSize: 13, color: kSubText)),
                                ],
                              ),
                            ),
                          ),
                          // Actions
                      
                        ],
                      ),
                    ),
                  );
                }).toList(),
                // Footer
                _buildTableFooter(customers),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableFooter(List<Customer> customers) {
    final totalAmount = customers.fold(0.0, (s, c) => s + c.totalAmount);
    final totalPaid = customers.fold(0.0, (s, c) => s + c.paidAmount);
    final totalOutstanding = customers.fold(0.0, (s, c) => s + c.outstandingAmount);
    final overdueCustomers = customers.where((c) => c.invoices.any((i) => i.status == 'Overdue')).length;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: kPrimary.withOpacity(0.06),
        border:  Border(top: BorderSide(color: kBorder)),
      ),
      child: Row(
        children: [
          Container(width: 60, child: const Text('')),
          Container(width: 200, child: const Text('TOTALS', style: TextStyle(fontWeight: FontWeight.bold))),
          Container(width: 180, child: const SizedBox()),
          Container(width: 80, child: const SizedBox()),
          Container(width: 150, child: Text(_formatAmount(totalAmount), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold))),
          Container(width: 150, child: Text(_formatAmount(totalPaid), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, color: kSuccess))),
          Container(width: 150, child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(color: kDanger.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(_formatAmount(totalOutstanding), style: const TextStyle(fontWeight: FontWeight.bold, color: kDanger)),
            ),
          )),
          Container(width: 120, child: Center(child: Text('$overdueCustomers w/ Overdue', style: const TextStyle(fontWeight: FontWeight.bold, color: kDanger)))),
          Container(width: 100, child: const SizedBox()),
        ],
      ),
    );
  }

  // ==================== MOBILE LIST ====================
  Widget _buildMobileCustomersList(List<Customer> customers, AccountsReceivableController controller, BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        final overdueCount = customer.invoices.where((inv) => inv.status == 'Overdue').length;
        final dueSoonCount = customer.invoices.where((inv) => _isDueSoon(inv.dueDate)).length;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildMobileCustomerCard(customer, controller, overdueCount, dueSoonCount, context),
        );
      },
    );
  }

  Widget _buildMobileCustomerCard(Customer customer, AccountsReceivableController controller, int overdueCount, int dueSoonCount, BuildContext context) {
    return Card(
      color: kCardBg,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showCustomerDetails(customer, controller, context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: Center(child: Text(customer.name[0].toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kPrimary))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(customer.name, style:  TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: kText), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(customer.email, style:  TextStyle(fontSize: 10, color: kSubText), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(customer.phone, style:  TextStyle(fontSize: 10, color: kSubText)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                       Text('Outstanding', style: TextStyle(fontSize: 9, color: kSubText, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text(_formatAmount(customer.outstandingAmount), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: kDanger)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildStatItem('Invoices', customer.totalInvoices.toString(), Icons.receipt, kPrimary, false)),
                  Expanded(child: _buildStatItem('Total', _formatAmount(customer.totalAmount), Icons.attach_money, kPrimary, false)),
                  Expanded(child: _buildStatItem('Paid', _formatAmount(customer.paidAmount), Icons.check_circle, kSuccess, false)),
                ],
              ),
              const SizedBox(height: 8),
              if (overdueCount > 0 || dueSoonCount > 0)
                Wrap(
                  spacing: 6,
                  children: [
                    if (overdueCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: kDanger.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.warning, size: 12, color: kDanger),
                          const SizedBox(width: 2),
                          Text('$overdueCount Overdue', style: TextStyle(fontSize: 9, color: kDanger, fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    if (dueSoonCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: kWarning.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.schedule, size: 12, color: kWarning),
                          const SizedBox(width: 2),
                          Text('$dueSoonCount Due Soon', style: TextStyle(fontSize: 9, color: kWarning, fontWeight: FontWeight.w600)),
                        ]),
                      ),
                  ],
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.viewInvoices(customer),
                      icon: const Icon(Icons.receipt, size: 14),
                      label: const Text('View Invoices', style: TextStyle(fontSize: 10)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: kPrimary, width: 1),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showPaymentDialog(customer, controller, context),
                      icon: const Icon(Icons.payment, size: 14, color: Colors.white),
                      label: const Text('Record Payment', style: TextStyle(fontSize: 10)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSuccess,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color, bool isWeb) {
    return Column(
      children: [
        Icon(icon, size: isWeb ? 20 : 16, color: color),
        SizedBox(height: isWeb ? 4 : 2),
        Text(value, style: TextStyle(fontSize: isWeb ? 13 : 11, fontWeight: FontWeight.w700, color: kText), overflow: TextOverflow.ellipsis),
        Text(label, style: TextStyle(fontSize: isWeb ? 10 : 8, color: kSubText)),
      ],
    );
  }

  // ==================== DIALOGS ====================
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
              width: isWeb ? 500 : MediaQuery.of(context).size.width * 0.9,
              constraints: BoxConstraints(maxHeight: isWeb ? 600 : 500),
              padding: EdgeInsets.all(isWeb ? 24 : 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Add New Customer', style: TextStyle(fontSize: isWeb ? 20 : 18, fontWeight: FontWeight.w800, color: kText)),
                  SizedBox(height: isWeb ? 20 : 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            _buildTextField('Customer Name *', (v) => name = v, isWeb: isWeb),
                            SizedBox(height: isWeb ? 16 : 12),
                            _buildTextField('Email', (v) => email = v, isWeb: isWeb),
                            SizedBox(height: isWeb ? 16 : 12),
                            _buildTextField('Phone *', (v) => phone = v, isWeb: isWeb),
                            SizedBox(height: isWeb ? 16 : 12),
                            _buildTextField('Address', (v) => address = v, isWeb: isWeb, maxLines: 2),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isWeb ? 20 : 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(fontSize: isWeb ? 14 : 12))),
                      ),
                      SizedBox(width: isWeb ? 16 : 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              Navigator.pop(context);
                              controller.createCustomer({'name': name, 'email': email, 'phone': phone, 'address': address});
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
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
    
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: isWeb ? 500 : MediaQuery.of(ctx).size.width * 0.9,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                    child: Center(child: Text(customer.name[0].toUpperCase(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: kPrimary))),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(customer.name, style:  TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kText)),
                      Text(customer.email, style:  TextStyle(fontSize: 13, color: kSubText)),
                    ]),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    _buildDetailRow('Phone', customer.phone, isWeb),
                    _buildDetailRow('Total Invoices', customer.totalInvoices.toString(), isWeb),
                    _buildDetailRow('Total Amount', _formatAmount(customer.totalAmount), isWeb),
                    _buildDetailRow('Paid Amount', _formatAmount(customer.paidAmount), isWeb),
                    _buildDetailRow('Outstanding', _formatAmount(customer.outstandingAmount), isWeb),
                    if (customer.lastPaymentDate != null)
                      _buildDetailRow('Last Payment', DateFormat('dd MMM yyyy').format(customer.lastPaymentDate!), isWeb),
                  ],
                ),
              ),
              const SizedBox(height: 16),
               Text('Recent Invoices', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kText)),
              const SizedBox(height: 8),
              ...customer.invoices.take(3).map((invoice) => _buildInvoiceItem(invoice, isWeb)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () { Navigator.pop(ctx); controller.viewInvoices(customer); },
                      icon: const Icon(Icons.receipt, size: 18),
                      label: const Text('All Invoices', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () { Navigator.pop(ctx); _showPaymentDialog(customer, controller, ctx); },
                      icon: const Icon(Icons.payment, size: 18),
                      label: const Text('Record Payment', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(backgroundColor: kSuccess),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentDialog(Customer customer, AccountsReceivableController controller, BuildContext context) {
    Get.defaultDialog(
      title: 'Record Payment',
      content: Column(
        children: [
          Text('Customer: ${customer.name}'),
          const SizedBox(height: 10),
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

  // ==================== HELPER WIDGETS ====================
  Widget _buildTextField(String label, Function(String) onChanged, {bool isWeb = false, int maxLines = 1}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: TextStyle(fontSize: isWeb ? 12 : 11),
      ),
      style: TextStyle(fontSize: isWeb ? 13 : 12, color: kText),
      maxLines: maxLines,
      validator: label.contains('*') ? (value) => value == null || value.isEmpty ? '$label required' : null : null,
      onChanged: onChanged,
    );
  }

  Widget _buildDetailRow(String label, String value, bool isWeb) {
    return Padding(
      padding: EdgeInsets.only(bottom: isWeb ? 12 : 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isWeb ? 13 : 11, color: kSubText, fontWeight: FontWeight.w500)),
          Flexible(child: Text(value, style: TextStyle(fontSize: isWeb ? 13 : 12, color: kText, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildInvoiceItem(Invoice invoice, bool isWeb) {
    final statusColor = invoice.status == 'Paid' ? kSuccess : invoice.status == 'Overdue' ? kDanger : kWarning;
    final outstanding = invoice.amount - invoice.paidAmount;
    
    return Container(
      margin: EdgeInsets.only(bottom: isWeb ? 8 : 6),
      padding: EdgeInsets.all(isWeb ? 12 : 10),
      decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(isWeb ? 10 : 8)),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(invoice.id, style: TextStyle(fontSize: isWeb ? 12 : 11, fontWeight: FontWeight.w600, color: kText)),
              Text(DateFormat('dd MMM yyyy').format(invoice.date), style: TextStyle(fontSize: isWeb ? 10 : 9, color: kSubText)),
            ]),
          ),
          Text(_formatAmount(outstanding), style: TextStyle(fontSize: isWeb ? 13 : 11, fontWeight: FontWeight.w700, color: statusColor)),
          const SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: isWeb ? 8 : 6, vertical: isWeb ? 4 : 2),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(isWeb ? 6 : 4)),
            child: Text(invoice.status, style: TextStyle(fontSize: isWeb ? 10 : 9, color: statusColor, fontWeight: FontWeight.w600)),
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
    return '\$ ${formatter.format(amount)}';
  }
}