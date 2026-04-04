import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/core/Income/controller/income_controller.dart';
import 'package:LedgerPro_app/core/Income/models/income_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';

class IncomeScreen extends StatelessWidget {
  const IncomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(IncomeController());

    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(controller),
      body: Obx(() {
        if (controller.isLoading.value && controller.incomes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
               LoadingAnimationWidget.waveDots(
                    color: kPrimary,
                    size: 10.w,
                  ),
                SizedBox(height: 2.h),
                Text('Loading incomes...', style: TextStyle(fontSize: 14.sp, color: kSubText)),
              ],
            ),
          );
        }
        return Column(
          children: [
            _buildSummaryCards(controller),
            _buildFilterBar(controller),
            Expanded(child: _buildIncomesList(controller)),
          ],
        );
      }),
      floatingActionButton: _buildFAB(controller),
    );
  }

  PreferredSizeWidget _buildAppBar(IncomeController controller) {
    return AppBar(
      title: Text('Income', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: Colors.white)),
      backgroundColor: kPrimary,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(Icons.filter_alt_outlined, color: Colors.white, size: 5.w),
          onPressed: () => _showFilterDialog(controller),
        ),
        IconButton(
          icon: Icon(Icons.download_outlined, color: Colors.white, size: 5.w),
          onPressed: () => controller.exportIncomes(),
        ),
        IconButton(
          icon: Icon(Icons.print_outlined, color: Colors.white, size: 5.w),
          onPressed: () => controller.printIncomes(),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(IncomeController controller) {
    return Obx(() => Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildSummaryCard('Total Income', controller.formatAmount(controller.totalIncome.value), kSuccess, Icons.trending_up, 28.w),
            SizedBox(width: 2.w),
            _buildSummaryCard('Total Tax', controller.formatAmount(controller.totalTax.value), kWarning, Icons.receipt, 25.w),
            SizedBox(width: 2.w),
            _buildSummaryCard('This Month', controller.formatAmount(controller.thisMonthTotal.value), kPrimary, Icons.calendar_month, 28.w),
            SizedBox(width: 2.w),
            _buildSummaryCard('This Week', controller.formatAmount(controller.thisWeekTotal.value), kPrimary, Icons.calendar_today, 25.w),
            SizedBox(width: 2.w),
            _buildSummaryCard('Total Records', controller.totalCount.value.toString(), kPrimary, Icons.receipt_long, 25.w, isNumber: true),
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
              Expanded(child: Text(title, style: TextStyle(fontSize: 12.sp, color: kSubText, fontWeight: FontWeight.w500))),
            ],
          ),
          SizedBox(height: 1.h),
          Text(isNumber ? amount : amount, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }

  Widget _buildFilterBar(IncomeController controller) {
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
                  decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
                  child: TextField(
                    controller: controller.searchController,
                    style: TextStyle(fontSize: 14.sp, color: kText),
                    decoration: InputDecoration(
                      hintText: 'Search by number, customer, description...',
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
          SizedBox(height: 1.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: controller.incomeTypes.map((type) {
                final isSelected = controller.selectedType.value == type;
                return Padding(
                  padding: EdgeInsets.only(right: 1.w),
                  child: FilterChip(
                    label: Text(type, style: TextStyle(fontSize: 12.sp)),
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
              padding: EdgeInsets.only(top: 1.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.date_range, size: 4.w, color: kPrimary),
                        SizedBox(width: 2.w),
                        Text(
                          '${DateFormat('dd MMM yyyy').format(controller.startDate.value!)} - ${DateFormat('dd MMM yyyy').format(controller.endDate.value!)}',
                          style: TextStyle(fontSize: 12.sp, color: kPrimary),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => controller.clearDateRange(),
                      child: Icon(Icons.close, size: 4.w, color: kPrimary),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIncomesList(IncomeController controller) {
    if (controller.incomes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.trending_up, size: 15.w, color: kSubText.withOpacity(0.5)),
            SizedBox(height: 2.h),
            Text('No income records found', style: TextStyle(fontSize: 14.sp, color: kSubText)),
            SizedBox(height: 2.h),
            ElevatedButton(
              onPressed: () => _showAddIncomeDialog(controller),
              style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
              child: Text('Add Income', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: controller.incomes.length,
      itemBuilder: (context, index) {
        final income = controller.incomes[index];
        return _buildIncomeCard(controller, income);
      },
    );
  }

  Widget _buildIncomeCard(IncomeController controller, Income income) {
    Color statusColor = income.status == 'Posted' ? kSuccess : income.status == 'Draft' ? kWarning : kDanger;
    Color typeColor = Color(int.parse(controller.getTypeColor(income.incomeType).substring(1, 7), radix: 16) + 0xFF000000);
    
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
          onTap: () => _showIncomeDetails(income),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 14.w, height: 14.w,
                      decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                      child: Icon(controller.getTypeIcon(income.incomeType), size: 7.w, color: typeColor),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(income.incomeNumber, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: kText)),
                              SizedBox(width: 2.w),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                child: Text(income.status, style: TextStyle(fontSize: 12.sp, color: statusColor, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          SizedBox(height: 0.5.h),
                          Text(income.incomeType, style: TextStyle(fontSize: 12.sp, color: typeColor, fontWeight: FontWeight.w600)),
                          if (income.customerName.isNotEmpty)
                            Text(income.customerName, style: TextStyle(fontSize: 12.sp, color: kSubText)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(controller.formatAmount(income.totalAmount), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: kSuccess)),
                        Text(DateFormat('dd MMM yyyy').format(income.date), style: TextStyle(fontSize: 12.sp, color: kSubText)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Divider(color: kBorder),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    if (income.status == 'Draft')
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => controller.postIncome(income.id),
                          icon: Icon(Icons.check_circle, size: 4.w, color: kSuccess),
                          label: Text('Post', style: TextStyle(fontSize: 12.sp, color: kSuccess)),
                          style: OutlinedButton.styleFrom(side: BorderSide(color: kSuccess, width: 1), padding: EdgeInsets.symmetric(vertical: 1.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        ),
                      ),
                    if (income.status == 'Draft') SizedBox(width: 2.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showIncomeDetails(income),
                        icon: Icon(Icons.visibility, size: 4.w, color: kPrimary),
                        label: Text('Details', style: TextStyle(fontSize: 12.sp, color: kPrimary)),
                        style: OutlinedButton.styleFrom(side: BorderSide(color: kPrimary, width: 1), padding: EdgeInsets.symmetric(vertical: 1.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
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

  void _showAddIncomeDialog(IncomeController controller) {
    final formKey = GlobalKey<FormState>();
    DateTime selectedDate = DateTime.now();
    String incomeType = 'Sales';
    String? selectedCustomerId;
    
    // For simple income (Interest, Rental, etc.)
    double simpleAmount = 0;
    
    // For detailed income (Sales, Services)
    List<Map<String, dynamic>> items = [];
    double taxRate = 0;
    
    String description = '';
    String reference = '';
    String paymentMethod = 'Cash';
    String? selectedBankAccountId;
    
    void addItem() {
      items.add({'description': '', 'quantity': 1, 'unitPrice': 0.0});
    }
    addItem(); // Start with one empty item
    
    // Check if income type requires items
    bool requiresItems() {
      return incomeType == 'Sales' || incomeType == 'Services';
    }
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 90.w, constraints: BoxConstraints(maxHeight: 85.h), padding: EdgeInsets.all(5.w),
          child: StatefulBuilder(
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
              
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Add Income', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: kText)),
                  SizedBox(height: 2.h),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            _buildDatePicker('Date', selectedDate, (date) => setState(() => selectedDate = date)),
                            SizedBox(height: 2.h),
                            _buildDropdown('Income Type', incomeType, controller.incomeTypes.skip(1).toList(), (v) => setState(() => incomeType = v!)),
                            SizedBox(height: 2.h),
                            _buildCustomerDropdown(selectedCustomerId, (v) => setState(() => selectedCustomerId = v), controller.customers),
                            SizedBox(height: 2.h),
                            
                            // ✅ CONDITIONAL FIELDS - Items OR Simple Amount
                            if (requiresItems()) ...[
                              // Detailed Income - Items Required
                              ..._buildItemsList(items, setState),
                              SizedBox(height: 1.h),
                              TextButton.icon(
                                onPressed: () => setState(() => addItem()),
                                icon: Icon(Icons.add, size: 4.w),
                                label: Text('Add Item', style: TextStyle(fontSize: 12.sp)),
                              ),
                              SizedBox(height: 2.h),
                              _buildTextField('Tax Rate (%)', (v) => taxRate = double.tryParse(v) ?? 0, isNumber: true),
                            ] else ...[
                              // Simple Income - Just Amount Field
                              _buildTextField('Amount *', (v) => simpleAmount = double.tryParse(v) ?? 0, isNumber: true, prefix: '₨ '),
                            ],
                            
                            SizedBox(height: 2.h),
                            _buildTextField('Description', (v) => description = v, maxLines: 2),
                            SizedBox(height: 2.h),
                            _buildTextField('Reference Number', (v) => reference = v),
                            SizedBox(height: 2.h),
                            _buildDropdown('Payment Method', paymentMethod, ['Cash', 'Bank Transfer', 'Cheque', 'Credit Card'], (v) => setState(() => paymentMethod = v!)),
                            if (paymentMethod == 'Bank Transfer')
                              _buildBankAccountDropdown(selectedBankAccountId, (v) => setState(() => selectedBankAccountId = v), controller.bankAccounts),
                            SizedBox(height: 2.h),
                            
                            // Total Amount Display
                            Container(
                              padding: EdgeInsets.all(3.w),
                              decoration: BoxDecoration(color: kPrimary.withOpacity(0.07), borderRadius: BorderRadius.circular(12)),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Text('Total Amount', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: kText)),
                                Text(controller.formatAmount(calculateTotal()), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: kSuccess)),
                              ]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(child: OutlinedButton(onPressed: () => Get.back(), child: Text('Cancel', style: TextStyle(fontSize: 14.sp)))),
                      SizedBox(width: 3.w),
                      Expanded(child: Obx(() => ElevatedButton(
                        onPressed: controller.isProcessing.value ? null : () async {
                          if (formKey.currentState!.validate()) {
                            if (requiresItems()) {
                              if (items.isEmpty || items.any((i) => i['description'].isEmpty || i['unitPrice'] <= 0)) {
                                Get.snackbar('Error', 'Please add at least one item with description and price', backgroundColor: kWarning, colorText: Colors.white);
                                return;
                              }
                            } else {
                              if (simpleAmount <= 0) {
                                Get.snackbar('Error', 'Please enter a valid amount', backgroundColor: kWarning, colorText: Colors.white);
                                return;
                              }
                            }
                            
                            Get.back();
                            await controller.createIncome(
                              date: selectedDate,
                              incomeType: incomeType,
                              customerId: selectedCustomerId,
                              items: requiresItems() ? items : [],
          amount: requiresItems() ? null : simpleAmount,  // ← Simple income ke liye amount
                              taxRate: requiresItems() ? taxRate : 0,
                              description: description,
                              reference: reference,
                              paymentMethod: paymentMethod,
                              bankAccountId: selectedBankAccountId,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                        child: controller.isProcessing.value ? SizedBox(width: 5.w, height: 5.w, child: LoadingAnimationWidget.waveDots(
                    color: kPrimary,
                    size: 10.w,
                  )) : Text('Save Income', style: TextStyle(fontSize: 14.sp, color: Colors.white)),
                      ))),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
  
  List<Widget> _buildItemsList(List<Map<String, dynamic>> items, void Function(void Function()) setState) {
    return items.asMap().entries.map((entry) {
      int index = entry.key;
      var item = entry.value;
      return Container(
        margin: EdgeInsets.only(bottom: 1.5.h),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildTextField('Description *', (v) => item['description'] = v, initialValue: item['description'])),
                IconButton(icon: Icon(Icons.delete, size: 5.w, color: kDanger), onPressed: () => setState(() => items.removeAt(index))),
              ],
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                Expanded(child: _buildTextField('Quantity', (v) => item['quantity'] = int.tryParse(v) ?? 1, isNumber: true, initialValue: item['quantity'].toString())),
                SizedBox(width: 2.w),
                Expanded(flex: 2, child: _buildTextField('Unit Price *', (v) => item['unitPrice'] = double.tryParse(v) ?? 0, isNumber: true, prefix: '₨ ', initialValue: item['unitPrice'].toString())),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text('Amount: ${_formatAmount((item['quantity'] * item['unitPrice']).toDouble())}', style: TextStyle(fontSize: 12.sp, color: kPrimary)),
            ),
          ],
        ),
      );
    }).toList();
  }
  
  void _showIncomeDetails(Income income) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(color: kCardBg, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        constraints: BoxConstraints(maxHeight: 85.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(width: 14.w, height: 14.w, decoration: BoxDecoration(color: kSuccess.withOpacity(0.1), borderRadius: BorderRadius.circular(14)), child: Icon(Icons.trending_up, size: 7.w, color: kSuccess)),
                SizedBox(width: 3.w),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(income.incomeNumber, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: kText)),
                  Text(DateFormat('dd MMM yyyy').format(income.date), style: TextStyle(fontSize: 12.sp, color: kSubText)),
                ])),
                Container(padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h), decoration: BoxDecoration(color: income.status == 'Posted' ? kSuccess.withOpacity(0.1) : kWarning.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(income.status, style: TextStyle(fontSize: 12.sp, color: income.status == 'Posted' ? kSuccess : kWarning))),
              ],
            ),
            SizedBox(height: 2.h),
            _buildDetailRow('Income Type', income.incomeType),
            if (income.customerName.isNotEmpty) _buildDetailRow('Customer', income.customerName),
            _buildDetailRow('Subtotal', _formatAmount(income.subtotal)),
            if (income.taxRate > 0) _buildDetailRow('Tax (${income.taxRate}%)', _formatAmount(income.taxAmount)),
            _buildDetailRow('Total Amount', _formatAmount(income.totalAmount)),
            _buildDetailRow('Payment Method', income.paymentMethod),
            if (income.reference.isNotEmpty) _buildDetailRow('Reference', income.reference),
            if (income.description.isNotEmpty) _buildDetailRow('Description', income.description),
            if (income.items.isNotEmpty) ...[
              SizedBox(height: 2.h),
              Text('Items', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: kText)),
              SizedBox(height: 1.h),
              ...income.items.map((item) => Container(
                margin: EdgeInsets.only(bottom: 1.h), padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item.description, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: kText)),
                      Text('${item.quantity} x ${_formatAmount(item.unitPrice)}', style: TextStyle(fontSize: 12.sp, color: kSubText)),
                    ])),
                    Text(_formatAmount(item.amount), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: kSuccess)),
                  ],
                ),
              )).toList(),
            ],
            SizedBox(height: 2.h),
            if (income.status == 'Draft')
              ElevatedButton.icon(
                onPressed: () { Get.back(); Get.find<IncomeController>().postIncome(income.id); },
                icon: Icon(Icons.check_circle, size: 4.5.w),
                label: Text('Post Income', style: TextStyle(fontSize: 12.sp)),
                style: ElevatedButton.styleFrom(backgroundColor: kSuccess),
              ),
          ],
        ),
      ),
    );
  }
  
  void _showFilterDialog(IncomeController controller) {
    DateTime? start = controller.startDate.value;
    DateTime? end = controller.endDate.value;
    
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: Text('Filter Incomes', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Date Range', style: TextStyle(fontSize: 14.sp)),
              trailing: Icon(Icons.arrow_forward_ios),
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
              leading: Icon(Icons.clear),
              title: Text('Clear Filters', style: TextStyle(fontSize: 14.sp)),
              onTap: () {
                controller.clearFilters();
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Close', style: TextStyle(fontSize: 12.sp)))],
      ),
    );
  }
  
  Widget _buildFAB(IncomeController controller) {
    return FloatingActionButton(
      onPressed: () => _showAddIncomeDialog(controller),
      backgroundColor: kPrimary,
      child: Icon(Icons.add, color: Colors.white, size: 6.w),
    );
  }
  
  // Helper widgets
  Widget _buildTextField(String label, Function(String) onChanged, {bool isNumber = false, String? prefix, int maxLines = 1, String initialValue = ''}) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        fillColor: kCardBg,
        filled: true,
        labelStyle: TextStyle(fontSize: 12.sp),
      ),
      style: TextStyle(fontSize: 14.sp, color: kText),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      onChanged: onChanged,
    );
  }
  
  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Container(
      decoration: BoxDecoration(color: kCardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
          labelStyle: TextStyle(fontSize: 12.sp),
        ),
        style: TextStyle(fontSize: 14.sp, color: kText),
        dropdownColor: kCardBg,
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: TextStyle(color: kText)))).toList(),
        onChanged: onChanged,
      ),
    );
  }
  
  Widget _buildDatePicker(String label, DateTime date, Function(DateTime) onChanged) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(context: Get.context!, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime.now());
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
        decoration: BoxDecoration(color: kCardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 5.w, color: kPrimary),
            SizedBox(width: 3.w),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: TextStyle(fontSize: 12.sp, color: kSubText)),
              Text(DateFormat('dd MMM yyyy').format(date), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: kText)),
            ])),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCustomerDropdown(String? selectedId, Function(String?) onChanged, List<Map<String, dynamic>> customers) {
    if (customers.isEmpty) return SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(color: kCardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
      child: DropdownButtonFormField<String>(
        value: selectedId,
        decoration: InputDecoration(
          labelText: 'Customer',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
          labelStyle: TextStyle(fontSize: 12.sp),
        ),
        style: TextStyle(fontSize: 14.sp, color: kText),
        dropdownColor: kCardBg,
        hint: Text('Select customer', style: TextStyle(fontSize: 12.sp, color: kSubText)),
        items: customers.map((cust) => DropdownMenuItem(value: cust['_id'].toString(), child: Text(cust['name'], style: TextStyle(color: kText)))).toList(),
        onChanged: onChanged,
      ),
    );
  }
  
  Widget _buildBankAccountDropdown(String? selectedId, Function(String?) onChanged, List<Map<String, dynamic>> bankAccounts) {
    if (bankAccounts.isEmpty) return SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(color: kCardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
      child: DropdownButtonFormField<String>(
        value: selectedId,
        decoration: InputDecoration(
          labelText: 'Bank Account',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
          labelStyle: TextStyle(fontSize: 12.sp),
        ),
        style: TextStyle(fontSize: 14.sp, color: kText),
        dropdownColor: kCardBg,
        hint: Text('Select bank account', style: TextStyle(fontSize: 12.sp, color: kSubText)),
        items: bankAccounts.map((acc) => DropdownMenuItem(value: acc['_id'].toString(), child: Text(acc['accountName'], style: TextStyle(color: kText)))).toList(),
        onChanged: onChanged,
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 30.w, child: Text(label, style: TextStyle(fontSize: 12.sp, color: kSubText, fontWeight: FontWeight.w500))),
          Expanded(child: Text(value, style: TextStyle(fontSize: 14.sp, color: kText, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
  
  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '₨ ${formatter.format(amount)}';
  }
}