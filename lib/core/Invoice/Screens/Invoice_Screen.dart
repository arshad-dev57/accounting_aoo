import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/Utils/toast_utils.dart';
import 'package:LedgerPro_app/core/Invoice/controller/invoice_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InvoiceController());

    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(controller),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }
        return Column(
          children: [
            _buildSummaryCards(controller),
            _buildFilterBar(controller),
            Expanded(child: _buildInvoicesList(controller)),
          ],
        );
      }),
      floatingActionButton: _buildFAB(controller),
    );
  }

  // ─── Loading State ───────────────────────────────────────────────
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: kPrimary, strokeWidth: 3),
          SizedBox(height: 2.h),
          Text(
            'Loading invoices...',
            style: TextStyle(
              fontSize: 14.sp,
              color: kSubText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ─── AppBar ──────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(InvoiceController controller) {
    return AppBar(
      title: Text(
        'Invoices',
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
          icon: Icon(Icons.filter_alt_outlined, color: Colors.white, size: 5.w),
          onPressed: () => _showFilterDialog(controller),
        ),
        IconButton(
          icon: Icon(Icons.download_outlined, color: Colors.white),
          onPressed: () => controller.exportInvoices(),
        ),
      ],
    );
  }

  // ─── Summary Cards ───────────────────────────────────────────────
  Widget _buildSummaryCards(InvoiceController controller) {
    return Obx(() => Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
          child: Row(
            children: [
              _buildSummaryCard(
                'Total',
                controller.totalAmount.value.toDouble(),
                kPrimary,
                Icons.receipt_long,
              ),
              SizedBox(width: 3.w),
              _buildSummaryCard(
                'Paid',
                controller.totalPaid.value.toDouble(),
                kSuccess,
                Icons.check_circle_outline,
              ),
              SizedBox(width: 3.w),
              _buildSummaryCard(
                'Outstanding',
                controller.totalOutstanding.value.toDouble(),
                kDanger,
                Icons.pending_outlined,
              ),
            ],
          ),
        ));
  }

  Widget _buildSummaryCard(
      String title, double amount, Color color, IconData icon) {
    return Expanded(
      child: Container(
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
              _formatAmount(amount),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Filter Bar ──────────────────────────────────────────────────
  Widget _buildFilterBar(InvoiceController controller) {
    return Container(
      width: 100.w,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      color: kCardBg,
      child: Row(
        children: [
          Expanded(
            child: _dropdownContainer(
              child: Obx(() => DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedFilter.value,
                      icon: Icon(Icons.arrow_drop_down, size: 5.w),
                      isExpanded: true,
                      style: TextStyle(fontSize: 12.sp, color: kText),
                      items: const [
                        DropdownMenuItem(value: 'All', child: Text('All')),
                        DropdownMenuItem(value: 'Unpaid', child: Text('Unpaid')),
                        DropdownMenuItem(value: 'Paid', child: Text('Paid')),
                        DropdownMenuItem(value: 'Overdue', child: Text('Overdue')),
                        DropdownMenuItem(value: 'Partial', child: Text('Partial')),
                      ],
                      onChanged: (value) {
                        if (value != null) controller.changeFilter(value);
                      },
                    ),
                  )),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: _dropdownContainer(
              child: Obx(() => DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedCustomerId.value.isEmpty
                          ? null
                          : controller.selectedCustomerId.value,
                      icon: Icon(Icons.arrow_drop_down, size: 5.w),
                      isExpanded: true,
                      hint: Text('All Customers',
                          style: TextStyle(fontSize: 12.sp, color: kSubText)),
                      style: TextStyle(fontSize: 12.sp, color: kText),
                      items: [
                        const DropdownMenuItem(
                          value: '',
                          child: Text('All Customers'),
                        ),
                        ...controller.customers.map((customer) {
                          return DropdownMenuItem(
                            value: customer['_id']?.toString() ?? '',
                            child: Text(customer['name'] ?? ''),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        if (value != null) controller.filterByCustomer(value);
                      },
                    ),
                  )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdownContainer({required Widget child}) {
    return Container(
      height: 6.h,
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      decoration: BoxDecoration(
        color: kBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: child,
    );
  }

  // ─── Invoices List ───────────────────────────────────────────────
  Widget _buildInvoicesList(InvoiceController controller) {
    return Obx(() {
      final invoices = controller.invoices;

      if (invoices.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_outlined,
                  size: 15.w, color: kSubText.withOpacity(0.4)),
              SizedBox(height: 2.h),
              Text(
                'No invoices found',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: kSubText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              ElevatedButton.icon(
                onPressed: () =>
                    _showCreateInvoiceDialog(Get.context!, controller),
                icon: Icon(Icons.add, size: 4.w),
                label: Text('Create Invoice',
                    style: TextStyle(
                        fontSize: 14.sp, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  padding:
                      EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(4.w),
        itemCount: invoices.length,
        itemBuilder: (context, index) {
          final invoice = invoices[index];
          return _buildInvoiceCard(invoice, controller);
        },
      );
    });
  }

  // ─── Invoice List Card ───────────────────────────────────────────
  Widget _buildInvoiceCard(Invoice invoice, InvoiceController controller) {
    Color statusColor = invoice.status == 'Paid'
        ? kSuccess
        : invoice.status == 'Overdue'
            ? kDanger
            : invoice.status == 'Partial'
                ? kWarning
                : kPrimary;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showInvoiceDetails(invoice, controller),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 13.w,
                      height: 13.w,
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.receipt, size: 6.5.w, color: statusColor),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                invoice.invoiceNumber,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w800,
                                  color: kText,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              _statusBadge(invoice.status, statusColor),
                            ],
                          ),
                          SizedBox(height: 0.4.h),
                          Text(
                            invoice.customerName,
                            style: TextStyle(fontSize: 12.sp, color: kSubText),
                          ),
                          SizedBox(height: 0.3.h),
                          Text(
                            'Due: ${DateFormat('dd MMM yyyy').format(invoice.dueDate)}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: invoice.isOverdue ? kDanger : kSubText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatAmount(invoice.totalAmount),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: kText,
                          ),
                        ),
                        SizedBox(height: 0.3.h),
                        if (invoice.paidAmount > 0)
                          Text(
                            'Paid: ${_formatAmount(invoice.paidAmount)}',
                            style: TextStyle(fontSize: 12.sp, color: kSuccess),
                          ),
                        if (invoice.outstanding > 0)
                          Text(
                            'Due: ${_formatAmount(invoice.outstanding)}',
                            style: TextStyle(
                              fontSize: 12.sp, 
                              color: kDanger,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        if (invoice.status == 'Paid')
                          Text(
                            'Fully Paid',
                            style: TextStyle(
                              fontSize: 12.sp, 
                              color: kSuccess,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                if (invoice.items.isNotEmpty) ...[
                  SizedBox(height: 1.5.h),
                  Divider(color: kBorder, height: 1),
                  SizedBox(height: 1.h),
                  _buildInvoiceItemsPreview(invoice.items),
                ],
                SizedBox(height: 1.5.h),
                Row(
                  children: [
                    if (invoice.status != 'Paid')
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _recordPayment(invoice, controller),
                          icon: Icon(Icons.payment, size: 4.w),
                          label: Text(
                            'Record Payment',
                            style: TextStyle(fontSize: 12.sp),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kSuccess,
                            side: BorderSide(color: kSuccess, width: 1),
                            padding: EdgeInsets.symmetric(vertical: 1.2.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    if (invoice.status != 'Paid') SizedBox(width: 2.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showInvoiceDetails(invoice, controller),
                        icon: Icon(Icons.visibility_outlined, size: 4.w),
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
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(String status, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12.sp,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildInvoiceItemsPreview(List<InvoiceItem> items) {
    return Column(
      children: items.take(2).map((item) {
        return Padding(
          padding: EdgeInsets.only(bottom: 0.8.h),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  item.description,
                  style: TextStyle(fontSize: 12.sp, color: kSubText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${item.quantity} x ${_formatAmount(item.unitPrice)}',
                style: TextStyle(fontSize: 12.sp, color: kSubText),
              ),
              SizedBox(width: 2.w),
              Text(
                _formatAmount(item.amount),
                style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: kText),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ─── FAB ─────────────────────────────────────────────────────────
  Widget _buildFAB(InvoiceController controller) {
    return Obx(() => FloatingActionButton.extended(
          onPressed: controller.isCreating.value
              ? null
              : () => _showCreateInvoiceDialog(Get.context!, controller),
          backgroundColor: kPrimary,
          icon: controller.isCreating.value
              ? SizedBox(
                  width: 4.w,
                  height: 4.w,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : Icon(Icons.add, color: Colors.white, size: 5.w),
          label: Text(
            controller.isCreating.value ? 'Creating...' : 'New Invoice',
            style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600),
          ),
          elevation: 3,
        ));
  }

  // ─── Professional Invoice Detail Dialog ──────────────────────────
  void _showInvoiceDetails(Invoice invoice, InvoiceController controller) {
    Color statusColor = invoice.status == 'Paid'
        ? kSuccess
        : invoice.status == 'Overdue'
            ? kDanger
            : invoice.status == 'Partial'
                ? kWarning
                : kPrimary;

    showDialog(
      context: Get.context!,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        insetPadding:
            EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(maxHeight: 90.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Colored Header ──────────────────────────────────
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 5.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: kPrimary,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.receipt_long,
                        color: Colors.white, size: 6.w),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'INVOICE',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white60,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            invoice.invoiceNumber,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _statusBadgeWhite(invoice.status),
                    SizedBox(width: 2.w),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close,
                          color: Colors.white, size: 5.w),
                    ),
                  ],
                ),
              ),

              // ── Scrollable Body ─────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(5.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info Table
                      _infoTable([
                        ['Customer', invoice.customerName],
                        [
                          'Issue Date',
                          DateFormat('dd/MM/yyyy').format(invoice.date)
                        ],
                        [
                          'Due Date',
                          DateFormat('dd/MM/yyyy').format(invoice.dueDate)
                        ],
                        ['Status', invoice.status],
                      ], statusColor),
                      SizedBox(height: 2.h),

                      // Items Table
                      _tableHeader(),
                      ...invoice.items.map((item) => _tableRow(item)),

                      SizedBox(height: 1.h),
                      Divider(color: kBorder, thickness: 1),

                      // Totals
                      _totalRow('Sub Total', invoice.subtotal),
                      if (invoice.taxTotal > 0)
                        _totalRow(
                            'VAT / Tax (${_taxPercent(invoice)}%)',
                            invoice.taxTotal,
                            color: kSubText),
                      if (invoice.discount > 0)
                        _totalRow('Discount', invoice.discount,
                            isNegative: true, color: kDanger),
                      Divider(color: kBorder, thickness: 1),
                      _totalRow('Total', invoice.totalAmount,
                          isBold: true),
                      _totalRow('Amount Paid', invoice.paidAmount,
                          color: kSuccess),

                      // Balance Due highlighted box
                      Container(
                        margin: EdgeInsets.only(top: 1.h),
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 1.8.h),
                        decoration: BoxDecoration(
                          color: invoice.outstanding > 0
                              ? kDanger.withOpacity(0.07)
                              : kSuccess.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: invoice.outstanding > 0
                                ? kDanger.withOpacity(0.3)
                                : kSuccess.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Balance Due',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w800,
                                color: invoice.outstanding > 0
                                    ? kDanger
                                    : kSuccess,
                              ),
                            ),
                            Text(
                              _formatAmount(invoice.outstanding),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w800,
                                color: invoice.outstanding > 0
                                    ? kDanger
                                    : kSuccess,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Notes
                      if (invoice.notes.isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: kBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: kBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notes',
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: kText),
                              ),
                              SizedBox(height: 0.8.h),
                              Text(invoice.notes,
                                  style: TextStyle(
                                      fontSize: 12.sp, color: kSubText)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // ── Footer Buttons ──────────────────────────────────
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 5.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: kCardBg,
                  border: Border(top: BorderSide(color: kBorder)),
                  borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    // Export Button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _exportSingleInvoice(invoice, controller);
                        },
                        icon: Icon(Icons.download_outlined, size: 4.5.w),
                        label: Text('Export', style: TextStyle(fontSize: 12.sp)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kWarning,
                          side: BorderSide(color: kWarning),
                          padding: EdgeInsets.symmetric(vertical: 1.4.h),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                 
                    if (invoice.status != 'Paid') ...[
                      SizedBox(width: 3.w),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _recordPayment(invoice, controller);
                          },
                          icon: Icon(Icons.payment, size: 4.5.w),
                          label: Text('Record Payment',
                              style: TextStyle(fontSize: 12.sp)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kSuccess,
                            padding: EdgeInsets.symmetric(vertical: 1.4.h),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Invoice Table Helpers ────────────────────────────────────────

  Widget _infoTable(List<List<String>> rows, Color statusColor) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: kBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: rows.asMap().entries.map((entry) {
          final isLast = entry.key == rows.length - 1;
          final row = entry.value;
          final isStatus = row[0] == 'Status';
          return Container(
            padding:
                EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.4.h),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(bottom: BorderSide(color: kBorder)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 28.w,
                  child: Text(
                    row[0],
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: kSubText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: isStatus
                      ? Align(
                          alignment: Alignment.centerRight,
                          child: _statusBadge(row[1], statusColor),
                        )
                      : Text(
                          row[1],
                          textAlign: TextAlign.right,
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
        }).toList(),
      ),
    );
  }

  Widget _tableHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.4.h),
      decoration: BoxDecoration(
        color: kPrimary.withOpacity(0.09),
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(8)),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Description',
              style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: kText),
            ),
          ),
          SizedBox(
            width: 22.w,
            child: Text(
              'Total',
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: kText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableRow(InvoiceItem item) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.4.h),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: kBorder),
          right: BorderSide(color: kBorder),
          bottom: BorderSide(color: kBorder),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: kText),
                ),
                SizedBox(height: 0.3.h),
                Text(
                  '${item.quantity} x ${_formatAmount(item.unitPrice)}',
                  style: TextStyle(fontSize: 12.sp, color: kSubText),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 22.w,
            child: Text(
              _formatAmount(item.amount),
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: kText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _totalRow(String label, double amount,
      {bool isBold = false, bool isNegative = false, Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: color ?? kSubText,
            ),
          ),
          Text(
            '${isNegative ? '- ' : ''}${_formatAmount(amount)}',
            style: TextStyle(
              fontSize: isBold ? 14.sp : 12.sp,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: color ?? kText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadgeWhite(String status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white38),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ─── Create Invoice Dialog ────────────────────────────────────────
  void _showCreateInvoiceDialog(
      BuildContext context, InvoiceController controller) {
    final formKey = GlobalKey<FormState>();
    String selectedCustomerId = '';
    DateTime selectedDate = DateTime.now();
    DateTime selectedDueDate =
        DateTime.now().add(const Duration(days: 30));
    List<Map<String, dynamic>> items = [];
    double discount = 0;
    String notes = '';

    void addItem() {
      items.add({
        'description': '',
        'quantity': 1,
        'unitPrice': 0.0,
        'taxRate': 0.0,
      });
    }

    addItem();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          double calculateTotal() {
            double subtotal = 0;
            for (var item in items) {
              final qty = (item['quantity'] ?? 1) is int
                  ? (item['quantity'] ?? 1).toDouble()
                  : (item['quantity'] ?? 1.0);
              final price = (item['unitPrice'] ?? 0.0) is double
                  ? (item['unitPrice'] ?? 0.0)
                  : (item['unitPrice'] ?? 0).toDouble();
              subtotal += qty * price;
            }
            return subtotal - discount;
          }

          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            child: Container(
              width: 90.w,
              constraints: BoxConstraints(maxHeight: 85.h),
              padding: EdgeInsets.all(5.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Row(
                    children: [
                      Icon(Icons.receipt_long, color: kPrimary, size: 6.w),
                      SizedBox(width: 2.w),
                      Text(
                        'Create Invoice',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: kText,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.close, size: 5.w, color: kSubText),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Divider(color: kBorder),
                  SizedBox(height: 1.h),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionLabel('Customer'),
                            DropdownButtonFormField<String>(
                              value: selectedCustomerId.isEmpty
                                  ? null
                                  : selectedCustomerId,
                              decoration:
                                  _inputDecoration('Select Customer'),
                              style: TextStyle(
                                  fontSize: 14.sp, color: kText),
                              items: controller.customers.map((customer) {
                                return DropdownMenuItem<String>(
                                  value: customer['_id']?.toString() ?? '',
                                  child: Text(customer['name'] ?? ''),
                                );
                              }).toList(),
                              onChanged: (value) =>
                                  selectedCustomerId = value!,
                              validator: (value) =>
                                  value == null ? 'Customer required' : null,
                            ),
                            SizedBox(height: 2.h),

                            _sectionLabel('Dates'),
                            Row(
                              children: [
                                Expanded(
                                  child: _dateTile(
                                    icon: Icons.calendar_today,
                                    label: 'Invoice Date',
                                    value: DateFormat('dd MMM yy')
                                        .format(selectedDate),
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: selectedDate,
                                        firstDate: DateTime(2020),
                                        lastDate: DateTime.now(),
                                      );
                                      if (picked != null) {
                                        setState(() => selectedDate = picked);
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                Expanded(
                                  child: _dateTile(
                                    icon: Icons.event,
                                    label: 'Due Date',
                                    value: DateFormat('dd MMM yy')
                                        .format(selectedDueDate),
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: selectedDueDate,
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.now()
                                            .add(const Duration(days: 365)),
                                      );
                                      if (picked != null) {
                                        setState(
                                            () => selectedDueDate = picked);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2.h),

                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                _sectionLabel('Items'),
                                TextButton.icon(
                                  onPressed: () =>
                                      setState(() => addItem()),
                                  icon: Icon(Icons.add, size: 4.w),
                                  label: Text('Add Item',
                                      style: TextStyle(fontSize: 12.sp)),
                                ),
                              ],
                            ),
                            ...items.asMap().entries.map((entry) {
                              int index = entry.key;
                              var item = entry.value;
                              return Container(
                                margin: EdgeInsets.only(bottom: 1.5.h),
                                padding: EdgeInsets.all(3.w),
                                decoration: BoxDecoration(
                                  color: kBg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: kBorder),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            decoration: _inputDecoration(
                                                'Description'),
                                            style: TextStyle(fontSize: 14.sp),
                                            onChanged: (v) =>
                                                item['description'] = v,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete_outline,
                                              size: 5.w, color: kDanger),
                                          onPressed: () => setState(
                                              () => items.removeAt(index)),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 1.h),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            decoration:
                                                _inputDecoration('Qty'),
                                            style: TextStyle(fontSize: 14.sp),
                                            keyboardType:
                                                TextInputType.number,
                                            initialValue: '1',
                                            onChanged: (v) {
                                              item['quantity'] =
                                                  int.tryParse(v) ?? 1;
                                              setState(() {});
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 2.w),
                                        Expanded(
                                          flex: 2,
                                          child: TextFormField(
                                            decoration: _inputDecoration(
                                                'Unit Price',
                                                prefix: '\$ '),
                                            style: TextStyle(fontSize: 14.sp),
                                            keyboardType:
                                                TextInputType.number,
                                            onChanged: (v) {
                                              item['unitPrice'] =
                                                  double.tryParse(v) ?? 0.0;
                                              setState(() {});
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 0.8.h),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        'Amount: ${_formatAmount(((item['quantity'] ?? 1) * (item['unitPrice'] ?? 0.0)).toDouble())}',
                                        style: TextStyle(
                                            fontSize: 12.sp,
                                            color: kPrimary,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),

                            SizedBox(height: 1.h),
                            _sectionLabel('Discount'),
                            TextFormField(
                              decoration: _inputDecoration(
                                  'Discount Amount',
                                  prefix: '\$ '),
                              style: TextStyle(fontSize: 14.sp),
                              keyboardType: TextInputType.number,
                              onChanged: (v) {
                                discount = double.tryParse(v) ?? 0;
                                setState(() {});
                              },
                            ),
                            SizedBox(height: 2.h),

                            _sectionLabel('Notes (Optional)'),
                            TextFormField(
                              decoration: _inputDecoration('Add notes...'),
                              style: TextStyle(fontSize: 14.sp),
                              maxLines: 2,
                              onChanged: (v) => notes = v,
                            ),
                            SizedBox(height: 2.h),

                            // Total
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: kPrimary.withOpacity(0.07),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: kPrimary.withOpacity(0.2)),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Total Amount',
                                      style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w700,
                                          color: kText)),
                                  Text(
                                    _formatAmount(calculateTotal()),
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w800,
                                        color: kPrimary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Obx(() => Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: controller.isCreating.value
                                  ? null
                                  : () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    EdgeInsets.symmetric(vertical: 1.5.h),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12)),
                              ),
                              child: Text('Cancel',
                                  style: TextStyle(fontSize: 14.sp)),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: controller.isCreating.value
                                  ? null
                                  : () async {
                                      if (formKey.currentState!.validate() &&
                                          selectedCustomerId.isNotEmpty) {
                                        Navigator.pop(context);
                                        await controller.createInvoice({
                                          'customerId': selectedCustomerId,
                                          'date':
                                              selectedDate.toIso8601String(),
                                          'dueDate': selectedDueDate
                                              .toIso8601String(),
                                          'items': items
                                              .map((item) => {
                                                    'description':
                                                        item['description'],
                                                    'quantity':
                                                        item['quantity'],
                                                    'unitPrice':
                                                        item['unitPrice'],
                                                    'taxRate': item['taxRate'],
                                                  })
                                              .toList(),
                                          'discount': discount,
                                          'notes': notes,
                                        });
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimary,
                                padding:
                                    EdgeInsets.symmetric(vertical: 1.5.h),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12)),
                              ),
                              child: controller.isCreating.value
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 4.w,
                                          height: 4.w,
                                          child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2),
                                        ),
                                        SizedBox(width: 2.w),
                                        Text('Creating...',
                                            style: TextStyle(
                                                fontSize: 14.sp,
                                                color: Colors.white)),
                                      ],
                                    )
                                  : Text('Create Invoice',
                                      style: TextStyle(fontSize: 14.sp)),
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Shared Helper Widgets ────────────────────────────────────────

  Widget _sectionLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          color: kSubText,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _dateTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: kBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kBorder),
        ),
        child: Row(
          children: [
            Icon(icon, size: 4.w, color: kPrimary),
            SizedBox(width: 1.5.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style:
                          TextStyle(fontSize: 12.sp, color: kSubText)),
                  Text(value,
                      style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: kText)),
                ],
              ),
            ),
            Icon(Icons.edit_calendar_outlined,
                size: 4.w, color: kSubText),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, {String? prefix}) {
    return InputDecoration(
      labelText: label,
      prefixText: prefix,
      labelStyle: TextStyle(fontSize: 12.sp, color: kSubText),
      border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding:
          EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
    );
  }

  // ─── Payment Recording Dialog ─────────────────────────────────────
  void _recordPayment(Invoice invoice, InvoiceController controller) {
    final formKey = GlobalKey<FormState>();
    double amount = invoice.outstanding;
    DateTime paymentDate = DateTime.now();
    String paymentMethod = 'Bank Transfer';
    String reference = '';
    String selectedBankAccountId = '';

    showDialog(
      context: Get.context!,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              width: 85.w,
              padding: EdgeInsets.all(5.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.payment, color: kSuccess, size: 6.w),
                      SizedBox(width: 2.w),
                      Text(
                        'Record Payment',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: kText,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: kBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: kBorder),
                          ),
                          child: Column(
                            children: [
                              _paymentDetailRow('Invoice', invoice.invoiceNumber),
                              SizedBox(height: 1.h),
                              _paymentDetailRow('Customer', invoice.customerName),
                              SizedBox(height: 1.h),
                              _paymentDetailRow('Total', _formatAmount(invoice.totalAmount)),
                              SizedBox(height: 1.h),
                              _paymentDetailRow('Outstanding', _formatAmount(invoice.outstanding), isImportant: true),
                            ],
                          ),
                        ),
                        SizedBox(height: 2.h),
                        TextFormField(
                          initialValue: amount.toString(),
                          decoration: InputDecoration(
                            labelText: 'Payment Amount *',
                            prefixText: '\$ ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            labelStyle: TextStyle(fontSize: 12.sp, color: kSubText),
                            fillColor: kCardBg,
                            filled: true,
                          ),
                          style: TextStyle(fontSize: 14.sp, color: kText),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              amount = double.tryParse(value) ?? 0;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Amount required';
                            final val = double.tryParse(value);
                            if (val == null) return 'Invalid amount';
                            if (val <= 0) return 'Amount must be greater than 0';
                            if (val > invoice.outstanding) return 'Amount exceeds outstanding';
                            return null;
                          },
                        ),
                        SizedBox(height: 2.h),
                        GestureDetector(
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
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.8.h),
                            decoration: BoxDecoration(
                              color: kCardBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: kBorder),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, size: 5.w, color: kPrimary),
                                SizedBox(width: 3.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Payment Date', style: TextStyle(fontSize: 11.sp, color: kSubText)),
                                      Text(DateFormat('dd MMM yyyy').format(paymentDate), style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: kText)),
                                    ],
                                  ),
                                ),
                                Icon(Icons.edit_calendar, size: 5.w, color: kSubText),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Container(
                          decoration: BoxDecoration(
                            color: kCardBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: kBorder),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: paymentMethod,
                            decoration: InputDecoration(
                              labelText: 'Payment Method',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
                              labelStyle: TextStyle(fontSize: 12.sp, color: kSubText),
                            ),
                            style: TextStyle(fontSize: 14.sp, color: kText),
                            dropdownColor: kCardBg,
                            items: const [
                              DropdownMenuItem(value: 'Bank Transfer', child: Text('Bank Transfer')),
                              DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                              DropdownMenuItem(value: 'Cheque', child: Text('Cheque')),
                              DropdownMenuItem(value: 'Credit Card', child: Text('Credit Card')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                paymentMethod = value!;
                                if (paymentMethod != 'Bank Transfer') {
                                  selectedBankAccountId = '';
                                }
                              });
                            },
                          ),
                        ),
                        SizedBox(height: 2.h),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Reference Number',
                            hintText: 'e.g., TRX-001, CHQ-123',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            labelStyle: TextStyle(fontSize: 12.sp, color: kSubText),
                            fillColor: kCardBg,
                            filled: true,
                          ),
                          style: TextStyle(fontSize: 14.sp, color: kText),
                          onChanged: (value) => reference = value,
                        ),
                        if (paymentMethod == 'Bank Transfer') ...[
                          SizedBox(height: 2.h),
                          Obx(() {
                            final bankAccounts = controller.bankAccounts;
                            if (bankAccounts.isEmpty) {
                              return Container(
                                padding: EdgeInsets.all(3.w),
                                decoration: BoxDecoration(
                                  color: kWarning.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.warning, size: 5.w, color: kWarning),
                                    SizedBox(width: 2.w),
                                    Expanded(
                                      child: Text(
                                        'No bank accounts found. Please add a bank account first.',
                                        style: TextStyle(fontSize: 12.sp, color: kWarning),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return Container(
                              decoration: BoxDecoration(
                                color: kCardBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: kBorder),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: selectedBankAccountId.isEmpty ? null : selectedBankAccountId,
                                decoration: InputDecoration(
                                  labelText: 'Select Bank Account',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
                                  labelStyle: TextStyle(fontSize: 12.sp, color: kSubText),
                                ),
                                style: TextStyle(fontSize: 14.sp, color: kText),
                                dropdownColor: kCardBg,
                                hint: Text('Select account', style: TextStyle(fontSize: 12.sp, color: kSubText)),
                                items: bankAccounts.map((account) {
                                  return DropdownMenuItem<String>(
                                    value: account['_id'].toString(),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(account['accountName'], style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: kText)),
                                        Text('${account['accountNumber']} • Balance: ${_formatAmount(account['currentBalance']?.toDouble() ?? 0.0)}', style: TextStyle(fontSize: 10.sp, color: kSubText)),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedBankAccountId = value!;
                                  });
                                },
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Obx(() => ElevatedButton(
                          onPressed: controller.isProcessingPayment.value
                              ? null
                              : () async {
                                  if (formKey.currentState!.validate()) {
                                    if (paymentMethod == 'Bank Transfer' && selectedBankAccountId.isEmpty) {
                                      AppSnackbar.error(kWarning, 'Error', 'Please select a bank account');
                                      return;
                                    }
                                    Navigator.pop(context);
                                    await controller.recordPayment(
                                      invoiceId: invoice.id,
                                      amount: amount,
                                      paymentDate: paymentDate,
                                      paymentMethod: paymentMethod,
                                      reference: reference,
                                      bankAccountId: selectedBankAccountId,
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kSuccess,
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: controller.isProcessingPayment.value
                              ? SizedBox(width: 5.w, height: 5.w, child: CircularProgressIndicator(strokeWidth: 2.w, color: Colors.white))
                              : Text('Record Payment', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white)),
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

  Widget _paymentDetailRow(String label, String value, {bool isImportant = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12.sp, color: kSubText)),
          Text(value, style: TextStyle(fontSize: 13.sp, fontWeight: isImportant ? FontWeight.w800 : FontWeight.w600, color: isImportant ? kDanger : kText)),
        ],
      ),
    );
  }

  // ─── Export Single Invoice ────────────────────────────────────────
  void _exportSingleInvoice(Invoice invoice, InvoiceController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
           Text(
              'Export Invoice',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              invoice.invoiceNumber,
              style: TextStyle(fontSize: 14, color: kPrimary),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.picture_as_pdf, color: Color(0xFFE53935)),
              title:Text('Export as PDF'),
              onTap: () {
                Get.back();
                controller.exportSingleInvoiceToPdf(invoice);
              },
            ),
            ListTile(
              leading: Icon(Icons.table_chart, color: Color(0xFF2E7D32)),
              title:Text('Export as Excel'),
              onTap: () {
                Get.back();
                controller.exportSingleInvoiceToExcel(invoice);
              },
            ),
          ],
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  // ─── Other Actions ────────────────────────────────────────────────
  void _showFilterDialog(InvoiceController controller) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: Text('Filter Invoices',
            style: TextStyle(
                fontSize: 14.sp, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.calendar_today),
              title:
                  Text('Date Range', style: TextStyle(fontSize: 14.sp)),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () async {
                Navigator.pop(context);
                final start = await showDatePicker(
                  context: Get.context!,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (start != null) {
                  final end = await showDatePicker(
                    context: Get.context!,
                    initialDate: DateTime.now(),
                    firstDate: start,
                    lastDate: DateTime.now(),
                  );
                  if (end != null) controller.setDateRange(start, end);
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.clear),
              title: Text('Clear Filters',
                  style: TextStyle(fontSize: 14.sp)),
              onTap: () {
                Navigator.pop(context);
                controller.clearFilters();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }



  String _taxPercent(Invoice invoice) {
    if (invoice.subtotal == 0) return '0';
    return ((invoice.taxTotal / invoice.subtotal) * 100)
        .toStringAsFixed(0);
  }

  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '\$ ${formatter.format(amount)}';
  }
}