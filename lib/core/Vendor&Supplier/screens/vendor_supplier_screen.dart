import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/core/Bills/Screen/bill_Screen.dart';
import 'package:LedgerPro_app/core/Vendor&Supplier/Controller/vendor_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';

class VendorsScreen extends StatefulWidget {
  const VendorsScreen({super.key});

  @override
  State<VendorsScreen> createState() => _VendorsScreenState();
}

class _VendorsScreenState extends State<VendorsScreen> {
  final VendorsController controller = Get.put(VendorsController());
  TextEditingController _searchController = TextEditingController();

  final List<String> _filterOptions = ['All', 'Active', 'Inactive', 'With Balance'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      controller.searchVendors(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child:LoadingAnimationWidget.waveDots(
                    color: kPrimary,
                    size: 10.w,
                  ),
          );
        }

        return Column(
          children: [
            _buildSummaryCards(),
            _buildFilterBar(),
            Expanded(
              child: _buildVendorsList(),
            ),
          ],
        );
      }),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Vendors / Suppliers',
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
          icon: Icon(Icons.download_outlined, color: Colors.white, size: 5.w),
  onPressed: () => controller.exportVendors(),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return Obx(() {
      int totalVendors = controller.vendors.length;
      int activeVendors = controller.vendors.where((v) => v.isActive).length;
      double totalOutstanding = controller.vendors.fold(0.0, (sum, v) => sum + v.outstandingBalance);
      double totalPurchases = controller.vendors.fold(0.0, (sum, v) => sum + v.totalPurchases);

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildSummaryCard('Total Vendors', totalVendors.toString(), kPrimary, Icons.business, 25.w, isNumber: true),
              SizedBox(width: 2.w),
              _buildSummaryCard('Active Vendors', activeVendors.toString(), kSuccess, Icons.check_circle, 25.w, isNumber: true),
              SizedBox(width: 2.w),
              _buildSummaryCard('Total Outstanding', _formatAmount(totalOutstanding), kDanger, Icons.payment, 28.w),
              SizedBox(width: 2.w),
              _buildSummaryCard('Total Purchases', _formatAmount(totalPurchases), kPrimary, Icons.shopping_cart, 28.w),
            ],
          ),
        ),
      );
    });
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
                onChanged: (value) => controller.searchVendors(value),
                style: TextStyle(fontSize: 12.sp),
                decoration: InputDecoration(
                  hintText: 'Search by name, email, phone, or tax ID...',
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
                child: Obx(() => DropdownButton<String>(
                  value: controller.selectedFilter.value,
                  icon: Icon(Icons.arrow_drop_down, size: 5.w),
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  isExpanded: true,
                  style: TextStyle(fontSize: 12.sp, color: kText),
                  items: _filterOptions.map((filter) {
                    return DropdownMenuItem(
                      value: filter,
                      child: Text(filter, style: TextStyle(fontSize: 12.sp)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) controller.changeFilter(value);
                  },
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorsList() {
    return Obx(() {
      final vendors = controller.filteredVendors;

      if (vendors.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.business_outlined, size: 15.w, color: kSubText.withOpacity(0.5)),
              SizedBox(height: 2.h),
              Text(
                'No vendors found',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: kSubText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              ElevatedButton(
                onPressed: () => _showAddVendorDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Add Vendor',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(4.w),
        itemCount: vendors.length,
        itemBuilder: (context, index) {
          final vendor = vendors[index];
          return _buildVendorCard(vendor);
        },
      );
    });
  }

  Widget _buildVendorCard(Vendor vendor) {
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
          onTap: () => _showVendorDetails(vendor),
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
                        color: vendor.isActive 
                            ? kSuccess.withOpacity(0.1) 
                            : kSubText.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          vendor.name[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: vendor.isActive ? kSuccess : kSubText,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  vendor.name,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w800,
                                    color: kText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                                decoration: BoxDecoration(
                                  color: vendor.isActive 
                                      ? kSuccess.withOpacity(0.1) 
                                      : kDanger.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  vendor.isActive ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: vendor.isActive ? kSuccess : kDanger,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            vendor.email,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: kSubText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            '${vendor.phone} • Tax: ${vendor.taxId}',
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
                
                Container(
                  padding: EdgeInsets.symmetric(vertical: 1.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          'Total Purchases',
                          _formatAmount(vendor.totalPurchases),
                          Icons.shopping_cart,
                          kPrimary,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 4.h,
                        color: kBorder,
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Total Paid',
                          _formatAmount(vendor.totalPaid),
                          Icons.check_circle,
                          kSuccess,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 4.h,
                        color: kBorder,
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Outstanding',
                          _formatAmount(vendor.outstandingBalance),
                          Icons.payment,
                          vendor.outstandingBalance > 0 ? kDanger : kSuccess,
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
                          'Payment Terms',
                          vendor.paymentTerms,
                          Icons.credit_card,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 3.h,
                        color: kBorder,
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          'Last Purchase',
                          vendor.lastPurchaseDate != null 
                              ? DateFormat('dd MMM yyyy').format(vendor.lastPurchaseDate!)
                              : 'N/A',
                          Icons.calendar_today,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 3.h,
                        color: kBorder,
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          'Contact',
                          vendor.contactPerson,
                          Icons.person,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 2.h),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _editVendor(vendor),
                        icon: Icon(Icons.edit, size: 4.w),
                        label: Text(
                          'Edit',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kPrimary,
                          side: BorderSide(color: kPrimary, width: 1),
                          padding: EdgeInsets.symmetric(vertical: 1.2.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _viewBills(vendor),
                        icon: Icon(Icons.receipt, size: 4.w),
                        label: Text(
                          'View Bills',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kPrimary,
                          side: BorderSide(color: kPrimary, width: 1),
                          padding: EdgeInsets.symmetric(vertical: 1.2.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _recordPayment(vendor),
                        icon: Icon(Icons.payment, size: 4.w, color: Colors.white),
                        label: Text(
                          'Pay Now',
                          style: TextStyle(fontSize: 12.sp),
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
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 4.w, color: color),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: kText,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: kSubText,
          ),
        ),
      ],
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
                  fontSize: 12.sp,
                  color: kSubText,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12.sp,
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

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () => _showAddVendorDialog(),
      backgroundColor: kPrimary,
      child: Icon(Icons.add, color: Colors.white, size: 6.w),
      elevation: 3,
    );
  }

  void _showAddVendorDialog() {
    final formKey = GlobalKey<FormState>();
    String name = '';
    String email = '';
    String phone = '';
    String address = '';
    String taxId = '';
    String contactPerson = '';
    String contactPersonPhone = '';
    String paymentTerms = 'Net 30';
    String notes = '';

    showDialog(
      context: Get.context!,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              width: 90.w,
              constraints: BoxConstraints(maxHeight: 85.h),
              padding: EdgeInsets.all(5.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Add New Vendor',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: kText,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            _buildTextField('Vendor Name *', (v) => name = v, validator: true),
                            SizedBox(height: 2.h),
                            _buildTextField('Email *', (v) => email = v, validator: true),
                            SizedBox(height: 2.h),
                            _buildTextField('Phone *', (v) => phone = v, validator: true),
                            SizedBox(height: 2.h),
                            _buildTextField('Tax ID (NTN)', (v) => taxId = v),
                            SizedBox(height: 2.h),
                            _buildTextField('Address', (v) => address = v, maxLines: 2),
                            SizedBox(height: 2.h),
                            _buildTextField('Contact Person', (v) => contactPerson = v),
                            SizedBox(height: 2.h),
                            _buildTextField('Contact Person Phone', (v) => contactPersonPhone = v),
                            SizedBox(height: 2.h),
                            DropdownButtonFormField<String>(
                              value: paymentTerms,
                              decoration: _inputDecoration('Payment Terms'),
                              style: TextStyle(fontSize: 12.sp),
                              items: const [
                                DropdownMenuItem(value: 'Net 7', child: Text('Net 7 days')),
                                DropdownMenuItem(value: 'Net 15', child: Text('Net 15 days')),
                                DropdownMenuItem(value: 'Net 30', child: Text('Net 30 days')),
                                DropdownMenuItem(value: 'Net 45', child: Text('Net 45 days')),
                                DropdownMenuItem(value: 'Net 60', child: Text('Net 60 days')),
                                DropdownMenuItem(value: 'Due on Receipt', child: Text('Due on Receipt')),
                              ],
                              onChanged: (value) => paymentTerms = value!,
                            ),
                            SizedBox(height: 2.h),
                            _buildTextField('Notes', (v) => notes = v, maxLines: 2),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          child: Text('Cancel', style: TextStyle(fontSize: 12.sp)),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              Get.back();
                              controller.createVendor({
                                'name': name,
                                'email': email,
                                'phone': phone,
                                'address': address,
                                'taxId': taxId,
                                'contactPerson': contactPerson,
                                'contactPersonPhone': contactPersonPhone,
                                'paymentTerms': paymentTerms,
                                'notes': notes,
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                          child: Text('Add Vendor', style: TextStyle(fontSize: 12.sp)),
                        ),
                      ),
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

  void _editVendor(Vendor vendor) {
    final formKey = GlobalKey<FormState>();
    String name = vendor.name;
    String email = vendor.email;
    String phone = vendor.phone;
    String address = vendor.address;
    String taxId = vendor.taxId;
    String contactPerson = vendor.contactPerson;
    String contactPersonPhone = vendor.contactPersonPhone;
    String paymentTerms = vendor.paymentTerms;
    bool isActive = vendor.isActive;
    String notes = vendor.notes;

    showDialog(
      context: Get.context!,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Edit Vendor', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800)),
            content: SizedBox(
              width: 80.w,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      _buildTextField('Vendor Name *', (v) => name = v, initialValue: name, validator: true),
                      SizedBox(height: 2.h),
                      _buildTextField('Email *', (v) => email = v, initialValue: email, validator: true),
                      SizedBox(height: 2.h),
                      _buildTextField('Phone *', (v) => phone = v, initialValue: phone, validator: true),
                      SizedBox(height: 2.h),
                      _buildTextField('Tax ID', (v) => taxId = v, initialValue: taxId),
                      SizedBox(height: 2.h),
                      _buildTextField('Address', (v) => address = v, initialValue: address, maxLines: 2),
                      SizedBox(height: 2.h),
                      _buildTextField('Contact Person', (v) => contactPerson = v, initialValue: contactPerson),
                      SizedBox(height: 2.h),
                      _buildTextField('Contact Person Phone', (v) => contactPersonPhone = v, initialValue: contactPersonPhone),
                      SizedBox(height: 2.h),
                      DropdownButtonFormField<String>(
                        value: paymentTerms,
                        decoration: _inputDecoration('Payment Terms'),
                        style: TextStyle(fontSize: 12.sp),
                        items: const [
                          DropdownMenuItem(value: 'Net 7', child: Text('Net 7 days')),
                          DropdownMenuItem(value: 'Net 15', child: Text('Net 15 days')),
                          DropdownMenuItem(value: 'Net 30', child: Text('Net 30 days')),
                          DropdownMenuItem(value: 'Net 45', child: Text('Net 45 days')),
                          DropdownMenuItem(value: 'Net 60', child: Text('Net 60 days')),
                          DropdownMenuItem(value: 'Due on Receipt', child: Text('Due on Receipt')),
                        ],
                        onChanged: (value) => paymentTerms = value!,
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Text('Active', style: TextStyle(fontSize: 12.sp)),
                          Spacer(),
                          Switch(
                            value: isActive,
                            onChanged: (value) => setState(() => isActive = value),
                            activeColor: kSuccess,
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      _buildTextField('Notes', (v) => notes = v, initialValue: notes, maxLines: 2),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text('Cancel', style: TextStyle(fontSize: 12.sp)),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Get.back();
                    controller.updateVendor(vendor.id, {
                      'name': name,
                      'email': email,
                      'phone': phone,
                      'address': address,
                      'taxId': taxId,
                      'contactPerson': contactPerson,
                      'contactPersonPhone': contactPersonPhone,
                      'paymentTerms': paymentTerms,
                      'isActive': isActive,
                      'notes': notes,
                    });
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                child: Text('Update Vendor', style: TextStyle(fontSize: 12.sp)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showVendorDetails(Vendor vendor) {
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(5.w),
        constraints: BoxConstraints(
          maxHeight: 85.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 14.w,
                  height: 14.w,
                  decoration: BoxDecoration(
                    color: vendor.isActive 
                        ? kSuccess.withOpacity(0.1) 
                        : kSubText.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      vendor.name[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: vendor.isActive ? kSuccess : kSubText,
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
                        vendor.name,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: kText,
                        ),
                      ),
                      Text(
                        vendor.email,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: kSubText,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                  decoration: BoxDecoration(
                    color: vendor.isActive 
                        ? kSuccess.withOpacity(0.1) 
                        : kDanger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    vendor.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: vendor.isActive ? kSuccess : kDanger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            _buildDetailRow('Phone', vendor.phone),
            _buildDetailRow('Tax ID', vendor.taxId),
            _buildDetailRow('Address', vendor.address),
            _buildDetailRow('Contact Person', vendor.contactPerson),
            _buildDetailRow('Contact Phone', vendor.contactPersonPhone),
            _buildDetailRow('Payment Terms', vendor.paymentTerms),
            _buildDetailRow('Total Purchases', _formatAmount(vendor.totalPurchases)),
            _buildDetailRow('Total Paid', _formatAmount(vendor.totalPaid)),
            _buildDetailRow('Outstanding Balance', _formatAmount(vendor.outstandingBalance)),
            if (vendor.lastPurchaseDate != null)
              _buildDetailRow(
                'Last Purchase',
                DateFormat('dd MMM yyyy').format(vendor.lastPurchaseDate!),
              ),
            if (vendor.notes.isNotEmpty)
              _buildDetailRow('Notes', vendor.notes),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _editVendor(vendor);
                    },
                    icon: Icon(Icons.edit, size: 4.5.w),
                    label: Text('Edit', style: TextStyle(fontSize: 12.sp)),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _viewBills(vendor);
                    },
                    icon: Icon(Icons.receipt, size: 4.5.w),
                    label: Text('View Bills', style: TextStyle(fontSize: 12.sp)),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _recordPayment(vendor);
                    },
                    icon: Icon(Icons.payment, size: 4.5.w),
                    label: Text('Pay Now', style: TextStyle(fontSize: 12.sp)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kSuccess,
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: kSubText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                color: kText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextFormField _buildTextField(
    String label,
    Function(String) onChanged, {
    String? initialValue,
    bool validator = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: _inputDecoration(label),
      maxLines: maxLines,
      style: TextStyle(fontSize: 12.sp),
      onChanged: onChanged,
      validator: validator ? (v) => v == null || v.isEmpty ? '$label required' : null : null,
    );
  }

  InputDecoration _inputDecoration(String label, {String? prefix}) {
    return InputDecoration(
      labelText: label,
      prefixText: prefix,
      labelStyle: TextStyle(fontSize: 12.sp),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
    );
  }

  void _viewBills(Vendor vendor) {
    Get.to(() => BillsScreen(vendorId: vendor.id));
  }

  void _recordPayment(Vendor vendor) {
    Get.to(() => BillsScreen(vendorId: vendor.id));
  }

  void _importVendors() {
    Get.snackbar(
      'Import',
      'Importing vendors from file...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: kPrimary,
      colorText: Colors.white,
    );
  }

  void _exportVendors() {
    Get.snackbar(
      'Export',
      'Exporting vendors list to Excel...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: kPrimary,
      colorText: Colors.white,
    );
  }

  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '₨ ${formatter.format(amount)}';
  }
}