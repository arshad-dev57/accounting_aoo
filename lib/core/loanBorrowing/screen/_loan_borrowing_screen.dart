import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/Utils/responsive_utils.dart';
import 'package:LedgerPro_app/core/loanBorrowing/controller/loan_controller.dart';
import 'package:LedgerPro_app/core/loanBorrowing/models/loan_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoansBorrowingsScreen extends StatelessWidget {
  const LoansBorrowingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoanController());

    return Container(
      color: kBg,
      child: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LoadingAnimationWidget.waveDots(
                  color: kPrimary,
                  size: ResponsiveUtils.isWeb(context) ? 60 : 40,
                ),
                SizedBox(height: ResponsiveUtils.isWeb(context) ? 16 : 12),
                Text('Loading loans...', style: TextStyle(fontSize: ResponsiveUtils.isWeb(context) ? 14 : 12, color: kSubText)),
              ],
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
              _buildLoansList(controller, context),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  // Custom Header without AppBar
  Widget _buildHeader(LoanController controller, BuildContext context) {
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
                  'Loans & Borrowings',
                  style: TextStyle(
                    fontSize: isWeb ? 20 : 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage all your loans and borrowings',
                  style: TextStyle(
                    fontSize: isWeb ? 13 : 11,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          // EMI Calculator Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.calculate_outlined, color: Colors.white, size: isWeb ? 22 : 20),
              onPressed: () => controller.showEMICalculator(),
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
              onPressed: () => controller.exportLoans(),
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
              onPressed: () => controller.printLoans(),
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
                onPressed: () => controller.showAddLoanDialog(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(LoanController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Obx(() => Container(
      padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 16 : 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildSummaryCard('Total Loans', controller.totalLoans.value.toString(), kPrimary, Icons.credit_card, context, width: isWeb ? 200 : 160, isNumber: true),
            SizedBox(width: isWeb ? 16 : 12),
            _buildSummaryCard('Total Principal', controller.formatAmount(controller.totalPrincipal.value), kPrimary, Icons.attach_money, context, width: isWeb ? 220 : 170),
            SizedBox(width: isWeb ? 16 : 12),
            _buildSummaryCard('Outstanding', controller.formatAmount(controller.totalOutstanding.value), kDanger, Icons.payment, context, width: isWeb ? 220 : 170),
            SizedBox(width: isWeb ? 16 : 12),
            _buildSummaryCard('Total Paid', controller.formatAmount(controller.totalPaid.value), kSuccess, Icons.check_circle, context, width: isWeb ? 220 : 170),
            SizedBox(width: isWeb ? 16 : 12),
            _buildSummaryCard('Monthly EMI', controller.formatAmount(controller.totalEMI.value), kWarning, Icons.calendar_month, context, width: isWeb ? 220 : 170),
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
              Expanded(child: Text(title, style: TextStyle(fontSize: isWeb ? 12 : 11, color: kSubText, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ),
          SizedBox(height: isWeb ? 8 : 6),
          Text(isNumber ? amount : amount, style: TextStyle(fontSize: isWeb ? 18 : 14, fontWeight: FontWeight.w800, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildFilterBar(LoanController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
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
              decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(isWeb ? 12 : 10), border: Border.all(color: kBorder)),
              child: TextField(
                controller: controller.searchController,
                style: TextStyle(fontSize: isWeb ? 14 : 12, color: kText),
                decoration: InputDecoration(
                  hintText: isWeb ? 'Search by loan ID, lender, type...' : 'Search...',
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
              decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(isWeb ? 12 : 10), border: Border.all(color: kBorder)),
              child: Obx(() => DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.selectedFilter.value,
                  icon: Icon(Icons.arrow_drop_down, size: isWeb ? 24 : 20, color: kText),
                  padding: EdgeInsets.symmetric(horizontal: isWeb ? 16 : 12),
                  isExpanded: true,
                  style: TextStyle(fontSize: isWeb ? 13 : 12, color: kText),
                  dropdownColor: kCardBg,
                  items: controller.filterOptions.map((filter) {
                    return DropdownMenuItem(value: filter, child: Text(filter, style: TextStyle(color: kText, fontSize: isWeb ? 13 : 12)));
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

  Widget _buildLoansList(LoanController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    if (controller.loans.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(isWeb ? 40 : 20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.credit_card_outlined, size: isWeb ? 80 : 64, color: kSubText.withOpacity(0.5)),
              SizedBox(height: isWeb ? 20 : 16),
              Text('No loans found', style: TextStyle(fontSize: isWeb ? 18 : 16, color: kSubText, fontWeight: FontWeight.w500)),
              SizedBox(height: isWeb ? 20 : 16),
              ElevatedButton(
                onPressed: () => controller.showAddLoanDialog(),
                style: ElevatedButton.styleFrom(backgroundColor: kPrimary, padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 12 : 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isWeb ? 12 : 10))),
                child: Text('Add Loan', style: TextStyle(fontSize: isWeb ? 14 : 12, fontWeight: FontWeight.w600, color: Colors.white)),
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
            'Loans & Borrowings',
            style: TextStyle(
              fontSize: isWeb ? 18 : 16,
              fontWeight: FontWeight.w700,
              color: kText,
            ),
          ),
        ),
        ...controller.loans.map((loan) => Padding(
          padding: EdgeInsets.symmetric(horizontal: isWeb ? 20 : 12, vertical: isWeb ? 8 : 6),
          child: _buildLoanCard(controller, loan, context),
        )).toList(),
      ],
    );
  }

  Widget _buildLoanCard(LoanController controller, Loan loan, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final isMobile = ResponsiveUtils.isMobile(context);
    
    Color statusColor = loan.status == 'Active' ? kPrimary : loan.status == 'Fully Paid' ? kSuccess : kDanger;
    double paidPercentage = (loan.totalPaid / loan.loanAmount) * 100;
    bool isOverdue = loan.nextPaymentDate != null && loan.nextPaymentDate!.isBefore(DateTime.now()) && loan.status == 'Active';
    
    return Container(
      margin: EdgeInsets.only(bottom: isWeb ? 12 : 8),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.showLoanDetails(loan),
          borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
          child: Padding(
            padding: EdgeInsets.all(isWeb ? 16 : 12),
            child: isMobile
                ? _buildMobileLoanCard(controller, loan, statusColor, paidPercentage, isOverdue, context)
                : _buildDesktopLoanCard(controller, loan, statusColor, paidPercentage, isOverdue, context),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLoanCard(LoanController controller, Loan loan, Color statusColor, double paidPercentage, bool isOverdue, BuildContext context) {
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
                color: controller.getLoanTypeColor(loan.loanType).withOpacity(0.1),
                borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
              ),
              child: Icon(controller.getLoanIcon(loan.loanType), size: isWeb ? 24 : 20, color: controller.getLoanTypeColor(loan.loanType)),
            ),
            SizedBox(width: isWeb ? 16 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(loan.loanNumber, style: TextStyle(fontSize: isWeb ? 15 : 13, fontWeight: FontWeight.w800, color: kText)),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: isWeb ? 8 : 6, vertical: isWeb ? 4 : 2),
                        decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(isWeb ? 6 : 4)),
                        child: Text(loan.status, style: TextStyle(fontSize: isWeb ? 11 : 10, color: statusColor, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  SizedBox(height: isWeb ? 4 : 2),
                  Text(loan.lenderName, style: TextStyle(fontSize: isWeb ? 12 : 11, color: kSubText)),
                  SizedBox(height: isWeb ? 4 : 2),
                  Text(loan.loanType, style: TextStyle(fontSize: isWeb ? 12 : 11, color: kSubText)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Outstanding', style: TextStyle(fontSize: isWeb ? 11 : 10, color: kSubText, fontWeight: FontWeight.w500)),
                SizedBox(height: isWeb ? 4 : 2),
                Text(controller.formatAmount(loan.outstandingBalance), style: TextStyle(fontSize: isWeb ? 16 : 14, fontWeight: FontWeight.w800, color: kDanger)),
              ],
            ),
          ],
        ),
        SizedBox(height: isWeb ? 16 : 12),
        Container(
          padding: EdgeInsets.symmetric(vertical: isWeb ? 10 : 8),
          child: Row(
            children: [
              Expanded(child: _buildInfoItem('Loan Amount', controller.formatAmount(loan.loanAmount), Icons.attach_money, isWeb)),
              Container(width: 1, height: isWeb ? 32 : 24, color: kBorder),
              Expanded(child: _buildInfoItem('Interest Rate', '${loan.interestRate.toStringAsFixed(1)}%', Icons.percent, isWeb)),
              Container(width: 1, height: isWeb ? 32 : 24, color: kBorder),
              Expanded(child: _buildInfoItem('Tenure', '${loan.tenureMonths} months', Icons.timeline, isWeb)),
            ],
          ),
        ),
        SizedBox(height: isWeb ? 8 : 6),
        Container(
          padding: EdgeInsets.symmetric(vertical: isWeb ? 10 : 8),
          child: Row(
            children: [
              Expanded(child: _buildInfoItem('EMI Amount', controller.formatAmount(loan.emiAmount), Icons.calendar_month, isWeb)),
              Container(width: 1, height: isWeb ? 32 : 24, color: kBorder),
              Expanded(child: _buildInfoItem('Total Paid', controller.formatAmount(loan.totalPaid), Icons.check_circle, isWeb)),
              Container(width: 1, height: isWeb ? 32 : 24, color: kBorder),
              Expanded(child: _buildInfoItem('Next Payment', loan.nextPaymentDate != null ? DateFormat('dd MMM yyyy').format(loan.nextPaymentDate!) : 'Completed', Icons.calendar_today, isWeb)),
            ],
          ),
        ),
        SizedBox(height: isWeb ? 12 : 8),
        Container(
          height: isWeb ? 6 : 4,
          width: double.infinity,
          decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(isWeb ? 4 : 2)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isWeb ? 4 : 2),
            child: LinearProgressIndicator(
              value: paidPercentage / 100,
              backgroundColor: kBg,
              valueColor: AlwaysStoppedAnimation<Color>(paidPercentage > 90 ? kSuccess : paidPercentage > 70 ? kWarning : kPrimary),
              minHeight: isWeb ? 6 : 4,
            ),
          ),
        ),
        SizedBox(height: isWeb ? 4 : 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0%', style: TextStyle(fontSize: isWeb ? 10 : 9, color: kSubText)),
            Text('Payment Progress', style: TextStyle(fontSize: isWeb ? 11 : 9, color: kSubText)),
            Text('100%', style: TextStyle(fontSize: isWeb ? 10 : 9, color: kSubText)),
          ],
        ),
        if (isOverdue)
          Padding(
            padding: EdgeInsets.only(top: isWeb ? 12 : 8),
            child: Container(
              padding: EdgeInsets.all(isWeb ? 12 : 10),
              decoration: BoxDecoration(color: kDanger.withOpacity(0.1), borderRadius: BorderRadius.circular(isWeb ? 10 : 8)),
              child: Row(
                children: [
                  Icon(Icons.warning, size: isWeb ? 18 : 14, color: kDanger),
                  SizedBox(width: isWeb ? 8 : 6),
                  Expanded(
                    child: Text(
                      'Payment overdue! Due on ${DateFormat('dd MMM yyyy').format(loan.nextPaymentDate!)}',
                      style: TextStyle(fontSize: isWeb ? 12 : 11, color: kDanger, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
        SizedBox(height: isWeb ? 16 : 12),
        Row(
          children: [
            if (loan.status == 'Active')
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.showRecordPaymentDialog(loan),
                  icon: Icon(Icons.payment, size: isWeb ? 18 : 14, color: kSuccess),
                  label: Text('Record Payment', style: TextStyle(fontSize: isWeb ? 12 : 10, color: kSuccess)),
                  style: _buttonStyle(kSuccess, isWeb),
                ),
              ),
            if (loan.status == 'Active') SizedBox(width: isWeb ? 12 : 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => controller.viewPaymentSchedule(loan),
                icon: Icon(Icons.calendar_view_month, size: isWeb ? 18 : 14, color: kPrimary),
                label: Text('Schedule', style: TextStyle(fontSize: isWeb ? 12 : 10, color: kPrimary)),
                style: _buttonStyle(kPrimary, isWeb),
              ),
            ),
            if (loan.status != 'Fully Paid') SizedBox(width: isWeb ? 12 : 8),
            if (loan.status != 'Fully Paid')
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => controller.showPrepayDialog(loan),
                  icon: Icon(Icons.speed, size: isWeb ? 18 : 14, color: Colors.white),
                  label: Text('Prepay', style: TextStyle(fontSize: isWeb ? 12 : 10, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kWarning,
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

  Widget _buildMobileLoanCard(LoanController controller, Loan loan, Color statusColor, double paidPercentage, bool isOverdue, BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: controller.getLoanTypeColor(loan.loanType).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(controller.getLoanIcon(loan.loanType), size: 20, color: controller.getLoanTypeColor(loan.loanType)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(loan.loanNumber, style:  TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: kText)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text(loan.status, style: TextStyle(fontSize: 9, color: statusColor, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(loan.lenderName, style:  TextStyle(fontSize: 10, color: kSubText)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                 Text('Outstanding', style: TextStyle(fontSize: 9, color: kSubText)),
                const SizedBox(height: 2),
                Text(controller.formatAmount(loan.outstandingBalance), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: kDanger)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildInfoItem('Amount', controller.formatAmount(loan.loanAmount), Icons.attach_money, false)),
            Expanded(child: _buildInfoItem('EMI', controller.formatAmount(loan.emiAmount), Icons.calendar_month, false)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildInfoItem('Paid', controller.formatAmount(loan.totalPaid), Icons.check_circle, false)),
            Expanded(child: _buildInfoItem('Rate', '${loan.interestRate.toStringAsFixed(1)}%', Icons.percent, false)),
          ],
        ),
        const SizedBox(height: 12),
        if (isOverdue)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: kDanger.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: Row(
              children: [
                Icon(Icons.warning, size: 14, color: kDanger),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Overdue!',
                    style: TextStyle(fontSize: 10, color: kDanger, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (loan.status == 'Active')
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.showRecordPaymentDialog(loan),
                  icon: Icon(Icons.payment, size: 14, color: kSuccess),
                  label: const Text('Pay', style: TextStyle(fontSize: 9, color: kSuccess)),
                  style: _buttonStyle(kSuccess, false),
                ),
              ),
            if (loan.status == 'Active') const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => controller.viewPaymentSchedule(loan),
                icon: Icon(Icons.calendar_view_month, size: 14, color: kPrimary),
                label: const Text('Schedule', style: TextStyle(fontSize: 9, color: kPrimary)),
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
              Text(label, style: TextStyle(fontSize: isWeb ? 11 : 8, color: kSubText)),
              Text(value, style: TextStyle(fontSize: isWeb ? 11 : 9, fontWeight: FontWeight.w600, color: kText), maxLines: 1, overflow: TextOverflow.ellipsis),
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