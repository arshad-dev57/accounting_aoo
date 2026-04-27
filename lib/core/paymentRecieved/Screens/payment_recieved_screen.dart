import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/Utils/responsive_utils.dart';
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
              _buildHeader(context),
              _buildSummaryCards(context),
              _buildFilterBar(context),
              _buildPaymentsList(context),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  // Custom Header without AppBar
  Widget _buildHeader(BuildContext context) {
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
                  'Payments Received',
                  style: TextStyle(
                    fontSize: isWeb ? 20 : 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Track all customer payments',
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
              onPressed: () => _selectDateRange(),
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
                onPressed: () => _showRecordPaymentDialog(context),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Obx(() => Container(
      padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 16 : 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildSummaryCard('Total Received', _formatAmount(controller.totalReceived.value), kSuccess, Icons.attach_money, context, width: isWeb ? 220 : 170),
            SizedBox(width: isWeb ? 16 : 12),
            _buildSummaryCard('This Month', _formatAmount(controller.thisMonth.value), kPrimary, Icons.calendar_month, context, width: isWeb ? 220 : 170),
            SizedBox(width: isWeb ? 16 : 12),
            _buildSummaryCard('This Week', _formatAmount(controller.thisWeek.value), kPrimary, Icons.view_week, context, width: isWeb ? 220 : 170),
            SizedBox(width: isWeb ? 16 : 12),
            _buildSummaryCard('Today', _formatAmount(controller.today.value), kPrimary, Icons.today, context, width: isWeb ? 200 : 160),
            SizedBox(width: isWeb ? 16 : 12),
            _buildSummaryCard('Pending', controller.pendingCount.value.toString(), kWarning, Icons.pending, context, width: isWeb ? 200 : 160, isNumber: true),
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

  Widget _buildFilterBar(BuildContext context) {
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
                    controller: _searchController,
                    style: TextStyle(fontSize: isWeb ? 14 : 12),
                    decoration: InputDecoration(
                      hintText: isWeb ? 'Search by payment ID, customer, invoice, reference...' : 'Search...',
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
                      items: _filterOptions.map((filter) {
                        return DropdownMenuItem(
                          value: filter,
                          child: Text(filter, style: TextStyle(fontSize: isWeb ? 13 : 12)),
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
                        onTap: () => controller.setDateRange(null),
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

  Widget _buildPaymentsList(BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Obx(() {
      final payments = controller.payments;

      if (payments.isEmpty) {
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
                  onPressed: () => _showRecordPaymentDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 12 : 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
                    ),
                  ),
                  child: Text(
                    'Record Payment',
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
              'Payments',
              style: TextStyle(
                fontSize: isWeb ? 18 : 16,
                fontWeight: FontWeight.w700,
                color: kText,
              ),
            ),
          ),
          ...payments.map((payment) => Padding(
            padding: EdgeInsets.symmetric(horizontal: isWeb ? 20 : 12, vertical: isWeb ? 8 : 6),
            child: _buildPaymentCard(payment, context),
          )).toList(),
        ],
      );
    });
  }

  Widget _buildPaymentCard(Payment payment, BuildContext context) {
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
          onTap: () => _showPaymentDetails(payment, context),
          borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
          child: Padding(
            padding: EdgeInsets.all(isWeb ? 16 : 12),
            child: isMobile
                ? _buildMobilePaymentCard(payment, statusColor, statusIcon, context)
                : _buildDesktopPaymentCard(payment, statusColor, statusIcon, context),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopPaymentCard(Payment payment, Color statusColor, IconData statusIcon, BuildContext context) {
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
                color: kSuccess.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
              ),
              child: Icon(Icons.payment, size: isWeb ? 24 : 20, color: kSuccess),
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
                        style: TextStyle(
                          fontSize: isWeb ? 15 : 13,
                          fontWeight: FontWeight.w800,
                          color: kText,
                        ),
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
                              style: TextStyle(
                                fontSize: isWeb ? 11 : 10,
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
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
                  _formatAmount(payment.amount),
                  style: TextStyle(fontSize: isWeb ? 16 : 14, fontWeight: FontWeight.w800, color: kSuccess),
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
                child: _buildInfoItem('Customer', payment.customerName, Icons.person, isWeb),
              ),
              Container(width: 1, height: isWeb ? 32 : 24, color: kBorder),
              Expanded(
                child: _buildInfoItem('Invoice', payment.invoiceNumber, Icons.receipt, isWeb),
              ),
              Container(width: 1, height: isWeb ? 32 : 24, color: kBorder),
              Expanded(
                child: _buildInfoItem('Invoice Amount', _formatAmount(payment.invoiceAmount), Icons.attach_money, isWeb),
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
                onPressed: () => controller.viewInvoice(payment),
                icon: Icon(Icons.receipt, size: isWeb ? 18 : 14),
                label: Text('View Invoice', style: TextStyle(fontSize: isWeb ? 12 : 10)),
                style: _buttonStyle(kPrimary, isWeb),
              ),
            ),
            SizedBox(width: isWeb ? 12 : 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => controller.printReceipt(payment),
                icon: Icon(Icons.print, size: isWeb ? 18 : 14, color: Colors.white),
                label: Text('Print Receipt', style: TextStyle(fontSize: isWeb ? 12 : 10)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
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

  Widget _buildMobilePaymentCard(Payment payment, Color statusColor, IconData statusIcon, BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: kSuccess.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.payment, size: 20, color: kSuccess),
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
                  _formatAmount(payment.amount),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: kSuccess),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInfoItem('Customer', payment.customerName, Icons.person, false),
            ),
            Expanded(
              child: _buildInfoItem('Invoice', payment.invoiceNumber, Icons.receipt, false),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => controller.viewInvoice(payment),
                icon: Icon(Icons.receipt, size: 14),
                label: const Text('Invoice', style: TextStyle(fontSize: 9)),
                style: _buttonStyle(kPrimary, false),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => controller.printReceipt(payment),
                icon: Icon(Icons.print, size: 14, color: Colors.white),
                label: const Text('Receipt', style: TextStyle(fontSize: 9)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
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
                  fontSize: isWeb ? 11 : 9,
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

  void _showRecordPaymentDialog(BuildContext ctx) {
    final isWeb = ResponsiveUtils.isWeb(ctx);
    final formKey = GlobalKey<FormState>();
    String selectedCustomerId = '';
    String selectedInvoiceId = '';
    double amount = 0;
    String paymentMethod = 'Bank Transfer';
    String reference = '';
    String selectedBankAccountId = '';
    String notes = '';

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
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.symmetric(vertical: isWeb ? 16 : 12),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(isWeb ? 12 : 10),
                          decoration: BoxDecoration(
                            color: kSuccess.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
                          ),
                          child: Icon(Icons.payment, size: isWeb ? 24 : 20, color: kSuccess),
                        ),
                        SizedBox(width: isWeb ? 16 : 12),
                        Expanded(
                          child: Text(
                            'Record Payment Received',
                            style: TextStyle(
                              fontSize: isWeb ? 18 : 16,
                              fontWeight: FontWeight.w800,
                              color: kText,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Icon(Icons.close, size: isWeb ? 24 : 20, color: kSubText),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: kBorder, height: 1),
                  SizedBox(height: isWeb ? 16 : 12),
                  
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
                                borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
                                border: Border.all(color: kBorder),
                              ),
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Select Customer *',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: isWeb ? 16 : 12, vertical: isWeb ? 12 : 10),
                                  labelStyle: TextStyle(fontSize: isWeb ? 12 : 11, color: kSubText),
                                ),
                                style: TextStyle(fontSize: isWeb ? 13 : 12, color: kText),
                                icon: Icon(Icons.arrow_drop_down, size: isWeb ? 24 : 20, color: kSubText),
                                value: selectedCustomerId.isEmpty ? null : selectedCustomerId,
                                items: controller.customers.map((customer) {
                                  return DropdownMenuItem(
                                    value: customer.id,
                                    child: Text(
                                      customer.name,
                                      style: TextStyle(fontSize: isWeb ? 13 : 12, color: kText),
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
                            SizedBox(height: isWeb ? 16 : 12),
                            
                            // Invoice Selection
                            Obx(() {
                              if (selectedCustomerId.isNotEmpty && controller.unpaidInvoices.isEmpty) {
                                return Container(
                                  padding: EdgeInsets.all(isWeb ? 16 : 12),
                                  decoration: BoxDecoration(
                                    color: kWarning.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
                                    border: Border.all(color: kWarning.withOpacity(0.3)),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(Icons.info_outline, size: isWeb ? 24 : 20, color: kWarning),
                                      SizedBox(height: isWeb ? 8 : 6),
                                      Text(
                                        'No unpaid invoices found for this customer.',
                                        style: TextStyle(
                                          fontSize: isWeb ? 13 : 12,
                                          color: kWarning,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: isWeb ? 8 : 6),
                                      TextButton(
                                        onPressed: () {
                                          Get.back();
                                          Get.toNamed('/invoices/create', 
                                            arguments: {'customerId': selectedCustomerId});
                                        },
                                        child: Text('Create Invoice First', style: TextStyle(fontSize: isWeb ? 13 : 12, color: kPrimary)),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              
                              return Container(
                                decoration: BoxDecoration(
                                  color: kBg,
                                  borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
                                  border: Border.all(color: kBorder),
                                ),
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    labelText: 'Select Invoice *',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: isWeb ? 16 : 12, vertical: isWeb ? 12 : 10),
                                    labelStyle: TextStyle(fontSize: isWeb ? 12 : 11, color: kSubText),
                                  ),
                                  style: TextStyle(fontSize: isWeb ? 13 : 12, color: kText),
                                  icon: Icon(Icons.arrow_drop_down, size: isWeb ? 24 : 20, color: kSubText),
                                  value: selectedInvoiceId.isEmpty ? null : selectedInvoiceId,
                                  items: controller.unpaidInvoices.map((invoice) {
                                    return DropdownMenuItem(
                                      value: invoice.id,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            invoice.invoiceNumber,
                                            style: TextStyle(fontSize: isWeb ? 13 : 12, fontWeight: FontWeight.w600, color: kText),
                                          ),
                                          Text(
                                            'Amount: ${_formatAmount(invoice.outstanding)} • Due: ${DateFormat('dd MMM yyyy').format(invoice.dueDate)}',
                                            style: TextStyle(fontSize: isWeb ? 10 : 9, color: kSubText),
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
                            SizedBox(height: isWeb ? 16 : 12),
                            
                            // Amount
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Payment Amount *',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(isWeb ? 12 : 10)),
                                prefixText: '₨ ',
                                labelStyle: TextStyle(fontSize: isWeb ? 12 : 11, color: kSubText),
                              ),
                              style: TextStyle(fontSize: isWeb ? 13 : 12, color: kText),
                              keyboardType: TextInputType.number,
                              initialValue: amount > 0 ? amount.toString() : '',
                              onChanged: (value) => amount = double.tryParse(value) ?? 0,
                              validator: (value) => value == null || value.isEmpty ? 'Amount required' : null,
                            ),
                            SizedBox(height: isWeb ? 16 : 12),
                            
                            // Payment Method
                            Container(
                              decoration: BoxDecoration(
                                color: kBg,
                                borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
                                border: Border.all(color: kBorder),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: paymentMethod,
                                decoration: InputDecoration(
                                  labelText: 'Payment Method *',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: isWeb ? 16 : 12, vertical: isWeb ? 12 : 10),
                                  labelStyle: TextStyle(fontSize: isWeb ? 12 : 11, color: kSubText),
                                ),
                                style: TextStyle(fontSize: isWeb ? 13 : 12, color: kText),
                                icon: Icon(Icons.arrow_drop_down, size: isWeb ? 24 : 20, color: kSubText),
                                items: const [
                                  DropdownMenuItem(value: 'Bank Transfer', child: Text('Bank Transfer')),
                                  DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                                  DropdownMenuItem(value: 'Cheque', child: Text('Cheque')),
                                  DropdownMenuItem(value: 'Credit Card', child: Text('Credit Card')),
                                ],
                                onChanged: (value) => paymentMethod = value!,
                              ),
                            ),
                            SizedBox(height: isWeb ? 16 : 12),
                            
                            // Reference
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Reference Number',
                                hintText: 'e.g., TRX-001, CHQ-123',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(isWeb ? 12 : 10)),
                                labelStyle: TextStyle(fontSize: isWeb ? 12 : 11, color: kSubText),
                              ),
                              style: TextStyle(fontSize: isWeb ? 13 : 12, color: kText),
                              onChanged: (value) => reference = value,
                            ),
                            SizedBox(height: isWeb ? 16 : 12),
                            
                            // Bank Account
                            if (paymentMethod == 'Bank Transfer')
                              Obx(() => Container(
                                decoration: BoxDecoration(
                                  color: kBg,
                                  borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
                                  border: Border.all(color: kBorder),
                                ),
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    labelText: 'Deposit To',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: isWeb ? 16 : 12, vertical: isWeb ? 12 : 10),
                                    labelStyle: TextStyle(fontSize: isWeb ? 12 : 11, color: kSubText),
                                  ),
                                  style: TextStyle(fontSize: isWeb ? 13 : 12, color: kText),
                                  icon: Icon(Icons.arrow_drop_down, size: isWeb ? 24 : 20, color: kSubText),
                                  value: selectedBankAccountId.isEmpty ? null : selectedBankAccountId,
                                  items: controller.bankAccounts.map((account) {
                                    return DropdownMenuItem(
                                      value: account.id,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            account.name,
                                            style: TextStyle(fontSize: isWeb ? 13 : 12, fontWeight: FontWeight.w600, color: kText),
                                          ),
                                          Text(
                                            '${account.number} • Balance: ${_formatAmount(account.balance)}',
                                            style: TextStyle(fontSize: isWeb ? 10 : 9, color: kSubText),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) => selectedBankAccountId = value!,
                                ),
                              )),
                            SizedBox(height: isWeb ? 16 : 12),
                            
                            // Notes
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Notes',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(isWeb ? 12 : 10)),
                                labelStyle: TextStyle(fontSize: isWeb ? 12 : 11, color: kSubText),
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
                  
                  SizedBox(height: isWeb ? 16 : 12),
                  Divider(color: kBorder, height: 1),
                  SizedBox(height: isWeb ? 16 : 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kSubText,
                            side: BorderSide(color: kBorder),
                            padding: EdgeInsets.symmetric(vertical: isWeb ? 12 : 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isWeb ? 12 : 10)),
                          ),
                          child: Text('Cancel', style: TextStyle(fontSize: isWeb ? 14 : 12)),
                        ),
                      ),
                      SizedBox(width: isWeb ? 16 : 12),
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
                            padding: EdgeInsets.symmetric(vertical: isWeb ? 12 : 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isWeb ? 12 : 10)),
                          ),
                          child: controller.isRecording.value
                              ? SizedBox(
                                  width: isWeb ? 20 : 16,
                                  height: isWeb ? 20 : 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: isWeb ? 2 : 1.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text('Record Payment', style: TextStyle(fontSize: isWeb ? 14 : 12, fontWeight: FontWeight.w600)),
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

  void _showPaymentDetails(Payment payment, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    if (isWeb) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            child: _buildPaymentDetailsContent(payment, ctx),
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
          child: _buildPaymentDetailsContent(payment, ctx),
        ),
      );
    }
  }

  Widget _buildPaymentDetailsContent(Payment payment, BuildContext ctx) {
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
                color: kSuccess.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isWeb ? 14 : 10),
              ),
              child: Icon(Icons.payment, size: isWeb ? 28 : 24, color: kSuccess),
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
              _buildDetailRow('Customer', payment.customerName, isWeb),
              _buildDetailRow('Invoice', payment.invoiceNumber, isWeb),
              _buildDetailRow('Invoice Amount', _formatAmount(payment.invoiceAmount), isWeb),
              _buildDetailRow('Payment Amount', _formatAmount(payment.amount), isWeb),
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
                  controller.viewInvoice(payment);
                },
                icon: Icon(Icons.receipt, size: isWeb ? 20 : 16),
                label: Text('View Invoice', style: TextStyle(fontSize: isWeb ? 14 : 12)),
                style: _buttonStyle(kPrimary, isWeb),
              ),
            ),
            SizedBox(width: isWeb ? 12 : 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  controller.printReceipt(payment);
                },
                icon: Icon(Icons.print, size: isWeb ? 20 : 16),
                label: Text('Print Receipt', style: TextStyle(fontSize: isWeb ? 14 : 12)),
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