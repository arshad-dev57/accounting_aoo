import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/Utils/responsive_utils.dart';
import 'package:LedgerPro_app/Utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class AgedReceivablesScreen extends StatefulWidget {
  const AgedReceivablesScreen({super.key});

  @override
  State<AgedReceivablesScreen> createState() => _AgedReceivablesScreenState();
}

class _AgedReceivablesScreenState extends State<AgedReceivablesScreen> {
  DateTime _asAtDate = DateTime.now();
  bool _isLoading = true;
  String _selectedFilter = 'All';
  TextEditingController _searchController = TextEditingController();
  
  List<AgedCustomer> _customers = [];
  double totalCurrent = 0;
  double total1to30 = 0;
  double total31to60 = 0;
  double total61to90 = 0;
  double totalOver90 = 0;
  double totalOutstanding = 0;

  final List<String> _filterOptions = ['All', 'Current', '1-30 Days', '31-60 Days', '61-90 Days', '90+ Days'];

  @override
  void initState() {
    super.initState();
    _loadAgedReceivablesData();
  }

  void _loadAgedReceivablesData() {
    setState(() {
      _isLoading = true;
    });
    
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _customers = [
          AgedCustomer(
            id: '1',
            name: 'ABC Company',
            email: 'info@abccompany.com',
            phone: '0300-1234567',
            totalOutstanding: 100000.00,
            invoices: [
              AgedInvoice(id: 'INV-001', date: DateTime(2026, 3, 25), dueDate: DateTime(2026, 4, 8), amount: 25000.00, paidAmount: 0),
              AgedInvoice(id: 'INV-002', date: DateTime(2026, 3, 20), dueDate: DateTime(2026, 4, 3), amount: 35000.00, paidAmount: 0),
              AgedInvoice(id: 'INV-003', date: DateTime(2026, 3, 15), dueDate: DateTime(2026, 3, 29), amount: 40000.00, paidAmount: 0),
            ],
          ),
          AgedCustomer(
            id: '2',
            name: 'XYZ Corporation',
            email: 'contact@xyzcorp.com',
            phone: '0300-7654321',
            totalOutstanding: 50000.00,
            invoices: [
              AgedInvoice(id: 'INV-004', date: DateTime(2026, 3, 22), dueDate: DateTime(2026, 4, 5), amount: 25000.00, paidAmount: 0),
              AgedInvoice(id: 'INV-005', date: DateTime(2026, 3, 18), dueDate: DateTime(2026, 4, 1), amount: 25000.00, paidAmount: 0),
              AgedInvoice(id: 'INV-006', date: DateTime(2026, 3, 10), dueDate: DateTime(2026, 3, 24), amount: 25000.00, paidAmount: 25000.00),
            ],
          ),
          AgedCustomer(
            id: '3',
            name: 'Tech Solutions Ltd',
            email: 'sales@techsolutions.com',
            phone: '0300-9876543',
            totalOutstanding: 85000.00,
            invoices: [
              AgedInvoice(id: 'INV-007', date: DateTime(2026, 3, 23), dueDate: DateTime(2026, 4, 6), amount: 45000.00, paidAmount: 0),
              AgedInvoice(id: 'INV-008', date: DateTime(2026, 3, 19), dueDate: DateTime(2026, 4, 2), amount: 40000.00, paidAmount: 0),
              AgedInvoice(id: 'INV-009', date: DateTime(2026, 3, 5), dueDate: DateTime(2026, 3, 19), amount: 35000.00, paidAmount: 35000.00),
            ],
          ),
          AgedCustomer(
            id: '4',
            name: 'Global Traders',
            email: 'info@globaltraders.com',
            phone: '0300-5555555',
            totalOutstanding: 50000.00,
            invoices: [
              AgedInvoice(id: 'INV-010', date: DateTime(2026, 3, 21), dueDate: DateTime(2026, 4, 4), amount: 50000.00, paidAmount: 0),
              AgedInvoice(id: 'INV-011', date: DateTime(2026, 2, 15), dueDate: DateTime(2026, 3, 1), amount: 50000.00, paidAmount: 50000.00),
              AgedInvoice(id: 'INV-012', date: DateTime(2026, 1, 10), dueDate: DateTime(2026, 1, 25), amount: 30000.00, paidAmount: 30000.00),
            ],
          ),
        ];
        
        _calculateAging();
        _isLoading = false;
      });
    });
  }

  void _calculateAging() {
    totalCurrent = 0;
    total1to30 = 0;
    total31to60 = 0;
    total61to90 = 0;
    totalOver90 = 0;
    totalOutstanding = 0;
    
    for (var customer in _customers) {
      double customerCurrent = 0;
      double customer1to30 = 0;
      double customer31to60 = 0;
      double customer61to90 = 0;
      double customerOver90 = 0;
      
      for (var invoice in customer.invoices) {
        double outstanding = invoice.amount - invoice.paidAmount;
        if (outstanding <= 0) continue;
        
        int daysOverdue = _asAtDate.difference(invoice.dueDate).inDays;
        
        if (daysOverdue <= 0) {
          customerCurrent += outstanding;
          totalCurrent += outstanding;
        } else if (daysOverdue <= 30) {
          customer1to30 += outstanding;
          total1to30 += outstanding;
        } else if (daysOverdue <= 60) {
          customer31to60 += outstanding;
          total31to60 += outstanding;
        } else if (daysOverdue <= 90) {
          customer61to90 += outstanding;
          total61to90 += outstanding;
        } else {
          customerOver90 += outstanding;
          totalOver90 += outstanding;
        }
      }
      
      customer.current = customerCurrent;
      customer.days1to30 = customer1to30;
      customer.days31to60 = customer31to60;
      customer.days61to90 = customer61to90;
      customer.daysOver90 = customerOver90;
      
      totalOutstanding += customer.totalOutstanding;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final isMobile = ResponsiveUtils.isMobile(context);
    
    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: kPrimary,
                strokeWidth: 3,
              ),
            )
          : Column(
              children: [
                _buildDateSelector(),
                _buildSummaryCards(),
                _buildFilterBar(),
                Expanded(
                  child: _buildAgedReceivablesTable(),
                ),
              ],
            ),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final isWeb = ResponsiveUtils.isWeb(Get.context!);
    final isMobile = ResponsiveUtils.isMobile(Get.context!);
    
    return AppBar(
      title: Text(
        'Aged Receivables',
        style: TextStyle(
          fontSize: isWeb ? 20 : 14,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      backgroundColor: kPrimary,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(Icons.calendar_today, color: Colors.white, size: isWeb ? 22 : 20),
          onPressed: () => _selectAsAtDate(),
        ),
        IconButton(
          icon: Icon(Icons.picture_as_pdf, color: Colors.white, size: isWeb ? 22 : 20),
          onPressed: () => _generateAndPrintPDF(),
        ),
      
      
      ],
    );
  }

  Widget _buildDateSelector() {
    final isWeb = ResponsiveUtils.isWeb(Get.context!);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 12 : 10),
      color: kCardBg,
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: isWeb ? 20 : 16, color: kPrimary),
          SizedBox(width: isWeb ? 8 : 6),
          Text(
            'As at:',
            style: TextStyle(
              fontSize: isWeb ? 13 : 12,
              color: kSubText,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: isWeb ? 8 : 6),
          GestureDetector(
            onTap: () => _selectAsAtDate(),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: isWeb ? 12 : 10, vertical: isWeb ? 6 : 4),
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isWeb ? 8 : 6),
              ),
              child: Text(
                DateFormat('dd MMM yyyy').format(_asAtDate),
                style: TextStyle(
                  fontSize: isWeb ? 13 : 12,
                  color: kPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    final isWeb = ResponsiveUtils.isWeb(Get.context!);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 16 : 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildSummaryCard('Current', _formatAmount(totalCurrent), kSuccess, Icons.access_time, isWeb ? 180 : 150),
            SizedBox(width: isWeb ? 16 : 12),
            _buildSummaryCard('1-30 Days', _formatAmount(total1to30), kWarning, Icons.calendar_view_month, isWeb ? 180 : 150),
            SizedBox(width: isWeb ? 16 : 12),
            _buildSummaryCard('31-60 Days', _formatAmount(total31to60), kWarning, Icons.calendar_view_month, isWeb ? 180 : 150),
            SizedBox(width: isWeb ? 16 : 12),
            _buildSummaryCard('61-90 Days', _formatAmount(total61to90), kDanger, Icons.calendar_view_month, isWeb ? 180 : 150),
            SizedBox(width: isWeb ? 16 : 12),
            _buildSummaryCard('90+ Days', _formatAmount(totalOver90), kDanger, Icons.warning, isWeb ? 180 : 150),
            SizedBox(width: isWeb ? 16 : 12),
            _buildSummaryCard('Total', _formatAmount(totalOutstanding), kPrimary, Icons.attach_money, isWeb ? 180 : 150),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String amount, Color color, IconData icon, double width) {
    final isWeb = ResponsiveUtils.isWeb(Get.context!);
    
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
            amount,
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

  Widget _buildFilterBar() {
    final isWeb = ResponsiveUtils.isWeb(Get.context!);
    
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
              decoration: BoxDecoration(
                color: kBg,
                borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
                border: Border.all(color: kBorder),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => _filterCustomers(),
                style: TextStyle(fontSize: isWeb ? 14 : 12),
                decoration: InputDecoration(
                  hintText: isWeb ? 'Search by customer name, email, or phone...' : 'Search...',
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
                child: DropdownButton<String>(
                  value: _selectedFilter,
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
                    setState(() {
                      _selectedFilter = value!;
                      _filterCustomers();
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgedReceivablesTable() {
    List<AgedCustomer> filteredCustomers = _getFilteredCustomers();
    final isWeb = ResponsiveUtils.isWeb(Get.context!);
    
    if (filteredCustomers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: isWeb ? 80 : 64, color: kSubText.withOpacity(0.5)),
            SizedBox(height: isWeb ? 20 : 16),
            Text(
              'No customers found',
              style: TextStyle(
                fontSize: isWeb ? 18 : 14,
                color: kSubText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(isWeb ? 20 : 12),
      itemCount: filteredCustomers.length,
      itemBuilder: (context, index) {
        final customer = filteredCustomers[index];
        return Padding(
          padding: EdgeInsets.only(bottom: isWeb ? 12 : 8),
          child: _buildCustomerRow(customer),
        );
      },
    );
  }

  Widget _buildCustomerRow(AgedCustomer customer) {
    final isWeb = ResponsiveUtils.isWeb(Get.context!);
    final isMobile = ResponsiveUtils.isMobile(Get.context!);
    
    return Container(
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
          onTap: () => _showCustomerDetails(customer),
          borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
          child: Padding(
            padding: EdgeInsets.all(isWeb ? 16 : 12),
            child: Column(
              children: [
                // Customer Header
                Container(
                  padding: EdgeInsets.all(isWeb ? 16 : 12),
                  decoration: BoxDecoration(
                    color: kBg,
                    borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: isWeb ? 50 : 44,
                        height: isWeb ? 50 : 44,
                        decoration: BoxDecoration(
                          color: kPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
                        ),
                        child: Center(
                          child: Text(
                            customer.name[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: isWeb ? 20 : 16,
                              fontWeight: FontWeight.w800,
                              color: kPrimary,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: isWeb ? 16 : 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer.name,
                              style: TextStyle(
                                fontSize: isWeb ? 15 : 13,
                                fontWeight: FontWeight.w700,
                                color: kText,
                              ),
                            ),
                            SizedBox(height: isWeb ? 4 : 2),
                            Text(
                              customer.email,
                              style: TextStyle(
                                fontSize: isWeb ? 12 : 11,
                                color: kSubText,
                              ),
                            ),
                            SizedBox(height: isWeb ? 4 : 2),
                            Text(
                              customer.phone,
                              style: TextStyle(
                                fontSize: isWeb ? 12 : 11,
                                color: kSubText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isMobile)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Total Outstanding',
                              style: TextStyle(
                                fontSize: isWeb ? 11 : 10,
                                color: kSubText,
                              ),
                            ),
                            SizedBox(height: isWeb ? 4 : 2),
                            Text(
                              _formatAmount(customer.totalOutstanding),
                              style: TextStyle(
                                fontSize: isWeb ? 16 : 14,
                                fontWeight: FontWeight.w800,
                                color: kDanger,
                              ),
                            ),
                          ],
                        ),
                      if (isMobile)
                        Text(
                          _formatAmount(customer.totalOutstanding),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: kDanger,
                          ),
                        ),
                    ],
                  ),
                ),
                
                SizedBox(height: isWeb ? 16 : 12),
                
                // Aging Table Row
                if (!isMobile)
                  Container(
                    padding: EdgeInsets.symmetric(vertical: isWeb ? 16 : 12),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildAgingCell('Current', _formatAmount(customer.current), customer.current > 0 ? kSuccess : kSubText),
                        ),
                        Expanded(
                          flex: 2,
                          child: _buildAgingCell('1-30 Days', _formatAmount(customer.days1to30), customer.days1to30 > 0 ? kWarning : kSubText),
                        ),
                        Expanded(
                          flex: 2,
                          child: _buildAgingCell('31-60 Days', _formatAmount(customer.days31to60), customer.days31to60 > 0 ? kWarning : kSubText),
                        ),
                        Expanded(
                          flex: 2,
                          child: _buildAgingCell('61-90 Days', _formatAmount(customer.days61to90), customer.days61to90 > 0 ? kDanger : kSubText),
                        ),
                        Expanded(
                          flex: 2,
                          child: _buildAgingCell('90+ Days', _formatAmount(customer.daysOver90), customer.daysOver90 > 0 ? kDanger : kSubText),
                        ),
                        Expanded(
                          flex: 2,
                          child: _buildAgingCell('Total', _formatAmount(customer.totalOutstanding), kPrimary, isBold: true),
                        ),
                      ],
                    ),
                  ),
                
                // Mobile Aging Cells
                if (isMobile)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildMobileAgingCell('Current', _formatAmount(customer.current), customer.current > 0 ? kSuccess : kSubText),
                      _buildMobileAgingCell('1-30', _formatAmount(customer.days1to30), customer.days1to30 > 0 ? kWarning : kSubText),
                      _buildMobileAgingCell('31-60', _formatAmount(customer.days31to60), customer.days31to60 > 0 ? kWarning : kSubText),
                      _buildMobileAgingCell('61-90', _formatAmount(customer.days61to90), customer.days61to90 > 0 ? kDanger : kSubText),
                      _buildMobileAgingCell('90+', _formatAmount(customer.daysOver90), customer.daysOver90 > 0 ? kDanger : kSubText),
                      _buildMobileAgingCell('Total', _formatAmount(customer.totalOutstanding), kPrimary, isBold: true),
                    ],
                  ),
                
                SizedBox(height: isWeb ? 16 : 12),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => _viewInvoices(customer),
                        icon: Icon(Icons.receipt, size: isWeb ? 18 : 14),
                        label: Text('View Invoices', style: TextStyle(fontSize: isWeb ? 12 : 10)),
                        style: TextButton.styleFrom(
                          foregroundColor: kPrimary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => _sendReminder(customer),
                        icon: Icon(Icons.email, size: isWeb ? 18 : 14),
                        label: Text('Send Reminder', style: TextStyle(fontSize: isWeb ? 12 : 10)),
                        style: TextButton.styleFrom(
                          foregroundColor: kPrimary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _recordPayment(customer),
                        icon: Icon(Icons.payment, size: isWeb ? 18 : 14, color: Colors.white),
                        label: Text('Record Payment', style: TextStyle(fontSize: isWeb ? 12 : 10)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kSuccess,
                          padding: EdgeInsets.symmetric(vertical: isWeb ? 10 : 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(isWeb ? 8 : 6),
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

  Widget _buildAgingCell(String label, String amount, Color color, {bool isBold = false}) {
    final isWeb = ResponsiveUtils.isWeb(Get.context!);
    
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isWeb ? 12 : 10,
            color: kSubText,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: isWeb ? 4 : 2),
        Text(
          amount,
          style: TextStyle(
            fontSize: isWeb ? (isBold ? 13 : 12) : (isBold ? 12 : 11),
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileAgingCell(String label, String amount, Color color, {bool isBold = false}) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: kSubText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            amount,
            style: TextStyle(
              fontSize: isBold ? 12 : 11,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    final isWeb = ResponsiveUtils.isWeb(Get.context!);
    
    return FloatingActionButton(
      onPressed: () => _exportToExcel(),
      backgroundColor: kPrimary,
      child: Icon(Icons.download, color: Colors.white, size: isWeb ? 24 : 20),
      elevation: 3,
    );
  }

  // ==================== PDF Generation Logic (Unchanged) ====================
  Future<void> _generateAndPrintPDF() async {
    try {
      Get.dialog(
        Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: kPrimary, strokeWidth: 3),
                const SizedBox(height: 16),
                Text(
                  'Generating PDF...',
                  style:  TextStyle(fontSize: 12, color: kText),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      final pdf = pw.Document();
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(20),
          build: (context) => [
            _buildPdfHeader(),
            pw.SizedBox(height: 20),
            _buildPdfSummaryCards(),
            pw.SizedBox(height: 20),
            _buildPdfTableHeader(),
            ..._customers.map((customer) => _buildPdfCustomerRow(customer)),
            pw.SizedBox(height: 20),
            _buildPdfTotalRow(),
            pw.SizedBox(height: 30),
            _buildPdfFooter(),
          ],
        ),
      );

      Get.back();
      
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'Aged_Receivables_${DateFormat('yyyyMMdd').format(_asAtDate)}.pdf',
      );
      
      AppSnackbar.success(
        Colors.green,
        'Success',
        'PDF generated successfully',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.back();
      AppSnackbar.error(
        Colors.red,
        'Error',
        'Failed to generate PDF: $e',
        duration: const Duration(seconds: 2),
      );
    }
  }

  pw.Widget _buildPdfHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          'Aged Receivables Report',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          'As at ${DateFormat('dd MMM yyyy').format(_asAtDate)}',
          style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          'Generated on: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}',
          style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
        ),
        pw.Divider(),
      ],
    );
  }

  pw.Widget _buildPdfSummaryCards() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _buildPdfSummaryCard('Current', _formatAmountForPdf(totalCurrent), PdfColors.green),
        _buildPdfSummaryCard('1-30 Days', _formatAmountForPdf(total1to30), PdfColors.orange),
        _buildPdfSummaryCard('31-60 Days', _formatAmountForPdf(total31to60), PdfColors.orange),
        _buildPdfSummaryCard('61-90 Days', _formatAmountForPdf(total61to90), PdfColors.red),
        _buildPdfSummaryCard('90+ Days', _formatAmountForPdf(totalOver90), PdfColors.red),
        _buildPdfSummaryCard('Total', _formatAmountForPdf(totalOutstanding), PdfColors.blue),
      ],
    );
  }

  pw.Widget _buildPdfSummaryCard(String title, String amount, PdfColor color) {
    return pw.Container(
      width: 90,
      padding: pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color, width: 1),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
          ),
          pw.Text(
            amount,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfTableHeader() {
    return pw.Container(
      padding: pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey300,
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(flex: 3, child: pw.Text('Customer', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold))),
          pw.Expanded(flex: 2, child: pw.Text('Current', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
          pw.Expanded(flex: 2, child: pw.Text('1-30', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
          pw.Expanded(flex: 2, child: pw.Text('31-60', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
          pw.Expanded(flex: 2, child: pw.Text('61-90', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
          pw.Expanded(flex: 2, child: pw.Text('90+', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
          pw.Expanded(flex: 2, child: pw.Text('Total', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
        ],
      ),
    );
  }

  pw.Widget _buildPdfCustomerRow(AgedCustomer customer) {
    return pw.Container(
      padding: pw.EdgeInsets.all(6),
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(flex: 3, child: pw.Text(customer.name, style: pw.TextStyle(fontSize: 12))),
          pw.Expanded(flex: 2, child: pw.Text(_formatAmountForPdf(customer.current), style: pw.TextStyle(fontSize: 12), textAlign: pw.TextAlign.right)),
          pw.Expanded(flex: 2, child: pw.Text(_formatAmountForPdf(customer.days1to30), style: pw.TextStyle(fontSize: 12), textAlign: pw.TextAlign.right)),
          pw.Expanded(flex: 2, child: pw.Text(_formatAmountForPdf(customer.days31to60), style: pw.TextStyle(fontSize: 12), textAlign: pw.TextAlign.right)),
          pw.Expanded(flex: 2, child: pw.Text(_formatAmountForPdf(customer.days61to90), style: pw.TextStyle(fontSize: 12), textAlign: pw.TextAlign.right)),
          pw.Expanded(flex: 2, child: pw.Text(_formatAmountForPdf(customer.daysOver90), style: pw.TextStyle(fontSize: 12), textAlign: pw.TextAlign.right)),
          pw.Expanded(flex: 2, child: pw.Text(_formatAmountForPdf(customer.totalOutstanding), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
        ],
      ),
    );
  }

  pw.Widget _buildPdfTotalRow() {
    return pw.Container(
      padding: pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(flex: 3, child: pw.Text('TOTAL', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold))),
          pw.Expanded(flex: 2, child: pw.Text(_formatAmountForPdf(totalCurrent), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
          pw.Expanded(flex: 2, child: pw.Text(_formatAmountForPdf(total1to30), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
          pw.Expanded(flex: 2, child: pw.Text(_formatAmountForPdf(total31to60), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
          pw.Expanded(flex: 2, child: pw.Text(_formatAmountForPdf(total61to90), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
          pw.Expanded(flex: 2, child: pw.Text(_formatAmountForPdf(totalOver90), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
          pw.Expanded(flex: 2, child: pw.Text(_formatAmountForPdf(totalOutstanding), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
        ],
      ),
    );
  }

  pw.Widget _buildPdfFooter() {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.SizedBox(height: 10),
        pw.Text(
          'This is a computer-generated document and does not require a signature.',
          style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  // ==================== Print Logic ====================
  void _printReport() async {
    try {
      Get.dialog(
        Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: kPrimary, strokeWidth: 3),
                const SizedBox(height: 16),
                Text(
                  'Preparing print...',
                  style:  TextStyle(fontSize: 12, color: kText),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      final pdf = pw.Document();
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(20),
          build: (context) => [
            _buildPdfHeader(),
            pw.SizedBox(height: 20),
            _buildPdfSummaryCards(),
            pw.SizedBox(height: 20),
            _buildPdfTableHeader(),
            ..._customers.map((customer) => _buildPdfCustomerRow(customer)),
            pw.SizedBox(height: 20),
            _buildPdfTotalRow(),
            pw.SizedBox(height: 30),
            _buildPdfFooter(),
          ],
        ),
      );

      Get.back();
      
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
      
      AppSnackbar.success(
        Colors.green,
        'Success',
        'Print job sent successfully',
       
      );
    } catch (e) {
      Get.back();
      AppSnackbar.error(
        Colors.red,
        'Error',
        'Failed to print: $e',
        duration: const Duration(seconds: 2),
      );
    }
  }

  void _exportToExcel() {
    AppSnackbar.success(
      Colors.blue,
      'Export',
      'Exporting to Excel...',
      duration: const Duration(seconds: 2),
    );
  }

  // ==================== Helper Functions ====================
  void _selectAsAtDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _asAtDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _asAtDate = picked;
        _calculateAging();
      });
    }
  }

  List<AgedCustomer> _getFilteredCustomers() {
    List<AgedCustomer> filtered = List.from(_customers);
    
    if (_selectedFilter != 'All') {
      filtered = filtered.where((customer) {
        switch (_selectedFilter) {
          case 'Current':
            return customer.current > 0;
          case '1-30 Days':
            return customer.days1to30 > 0;
          case '31-60 Days':
            return customer.days31to60 > 0;
          case '61-90 Days':
            return customer.days61to90 > 0;
          case '90+ Days':
            return customer.daysOver90 > 0;
          default:
            return true;
        }
      }).toList();
    }
    
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filtered = filtered.where((customer) {
        return customer.name.toLowerCase().contains(searchTerm) ||
               customer.email.toLowerCase().contains(searchTerm) ||
               customer.phone.contains(searchTerm);
      }).toList();
    }
    
    return filtered;
  }

  void _filterCustomers() {
    setState(() {});
  }

  void _showCustomerDetails(AgedCustomer customer) {
    final isWeb = ResponsiveUtils.isWeb(Get.context!);
    final isMobile = ResponsiveUtils.isMobile(Get.context!);
    
    if (isWeb) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            child: _buildCustomerDetailsContent(customer),
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
          constraints: const BoxConstraints(maxHeight: 70, maxWidth: 500),
          child: _buildCustomerDetailsContent(customer),
        ),
      );
    }
  }

  Widget _buildCustomerDetailsContent(AgedCustomer customer) {
    final isWeb = ResponsiveUtils.isWeb(Get.context!);
    
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
                color: kPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isWeb ? 14 : 10),
              ),
              child: Center(
                child: Text(
                  customer.name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: isWeb ? 24 : 18,
                    fontWeight: FontWeight.w800,
                    color: kPrimary,
                  ),
                ),
              ),
            ),
            SizedBox(width: isWeb ? 16 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: TextStyle(
                      fontSize: isWeb ? 18 : 16,
                      fontWeight: FontWeight.w800,
                      color: kText,
                    ),
                  ),
                  Text(
                    customer.email,
                    style: TextStyle(
                      fontSize: isWeb ? 13 : 12,
                      color: kSubText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: isWeb ? 20 : 16),
        Container(
          padding: EdgeInsets.all(isWeb ? 16 : 12),
          decoration: BoxDecoration(
            color: kBg,
            borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
          ),
          child: Column(
            children: [
              _buildDetailRow('Phone', customer.phone, isWeb),
              _buildDetailRow('Total Outstanding', _formatAmount(customer.totalOutstanding), isWeb),
              _buildDetailRow('Current', _formatAmount(customer.current), isWeb),
              _buildDetailRow('1-30 Days', _formatAmount(customer.days1to30), isWeb),
              _buildDetailRow('31-60 Days', _formatAmount(customer.days31to60), isWeb),
              _buildDetailRow('61-90 Days', _formatAmount(customer.days61to90), isWeb),
              _buildDetailRow('90+ Days', _formatAmount(customer.daysOver90), isWeb),
            ],
          ),
        ),
        SizedBox(height: isWeb ? 20 : 16),
        Text(
          'Invoices',
          style: TextStyle(
            fontSize: isWeb ? 16 : 14,
            fontWeight: FontWeight.w700,
            color: kText,
          ),
        ),
        SizedBox(height: isWeb ? 12 : 8),
        ...customer.invoices.map((invoice) => _buildInvoiceItem(invoice, isWeb)),
        SizedBox(height: isWeb ? 20 : 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(Get.context!);
                  _viewInvoices(customer);
                },
                icon: Icon(Icons.receipt, size: isWeb ? 20 : 16),
                label: Text('View All', style: TextStyle(fontSize: isWeb ? 14 : 12)),
              ),
            ),
            SizedBox(width: isWeb ? 12 : 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(Get.context!);
                  _recordPayment(customer);
                },
                icon: Icon(Icons.payment, size: isWeb ? 20 : 16),
                label: Text('Record Payment', style: TextStyle(fontSize: isWeb ? 14 : 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kSuccess,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isWeb ? 13 : 11,
              color: kSubText,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isWeb ? 13 : 12,
              color: kText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceItem(AgedInvoice invoice, bool isWeb) {
    double outstanding = invoice.amount - invoice.paidAmount;
    int daysOverdue = _asAtDate.difference(invoice.dueDate).inDays;
    Color statusColor = daysOverdue <= 0 ? kSuccess :
                        daysOverdue <= 30 ? kWarning : kDanger;
    
    return Container(
      margin: EdgeInsets.only(bottom: isWeb ? 12 : 8),
      padding: EdgeInsets.all(isWeb ? 12 : 10),
      decoration: BoxDecoration(
        color: kBg,
        borderRadius: BorderRadius.circular(isWeb ? 10 : 8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoice.id,
                  style: TextStyle(
                    fontSize: isWeb ? 13 : 12,
                    fontWeight: FontWeight.w600,
                    color: kText,
                  ),
                ),
                Text(
                  'Due: ${DateFormat('dd MMM yyyy').format(invoice.dueDate)}',
                  style: TextStyle(
                    fontSize: isWeb ? 11 : 10,
                    color: kSubText,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatAmount(outstanding),
            style: TextStyle(
              fontSize: isWeb ? 14 : 12,
              fontWeight: FontWeight.w700,
              color: statusColor,
            ),
          ),
          SizedBox(width: isWeb ? 8 : 6),
          Container(
            padding: EdgeInsets.symmetric(horizontal: isWeb ? 8 : 6, vertical: isWeb ? 4 : 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(isWeb ? 6 : 4),
            ),
            child: Text(
              daysOverdue <= 0 ? 'Current' : '$daysOverdue days',
              style: TextStyle(
                fontSize: isWeb ? 10 : 9,
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _viewInvoices(AgedCustomer customer) {
    AppSnackbar.success(
      Colors.blue,
      'Invoices',
      'Viewing invoices for ${customer.name}',
      duration: const Duration(seconds: 2),
    );
  }

  void _sendReminder(AgedCustomer customer) {
    AppSnackbar.success(
      Colors.blue,
      'Reminder',
      'Sending payment reminder to ${customer.name}',
      duration: const Duration(seconds: 2),
    );
  }

  void _recordPayment(AgedCustomer customer) {
    AppSnackbar.success(
      Colors.green,
      'Record Payment',
      'Recording payment from ${customer.name}',
      duration: const Duration(seconds: 2),
    );
  }

  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '\$ ${formatter.format(amount)}';
  }

  String _formatAmountForPdf(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '\$ ${formatter.format(amount)}';
  }
}

class AgedCustomer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final double totalOutstanding;
  final List<AgedInvoice> invoices;
  
  double current = 0;
  double days1to30 = 0;
  double days31to60 = 0;
  double days61to90 = 0;
  double daysOver90 = 0;

  AgedCustomer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.totalOutstanding,
    required this.invoices,
  });
}

class AgedInvoice {
  final String id;
  final DateTime date;
  final DateTime dueDate;
  final double amount;
  final double paidAmount;

  AgedInvoice({
    required this.id,
    required this.date,
    required this.dueDate,
    required this.amount,
    required this.paidAmount,
  });
}