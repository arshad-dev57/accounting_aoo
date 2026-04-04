import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
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
      
      // Update customer aging buckets
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
    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: kPrimary,
                strokeWidth: 3.w,
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
    return AppBar(
      title: Text(
        'Aged Receivables',
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
          icon: Icon(Icons.calendar_today, color: Colors.white, size: 5.w),
          onPressed: () => _selectAsAtDate(),
        ),
        IconButton(
          icon: Icon(Icons.picture_as_pdf, color: Colors.white, size: 5.w),
          onPressed: () => _generateAndPrintPDF(),
        ),
        IconButton(
          icon: Icon(Icons.print, color: Colors.white, size: 5.w),
          onPressed: () => _printReport(),
        ),
        IconButton(
          icon: Icon(Icons.download, color: Colors.white, size: 5.w),
          onPressed: () => _exportToExcel(),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Container(
      width: 100.w,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      color: kCardBg,
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 5.w, color: kPrimary),
          SizedBox(width: 2.w),
          Text(
            'As at:',
            style: TextStyle(
              fontSize: 12.sp,
              color: kSubText,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 2.w),
          GestureDetector(
            onTap: () => _selectAsAtDate(),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                DateFormat('dd MMM yyyy').format(_asAtDate),
                style: TextStyle(
                  fontSize: 12.sp,
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildSummaryCard('Current', _formatAmount(totalCurrent), kSuccess, Icons.access_time, 28.w),
            SizedBox(width: 2.w),
            _buildSummaryCard('1-30 Days', _formatAmount(total1to30), kWarning, Icons.calendar_view_month, 28.w),
            SizedBox(width: 2.w),
            _buildSummaryCard('31-60 Days', _formatAmount(total31to60), kWarning, Icons.calendar_view_month, 28.w),
            SizedBox(width: 2.w),
            _buildSummaryCard('61-90 Days', _formatAmount(total61to90), kDanger, Icons.calendar_view_month, 28.w),
            SizedBox(width: 2.w),
            _buildSummaryCard('90+ Days', _formatAmount(totalOver90), kDanger, Icons.warning, 28.w),
            SizedBox(width: 2.w),
            _buildSummaryCard('Total', _formatAmount(totalOutstanding), kPrimary, Icons.attach_money, 28.w),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String amount, Color color, IconData icon, double width) {
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
            amount,
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

  Widget _buildFilterBar() {
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
              decoration: BoxDecoration(
                color: kBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kBorder),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => _filterCustomers(),
                style: TextStyle(fontSize: 14.sp),
                decoration: InputDecoration(
                  hintText: 'Search by customer name, email, or phone...',
                  hintStyle: TextStyle(fontSize: 12.sp, color: kSubText),
                  prefixIcon: Icon(Icons.search, size: 5.w),
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
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedFilter,
                  icon: Icon(Icons.arrow_drop_down, size: 5.w),
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  isExpanded: true,
                  style: TextStyle(fontSize: 14.sp, color: kText),
                  items: _filterOptions.map((filter) {
                    return DropdownMenuItem(
                      value: filter,
                      child: Text(filter),
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
    
    if (filteredCustomers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 15.w, color: kSubText.withOpacity(0.5)),
            SizedBox(height: 2.h),
            Text(
              'No customers found',
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

    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: filteredCustomers.length,
      itemBuilder: (context, index) {
        final customer = filteredCustomers[index];
        return _buildCustomerRow(customer);
      },
    );
  }

  Widget _buildCustomerRow(AgedCustomer customer) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showCustomerDetails(customer),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              // Customer Header
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: kBg,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: kPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          customer.name[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: kPrimary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.name,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: kText,
                            ),
                          ),
                          Text(
                            customer.email,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: kSubText,
                            ),
                          ),
                          Text(
                            customer.phone,
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
                          'Total Outstanding',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: kSubText,
                          ),
                        ),
                        Text(
                          _formatAmount(customer.totalOutstanding),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: kDanger,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Aging Table Row
              Container(
                padding: EdgeInsets.all(3.w),
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
              
              // Action Buttons
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: kBg,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => _viewInvoices(customer),
                        icon: Icon(Icons.receipt, size: 4.w),
                        label: Text('View Invoices', style: TextStyle(fontSize: 12.sp)),
                        style: TextButton.styleFrom(
                          foregroundColor: kPrimary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => _sendReminder(customer),
                        icon: Icon(Icons.email, size: 4.w),
                        label: Text('Send Reminder', style: TextStyle(fontSize: 12.sp)),
                        style: TextButton.styleFrom(
                          foregroundColor: kPrimary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _recordPayment(customer),
                        icon: Icon(Icons.payment, size: 4.w, color: Colors.white),
                        label: Text('Record Payment', style: TextStyle(fontSize: 12
                        .sp)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kSuccess,
                          padding: EdgeInsets.symmetric(vertical: 1.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgingCell(String label, String amount, Color color, {bool isBold = false}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: kSubText,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          amount,
          style: TextStyle(
            fontSize: isBold ? 12.sp : 12.sp,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () => _exportToExcel(),
      backgroundColor: kPrimary,
      child: Icon(Icons.download, color: Colors.white, size: 6.w),
      elevation: 3,
    );
  }

  // ==================== PDF Generation Logic ====================
  Future<void> _generateAndPrintPDF() async {
    try {
      Get.dialog(
        Center(
          child: Container(
            padding: EdgeInsets.all(5.w),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: kPrimary, strokeWidth: 3.w),
                SizedBox(height: 2.h),
                Text(
                  'Generating PDF...',
                  style: TextStyle(fontSize: 12.sp, color: kText),
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
      
      Get.snackbar(
        'Success',
        'PDF generated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: kSuccess,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Failed to generate PDF: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: kDanger,
        colorText: Colors.white,
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
            padding: EdgeInsets.all(5.w),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: kPrimary, strokeWidth: 3.w),
                SizedBox(height: 2.h),
                Text(
                  'Preparing print...',
                  style: TextStyle(fontSize: 12.sp, color: kText),
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
      
      Get.snackbar(
        'Success',
        'Print job sent successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: kSuccess,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Failed to print: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: kDanger,
        colorText: Colors.white,
      );
    }
  }

  void _exportToExcel() {
    Get.snackbar(
      'Export',
      'Exporting to Excel...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: kPrimary,
      colorText: Colors.white,
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(5.w),
        constraints: BoxConstraints(maxHeight: 70.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      customer.name[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: kPrimary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: kText,
                        ),
                      ),
                      Text(
                        customer.email,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: kSubText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            _buildDetailRow('Phone', customer.phone),
            _buildDetailRow('Total Outstanding', _formatAmount(customer.totalOutstanding)),
            _buildDetailRow('Current', _formatAmount(customer.current)),
            _buildDetailRow('1-30 Days', _formatAmount(customer.days1to30)),
            _buildDetailRow('31-60 Days', _formatAmount(customer.days31to60)),
            _buildDetailRow('61-90 Days', _formatAmount(customer.days61to90)),
            _buildDetailRow('90+ Days', _formatAmount(customer.daysOver90)),
            SizedBox(height: 2.h),
            Text(
              'Invoices',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: kText,
              ),
            ),
            SizedBox(height: 1.h),
            ...customer.invoices.map((invoice) => _buildInvoiceItem(invoice)),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _viewInvoices(customer);
                    },
                    icon: Icon(Icons.receipt, size: 4.5.w),
                    label: Text('View All', style: TextStyle(fontSize: 12.sp)),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _recordPayment(customer);
                    },
                    icon: Icon(Icons.payment, size: 4.5.w),
                    label: Text('Record Payment', style: TextStyle(fontSize: 12.sp)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kSuccess,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: kSubText,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: kText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceItem(AgedInvoice invoice) {
    double outstanding = invoice.amount - invoice.paidAmount;
    int daysOverdue = _asAtDate.difference(invoice.dueDate).inDays;
    Color statusColor = daysOverdue <= 0 ? kSuccess :
                        daysOverdue <= 30 ? kWarning : kDanger;
    
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: kBg,
        borderRadius: BorderRadius.circular(10),
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
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: kText,
                  ),
                ),
                Text(
                  'Due: ${DateFormat('dd MMM yyyy').format(invoice.dueDate)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: kSubText,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatAmount(outstanding),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: statusColor,
            ),
          ),
          SizedBox(width: 2.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.3.h),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              daysOverdue <= 0 ? 'Current' : '$daysOverdue days overdue',
              style: TextStyle(
                fontSize: 12.sp,
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
    Get.snackbar(
      'Invoices',
      'Viewing invoices for ${customer.name}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: kPrimary,
      colorText: Colors.white,
    );
  }

  void _sendReminder(AgedCustomer customer) {
    Get.snackbar(
      'Reminder',
      'Sending payment reminder to ${customer.name}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: kPrimary,
      colorText: Colors.white,
    );
  }

  void _recordPayment(AgedCustomer customer) {
    Get.snackbar(
      'Record Payment',
      'Recording payment from ${customer.name}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: kSuccess,
      colorText: Colors.white,
    );
  }

  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '₨ ${formatter.format(amount)}';
  }

  String _formatAmountForPdf(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '₨ ${formatter.format(amount)}';
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