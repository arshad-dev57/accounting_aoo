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
    
    return Scaffold(
      backgroundColor: kBg,
      body: Obx(() {
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

  // ==================== HEADER ====================
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
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _headerIconBtn(
            icon: Icons.calculate_outlined,
            size: isWeb ? 22 : 20,
            onTap: () => controller.showEMICalculator(),
          ),
          if (!isMobile) const SizedBox(width: 8),
          _headerIconBtn(
            icon: Icons.download_outlined,
            size: isWeb ? 22 : 20,
            onTap: () => controller.exportLoans(),
          ),
          if (!isMobile) const SizedBox(width: 8),
          if (!isMobile)
            _headerIconBtn(
              icon: Icons.add,
              size: isWeb ? 22 : 20,
              onTap: () => controller.showAddLoanDialog(),
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
  Widget _buildFilterBar(LoanController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
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
                      if (value != null) controller.applyFilter(value);
                    },
                  ),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== LOANS LIST ====================
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
                style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                child: Text('Add Loan', style: TextStyle(fontSize: isWeb ? 14 : 12, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (isWeb) {
      return _buildWebLoansTable(controller, context);
    } else {
      return _buildMobileLoansList(controller, context);
    }
  }

  // ==================== WEB TABLE ====================
  Widget _buildWebLoansTable(LoanController controller, BuildContext context) {
    final loans = controller.loans;
    
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
                      Container(width: 120, child: const Text('Loan #', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 180, child: const Text('Lender', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 120, child: const Text('Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 150, child: const Text('Loan Amount', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 120, child: const Text('EMI', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 150, child: const Text('Total Paid', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 150, child: const Text('Outstanding', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 100, child: const Text('Status', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 80, child: const Text('Actions', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    ],
                  ),
                ),
                ...loans.asMap().entries.map((entry) {
                  final index = entry.key;
                  final loan = entry.value;
                  final isEven = index.isEven;
                  final statusColor = loan.status == 'Active' ? kPrimary : loan.status == 'Fully Paid' ? kSuccess : kDanger;
                  
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
                          decoration: BoxDecoration(
                            color: controller.getLoanTypeColor(loan.loanType).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(controller.getLoanIcon(loan.loanType), size: 22, color: controller.getLoanTypeColor(loan.loanType)),
                        ),
                        // Loan Number
                        Container(
                          width: 120,
                          child: Text(loan.loanNumber, style:  TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kText)),
                        ),
                        // Lender
                        Container(
                          width: 180,
                          child: Text(loan.lenderName, style:  TextStyle(fontSize: 13, color: kText), overflow: TextOverflow.ellipsis),
                        ),
                        // Type
                        Container(
                          width: 120,
                          child: Text(loan.loanType, style:  TextStyle(fontSize: 13, color: kText), overflow: TextOverflow.ellipsis),
                        ),
                        // Loan Amount
                        Container(
                          width: 150,
                          child: Text(controller.formatAmount(loan.loanAmount), textAlign: TextAlign.right, style:  TextStyle(fontSize: 13, color: kText)),
                        ),
                        // EMI
                        Container(
                          width: 120,
                          child: Text(controller.formatAmount(loan.emiAmount), textAlign: TextAlign.right, style:  TextStyle(fontSize: 13, color: kText)),
                        ),
                        // Total Paid
                        Container(
                          width: 150,
                          child: Text(controller.formatAmount(loan.totalPaid), textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, color: kSuccess)),
                        ),
                        // Outstanding
                        Container(
                          width: 150,
                          child: Text(controller.formatAmount(loan.outstandingBalance), textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kDanger)),
                        ),
                        // Status
                        Container(
                          width: 100,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                              child: Text(loan.status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
                            ),
                          ),
                        ),
                        // Actions
                        Container(
                          width: 80,
                          child: IconButton(
                            onPressed: () => controller.showLoanDetails(loan),
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
                _buildTableFooter(controller, loans),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableFooter(LoanController controller, List<Loan> loans) {
    final totalAmount = loans.fold(0.0, (sum, l) => sum + l.loanAmount);
    final totalEMI = loans.fold(0.0, (sum, l) => sum + l.emiAmount);
    final totalPaid = loans.fold(0.0, (sum, l) => sum + l.totalPaid);
    final totalOutstanding = loans.fold(0.0, (sum, l) => sum + l.outstandingBalance);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: kPrimary.withOpacity(0.06),
        border:  Border(top: BorderSide(color: kBorder)),
      ),
      child: Row(
        children: [
          Container(width: 60, child: const Text('')),
          Container(width: 120, child: const Text('TOTALS', style: TextStyle(fontWeight: FontWeight.bold))),
          Container(width: 180, child: const SizedBox()),
          Container(width: 120, child: const SizedBox()),
          Container(width: 150, child: Text(controller.formatAmount(totalAmount), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold))),
          Container(width: 120, child: Text(controller.formatAmount(totalEMI), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold))),
          Container(width: 150, child: Text(controller.formatAmount(totalPaid), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, color: kSuccess))),
          Container(width: 150, child: Text(controller.formatAmount(totalOutstanding), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, color: kDanger))),
          Container(width: 100, child: const SizedBox()),
          Container(width: 80, child: const SizedBox()),
        ],
      ),
    );
  }

  // ==================== MOBILE LIST ====================
  Widget _buildMobileLoansList(LoanController controller, BuildContext context) {
    final loans = controller.loans;
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text('Loans & Borrowings', style:  TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kText)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text('${loans.length} loans', style: const TextStyle(fontSize: 11, color: kPrimary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: loans.length,
          itemBuilder: (context, index) {
            final loan = loans[index];
            final statusColor = loan.status == 'Active' ? kPrimary : loan.status == 'Fully Paid' ? kSuccess : kDanger;
            final paidPercentage = (loan.totalPaid / loan.loanAmount) * 100;
            final isOverdue = loan.nextPaymentDate != null && loan.nextPaymentDate!.isBefore(DateTime.now()) && loan.status == 'Active';
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildMobileLoanCard(controller, loan, statusColor, paidPercentage, isOverdue, context),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMobileLoanCard(LoanController controller, Loan loan, Color statusColor, double paidPercentage, bool isOverdue, BuildContext context) {
    return Card(
      color: kCardBg,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => controller.showLoanDetails(loan),
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
                            Expanded(child: Text(loan.loanNumber, style:  TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: kText), overflow: TextOverflow.ellipsis)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                              child: Text(loan.status, style: TextStyle(fontSize: 9, color: statusColor, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(loan.lenderName, style:  TextStyle(fontSize: 10, color: kSubText), overflow: TextOverflow.ellipsis),
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
              if (isOverdue) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: kDanger.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Row(
                    children: [
                      Icon(Icons.warning, size: 14, color: kDanger),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text('Overdue!', style: TextStyle(fontSize: 10, color: kDanger, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  if (loan.status == 'Active')
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => controller.showRecordPaymentDialog(loan),
                        icon: Icon(Icons.payment, size: 14, color: kSuccess),
                        label: const Text('Pay', style: TextStyle(fontSize: 10)),
                        style: _buttonStyle(kSuccess, false),
                      ),
                    ),
                  if (loan.status == 'Active') const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.viewPaymentSchedule(loan),
                      icon: Icon(Icons.calendar_view_month, size: 14, color: kPrimary),
                      label: const Text('Schedule', style: TextStyle(fontSize: 10)),
                      style: _buttonStyle(kPrimary, false),
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
}