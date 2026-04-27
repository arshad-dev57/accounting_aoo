import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/Utils/responsive_utils.dart';
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
    
    return Container(
      color: kBg,
      child: Obx(() {
        if (controller.isLoading.value && controller.payments.isEmpty) {
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
              _buildPaymentsList(controller, context),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  // Custom Header without AppBar
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
                ),
              ],
            ),
          ),
          // Calendar Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.calendar_today_outlined, color: Colors.white, size: isWeb ? 22 : 20),
              onPressed: () => controller.selectDateRange(),
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
              onPressed: () => controller.exportPayments(),
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
                onPressed: () => _showRecordPaymentDialog(controller, context),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(PaymentMadeController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 16 : 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Obx(() => _buildSummaryCard(
              'Total Paid',
              controller.formatAmount(controller.totalPaid.value),
              kDanger,
              Icons.payment,
              context,
              width: isWeb ? 220 : 170,
            )),
            SizedBox(width: isWeb ? 16 : 12),
            Obx(() => _buildSummaryCard(
              'This Month',
              controller.formatAmount(controller.thisMonthTotal.value),
              kPrimary,
              Icons.calendar_month,
              context,
              width: isWeb ? 220 : 170,
            )),
            SizedBox(width: isWeb ? 16 : 12),
            Obx(() => _buildSummaryCard(
              'This Week',
              controller.formatAmount(controller.thisWeekTotal.value),
              kPrimary,
              Icons.view_week,
              context,
              width: isWeb ? 220 : 170,
            )),
            SizedBox(width: isWeb ? 16 : 12),
            Obx(() => _buildSummaryCard(
              'Today',
              controller.formatAmount(controller.todayTotal.value),
              kPrimary,
              Icons.today,
              context,
              width: isWeb ? 200 : 160,
            )),
            SizedBox(width: isWeb ? 16 : 12),
            Obx(() => _buildSummaryCard(
              'Pending',
              controller.pendingCount.value.toString(),
              kWarning,
              Icons.pending,
              context,
              width: isWeb ? 200 : 160,
              isNumber: true,
            )),
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

  Widget _buildFilterBar(PaymentMadeController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 12 : 10),
      color: kCardBg,
      child: Column(
        children: [
          Row(
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
              Expanded(
                flex: isWeb ? 2 : 1,
                child: Container(
                  height: isWeb ? 45 : 40,
                  decoration: BoxDecoration(
                    color: kBg,
                    borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
                    border: Border.all(color: kBorder),
                  ),
                  child: Obx(() => DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedFilter.value,
                      icon: Icon(Icons.arrow_drop_down, size: isWeb ? 24 : 20, color: kText),
                      padding: EdgeInsets.symmetric(horizontal: isWeb ? 16 : 12),
                      isExpanded: true,
                      style: TextStyle(fontSize: isWeb ? 13 : 12, color: kText),
                      dropdownColor: kCardBg,
                      items: controller.filterOptions.map((filter) {
                        return DropdownMenuItem(
                          value: filter,
                          child: Text(filter, style: TextStyle(color: kText, fontSize: isWeb ? 13 : 12)),
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
              final range = controller.selectedDateRange.value!;
              return Padding(
                padding: EdgeInsets.only(top: isWeb ? 12 : 8),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: isWeb ? 16 : 12, vertical: isWeb ? 12 : 10),
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isWeb ? 10 : 8),
                  ),
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
                                style: TextStyle(
                                  fontSize: isWeb ? 12 : 11,
                                  color: kPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
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
    );
  }

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
              Text(
                'No payments found',
                style: TextStyle(fontSize: isWeb ? 18 : 16, color: kSubText),
              ),
              SizedBox(height: isWeb ? 20 : 16),
              ElevatedButton(
                onPressed: () => _showRecordPaymentDialog(controller, context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 12 : 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
                  ),
                ),
                child: Text(
                  'Record Payment',
                  style: TextStyle(fontSize: isWeb ? 14 : 12, fontWeight: FontWeight.w600, color: Colors.white),
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
            'Payments',
            style: TextStyle(
              fontSize: isWeb ? 18 : 16,
              fontWeight: FontWeight.w700,
              color: kText,
            ),
          ),
        ),
        ...controller.payments.map((payment) => Padding(
          padding: EdgeInsets.symmetric(horizontal: isWeb ? 20 : 12, vertical: isWeb ? 8 : 6),
          child: _buildPaymentCard(controller, payment, context),
        )).toList(),
      ],
    );
  }

  Widget _buildPaymentCard(PaymentMadeController controller, PaymentMade payment, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final isMobile = ResponsiveUtils.isMobile(context);
    
    Color statusColor = payment.status == 'Cleared' ? kSuccess : kWarning;
    IconData statusIcon = payment.status == 'Cleared' ? Icons.check_circle : Icons.pending;
    
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
          onTap: () => _showPaymentDetails(controller, payment, context),
          borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
          child: Padding(
            padding: EdgeInsets.all(isWeb ? 16 : 12),
            child: isMobile
                ? _buildMobilePaymentCard(controller, payment, statusColor, statusIcon, context)
                : _buildDesktopPaymentCard(controller, payment, statusColor, statusIcon, context),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopPaymentCard(PaymentMadeController controller, PaymentMade payment, Color statusColor, IconData statusIcon, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: isWeb ? 50 : 44,
              height: isWeb ? 50 : 44,
              decoration: BoxDecoration(
                color: kDanger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
              ),
              child: Icon(Icons.payment, size: isWeb ? 24 : 20, color: kDanger),
            ),
            SizedBox(width: isWeb ? 16 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        payment.paymentNumber,
                        style: TextStyle(fontSize: isWeb ? 15 : 13, fontWeight: FontWeight.w800, color: kText),
                      ),
                      SizedBox(width: isWeb ? 8 : 6),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: isWeb ? 8 : 6, vertical: isWeb ? 4 : 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(isWeb ? 6 : 4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: isWeb ? 14 : 10, color: statusColor),
                            SizedBox(width: isWeb ? 4 : 2),
                            Text(
                              payment.status,
                              style: TextStyle(fontSize: isWeb ? 11 : 10, color: statusColor, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isWeb ? 4 : 2),
                  Text(
                    DateFormat('EEEE, dd MMM yyyy').format(payment.paymentDate),
                    style: TextStyle(fontSize: isWeb ? 12 : 11, color: kSubText),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Amount',
                  style: TextStyle(fontSize: isWeb ? 11 : 10, color: kSubText, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: isWeb ? 4 : 2),
                Text(
                  controller.formatAmount(payment.amount),
                  style: TextStyle(fontSize: isWeb ? 16 : 14, fontWeight: FontWeight.w800, color: kDanger),
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
                child: _buildInfoItem('Vendor', payment.vendorName, Icons.business, isWeb),
              ),
              Container(width: 1, height: isWeb ? 32 : 24, color: kBorder),
              Expanded(
                child: _buildInfoItem('Bill', payment.billNumber, Icons.receipt, isWeb),
              ),
              Container(width: 1, height: isWeb ? 32 : 24, color: kBorder),
              Expanded(
                child: _buildInfoItem('Bill Amount', controller.formatAmount(payment.billAmount), Icons.attach_money, isWeb),
              ),
            ],
          ),
        ),
        SizedBox(height: isWeb ? 8 : 6),
        Container(
          padding: EdgeInsets.symmetric(vertical: isWeb ? 10 : 8),
          child: Row(
            children: [
              Expanded(
                child: _buildInfoItem('Payment Method', payment.paymentMethod, Icons.credit_card, isWeb),
              ),
              Container(width: 1, height: isWeb ? 32 : 24, color: kBorder),
              Expanded(
                child: _buildInfoItem('Reference', payment.reference.isEmpty ? '-' : payment.reference, Icons.receipt_long, isWeb),
              ),
              Container(width: 1, height: isWeb ? 32 : 24, color: kBorder),
              Expanded(
                child: _buildInfoItem('Bank Account', payment.bankAccountName.isEmpty ? '-' : payment.bankAccountName, Icons.account_balance, isWeb),
              ),
            ],
          ),
        ),
        if (payment.notes.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: isWeb ? 8 : 6),
            child: Container(
              padding: EdgeInsets.all(isWeb ? 12 : 10),
              decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(isWeb ? 10 : 8)),
              child: Row(
                children: [
                  Icon(Icons.note, size: isWeb ? 18 : 14, color: kSubText),
                  SizedBox(width: isWeb ? 8 : 6),
                  Expanded(
                    child: Text(
                      payment.notes,
                      style: TextStyle(fontSize: isWeb ? 12 : 11, color: kSubText),
                    ),
                  ),
                ],
              ),
            ),
          ),
        SizedBox(height: isWeb ? 16 : 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => controller.viewBill(payment),
                icon: Icon(Icons.receipt, size: isWeb ? 18 : 14, color: kPrimary),
                label: Text('View Bill', style: TextStyle(fontSize: isWeb ? 12 : 10, color: kPrimary)),
                style: _buttonStyle(kPrimary, isWeb),
              ),
            ),
            SizedBox(width: isWeb ? 12 : 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => controller.printVoucher(payment),
                icon: Icon(Icons.print, size: isWeb ? 18 : 14, color: Colors.white),
                label: Text('Print Voucher', style: TextStyle(fontSize: isWeb ? 12 : 10, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  padding: EdgeInsets.symmetric(vertical: isWeb ? 10 : 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isWeb ? 8 : 6)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobilePaymentCard(PaymentMadeController controller, PaymentMade payment, Color statusColor, IconData statusIcon, BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: kDanger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.payment, size: 20, color: kDanger),
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
                          payment.paymentNumber,
                          style:  TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: kText),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 10, color: statusColor),
                            const SizedBox(width: 2),
                            Text(
                              payment.status,
                              style: TextStyle(fontSize: 9, color: statusColor, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('dd MMM yyyy').format(payment.paymentDate),
                    style:  TextStyle(fontSize: 10, color: kSubText),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                 Text('Amount', style: TextStyle(fontSize: 9, color: kSubText)),
                const SizedBox(height: 2),
                Text(
                  controller.formatAmount(payment.amount),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: kDanger),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInfoItem('Vendor', payment.vendorName, Icons.business, false),
            ),
            Expanded(
              child: _buildInfoItem('Bill', payment.billNumber, Icons.receipt, false),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => controller.viewBill(payment),
                icon: Icon(Icons.receipt, size: 14, color: kPrimary),
                label: const Text('Bill', style: TextStyle(fontSize: 9, color: kPrimary)),
                style: _buttonStyle(kPrimary, false),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => controller.printVoucher(payment),
                icon: Icon(Icons.print, size: 14, color: Colors.white),
                label: const Text('Voucher', style: TextStyle(fontSize: 9, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ),
          ],
        ),
      ],
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
              Text(
                label,
                style: TextStyle(
                  fontSize: isWeb ? 11 : 8,
                  color: kSubText,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: isWeb ? 11 : 9,
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

  ButtonStyle _buttonStyle(Color color, bool isWeb) {
    return OutlinedButton.styleFrom(
      foregroundColor: color,
      side: BorderSide(color: color),
      padding: EdgeInsets.symmetric(vertical: isWeb ? 10 : 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isWeb ? 8 : 6)),
    );
  }

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
              width: isWeb ? 600 : double.infinity,
              constraints: BoxConstraints(maxHeight: isWeb ? 700 : 600),
              padding: EdgeInsets.all(isWeb ? 24 : 20),
              child: Column(
                children: [
                  Text(
                    'Record Payment Made',
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
                            // Payment Date
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text('Payment Date', style: TextStyle(fontSize: isWeb ? 13 : 12)),
                              subtitle: Text(
                                DateFormat('dd MMM yyyy').format(paymentDate),
                                style: TextStyle(fontSize: isWeb ? 14 : 13, color: kText),
                              ),
                              trailing: Icon(Icons.calendar_today, color: kPrimary, size: isWeb ? 24 : 20),
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
                            SizedBox(height: isWeb ? 16 : 12),
                            // Vendor Selection
                            Obx(() => DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Select Vendor *',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(isWeb ? 12 : 10)),
                                labelStyle: TextStyle(fontSize: isWeb ? 12 : 11),
                              ),
                              style: TextStyle(fontSize: isWeb ? 13 : 12, color: kText),
                              dropdownColor: kCardBg,
                              value: selectedVendorId.isEmpty ? null : selectedVendorId,
                              items: controller.vendors.map((vendor) {
                                return DropdownMenuItem(
                                  value: vendor.id,
                                  child: Text(vendor.name, style: TextStyle(color: kText, fontSize: isWeb ? 13 : 12)),
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
                            SizedBox(height: isWeb ? 16 : 12),
                            
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
                                  return Center(
                                    child: LoadingAnimationWidget.waveDots(
                                      color: kPrimary,
                                      size: isWeb ? 40 : 30,
                                    ),
                                  );
                                }

                                final bills = snapshot.data ?? [];

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        labelText: 'Select Bill *',
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(isWeb ? 12 : 10)),
                                        labelStyle: TextStyle(fontSize: isWeb ? 12 : 11),
                                      ),
                                      style: TextStyle(fontSize: isWeb ? 13 : 12, color: kText),
                                      dropdownColor: kCardBg,
                                      value: selectedBillId.isEmpty ? null : selectedBillId,
                                      items: bills.map((bill) {
                                        return DropdownMenuItem<String>(
                                          value: bill.id,
                                          child: Text(
                                            '${bill.billNumber} • ${controller.formatAmount(bill.outstanding)}',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: TextStyle(color: kText, fontSize: isWeb ? 13 : 12),
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
                                    SizedBox(height: isWeb ? 12 : 8),
                                    if (selectedBillId.isNotEmpty)
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(isWeb ? 12 : 10),
                                        decoration: BoxDecoration(
                                          color: kCardBg,
                                          borderRadius: BorderRadius.circular(isWeb ? 10 : 8),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Bill: ${bills.firstWhere((b) => b.id == selectedBillId).billNumber}',
                                              style: TextStyle(color: kText, fontWeight: FontWeight.w600, fontSize: isWeb ? 13 : 12),
                                            ),
                                            Text(
                                              'Total: ${controller.formatAmount(bills.firstWhere((b) => b.id == selectedBillId).totalAmount)}',
                                              style: TextStyle(fontSize: isWeb ? 11 : 10, color: kSubText),
                                            ),
                                            Text(
                                              'Outstanding: ${controller.formatAmount(bills.firstWhere((b) => b.id == selectedBillId).outstanding)}',
                                              style: TextStyle(fontSize: isWeb ? 11 : 10, color: kSubText),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                            SizedBox(height: isWeb ? 16 : 12),
                            
                            // Amount
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Amount *',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(isWeb ? 12 : 10)),
                                labelStyle: TextStyle(fontSize: isWeb ? 12 : 11),
                                prefixText: '₨ ',
                              ),
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
                              decoration: InputDecoration(
                                labelText: 'Payment Method *',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(isWeb ? 12 : 10)),
                                labelStyle: TextStyle(fontSize: isWeb ? 12 : 11),
                              ),
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
                              decoration: InputDecoration(
                                labelText: 'Reference Number',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(isWeb ? 12 : 10)),
                                labelStyle: TextStyle(fontSize: isWeb ? 12 : 11),
                              ),
                              style: TextStyle(fontSize: isWeb ? 13 : 12, color: kText),
                              onChanged: (value) => reference = value,
                            ),
                            SizedBox(height: isWeb ? 16 : 12),
                            
                            // Notes
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Notes',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(isWeb ? 12 : 10)),
                                labelStyle: TextStyle(fontSize: isWeb ? 12 : 11),
                              ),
                              style: TextStyle(fontSize: isWeb ? 13 : 12, color: kText),
                              maxLines: 2,
                              onChanged: (value) => notes = value,
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isWeb ? 12 : 10)),
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
                            padding: EdgeInsets.symmetric(vertical: isWeb ? 12 : 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isWeb ? 12 : 10)),
                          ),
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
    
    if (isWeb) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            child: _buildPaymentDetailsContent(controller, payment, ctx),
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
          child: _buildPaymentDetailsContent(controller, payment, ctx),
        ),
      );
    }
  }

  Widget _buildPaymentDetailsContent(PaymentMadeController controller, PaymentMade payment, BuildContext ctx) {
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
                color: kDanger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isWeb ? 14 : 10),
              ),
              child: Icon(Icons.payment, size: isWeb ? 28 : 24, color: kDanger),
            ),
            SizedBox(width: isWeb ? 16 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payment.paymentNumber,
                    style: TextStyle(fontSize: isWeb ? 18 : 16, fontWeight: FontWeight.w800, color: kText),
                  ),
                  Text(
                    DateFormat('EEEE, dd MMM yyyy').format(payment.paymentDate),
                    style: TextStyle(fontSize: isWeb ? 13 : 12, color: kSubText),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: isWeb ? 12 : 10, vertical: isWeb ? 6 : 4),
              decoration: BoxDecoration(
                color: payment.status == 'Cleared' ? kSuccess.withOpacity(0.1) : kWarning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isWeb ? 8 : 6),
              ),
              child: Text(
                payment.status,
                style: TextStyle(
                  fontSize: isWeb ? 13 : 12,
                  color: payment.status == 'Cleared' ? kSuccess : kWarning,
                  fontWeight: FontWeight.w600,
                ),
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
        SizedBox(height: isWeb ? 20 : 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  controller.viewBill(payment);
                },
                icon: Icon(Icons.receipt, size: isWeb ? 20 : 16),
                label: Text('View Bill', style: TextStyle(fontSize: isWeb ? 14 : 12)),
                style: _buttonStyle(kPrimary, isWeb),
              ),
            ),
            SizedBox(width: isWeb ? 12 : 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  controller.printVoucher(payment);
                },
                icon: Icon(Icons.print, size: isWeb ? 20 : 16),
                label: Text('Print Voucher', style: TextStyle(fontSize: isWeb ? 14 : 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  padding: EdgeInsets.symmetric(vertical: isWeb ? 12 : 10),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, bool isWeb) {
    return Padding(
      padding: EdgeInsets.only(bottom: isWeb ? 12 : 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isWeb ? 120 : 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: isWeb ? 13 : 11,
                color: kSubText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isWeb ? 13 : 12,
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