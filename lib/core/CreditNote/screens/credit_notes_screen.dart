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
    
    // ✅ Scaffold for Material context
    return Scaffold(
      backgroundColor: kBg,
      body: Obx(() {
        if (controller.isLoading.value && controller.creditNotes.isEmpty) {
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
              _buildCreditNotesList(controller, context),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  // ==================== HEADER ====================
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
            onTap: () => controller.exportCreditNotes(),
          ),
          if (!isMobile) const SizedBox(width: 8),
          if (!isMobile)
            _headerIconBtn(
              icon: Icons.add,
              size: isWeb ? 22 : 20,
              onTap: () => controller.showCreateCreditNoteDialog(),
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
  Widget _buildSummaryCards(CreditNoteController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 16 : 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Obx(() => _buildSummaryCard('Total Credit Notes', controller.totalCount.value.toString(), kPrimary, Icons.note, context, width: isWeb ? 200 : 160, isNumber: true)),
            SizedBox(width: isWeb ? 16 : 12),
            Obx(() => _buildSummaryCard('Total Amount', controller.formatAmount(controller.totalAmount.value), kWarning, Icons.attach_money, context, width: isWeb ? 200 : 160)),
            SizedBox(width: isWeb ? 16 : 12),
            Obx(() => _buildSummaryCard('Applied', controller.formatAmount(controller.appliedAmount.value), kSuccess, Icons.check_circle, context, width: isWeb ? 200 : 160)),
            SizedBox(width: isWeb ? 16 : 12),
            Obx(() => _buildSummaryCard('Remaining', controller.formatAmount(controller.remainingAmount.value), kPrimary, Icons.pending, context, width: isWeb ? 200 : 160)),
            SizedBox(width: isWeb ? 16 : 12),
            Obx(() => _buildSummaryCard('Expired', controller.formatAmount(controller.expiredAmount.value), kDanger, Icons.warning, context, width: isWeb ? 200 : 160)),
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
  Widget _buildFilterBar(CreditNoteController controller, BuildContext context) {
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

  // ==================== CREDIT NOTES LIST ====================
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
              Text('No credit notes found', style: TextStyle(fontSize: isWeb ? 18 : 16, color: kSubText)),
              SizedBox(height: isWeb ? 20 : 16),
              ElevatedButton(
                onPressed: () => controller.showCreateCreditNoteDialog(),
                style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                child: Text('Create Credit Note', style: TextStyle(fontSize: isWeb ? 14 : 12, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (isWeb) {
      return _buildWebCreditNotesTable(controller, context);
    } else {
      return _buildMobileCreditNotesList(controller, context);
    }
  }

  // ==================== WEB TABLE ====================
  Widget _buildWebCreditNotesTable(CreditNoteController controller, BuildContext context) {
    final creditNotes = controller.creditNotes;

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
                      Container(width: 150, child: const Text('Credit Note #', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 200, child: const Text('Customer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 120, child: const Text('Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 150, child: const Text('Amount', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 150, child: const Text('Applied', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 150, child: const Text('Remaining', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 120, child: const Text('Status', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 100, child: const Text('Actions', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    ],
                  ),
                ),
                ...creditNotes.asMap().entries.map((entry) {
                  final index = entry.key;
                  final creditNote = entry.value;
                  final isEven = index.isEven;
                  final statusColor = creditNote.status == 'Issued' ? kWarning : creditNote.status == 'Applied' ? kSuccess : kDanger;
                  
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
                          decoration: BoxDecoration(color: kWarning.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.note, size: 22, color: kWarning),
                        ),
                        // Credit Note #
                        Container(
                          width: 150,
                          child: Text(creditNote.creditNoteNumber, style:  TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kText)),
                        ),
                        // Customer
                        Container(
                          width: 200,
                          child: Text(creditNote.customerName, style:  TextStyle(fontSize: 13, color: kText), overflow: TextOverflow.ellipsis),
                        ),
                        // Date
                        Container(
                          width: 120,
                          child: Text(DateFormat('dd MMM yyyy').format(creditNote.date), style:  TextStyle(fontSize: 13, color: kSubText)),
                        ),
                        // Amount
                        Container(
                          width: 150,
                          child: Text(controller.formatAmount(creditNote.amount), textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kWarning)),
                        ),
                        // Applied
                        Container(
                          width: 150,
                          child: Text(controller.formatAmount(creditNote.appliedAmount), textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, color: kSuccess)),
                        ),
                        // Remaining
                        Container(
                          width: 150,
                          child: Text(controller.formatAmount(creditNote.remainingAmount), textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kPrimary)),
                        ),
                        // Status
                        Container(
                          width: 120,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                              child: Text(creditNote.status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
                            ),
                          ),
                        ),
                        // Actions
                        Container(
                          width: 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () => controller.viewCreditNoteDetails(creditNote),
                                icon: const Icon(Icons.remove_red_eye, size: 18),
                                padding: EdgeInsets.zero,
                                color: kPrimary,
                              ),
                              if (creditNote.status == 'Issued')
                                IconButton(
                                  onPressed: () => controller.showApplyCreditNoteDialog(creditNote),
                                  icon: const Icon(Icons.check_circle, size: 18),
                                  padding: EdgeInsets.zero,
                                  color: kSuccess,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                // Footer
                _buildTableFooter(controller, creditNotes),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableFooter(CreditNoteController controller, List<CreditNote> creditNotes) {
    final totalAmount = creditNotes.fold(0.0, (sum, c) => sum + c.amount);
    final totalApplied = creditNotes.fold(0.0, (sum, c) => sum + c.appliedAmount);
    final totalRemaining = creditNotes.fold(0.0, (sum, c) => sum + c.remainingAmount);
    
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
          Container(width: 150, child: Text(controller.formatAmount(totalAmount), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, color: kWarning))),
          Container(width: 150, child: Text(controller.formatAmount(totalApplied), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, color: kSuccess))),
          Container(width: 150, child: Text(controller.formatAmount(totalRemaining), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, color: kPrimary))),
          Container(width: 120, child: const SizedBox()),
          Container(width: 100, child: const SizedBox()),
        ],
      ),
    );
  }

  // ==================== MOBILE LIST ====================
  Widget _buildMobileCreditNotesList(CreditNoteController controller, BuildContext context) {
    final creditNotes = controller.creditNotes;
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text('Credit Notes', style:  TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kText)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text('${creditNotes.length} notes', style: const TextStyle(fontSize: 11, color: kPrimary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: creditNotes.length,
          itemBuilder: (context, index) {
            final creditNote = creditNotes[index];
            final statusColor = creditNote.status == 'Issued' ? kWarning : creditNote.status == 'Applied' ? kSuccess : kDanger;
            final statusIcon = creditNote.status == 'Issued' ? Icons.pending : creditNote.status == 'Applied' ? Icons.check_circle : Icons.warning;
            final isExpiringSoon = creditNote.status == 'Issued' && creditNote.expiryDate != null && creditNote.expiryDate!.difference(DateTime.now()).inDays <= 7;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildMobileCreditNoteCard(controller, creditNote, statusColor, statusIcon, isExpiringSoon, context),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMobileCreditNoteCard(CreditNoteController controller, CreditNote creditNote, Color statusColor, IconData statusIcon, bool isExpiringSoon, BuildContext context) {
    return Card(
      color: kCardBg,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => controller.viewCreditNoteDetails(creditNote),
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
                    decoration: BoxDecoration(color: kWarning.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.note, size: 20, color: kWarning),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(creditNote.creditNoteNumber, style:  TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: kText), overflow: TextOverflow.ellipsis)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(statusIcon, size: 10, color: statusColor),
                                const SizedBox(width: 2),
                                Text(creditNote.status, style: TextStyle(fontSize: 9, color: statusColor, fontWeight: FontWeight.w600)),
                              ]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(creditNote.customerName, style:  TextStyle(fontSize: 11, color: kSubText), overflow: TextOverflow.ellipsis),
                        Text('Date: ${DateFormat('dd MMM yyyy').format(creditNote.date)}', style:  TextStyle(fontSize: 10, color: kSubText)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                       Text('Amount', style: TextStyle(fontSize: 9, color: kSubText)),
                      const SizedBox(height: 2),
                      Text(controller.formatAmount(creditNote.amount), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: kWarning)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (isExpiringSoon && creditNote.expiryDate != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: kDanger.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      Icon(Icons.warning, size: 14, color: kDanger),
                      const SizedBox(width: 6),
                      Expanded(child: Text('Expires on: ${DateFormat('dd MMM yyyy').format(creditNote.expiryDate!)}', style: TextStyle(fontSize: 11, color: kDanger, fontWeight: FontWeight.w600))),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (creditNote.status == 'Issued')
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => controller.showApplyCreditNoteDialog(creditNote),
                        icon: const Icon(Icons.check_circle, size: 14, color: Colors.white),
                        label: const Text('Apply', style: TextStyle(fontSize: 10)),
                        style: ElevatedButton.styleFrom(backgroundColor: kSuccess, padding: const EdgeInsets.symmetric(vertical: 8)),
                      ),
                    ),
                  if (creditNote.status == 'Issued') const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.printCreditNote(creditNote),
                      icon: const Icon(Icons.print, size: 14),
                      label: const Text('Print', style: TextStyle(fontSize: 10)),
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