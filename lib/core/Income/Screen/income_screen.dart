import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/Utils/responsive_utils.dart';
import 'package:LedgerPro_app/Utils/toast_utils.dart';
import 'package:LedgerPro_app/core/Income/controller/income_controller.dart';
import 'package:LedgerPro_app/core/Income/models/income_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class IncomeScreen extends StatelessWidget {
  const IncomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(IncomeController());

    // ✅ Scaffold for Material context
    return Scaffold(
      backgroundColor: kBg,
      body: Obx(() {
        if (controller.isLoading.value && controller.incomes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LoadingAnimationWidget.waveDots(
                  color: kPrimary,
                  size: ResponsiveUtils.isWeb(context) ? 60 : 40,
                ),
                SizedBox(height: ResponsiveUtils.isWeb(context) ? 16 : 12),
                Text('Loading incomes...', style: TextStyle(fontSize: ResponsiveUtils.isWeb(context) ? 14 : 12, color: kSubText)),
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
              _buildIncomesList(controller, context),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader(IncomeController controller, BuildContext context) {
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
                  'Income',
                  style: TextStyle(
                    fontSize: isWeb ? 20 : 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage all your income transactions',
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
            icon: Icons.filter_alt_outlined,
            size: isWeb ? 22 : 20,
            onTap: () => _showFilterDialog(controller, context),
          ),
          const SizedBox(width: 8),
          _headerIconBtn(
            icon: Icons.download_outlined,
            size: isWeb ? 22 : 20,
            onTap: () => controller.exportIncomes(),
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
                onPressed: () => _showAddIncomeDialog(controller, context),
              ),
            ),
        ],
      ),
    );
  }

  Widget _headerIconBtn({
    required IconData icon,
    required double size,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: size),
      ),
    );
  }

  // ==================== SUMMARY CARDS ====================
  Widget _buildSummaryCards(IncomeController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Obx(() => Container(
      padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 16 : 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildSummaryCard('Total Income', controller.formatAmount(controller.totalIncome.value), kSuccess, Icons.trending_up, context, width: isWeb ? 220 : 160),
            SizedBox(width: isWeb ? 16 : 12),
            _buildSummaryCard('Total Tax', controller.formatAmount(controller.totalTax.value), kWarning, Icons.receipt, context, width: isWeb ? 200 : 150),
            SizedBox(width: isWeb ? 16 : 12),
            _buildSummaryCard('This Month', controller.formatAmount(controller.thisMonthTotal.value), kPrimary, Icons.calendar_month, context, width: isWeb ? 220 : 160),
            SizedBox(width: isWeb ? 16 : 12),
            _buildSummaryCard('This Week', controller.formatAmount(controller.thisWeekTotal.value), kPrimary, Icons.calendar_today, context, width: isWeb ? 200 : 150),
            SizedBox(width: isWeb ? 16 : 12),
            _buildSummaryCard('Total Records', controller.totalCount.value.toString(), kPrimary, Icons.receipt_long, context, width: isWeb ? 200 : 150, isNumber: true),
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
  Widget _buildFilterBar(IncomeController controller, BuildContext context) {
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
                        hintText: isWeb ? 'Search by number, customer, description...' : 'Search...',
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
                          return DropdownMenuItem(value: filter, child: Text(filter, style: TextStyle(color: kText), overflow: TextOverflow.ellipsis));
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
            SizedBox(height: isWeb ? 12 : 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: controller.incomeTypes.map((type) {
                  final isSelected = controller.selectedType.value == type;
                  return Padding(
                    padding: EdgeInsets.only(right: isWeb ? 8 : 6),
                    child: FilterChip(
                      label: Text(type, style: TextStyle(fontSize: isWeb ? 12 : 11)),
                      selected: isSelected,
                      onSelected: (selected) {
                        controller.applyTypeFilter(selected ? type : 'All');
                      },
                      backgroundColor: kBg,
                      selectedColor: kPrimary.withOpacity(0.2),
                      labelStyle: TextStyle(color: isSelected ? kPrimary : kSubText),
                    ),
                  );
                }).toList(),
              ),
            ),
            if (controller.startDate.value != null && controller.endDate.value != null)
              Padding(
                padding: EdgeInsets.only(top: isWeb ? 12 : 8),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: isWeb ? 16 : 12, vertical: isWeb ? 10 : 8),
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
                                '${DateFormat('dd MMM yyyy').format(controller.startDate.value!)} - ${DateFormat('dd MMM yyyy').format(controller.endDate.value!)}',
                                style: TextStyle(fontSize: isWeb ? 12 : 11, color: kPrimary),
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
              ),
          ],
        ),
      ),
    );
  }

  // ==================== INCOMES LIST ====================
  Widget _buildIncomesList(IncomeController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    if (controller.incomes.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(isWeb ? 40 : 20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.trending_up, size: isWeb ? 80 : 64, color: kSubText.withOpacity(0.5)),
              SizedBox(height: isWeb ? 20 : 16),
              Text('No income records found', style: TextStyle(fontSize: isWeb ? 18 : 16, color: kSubText)),
              SizedBox(height: isWeb ? 20 : 16),
              ElevatedButton(
                onPressed: () => _showAddIncomeDialog(controller, context),
                style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                child: Text('Add Income', style: TextStyle(fontSize: isWeb ? 14 : 12, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (isWeb) {
      return _buildWebIncomeTable(controller, context);
    } else {
      return _buildMobileIncomeList(controller, context);
    }
  }

  // ==================== WEB TABLE ====================
  Widget _buildWebIncomeTable(IncomeController controller, BuildContext context) {
    final incomes = controller.incomes;

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
                      Container(width: 150, child: const Text('Income #', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 120, child: const Text('Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 180, child: const Text('Customer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 120, child: const Text('Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 80, child: const Text('Tax', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 150, child: const Text('Amount', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 100, child: const Text('Status', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 120, child: const Text('Actions', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    ],
                  ),
                ),
                ...incomes.asMap().entries.map((entry) {
                  final index = entry.key;
                  final income = entry.value;
                  final isEven = index.isEven;
                  final typeColor = Color(int.parse(controller.getTypeColor(income.incomeType).substring(1, 7), radix: 16) + 0xFF000000);
                  final statusColor = income.status == 'Posted' ? kSuccess : income.status == 'Draft' ? kWarning : kDanger;

                  return InkWell(
                    onTap: () => _showIncomeDetails(income, context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
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
                            decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                            child: Icon(controller.getTypeIcon(income.incomeType), size: 20, color: typeColor),
                          ),
                          // Income Number
                          Container(
                            width: 150,
                            child: Text(income.incomeNumber, style:  TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kText), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                          // Type
                          Container(
                            width: 120,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                              child: Text(income.incomeType, style: TextStyle(fontSize: 11, color: typeColor, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                            ),
                          ),
                          // Customer
                          Container(
                            width: 180,
                            child: Text(income.customerName.isNotEmpty ? income.customerName : '-', style:  TextStyle(fontSize: 13, color: kSubText), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                          // Date
                          Container(
                            width: 120,
                            child: Text(DateFormat('dd MMM yyyy').format(income.date), style:  TextStyle(fontSize: 13, color: kSubText)),
                          ),
                          // Tax
                          Container(
                            width: 80,
                            child: Text(income.taxRate > 0 ? '${income.taxRate.toStringAsFixed(0)}%' : '-', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: kWarning, fontWeight: FontWeight.w600)),
                          ),
                          // Amount
                          Container(
                            width: 150,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(color: kSuccess.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                                child: Text(controller.formatAmount(income.totalAmount), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kSuccess)),
                              ),
                            ),
                          ),
                          // Status
                          Container(
                            width: 100,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                                    const SizedBox(width: 4),
                                    Text(income.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Actions
                          Container(
                            width: 120,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () => _showIncomeDetails(income, context),
                                  icon: const Icon(Icons.remove_red_eye, size: 18),
                                  tooltip: 'View Details',
                                  padding: EdgeInsets.zero,
                                  color: kPrimary,
                                ),
                                if (income.status == 'Draft') ...[
                                  IconButton(
                                    onPressed: () => controller.postIncome(income.id),
                                    icon: const Icon(Icons.check_circle, size: 18),
                                    tooltip: 'Post',
                                    padding: EdgeInsets.zero,
                                    color: kSuccess,
                                  ),
                                  IconButton(
                                    onPressed: () => _showRowActions(controller, income, context),
                                    icon: const Icon(Icons.more_vert, size: 18),
                                    tooltip: 'More',
                                    padding: EdgeInsets.zero,
                                    color: kSubText,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                // Footer
                _buildTableFooter(controller, incomes),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableFooter(IncomeController controller, List<Income> incomes) {
    final postedCount = incomes.where((i) => i.status == 'Posted').length;
    
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
          Container(width: 120, child: const SizedBox()),
          Container(width: 180, child: const SizedBox()),
          Container(width: 120, child: const SizedBox()),
          Container(width: 80, child: const SizedBox()),
          Container(width: 150, child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(color: kSuccess.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(controller.formatAmount(controller.totalIncome.value), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: kSuccess)),
            ),
          )),
          Container(width: 100, child: Center(child: Text('$postedCount Posted', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: kSuccess)))),
          Container(width: 120, child: const SizedBox()),
        ],
      ),
    );
  }

  // ==================== MOBILE LIST ====================
  Widget _buildMobileIncomeList(IncomeController controller, BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text('Income Records', style:  TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kText)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text('${controller.incomes.length} records', style: const TextStyle(fontSize: 11, color: kPrimary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: controller.incomes.length,
          itemBuilder: (context, index) {
            final income = controller.incomes[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildMobileIncomeCard(controller, income, context),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMobileIncomeCard(IncomeController controller, Income income, BuildContext context) {
    final statusColor = income.status == 'Posted' ? kSuccess : income.status == 'Draft' ? kWarning : kDanger;
    final typeColor = Color(int.parse(controller.getTypeColor(income.incomeType).substring(1, 7), radix: 16) + 0xFF000000);
    
    return Card(
      color: kCardBg,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showIncomeDetails(income, context),
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
                    decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: Icon(controller.getTypeIcon(income.incomeType), size: 20, color: typeColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(income.incomeNumber, style:  TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: kText), overflow: TextOverflow.ellipsis),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                              child: Text(income.status, style: TextStyle(fontSize: 9, color: statusColor, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(income.incomeType, style: TextStyle(fontSize: 11, color: typeColor, fontWeight: FontWeight.w600)),
                        if (income.customerName.isNotEmpty)
                          Text(income.customerName, style:  TextStyle(fontSize: 11, color: kSubText), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(controller.formatAmount(income.totalAmount), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: kSuccess)),
                      const SizedBox(height: 2),
                      Text(DateFormat('dd MMM yyyy').format(income.date), style:  TextStyle(fontSize: 9, color: kSubText)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Divider(color: kBorder),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (income.status == 'Draft')
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => controller.postIncome(income.id),
                        icon: Icon(Icons.check_circle, size: 14, color: kSuccess),
                        label: const Text('Post', style: TextStyle(fontSize: 10, color: kSuccess)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: kSuccess, width: 1),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                    ),
                  if (income.status == 'Draft') const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showIncomeDetails(income, context),
                      icon: Icon(Icons.visibility, size: 14, color: kPrimary),
                      label: const Text('Details', style: TextStyle(fontSize: 10, color: kPrimary)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: kPrimary, width: 1),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
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

  // ==================== DIALOGS & MODALS ====================
  void _showAddIncomeDialog(IncomeController controller, BuildContext ctx) {
    final isWeb = ResponsiveUtils.isWeb(ctx);
    final formKey = GlobalKey<FormState>();
    DateTime selectedDate = DateTime.now();
    String incomeType = 'Sales';
    String? selectedCustomerId;
    double simpleAmount = 0;
    List<Map<String, dynamic>> items = [];
    double taxRate = 0;
    String description = '';
    String reference = '';
    String paymentMethod = 'Cash';
    String? selectedBankAccountId;
    
    void addItem() {
      items.add({'description': '', 'quantity': 1, 'unitPrice': 0.0});
    }
    addItem();
    
    bool requiresItems() {
      return incomeType == 'Sales' || incomeType == 'Services';
    }
    
    showDialog(
      context: ctx,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          double calculateTotal() {
            if (requiresItems()) {
              double total = 0;
              for (var item in items) {
                final qty = (item['quantity'] ?? 1).toDouble();
                final price = (item['unitPrice'] ?? 0).toDouble();
                total += qty * price;
              }
              final tax = total * (taxRate / 100);
              return total + tax;
            } else {
              return simpleAmount;
            }
          }
          
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              width: isWeb ? 600 : MediaQuery.of(context).size.width * 0.9,
              constraints: BoxConstraints(maxHeight: isWeb ? 700 : 600),
              padding: EdgeInsets.all(isWeb ? 24 : 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Add Income', style: TextStyle(fontSize: isWeb ? 20 : 18, fontWeight: FontWeight.w800, color: kText)),
                  SizedBox(height: isWeb ? 20 : 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            _buildDatePicker('Date', selectedDate, (date) => setState(() => selectedDate = date), isWeb, context),
                            SizedBox(height: isWeb ? 16 : 12),
                            _buildDropdown('Income Type', incomeType, controller.incomeTypes.skip(1).toList(), (v) => setState(() => incomeType = v!), isWeb, context),
                            SizedBox(height: isWeb ? 16 : 12),
                            _buildCustomerDropdown(selectedCustomerId, (v) => setState(() => selectedCustomerId = v), controller.customers, isWeb, context),
                            SizedBox(height: isWeb ? 16 : 12),
                            
                            if (requiresItems()) ...[
                              ..._buildItemsList(items, setState, isWeb, context),
                              SizedBox(height: isWeb ? 12 : 8),
                              TextButton.icon(
                                onPressed: () => setState(() => addItem()),
                                icon: Icon(Icons.add, size: isWeb ? 20 : 16),
                                label: Text('Add Item', style: TextStyle(fontSize: isWeb ? 12 : 11)),
                              ),
                              SizedBox(height: isWeb ? 16 : 12),
                              _buildTextField('Tax Rate (%)', (v) => taxRate = double.tryParse(v) ?? 0, isWeb: isWeb, isNumber: true),
                            ] else ...[
                              _buildTextField('Amount *', (v) => simpleAmount = double.tryParse(v) ?? 0, isWeb: isWeb, isNumber: true, prefix: '\$ '),
                            ],
                            
                            SizedBox(height: isWeb ? 16 : 12),
                            _buildTextField('Description', (v) => description = v, isWeb: isWeb, maxLines: 2),
                            SizedBox(height: isWeb ? 16 : 12),
                            _buildTextField('Reference Number', (v) => reference = v, isWeb: isWeb),
                            SizedBox(height: isWeb ? 16 : 12),
                            _buildDropdown('Payment Method', paymentMethod, ['Cash', 'Bank Transfer', 'Cheque', 'Credit Card'], (v) => setState(() => paymentMethod = v!), isWeb, context),
                            if (paymentMethod == 'Bank Transfer')
                              _buildBankAccountDropdown(selectedBankAccountId, (v) => setState(() => selectedBankAccountId = v), controller.bankAccounts, isWeb, context),
                            SizedBox(height: isWeb ? 16 : 12),
                            
                            Container(
                              padding: EdgeInsets.all(isWeb ? 16 : 12),
                              decoration: BoxDecoration(color: kPrimary.withOpacity(0.07), borderRadius: BorderRadius.circular(isWeb ? 12 : 10)),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Text('Total Amount', style: TextStyle(fontSize: isWeb ? 14 : 12, fontWeight: FontWeight.w700, color: kText)),
                                Text(controller.formatAmount(calculateTotal()), style: TextStyle(fontSize: isWeb ? 16 : 14, fontWeight: FontWeight.w800, color: kSuccess)),
                              ]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isWeb ? 20 : 16),
                  Row(
                    children: [
                      Expanded(child: OutlinedButton(onPressed: () => Get.back(), child: Text('Cancel', style: TextStyle(fontSize: isWeb ? 14 : 12)))),
                      SizedBox(width: isWeb ? 16 : 12),
                      Expanded(child: Obx(() => ElevatedButton(
                        onPressed: controller.isProcessing.value ? null : () async {
                          if (formKey.currentState!.validate()) {
                            if (requiresItems()) {
                              if (items.isEmpty || items.any((i) => i['description'].isEmpty || i['unitPrice'] <= 0)) {
                                AppSnackbar.error(kWarning, 'Error', 'Please add at least one item with description and price');
                                return;
                              }
                            } else {
                              if (simpleAmount <= 0) {
                                AppSnackbar.error(kWarning, 'Error', 'Please enter a valid amount');
                                return;
                              }
                            }
                            
                            Get.back();
                            await controller.createIncome(
                              date: selectedDate,
                              incomeType: incomeType,
                              customerId: selectedCustomerId,
                              items: requiresItems() ? items : [],
                              amount: requiresItems() ? null : simpleAmount,
                              taxRate: requiresItems() ? taxRate : 0,
                              description: description,
                              reference: reference,
                              paymentMethod: paymentMethod,
                              bankAccountId: selectedBankAccountId,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                        child: controller.isProcessing.value 
                            ? SizedBox(width: isWeb ? 24 : 20, height: isWeb ? 24 : 20, child: LoadingAnimationWidget.waveDots(color: kPrimary, size: isWeb ? 24 : 20)) 
                            : Text('Save Income', style: TextStyle(fontSize: isWeb ? 14 : 12, color: Colors.white)),
                      ))),
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
  
  List<Widget> _buildItemsList(List<Map<String, dynamic>> items, void Function(void Function()) setState, bool isWeb, BuildContext context) {
    return items.asMap().entries.map((entry) {
      int index = entry.key;
      var item = entry.value;
      return Container(
        margin: EdgeInsets.only(bottom: isWeb ? 12 : 8),
        padding: EdgeInsets.all(isWeb ? 12 : 10),
        decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(isWeb ? 12 : 10), border: Border.all(color: kBorder)),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildTextField('Description *', (v) => item['description'] = v, isWeb: isWeb, initialValue: item['description'])),
                IconButton(icon: Icon(Icons.delete, size: isWeb ? 20 : 16, color: kDanger), onPressed: () => setState(() => items.removeAt(index))),
              ],
            ),
            SizedBox(height: isWeb ? 8 : 6),
            Row(
              children: [
                Expanded(child: _buildTextField('Quantity', (v) => item['quantity'] = int.tryParse(v) ?? 1, isWeb: isWeb, isNumber: true, initialValue: item['quantity'].toString())),
                SizedBox(width: isWeb ? 12 : 8),
                Expanded(flex: 2, child: _buildTextField('Unit Price *', (v) => item['unitPrice'] = double.tryParse(v) ?? 0, isWeb: isWeb, isNumber: true, prefix: '\$ ', initialValue: item['unitPrice'].toString())),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text('Amount: ${_formatAmount((item['quantity'] * item['unitPrice']).toDouble())}', style: TextStyle(fontSize: isWeb ? 11 : 10, color: kPrimary)),
            ),
          ],
        ),
      );
    }).toList();
  }
  
  void _showIncomeDetails(Income income, BuildContext context) {
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
                    decoration: BoxDecoration(color: kSuccess.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                    child: Icon(Icons.trending_up, size: 28, color: kSuccess),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(income.incomeNumber, style:  TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kText)),
                      Text(DateFormat('dd MMM yyyy').format(income.date), style:  TextStyle(fontSize: 13, color: kSubText)),
                    ]),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: income.status == 'Posted' ? kSuccess.withOpacity(0.1) : kWarning.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(income.status, style: TextStyle(fontSize: 13, color: income.status == 'Posted' ? kSuccess : kWarning)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    _buildDetailRow('Income Type', income.incomeType, isWeb),
                    if (income.customerName.isNotEmpty) _buildDetailRow('Customer', income.customerName, isWeb),
                    _buildDetailRow('Subtotal', _formatAmount(income.subtotal), isWeb),
                    if (income.taxRate > 0) _buildDetailRow('Tax (${income.taxRate}%)', _formatAmount(income.taxAmount), isWeb),
                    _buildDetailRow('Total Amount', _formatAmount(income.totalAmount), isWeb),
                    _buildDetailRow('Payment Method', income.paymentMethod, isWeb),
                    if (income.reference.isNotEmpty) _buildDetailRow('Reference', income.reference, isWeb),
                    if (income.description.isNotEmpty) _buildDetailRow('Description', income.description, isWeb),
                  ],
                ),
              ),
              if (income.items.isNotEmpty) ...[
                const SizedBox(height: 16),
                 Text('Items', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kText)),
                const SizedBox(height: 8),
                ...income.items.map((item) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(item.description, style:  TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kText)),
                          Text('${item.quantity} x ${_formatAmount(item.unitPrice)}', style:  TextStyle(fontSize: 10, color: kSubText)),
                        ]),
                      ),
                      Text(_formatAmount(item.amount), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kSuccess)),
                    ],
                  ),
                )).toList(),
              ],
              const SizedBox(height: 16),
              if (income.status == 'Draft')
                ElevatedButton.icon(
                  onPressed: () { 
                    Navigator.pop(context); 
                    Get.find<IncomeController>().postIncome(income.id); 
                  },
                  icon: const Icon(Icons.check_circle, size: 18),
                  label: const Text('Post Income', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(backgroundColor: kSuccess),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showFilterDialog(IncomeController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    DateTime? start = controller.startDate.value;
    DateTime? end = controller.endDate.value;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter Incomes', style: TextStyle(fontSize: isWeb ? 18 : 14, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.calendar_today, size: isWeb ? 24 : 20),
              title: Text('Date Range', style: TextStyle(fontSize: isWeb ? 14 : 13)),
              trailing: Icon(Icons.arrow_forward_ios, size: isWeb ? 20 : 16),
              onTap: () async {
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: start != null && end != null ? DateTimeRange(start: start, end: end) : null,
                );
                if (range != null) {
                  controller.setDateRange(range.start, range.end);
                  Navigator.pop(context);
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.clear, size: isWeb ? 24 : 20),
              title: Text('Clear Filters', style: TextStyle(fontSize: isWeb ? 14 : 13)),
              onTap: () {
                controller.clearFilters();
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Close', style: TextStyle(fontSize: isWeb ? 14 : 12)))],
      ),
    );
  }

  void _showRowActions(IncomeController controller, Income income, BuildContext context) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 0, 0),
      items: [
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.edit, size: 20, color: kPrimary),
            title: const Text('Edit', style: TextStyle(fontSize: 14)),
            dense: true,
          ),
          onTap: () {
            AppSnackbar.info('Info', 'Edit income #${income.incomeNumber}');
          },
        ),
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.delete, size: 20, color: kDanger),
            title: const Text('Delete', style: TextStyle(fontSize: 14)),
            dense: true,
          ),
          onTap: () {
            _showDeleteConfirmation(controller, income, context);
          },
        ),
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.print, size: 20, color: kPrimary),
            title: const Text('Print', style: TextStyle(fontSize: 14)),
            dense: true,
          ),
          onTap: () {
            controller.printIncomes();
          },
        ),
      ],
      elevation: 4,
    );
  }

  void _showDeleteConfirmation(IncomeController controller, Income income, BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Income'),
        content: Text('Are you sure you want to delete ${income.incomeNumber}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              AppSnackbar.success(Colors.green, 'Deleted', 'Income deleted successfully');
            },
            style: TextButton.styleFrom(foregroundColor: kDanger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  // ==================== HELPER WIDGETS ====================
  Widget _buildTextField(String label, Function(String) onChanged, {bool isWeb = false, bool isNumber = false, String? prefix, int maxLines = 1, String initialValue = ''}) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        fillColor: kCardBg,
        filled: true,
        labelStyle: TextStyle(fontSize: isWeb ? 12 : 11),
      ),
      style: TextStyle(fontSize: isWeb ? 13 : 12, color: kText),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      onChanged: onChanged,
    );
  }
  
  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged, bool isWeb, BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: kCardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: isWeb ? 16 : 12, vertical: isWeb ? 12 : 10),
          labelStyle: TextStyle(fontSize: isWeb ? 12 : 11),
        ),
        style: TextStyle(fontSize: isWeb ? 13 : 12, color: kText),
        dropdownColor: kCardBg,
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: TextStyle(color: kText), overflow: TextOverflow.ellipsis))).toList(),
        onChanged: onChanged,
      ),
    );
  }
  
  Widget _buildDatePicker(String label, DateTime date, Function(DateTime) onChanged, bool isWeb, BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isWeb ? 16 : 12, vertical: isWeb ? 12 : 10),
        decoration: BoxDecoration(color: kCardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
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
  
  Widget _buildCustomerDropdown(String? selectedId, Function(String?) onChanged, List<Map<String, dynamic>> customers, bool isWeb, BuildContext context) {
    if (customers.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(color: kCardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
      child: DropdownButtonFormField<String>(
        value: selectedId,
        decoration: InputDecoration(
          labelText: 'Customer',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: isWeb ? 16 : 12, vertical: isWeb ? 12 : 10),
          labelStyle: TextStyle(fontSize: isWeb ? 12 : 11),
        ),
        style: TextStyle(fontSize: isWeb ? 13 : 12, color: kText),
        dropdownColor: kCardBg,
        hint: Text('Select customer', style: TextStyle(fontSize: isWeb ? 12 : 11, color: kSubText)),
        items: customers.map((cust) => DropdownMenuItem(value: cust['_id'].toString(), child: Text(cust['name'], style: TextStyle(color: kText), overflow: TextOverflow.ellipsis))).toList(),
        onChanged: onChanged,
      ),
    );
  }
  
  Widget _buildBankAccountDropdown(String? selectedId, Function(String?) onChanged, List<Map<String, dynamic>> bankAccounts, bool isWeb, BuildContext context) {
    if (bankAccounts.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(color: kCardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
      child: DropdownButtonFormField<String>(
        value: selectedId,
        decoration: InputDecoration(
          labelText: 'Bank Account',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: isWeb ? 16 : 12, vertical: isWeb ? 12 : 10),
          labelStyle: TextStyle(fontSize: isWeb ? 12 : 11),
        ),
        style: TextStyle(fontSize: isWeb ? 13 : 12, color: kText),
        dropdownColor: kCardBg,
        hint: Text('Select bank account', style: TextStyle(fontSize: isWeb ? 12 : 11, color: kSubText)),
        items: bankAccounts.map((acc) => DropdownMenuItem(value: acc['_id'].toString(), child: Text(acc['accountName'], style: TextStyle(color: kText), overflow: TextOverflow.ellipsis))).toList(),
        onChanged: onChanged,
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
  
  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '\$ ${formatter.format(amount)}';
  }
}