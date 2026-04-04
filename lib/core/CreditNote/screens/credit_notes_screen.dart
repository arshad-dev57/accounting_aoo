import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/core/CreditNote/controllers/creditnote_controller.dart';
import 'package:LedgerPro_app/core/CreditNote/models/credit_note_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';

class CreditNotesScreen extends StatelessWidget {
  const CreditNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreditNoteController());
    
    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(controller),
      body: Obx(() {
        if (controller.isLoading.value && controller.creditNotes.isEmpty) {
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
              child: _buildCreditNotesList(controller),
            ),
          ],
        );
      }),
      floatingActionButton: _buildFAB(controller),
    );
  }

  PreferredSizeWidget _buildAppBar(CreditNoteController controller) {
    return AppBar(
      title: Text(
        'Credit Notes',
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
          icon: Icon(Icons.calendar_today_outlined, color: Colors.white, size: 5.w),
          onPressed: () => controller.selectDateRange(),
        ),
        IconButton(
          icon: Icon(Icons.download_outlined, color: Colors.white, size: 5.w),
          onPressed: () => controller.exportCreditNotes(),
        ),
       
      ],
    );
  }

  Widget _buildSummaryCards(CreditNoteController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Obx(() => _buildSummaryCard(
              'Total Credit Notes',
              controller.totalCount.value.toString(),
              kPrimary,
              Icons.note,
              28.w,
              isNumber: true,
            )),
            SizedBox(width: 2.w),
            Obx(() => _buildSummaryCard(
              'Total Amount',
              controller.formatAmount(controller.totalAmount.value),
              kWarning,
              Icons.attach_money,
              28.w,
            )),
            SizedBox(width: 2.w),
            Obx(() => _buildSummaryCard(
              'Applied',
              controller.formatAmount(controller.appliedAmount.value),
              kSuccess,
              Icons.check_circle,
              28.w,
            )),
            SizedBox(width: 2.w),
            Obx(() => _buildSummaryCard(
              'Remaining',
              controller.formatAmount(controller.remainingAmount.value),
              kPrimary,
              Icons.pending,
              28.w,
            )),
            SizedBox(width: 2.w),
            Obx(() => _buildSummaryCard(
              'Expired',
              controller.formatAmount(controller.expiredAmount.value),
              kDanger,
              Icons.warning,
              28.w,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String amount, Color color, IconData icon, double width, {bool isNumber = false}) {
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

  Widget _buildFilterBar(CreditNoteController controller) {
    return Container(
      width: 100.w,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      color: kCardBg,
      child: Column(
        children: [
          Row(
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
                    controller: controller.searchController,
                    style: TextStyle(fontSize: 14.sp, color: kText),
                    decoration: InputDecoration(
                      hintText: 'Search by credit note ID, customer, invoice...',
                      hintStyle: TextStyle(fontSize: 12.sp, color: kSubText),
                      prefixIcon: Icon(Icons.search, size: 5.w, color: kSubText),
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
                  child: Obx(() => DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedFilter.value,
                      icon: Icon(Icons.arrow_drop_down, size: 5.w, color: kText),
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      isExpanded: true,
                      style: TextStyle(fontSize: 14.sp, color: kText),
                      dropdownColor: kCardBg,
                      items: controller.filterOptions.map((filter) {
                        return DropdownMenuItem(
                          value: filter,
                          child: Text(filter, style: TextStyle(color: kText)),
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
              return Padding(
                padding: EdgeInsets.only(top: 1.5.h),
                child: Container(
                  width: 100.w,
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.date_range, size: 5.w, color: kPrimary),
                          SizedBox(width: 2.w),
                          Text(
                            '${DateFormat('dd MMM yyyy').format(controller.selectedDateRange.value!.start)} - ${DateFormat('dd MMM yyyy').format(controller.selectedDateRange.value!.end)}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: kPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => controller.clearDateRange(),
                        child: Icon(Icons.close, size: 5.w, color: kPrimary),
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

  Widget _buildCreditNotesList(CreditNoteController controller) {
    if (controller.creditNotes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_outlined, size: 15.w, color: kSubText.withOpacity(0.5)),
            SizedBox(height: 2.h),
            Text(
              'No credit notes found',
              style: TextStyle(
                fontSize: 14.sp,
                color: kSubText,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 2.h),
            ElevatedButton(
              onPressed: () => controller.showCreateCreditNoteDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Create Credit Note',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: controller.creditNotes.length,
      itemBuilder: (context, index) {
        final creditNote = controller.creditNotes[index];
        return _buildCreditNoteCard(controller, creditNote);
      },
    );
  }

  Widget _buildCreditNoteCard(CreditNoteController controller, CreditNote creditNote) {
    Color statusColor = creditNote.status == 'Issued' ? kWarning :
                        creditNote.status == 'Applied' ? kSuccess : kDanger;
    IconData statusIcon = creditNote.status == 'Issued' ? Icons.pending :
                          creditNote.status == 'Applied' ? Icons.check_circle : Icons.warning;
    
    bool isExpiringSoon = creditNote.status == 'Issued' && 
                          creditNote.expiryDate != null &&
                          creditNote.expiryDate!.difference(DateTime.now()).inDays <= 7;
    
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
          onTap: () => controller.viewCreditNoteDetails(creditNote),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 14.w,
                      height: 14.w,
                      decoration: BoxDecoration(
                        color: kWarning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.note,
                        size: 7.w,
                        color: kWarning,
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
                                creditNote.creditNoteNumber,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w800,
                                  color: kText,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(statusIcon, size: 3.w, color: statusColor),
                                    SizedBox(width: 1.w),
                                    Text(
                                      creditNote.status,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: statusColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isExpiringSoon)
                                SizedBox(width: 2.w),
                              if (isExpiringSoon)
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                                  decoration: BoxDecoration(
                                    color: kDanger.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Expiring Soon',
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                      color: kDanger,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            'Date: ${DateFormat('dd MMM yyyy').format(creditNote.date)}',
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
                          'Amount',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: kSubText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          controller.formatAmount(creditNote.amount),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: kWarning,
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
                        child: _buildInfoItem(
                          'Customer',
                          creditNote.customerName,
                          Icons.person,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 4.h,
                        color: kBorder,
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          'Original Invoice',
                          creditNote.originalInvoiceNumber,
                          Icons.receipt,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 4.h,
                        color: kBorder,
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          'Invoice Amount',
                          controller.formatAmount(creditNote.originalInvoiceAmount),
                          Icons.attach_money,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 1.h),
                
                Container(
                  padding: EdgeInsets.symmetric(vertical: 1.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          'Reason',
                          creditNote.reason,
                          Icons.info_outline,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 4.h,
                        color: kBorder,
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          'Applied',
                          controller.formatAmount(creditNote.appliedAmount),
                          Icons.check_circle,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 4.h,
                        color: kBorder,
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          'Remaining',
                          controller.formatAmount(creditNote.remainingAmount),
                          Icons.pending,
                        ),
                      ),
                    ],
                  ),
                ),
                
                if (creditNote.expiryDate != null)
                  Padding(
                    padding: EdgeInsets.only(top: 1.h),
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: isExpiringSoon ? kDanger.withOpacity(0.1) : kBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, size: 4.w, color: isExpiringSoon ? kDanger : kSubText),
                          SizedBox(width: 2.w),
                          Text(
                            'Expires on: ${DateFormat('dd MMM yyyy').format(creditNote.expiryDate!)}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: isExpiringSoon ? kDanger : kSubText,
                              fontWeight: isExpiringSoon ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                SizedBox(height: 2.h),
                
                Row(
                  children: [
                    if (creditNote.status == 'Issued')
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => controller.showApplyCreditNoteDialog(creditNote),
                          icon: Icon(Icons.check_circle, size: 4.w, color: Colors.white),
                          label: Text(
                            'Apply to Invoice',
                            style: TextStyle(fontSize: 12.sp, color: Colors.white),
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
                    if (creditNote.status == 'Issued') SizedBox(width: 3.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => controller.printCreditNote(creditNote),
                        icon: Icon(Icons.print, size: 4.w, color: kPrimary),
                        label: Text(
                          'Print',
                          style: TextStyle(fontSize: 12.sp, color: kPrimary),
                        ),
                        style: OutlinedButton.styleFrom(
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

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 3.5.w, color: kSubText),
        SizedBox(width: 1.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 9.sp,
                  color: kSubText,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 11.sp,
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

  Widget _buildFAB(CreditNoteController controller) {
    return FloatingActionButton(
      onPressed: () => controller.showCreateCreditNoteDialog(),
      backgroundColor: kPrimary,
      child: Icon(Icons.add, color: Colors.white, size: 6.w),
      elevation: 3,
    );
  }
}