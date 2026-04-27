import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/Utils/responsive_utils.dart';
import 'package:LedgerPro_app/core/CreditNote/controllers/creditnote_controller.dart';
import 'package:LedgerPro_app/core/CreditNote/models/credit_note_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CreditNotesScreen extends StatelessWidget {
  const CreditNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreditNoteController());
    
    return Container(
      color: kBg,
      child: Obx(() {
        if (controller.isLoading.value && controller.creditNotes.isEmpty) {
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
              _buildCreditNotesList(controller, context),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  // Custom Header without AppBar
  Widget _buildHeader(CreditNoteController controller, BuildContext context) {
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
                  'Credit Notes',
                  style: TextStyle(
                    fontSize: isWeb ? 20 : 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage customer credit notes',
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
              onPressed: () => controller.exportCreditNotes(),
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
                onPressed: () => controller.showCreateCreditNoteDialog(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(CreditNoteController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 16 : 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Obx(() => _buildSummaryCard(
              'Total Credit Notes',
              controller.totalCount.value.toString(),
              kPrimary,
              Icons.note,
              context,
              width: isWeb ? 200 : 160,
              isNumber: true,
            )),
            SizedBox(width: isWeb ? 16 : 12),
            Obx(() => _buildSummaryCard(
              'Total Amount',
              controller.formatAmount(controller.totalAmount.value),
              kWarning,
              Icons.attach_money,
              context,
              width: isWeb ? 200 : 160,
            )),
            SizedBox(width: isWeb ? 16 : 12),
            Obx(() => _buildSummaryCard(
              'Applied',
              controller.formatAmount(controller.appliedAmount.value),
              kSuccess,
              Icons.check_circle,
              context,
              width: isWeb ? 200 : 160,
            )),
            SizedBox(width: isWeb ? 16 : 12),
            Obx(() => _buildSummaryCard(
              'Remaining',
              controller.formatAmount(controller.remainingAmount.value),
              kPrimary,
              Icons.pending,
              context,
              width: isWeb ? 200 : 160,
            )),
            SizedBox(width: isWeb ? 16 : 12),
            Obx(() => _buildSummaryCard(
              'Expired',
              controller.formatAmount(controller.expiredAmount.value),
              kDanger,
              Icons.warning,
              context,
              width: isWeb ? 200 : 160,
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

  Widget _buildFilterBar(CreditNoteController controller, BuildContext context) {
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
                      hintText: isWeb ? 'Search by credit note ID, customer, invoice...' : 'Search...',
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

  Widget _buildCreditNotesList(CreditNoteController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    if (controller.creditNotes.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(isWeb ? 40 : 20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.note_outlined, size: isWeb ? 80 : 64, color: kSubText.withOpacity(0.5)),
              SizedBox(height: isWeb ? 20 : 16),
              Text(
                'No credit notes found',
                style: TextStyle(fontSize: isWeb ? 18 : 16, color: kSubText),
              ),
              SizedBox(height: isWeb ? 20 : 16),
              ElevatedButton(
                onPressed: () => controller.showCreateCreditNoteDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 12 : 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
                  ),
                ),
                child: Text(
                  'Create Credit Note',
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
            'Credit Notes',
            style: TextStyle(
              fontSize: isWeb ? 18 : 16,
              fontWeight: FontWeight.w700,
              color: kText,
            ),
          ),
        ),
        ...controller.creditNotes.map((creditNote) => Padding(
          padding: EdgeInsets.symmetric(horizontal: isWeb ? 20 : 12, vertical: isWeb ? 8 : 6),
          child: _buildCreditNoteCard(controller, creditNote, context),
        )).toList(),
      ],
    );
  }

  Widget _buildCreditNoteCard(CreditNoteController controller, CreditNote creditNote, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final isMobile = ResponsiveUtils.isMobile(context);
    
    Color statusColor = creditNote.status == 'Issued' ? kWarning :
                        creditNote.status == 'Applied' ? kSuccess : kDanger;
    IconData statusIcon = creditNote.status == 'Issued' ? Icons.pending :
                          creditNote.status == 'Applied' ? Icons.check_circle : Icons.warning;
    
    bool isExpiringSoon = creditNote.status == 'Issued' && 
                          creditNote.expiryDate != null &&
                          creditNote.expiryDate!.difference(DateTime.now()).inDays <= 7;
    
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
          onTap: () => controller.viewCreditNoteDetails(creditNote),
          borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
          child: Padding(
            padding: EdgeInsets.all(isWeb ? 16 : 12),
            child: isMobile
                ? _buildMobileCreditNoteCard(controller, creditNote, statusColor, statusIcon, isExpiringSoon, context)
                : _buildDesktopCreditNoteCard(controller, creditNote, statusColor, statusIcon, isExpiringSoon, context),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopCreditNoteCard(CreditNoteController controller, CreditNote creditNote, Color statusColor, IconData statusIcon, bool isExpiringSoon, BuildContext context) {
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
                color: kWarning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
              ),
              child: Icon(Icons.note, size: isWeb ? 24 : 20, color: kWarning),
            ),
            SizedBox(width: isWeb ? 16 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        creditNote.creditNoteNumber,
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
                              creditNote.status,
                              style: TextStyle(fontSize: isWeb ? 11 : 10, color: statusColor, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      if (isExpiringSoon)
                        SizedBox(width: isWeb ? 8 : 6),
                      if (isExpiringSoon)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: isWeb ? 8 : 6, vertical: isWeb ? 4 : 2),
                          decoration: BoxDecoration(
                            color: kDanger.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(isWeb ? 6 : 4),
                          ),
                          child: Text(
                            'Expiring Soon',
                            style: TextStyle(fontSize: isWeb ? 11 : 10, color: kDanger, fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: isWeb ? 4 : 2),
                  Text(
                    'Date: ${DateFormat('dd MMM yyyy').format(creditNote.date)}',
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
                  controller.formatAmount(creditNote.amount),
                  style: TextStyle(fontSize: isWeb ? 16 : 14, fontWeight: FontWeight.w800, color: kWarning),
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
                child: _buildInfoItem('Customer', creditNote.customerName, Icons.person, isWeb),
              ),
              Container(width: 1, height: isWeb ? 32 : 24, color: kBorder),
              Expanded(
                child: _buildInfoItem('Original Invoice', creditNote.originalInvoiceNumber, Icons.receipt, isWeb),
              ),
              Container(width: 1, height: isWeb ? 32 : 24, color: kBorder),
              Expanded(
                child: _buildInfoItem('Invoice Amount', controller.formatAmount(creditNote.originalInvoiceAmount), Icons.attach_money, isWeb),
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
                child: _buildInfoItem('Reason', creditNote.reason, Icons.info_outline, isWeb),
              ),
              Container(width: 1, height: isWeb ? 32 : 24, color: kBorder),
              Expanded(
                child: _buildInfoItem('Applied', controller.formatAmount(creditNote.appliedAmount), Icons.check_circle, isWeb),
              ),
              Container(width: 1, height: isWeb ? 32 : 24, color: kBorder),
              Expanded(
                child: _buildInfoItem('Remaining', controller.formatAmount(creditNote.remainingAmount), Icons.pending, isWeb),
              ),
            ],
          ),
        ),
        if (creditNote.expiryDate != null)
          Padding(
            padding: EdgeInsets.only(top: isWeb ? 8 : 6),
            child: Container(
              padding: EdgeInsets.all(isWeb ? 12 : 10),
              decoration: BoxDecoration(
                color: isExpiringSoon ? kDanger.withOpacity(0.1) : kBg,
                borderRadius: BorderRadius.circular(isWeb ? 10 : 8),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: isWeb ? 18 : 14, color: isExpiringSoon ? kDanger : kSubText),
                  SizedBox(width: isWeb ? 8 : 6),
                  Expanded(
                    child: Text(
                      'Expires on: ${DateFormat('dd MMM yyyy').format(creditNote.expiryDate!)}',
                      style: TextStyle(
                        fontSize: isWeb ? 12 : 11,
                        color: isExpiringSoon ? kDanger : kSubText,
                        fontWeight: isExpiringSoon ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        SizedBox(height: isWeb ? 16 : 12),
        Row(
          children: [
            if (creditNote.status == 'Issued')
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => controller.showApplyCreditNoteDialog(creditNote),
                  icon: Icon(Icons.check_circle, size: isWeb ? 18 : 14, color: Colors.white),
                  label: Text('Apply to Invoice', style: TextStyle(fontSize: isWeb ? 12 : 10, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kSuccess,
                    padding: EdgeInsets.symmetric(vertical: isWeb ? 10 : 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isWeb ? 8 : 6)),
                  ),
                ),
              ),
            if (creditNote.status == 'Issued') SizedBox(width: isWeb ? 12 : 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => controller.printCreditNote(creditNote),
                icon: Icon(Icons.print, size: isWeb ? 18 : 14, color: kPrimary),
                label: Text('Print', style: TextStyle(fontSize: isWeb ? 12 : 10, color: kPrimary)),
                style: _buttonStyle(kPrimary, isWeb),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileCreditNoteCard(CreditNoteController controller, CreditNote creditNote, Color statusColor, IconData statusIcon, bool isExpiringSoon, BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: kWarning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.note, size: 20, color: kWarning),
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
                          creditNote.creditNoteNumber,
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
                              creditNote.status,
                              style: TextStyle(fontSize: 9, color: statusColor, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Date: ${DateFormat('dd MMM yyyy').format(creditNote.date)}',
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
                  controller.formatAmount(creditNote.amount),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: kWarning),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInfoItem('Customer', creditNote.customerName, Icons.person, false),
            ),
            Expanded(
              child: _buildInfoItem('Invoice', creditNote.originalInvoiceNumber, Icons.receipt, false),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (creditNote.status == 'Issued')
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => controller.showApplyCreditNoteDialog(creditNote),
                  icon: Icon(Icons.check_circle, size: 14, color: Colors.white),
                  label: const Text('Apply', style: TextStyle(fontSize: 9, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kSuccess,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ),
            if (creditNote.status == 'Issued') const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => controller.printCreditNote(creditNote),
                icon: Icon(Icons.print, size: 14, color: kPrimary),
                label: const Text('Print', style: TextStyle(fontSize: 9, color: kPrimary)),
                style: _buttonStyle(kPrimary, false),
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
}