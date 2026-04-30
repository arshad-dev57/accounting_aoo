import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/Utils/responsive_utils.dart';
import 'package:LedgerPro_app/core/PaymentMade/controller/paymentmade_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class PaymentsMadeScreen extends StatelessWidget {
  const PaymentsMadeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PaymentMadeController());
    
    // ✅ Scaffold for Material context
    return Scaffold(
      backgroundColor: kBg,
      body: Obx(() {
        if (controller.isLoading.value && controller.payments.isEmpty) {
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
              _buildPaymentsList(controller, context),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader(PaymentMadeController controller, BuildContext context) {
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
                  'Payments Made',
                  style: TextStyle(
                    fontSize: isWeb ? 20 : 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Track all vendor payments',
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
            icon: Icons.calendar_today_outlined,
            size: isWeb ? 22 : 20,
            onTap: () => controller.selectDateRange(),
          ),
          if (!isMobile) const SizedBox(width: 8),
          _headerIconBtn(
            icon: Icons.download_outlined,
            size: isWeb ? 22 : 20,
            onTap: () => controller.exportPayments(),
          ),
          if (!isMobile) const SizedBox(width: 8),
          if (!isMobile)
            _headerIconBtn(
              icon: Icons.add,
              size: isWeb ? 22 : 20,
              onTap: () => _showRecordPaymentDialog(controller, context),
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
  Widget _buildSummaryCards(PaymentMadeController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 16 : 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Obx(() => _buildSummaryCard('Total Paid', controller.formatAmount(controller.totalPaid.value), kDanger, Icons.payment, context, width: isWeb ? 220 : 170)),
            SizedBox(width: isWeb ? 16 : 12),
            Obx(() => _buildSummaryCard('This Month', controller.formatAmount(controller.thisMonthTotal.value), kPrimary, Icons.calendar_month, context, width: isWeb ? 220 : 170)),
            SizedBox(width: isWeb ? 16 : 12),
            Obx(() => _buildSummaryCard('This Week', controller.formatAmount(controller.thisWeekTotal.value), kPrimary, Icons.view_week, context, width: isWeb ? 220 : 170)),
            SizedBox(width: isWeb ? 16 : 12),
            Obx(() => _buildSummaryCard('Today', controller.formatAmount(controller.todayTotal.value), kPrimary, Icons.today, context, width: isWeb ? 200 : 160)),
            SizedBox(width: isWeb ? 16 : 12),
            Obx(() => _buildSummaryCard('Pending', controller.pendingCount.value.toString(), kWarning, Icons.pending, context, width: isWeb ? 200 : 160, isNumber: true)),
          ],
        ),
      ),
    );
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
  Widget _buildFilterBar(PaymentMadeController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Material(
      color: kCardBg,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 12 : 10),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: isWeb ? 3 : 2,
                  child: Container(
                    height: isWeb ? 45 : 40,
                    decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(isWeb ? 12 : 10), border: Border.all(color: kBorder)),
                    child: TextField(
                      controller: controller.searchController,
                      style: TextStyle(fontSize: isWeb ? 14 : 12, color: kText),
                      decoration: InputDecoration(
                        hintText: isWeb ? 'Search by payment ID, vendor, bill, reference...' : 'Search...',
                        hintStyle: TextStyle(fontSize: isWeb ? 12 : 11, color: kSubText),
                        prefixIcon: Icon(Icons.search, size: isWeb ? 20 : 18, color: kSubText),
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
                    child: Obx(() => DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.selectedFilter.value,
                        icon: Icon(Icons.arrow_drop_down, size: isWeb ? 24 : 20, color: kText),
                        padding: EdgeInsets.symmetric(horizontal: isWeb ? 12 : 8),
                        isExpanded: true,
                        style: TextStyle(fontSize: isWeb ? 13 : 12, color: kText),
                        dropdownColor: kCardBg,
                        items: controller.filterOptions.map((filter) {
                          return DropdownMenuItem(value: filter, child: Text(filter, overflow: TextOverflow.ellipsis));
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) controller.applyDateFilter(value);
                        },
                      ),
                    )),
                  ),
                ),
              ],
            ),
            Obx(() {
              if (controller.selectedDateRange.value != null) {
                final range = controller.selectedDateRange.value!;
                return Padding(
                  padding: EdgeInsets.only(top: isWeb ? 12 : 8),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: isWeb ? 16 : 12, vertical: isWeb ? 12 : 10),
                    decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(isWeb ? 10 : 8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            children: [
                              Icon(Icons.date_range, size: isWeb ? 20 : 16, color: kPrimary),
                              SizedBox(width: isWeb ? 8 : 6),
                              Flexible(
                                child: Text(
                                  '${DateFormat('dd MMM yyyy').format(range.start)} - ${DateFormat('dd MMM yyyy').format(range.end)}',
                                  style: TextStyle(fontSize: isWeb ? 12 : 11, color: kPrimary, fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => controller.clearDateRange(),
                          child: Icon(Icons.close, size: isWeb ? 20 : 16, color: kPrimary),
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
      ),
    );
  }

  // ==================== PAYMENTS LIST ====================
  Widget _buildPaymentsList(PaymentMadeController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    if (controller.payments.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(isWeb ? 40 : 20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.payment_outlined, size: isWeb ? 80 : 64, color: kSubText.withOpacity(0.5)),
              SizedBox(height: isWeb ? 20 : 16),
              Text('No payments found', style: TextStyle(fontSize: isWeb ? 18 : 16, color: kSubText)),
              SizedBox(height: isWeb ? 20 : 16),
              ElevatedButton(
                onPressed: () => _showRecordPaymentDialog(controller, context),
                style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                child: Text('Record Payment', style: TextStyle(fontSize: isWeb ? 14 : 12, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (isWeb) {
      return _buildWebPaymentsTable(controller, context);
    } else {
      return _buildMobilePaymentsList(controller, context);
    }
  }

  // ==================== WEB TABLE ====================
  Widget _buildWebPaymentsTable(PaymentMadeController controller, BuildContext context) {
    final payments = controller.payments;

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
                      Container(width: 150, child: const Text('Payment #', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 200, child: const Text('Vendor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 120, child: const Text('Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 150, child: const Text('Amount', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 130, child: const Text('Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 100, child: const Text('Status', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 80, child: const Text('Actions', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    ],
                  ),
                ),
                ...payments.asMap().entries.map((entry) {
                  final index = entry.key;
                  final payment = entry.value;
                  final isEven = index.isEven;
                  final statusColor = payment.status == 'Cleared' ? kSuccess : kWarning;
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: isEven ? Colors.transparent : kPrimary.withOpacity(0.01),
                      border: Border(top: BorderSide(color: kBorder.withOpacity(0.5))),
                    ),
                    child: Row(
                      children: [
                        // Icon
                        Container(
                          width: 60,
                          height: 44,
                          decoration: BoxDecoration(color: kDanger.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.payment, size: 22, color: kDanger),
                        ),
                        // Payment #
                        Container(
                          width: 150,
                          child: Text(payment.paymentNumber, style:  TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kText)),
                        ),
                        // Vendor
                        Container(
                          width: 200,
                          child: Text(payment.vendorName, style:  TextStyle(fontSize: 13, color: kText), overflow: TextOverflow.ellipsis),
                        ),
                        // Date
                        Container(
                          width: 120,
                          child: Text(DateFormat('dd MMM yyyy').format(payment.paymentDate), style:  TextStyle(fontSize: 13, color: kSubText)),
                        ),
                        // Amount
                        Container(
                          width: 150,
                          child: Text(controller.formatAmount(payment.amount), textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kDanger)),
                        ),
                        // Method
                        Container(
                          width: 130,
                          child: Text(payment.paymentMethod, style:  TextStyle(fontSize: 13, color: kText), overflow: TextOverflow.ellipsis),
                        ),
                        // Status
                        Container(
                          width: 100,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                              child: Text(payment.status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
                            ),
                          ),
                        ),
                        // Actions
                        Container(
                          width: 80,
                          child: IconButton(
                            onPressed: () => _showPaymentDetails(controller, payment, context),
                            icon: const Icon(Icons.remove_red_eye, size: 18),
                            padding: EdgeInsets.zero,
                            color: kPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                // Footer
                _buildTableFooter(controller, payments),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableFooter(PaymentMadeController controller, List<PaymentMade> payments) {
    final totalAmount = payments.fold(0.0, (sum, p) => sum + p.amount);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: kPrimary.withOpacity(0.06),
        border:  Border(top: BorderSide(color: kBorder)),
      ),
      child: Row(
        children: [
          Container(width: 60, child: const Text('')),
          Container(width: 150, child: const Text('TOTALS', style: TextStyle(fontWeight: FontWeight.bold))),
          Container(width: 200, child: const SizedBox()),
          Container(width: 120, child: const SizedBox()),
          Container(width: 150, child: Text(controller.formatAmount(totalAmount), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, color: kDanger))),
          Container(width: 130, child: const SizedBox()),
          Container(width: 100, child: const SizedBox()),
          Container(width: 80, child: const SizedBox()),
        ],
      ),
    );
  }

  // ==================== MOBILE LIST ====================
  Widget _buildMobilePaymentsList(PaymentMadeController controller, BuildContext context) {
    final payments = controller.payments;
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text('Payments', style:  TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kText)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text('${payments.length} payments', style: const TextStyle(fontSize: 11, color: kPrimary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: payments.length,
          itemBuilder: (context, index) {
            final payment = payments[index];
            final statusColor = payment.status == 'Cleared' ? kSuccess : kWarning;
            final statusIcon = payment.status == 'Cleared' ? Icons.check_circle : Icons.pending;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildMobilePaymentCard(controller, payment, statusColor, statusIcon, context),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMobilePaymentCard(PaymentMadeController controller, PaymentMade payment, Color statusColor, IconData statusIcon, BuildContext context) {
    return Card(
      color: kCardBg,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showPaymentDetails(controller, payment, context),
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
                    decoration: BoxDecoration(color: kDanger.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.payment, size: 20, color: kDanger),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(payment.paymentNumber, style:  TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: kText), overflow: TextOverflow.ellipsis)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(statusIcon, size: 10, color: statusColor),
                                const SizedBox(width: 2),
                                Text(payment.status, style: TextStyle(fontSize: 9, color: statusColor, fontWeight: FontWeight.w600)),
                              ]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(payment.vendorName, style:  TextStyle(fontSize: 11, color: kSubText), overflow: TextOverflow.ellipsis),
                        Text(DateFormat('dd MMM yyyy').format(payment.paymentDate), style:  TextStyle(fontSize: 10, color: kSubText)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                       Text('Amount', style: TextStyle(fontSize: 9, color: kSubText)),
                      const SizedBox(height: 2),
                      Text(controller.formatAmount(payment.amount), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: kDanger)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.viewBill(payment),
                      icon: const Icon(Icons.receipt, size: 14),
                      label: const Text('Bill', style: TextStyle(fontSize: 10)),
                      style: _buttonStyle(kPrimary, false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => controller.printVoucher(payment),
                      icon: const Icon(Icons.print, size: 14, color: Colors.white),
                      label: const Text('Voucher', style: TextStyle(fontSize: 10)),
                      style: ElevatedButton.styleFrom(backgroundColor: kPrimary, padding: const EdgeInsets.symmetric(vertical: 8)),
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

  Widget _buildInfoItem(String label, String value, IconData icon, bool isWeb) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: isWeb ? 16 : 12, color: kSubText),
        SizedBox(width: isWeb ? 8 : 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: isWeb ? 11 : 8, color: kSubText)),
              Text(value, style: TextStyle(fontSize: isWeb ? 11 : 9, fontWeight: FontWeight.w600, color: kText), overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  ButtonStyle _buttonStyle(Color color, bool isWeb) {
    return OutlinedButton.styleFrom(
      foregroundColor: color,
      side: BorderSide(color: color),
      padding: EdgeInsets.symmetric(vertical: isWeb ? 10 : 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isWeb ? 8 : 6)),
    );
  }

  // ==================== DIALOGS ====================
  void _showRecordPaymentDialog(PaymentMadeController controller, BuildContext ctx) {
    final isWeb = ResponsiveUtils.isWeb(ctx);
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
      context: ctx,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              width: isWeb ? 600 : MediaQuery.of(context).size.width * 0.9,
              constraints: BoxConstraints(maxHeight: isWeb ? 700 : 600),
              padding: EdgeInsets.all(isWeb ? 24 : 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(isWeb ? 12 : 10),
                        decoration: BoxDecoration(color: kDanger.withOpacity(0.1), borderRadius: BorderRadius.circular(isWeb ? 12 : 10)),
                        child: Icon(Icons.payment, size: isWeb ? 24 : 20, color: kDanger),
                      ),
                      SizedBox(width: isWeb ? 16 : 12),
                      Expanded(child: Text('Record Payment Made', style: TextStyle(fontSize: isWeb ? 20 : 18, fontWeight: FontWeight.w800, color: kText))),
                      GestureDetector(onTap: () => Get.back(), child: Icon(Icons.close, size: isWeb ? 24 : 20, color: kSubText)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: kBorder, height: 1),
                  SizedBox(height: isWeb ? 16 : 12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            // Payment Date
                            _dateTile('Payment Date', paymentDate, (date) => setState(() => paymentDate = date), isWeb, context),
                            SizedBox(height: isWeb ? 16 : 12),
                            // Vendor Selection
                            Obx(() => DropdownButtonFormField<String>(
                              decoration: _inputDecoration('Select Vendor *', isWeb),
                              style: TextStyle(fontSize: isWeb ? 13 : 12, color: kText),
                              dropdownColor: kCardBg,
                              value: selectedVendorId.isEmpty ? null : selectedVendorId,
                              items: controller.vendors.map((vendor) {
                                return DropdownMenuItem(value: vendor.id, child: Text(vendor.name, overflow: TextOverflow.ellipsis));
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
                            SizedBox(height: isWeb ? 16 : 12),
                            
                            // Bill Selection
                            FutureBuilder<List<BillForPayment>>(
                              future: selectedVendorId.isNotEmpty ? controller.getUnpaidBills(selectedVendorId) : Future.value([]),
                              builder: (context, snapshot) {
                                if (selectedVendorId.isEmpty) return const SizedBox.shrink();

                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: LoadingAnimationWidget.waveDots(color: kPrimary, size: isWeb ? 40 : 30));
                                }

                                final bills = snapshot.data ?? [];

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    DropdownButtonFormField<String>(
                                      decoration: _inputDecoration('Select Bill *', isWeb),
                                      style: TextStyle(fontSize: isWeb ? 13 : 12, color: kText),
                                      dropdownColor: kCardBg,
                                      value: selectedBillId.isEmpty ? null : selectedBillId,
                                      items: bills.map((bill) {
                                        return DropdownMenuItem<String>(
                                          value: bill.id,
                                          child: Text('${bill.billNumber} • ${controller.formatAmount(bill.outstanding)}', overflow: TextOverflow.ellipsis),
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
                                    if (selectedBillId.isNotEmpty) ...[
                                      SizedBox(height: isWeb ? 12 : 8),
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(isWeb ? 12 : 10),
                                        decoration: BoxDecoration(color: kCardBg, borderRadius: BorderRadius.circular(isWeb ? 10 : 8)),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Bill: ${bills.firstWhere((b) => b.id == selectedBillId).billNumber}', style: TextStyle(color: kText, fontWeight: FontWeight.w600, fontSize: isWeb ? 13 : 12)),
                                            Text('Total: ${controller.formatAmount(bills.firstWhere((b) => b.id == selectedBillId).totalAmount)}', style: TextStyle(fontSize: isWeb ? 11 : 10, color: kSubText)),
                                            Text('Outstanding: ${controller.formatAmount(bills.firstWhere((b) => b.id == selectedBillId).outstanding)}', style: TextStyle(fontSize: isWeb ? 11 : 10, color: kSubText)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                );
                              },
                            ),
                            SizedBox(height: isWeb ? 16 : 12),
                            
                            // Amount
                            TextFormField(
                              decoration: _inputDecoration('Amount *', isWeb, prefix: '\$ '),
                              style: TextStyle(fontSize: isWeb ? 13 : 12, color: kText),
                              keyboardType: TextInputType.number,
                              initialValue: amount > 0 ? amount.toString() : '',
                              onChanged: (value) => amount = double.tryParse(value) ?? 0,
                              validator: (value) => value == null || value.isEmpty ? 'Amount required' : null,
                            ),
                            SizedBox(height: isWeb ? 16 : 12),
                            
                            // Payment Method
                            DropdownButtonFormField<String>(
                              value: paymentMethod,
                              decoration: _inputDecoration('Payment Method *', isWeb),
                              style: TextStyle(fontSize: isWeb ? 13 : 12, color: kText),
                              dropdownColor: kCardBg,
                              items: const [
                                DropdownMenuItem(value: 'Bank Transfer', child: Text('Bank Transfer')),
                                DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                                DropdownMenuItem(value: 'Cheque', child: Text('Cheque')),
                                DropdownMenuItem(value: 'Credit Card', child: Text('Credit Card')),
                              ],
                              onChanged: (value) => setState(() => paymentMethod = value!),
                            ),
                            SizedBox(height: isWeb ? 16 : 12),
                            
                            // Reference
                            TextFormField(
                              decoration: _inputDecoration('Reference Number', isWeb),
                              style: TextStyle(fontSize: isWeb ? 13 : 12, color: kText),
                              onChanged: (value) => reference = value,
                            ),
                            SizedBox(height: isWeb ? 16 : 12),
                            
                            // Notes
                            TextFormField(
                              decoration: _inputDecoration('Notes', isWeb),
                              style: TextStyle(fontSize: isWeb ? 13 : 12, color: kText),
                              maxLines: 2,
                              onChanged: (value) => notes = value,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isWeb ? 16 : 12),
                  Divider(color: kBorder, height: 1),
                  SizedBox(height: isWeb ? 16 : 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(side: BorderSide(color: kBorder), padding: EdgeInsets.symmetric(vertical: isWeb ? 12 : 10)),
                          child: Text('Cancel', style: TextStyle(fontSize: isWeb ? 14 : 12)),
                        ),
                      ),
                      SizedBox(width: isWeb ? 16 : 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              Get.back();
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
                          style: ElevatedButton.styleFrom(backgroundColor: kPrimary, padding: EdgeInsets.symmetric(vertical: isWeb ? 12 : 10)),
                          child: Text('Record Payment', style: TextStyle(fontSize: isWeb ? 14 : 12, color: Colors.white)),
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

  void _showPaymentDetails(PaymentMadeController controller, PaymentMade payment, BuildContext context) {
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
                    decoration: BoxDecoration(color: kDanger.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.payment, size: 28, color: kDanger),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(payment.paymentNumber, style:  TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kText)),
                      Text(DateFormat('EEEE, dd MMM yyyy').format(payment.paymentDate), style:  TextStyle(fontSize: 13, color: kSubText)),
                    ]),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: payment.status == 'Cleared' ? kSuccess.withOpacity(0.1) : kWarning.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(payment.status, style: TextStyle(fontSize: 13, color: payment.status == 'Cleared' ? kSuccess : kWarning, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    _buildDetailRow('Vendor', payment.vendorName, isWeb),
                    _buildDetailRow('Bill', payment.billNumber, isWeb),
                    _buildDetailRow('Bill Amount', controller.formatAmount(payment.billAmount), isWeb),
                    _buildDetailRow('Payment Amount', controller.formatAmount(payment.amount), isWeb),
                    _buildDetailRow('Payment Method', payment.paymentMethod, isWeb),
                    _buildDetailRow('Reference', payment.reference.isEmpty ? '-' : payment.reference, isWeb),
                    _buildDetailRow('Bank Account', payment.bankAccountName.isEmpty ? '-' : payment.bankAccountName, isWeb),
                    _buildDetailRow('Created At', DateFormat('dd MMM yyyy, hh:mm a').format(payment.createdAt), isWeb),
                    if (payment.notes.isNotEmpty) _buildDetailRow('Notes', payment.notes, isWeb),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () { Navigator.pop(ctx); controller.viewBill(payment); },
                      icon: const Icon(Icons.receipt, size: 18),
                      label: const Text('View Bill', style: TextStyle(fontSize: 12)),
                      style: _buttonStyle(kPrimary, isWeb),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () { Navigator.pop(ctx); controller.printVoucher(payment); },
                      icon: const Icon(Icons.print, size: 18),
                      label: const Text('Print Voucher', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
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

  // ==================== HELPER METHODS ====================
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
        final picked = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime.now());
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isWeb ? 16 : 12, vertical: isWeb ? 12 : 10),
        decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(isWeb ? 10 : 8), border: Border.all(color: kBorder)),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: isWeb ? 20 : 16, color: kPrimary),
            SizedBox(width: isWeb ? 12 : 8),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: TextStyle(fontSize: isWeb ? 11 : 10, color: kSubText)),
                Text(DateFormat('dd MMM yyyy').format(date), style: TextStyle(fontSize: isWeb ? 13 : 12, fontWeight: FontWeight.w600, color: kText)),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isWeb) {
    return Padding(
      padding: EdgeInsets.only(bottom: isWeb ? 12 : 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: isWeb ? 120 : 100, child: Text(label, style: TextStyle(fontSize: isWeb ? 13 : 11, color: kSubText, fontWeight: FontWeight.w500))),
          Expanded(child: Text(value, style: TextStyle(fontSize: isWeb ? 13 : 12, color: kText, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}