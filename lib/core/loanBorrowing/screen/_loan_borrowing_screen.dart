import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/core/loanBorrowing/controller/loan_controller.dart';
import 'package:LedgerPro_app/core/loanBorrowing/models/loan_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';

class LoansBorrowingsScreen extends StatelessWidget {
  const LoansBorrowingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoanController());

    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(controller),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
LoadingAnimationWidget.waveDots(
                    color: kPrimary,
                    size: 10.w,
                  ) ,               SizedBox(height: 2.h),
                Text('Loading loans...', style: TextStyle(fontSize: 14.sp, color: kSubText)),
              ],
            ),
          );
        }
        return Column(
          children: [
            _buildSummaryCards(controller),
            _buildFilterBar(controller),
            Expanded(child: _buildLoansList(controller)),
          ],
        );
      }),
      floatingActionButton: _buildFAB(controller),
    );
  }

  PreferredSizeWidget _buildAppBar(LoanController controller) {
    return AppBar(
      title: Text('Loans & Borrowings', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: Colors.white)),
      backgroundColor: kPrimary,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(Icons.calculate_outlined, color: Colors.white, size: 5.w),
          onPressed: () => controller.showEMICalculator(),
        ),
        IconButton(
          icon: Icon(Icons.download_outlined, color: Colors.white, size: 5.w),
          onPressed: () => controller.exportLoans(),
        ),
        IconButton(
          icon: Icon(Icons.print_outlined, color: Colors.white, size: 5.w),
          onPressed: () => controller.printLoans(),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(LoanController controller) {
    return Obx(() => Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildSummaryCard('Total Loans', controller.totalLoans.value.toString(), kPrimary, Icons.credit_card, 25.w, isNumber: true),
            SizedBox(width: 2.w),
            _buildSummaryCard('Total Principal', controller.formatAmount(controller.totalPrincipal.value), kPrimary, Icons.attach_money, 28.w),
            SizedBox(width: 2.w),
            _buildSummaryCard('Outstanding', controller.formatAmount(controller.totalOutstanding.value), kDanger, Icons.payment, 28.w),
            SizedBox(width: 2.w),
            _buildSummaryCard('Total Paid', controller.formatAmount(controller.totalPaid.value), kSuccess, Icons.check_circle, 28.w),
            SizedBox(width: 2.w),
            _buildSummaryCard('Monthly EMI', controller.formatAmount(controller.totalEMI.value), kWarning, Icons.calendar_month, 28.w),
          ],
        ),
      ),
    ));
  }

  Widget _buildSummaryCard(String title, String amount, Color color, IconData icon, double width, {bool isNumber = false}) {
    return Container(
      width: width,
      padding: EdgeInsets.all(2.5.w),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 4.5.w, color: color),
              SizedBox(width: 1.5.w),
              Expanded(child: Text(title, style: TextStyle(fontSize: 12.sp, color: kSubText, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ),
          SizedBox(height: 1.h),
          Text(isNumber ? amount : amount, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildFilterBar(LoanController controller) {
    return Container(
      width: 100.w,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      color: kCardBg,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              height: 6.h,
              decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
              child: TextField(
                controller: controller.searchController,
                style: TextStyle(fontSize: 14.sp, color: kText),
                decoration: InputDecoration(
                  hintText: 'Search by loan ID, lender, type...',
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
              decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
              child: Obx(() => DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.selectedFilter.value,
                  icon: Icon(Icons.arrow_drop_down, size: 5.w, color: kText),
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  isExpanded: true,
                  style: TextStyle(fontSize: 14.sp, color: kText),
                  dropdownColor: kCardBg,
                  items: controller.filterOptions.map((filter) {
                    return DropdownMenuItem(value: filter, child: Text(filter, style: TextStyle(color: kText)));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) controller.applyFilter(value);
                  },
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoansList(LoanController controller) {
    if (controller.loans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.credit_card_outlined, size: 15.w, color: kSubText.withOpacity(0.5)),
            SizedBox(height: 2.h),
            Text('No loans found', style: TextStyle(fontSize: 14.sp, color: kSubText, fontWeight: FontWeight.w500)),
            SizedBox(height: 2.h),
            ElevatedButton(
              onPressed: () => controller.showAddLoanDialog(),
              style: ElevatedButton.styleFrom(backgroundColor: kPrimary, padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('Add Loan', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: controller.loans.length,
      itemBuilder: (context, index) {
        final loan = controller.loans[index];
        return _buildLoanCard(controller, loan);
      },
    );
  }

  Widget _buildLoanCard(LoanController controller, Loan loan) {
    Color statusColor = loan.status == 'Active' ? kPrimary : loan.status == 'Fully Paid' ? kSuccess : kDanger;
    double paidPercentage = (loan.totalPaid / loan.loanAmount) * 100;
    bool isOverdue = loan.nextPaymentDate != null && loan.nextPaymentDate!.isBefore(DateTime.now()) && loan.status == 'Active';
    
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.showLoanDetails(loan),
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
                        color: controller.getLoanTypeColor(loan.loanType).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(controller.getLoanIcon(loan.loanType), size: 7.w, color: controller.getLoanTypeColor(loan.loanType)),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(loan.loanNumber, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: kText))),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                child: Text(loan.status, style: TextStyle(fontSize: 12.sp, color: statusColor, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          SizedBox(height: 0.5.h),
                          Text(loan.lenderName, style: TextStyle(fontSize: 12.sp, color: kSubText)),
                          SizedBox(height: 0.5.h),
                          Text(loan.loanType, style: TextStyle(fontSize: 12.sp, color: kSubText)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Outstanding', style: TextStyle(fontSize: 12.sp, color: kSubText, fontWeight: FontWeight.w500)),
                        SizedBox(height: 0.5.h),
                        Text(controller.formatAmount(loan.outstandingBalance), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: kDanger)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 1.h),
                  child: Row(
                    children: [
                      Expanded(child: _buildInfoItem('Loan Amount', controller.formatAmount(loan.loanAmount), Icons.attach_money)),
                      Container(width: 1, height: 4.h, color: kBorder),
                      Expanded(child: _buildInfoItem('Interest Rate', '${loan.interestRate.toStringAsFixed(1)}%', Icons.percent)),
                      Container(width: 1, height: 4.h, color: kBorder),
                      Expanded(child: _buildInfoItem('Tenure', '${loan.tenureMonths} months', Icons.timeline)),
                    ],
                  ),
                ),
                SizedBox(height: 1.h),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 1.h),
                  child: Row(
                    children: [
                      Expanded(child: _buildInfoItem('EMI Amount', controller.formatAmount(loan.emiAmount), Icons.calendar_month)),
                      Container(width: 1, height: 4.h, color: kBorder),
                      Expanded(child: _buildInfoItem('Total Paid', controller.formatAmount(loan.totalPaid), Icons.check_circle)),
                      Container(width: 1, height: 4.h, color: kBorder),
                      Expanded(child: _buildInfoItem('Next Payment', loan.nextPaymentDate != null ? DateFormat('dd MMM yyyy').format(loan.nextPaymentDate!) : 'Completed', Icons.calendar_today)),
                    ],
                  ),
                ),
                SizedBox(height: 1.h),
                Container(
                  height: 0.8.h,
                  width: 100.w,
                  decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(4)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: paidPercentage / 100,
                      backgroundColor: kBg,
                      valueColor: AlwaysStoppedAnimation<Color>(paidPercentage > 90 ? kSuccess : paidPercentage > 70 ? kWarning : kPrimary),
                      minHeight: 0.8.h,
                    ),
                  ),
                ),
                SizedBox(height: 0.5.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('0%', style: TextStyle(fontSize: 12.sp, color: kSubText)),
                    Text('Payment Progress', style: TextStyle(fontSize: 12.sp, color: kSubText)),
                    Text('100%', style: TextStyle(fontSize: 12.sp, color: kSubText)),
                  ],
                ),
                if (isOverdue)
                  Padding(
                    padding: EdgeInsets.only(top: 1.h),
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(color: kDanger.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          Icon(Icons.warning, size: 4.w, color: kDanger),
                          SizedBox(width: 2.w),
                          Expanded(child: Text('Payment overdue! Due on ${DateFormat('dd MMM yyyy').format(loan.nextPaymentDate!)}', style: TextStyle(fontSize: 11.sp, color: kDanger, fontWeight: FontWeight.w500))),
                        ],
                      ),
                    ),
                  ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    if (loan.status == 'Active')
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => controller.showRecordPaymentDialog(loan),
                          icon: Icon(Icons.payment, size: 4.w, color: kSuccess),
                          label: Text('Record Payment', style: TextStyle(fontSize: 12.sp, color: kSuccess)),
                          style: OutlinedButton.styleFrom(side: BorderSide(color: kSuccess, width: 1), padding: EdgeInsets.symmetric(vertical: 1.2.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        ),
                      ),
                    if (loan.status == 'Active') SizedBox(width: 3.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => controller.viewPaymentSchedule(loan),
                        icon: Icon(Icons.calendar_view_month, size: 4.w, color: kPrimary),
                        label: Text('Schedule', style: TextStyle(fontSize: 12.sp, color: kPrimary)),
                        style: OutlinedButton.styleFrom(side: BorderSide(color: kPrimary, width: 1), padding: EdgeInsets.symmetric(vertical: 1.2.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      ),
                    ),
                    if (loan.status != 'Fully Paid') SizedBox(width: 3.w),
                    if (loan.status != 'Fully Paid')
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => controller.showPrepayDialog(loan),
                          icon: Icon(Icons.speed, size: 4.w, color: Colors.white),
                          label: Text('Prepay', style: TextStyle(fontSize: 12.sp, color: Colors.white)),
                          style: ElevatedButton.styleFrom(backgroundColor: kWarning, padding: EdgeInsets.symmetric(vertical: 1.2.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
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
              Text(label, style: TextStyle(fontSize: 12.sp, color: kSubText)),
              Text(value, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: kText), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFAB(LoanController controller) {
    return FloatingActionButton(
      onPressed: () => controller.showAddLoanDialog(),
      backgroundColor: kPrimary,
      child: Icon(Icons.add, color: Colors.white, size: 6.w),
      elevation: 3,
    );
  }
}