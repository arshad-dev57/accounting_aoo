import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/Utils/responsive_utils.dart';
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
    return Container(
      color: kBg,
      child: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: LoadingAnimationWidget.waveDots(
              color: kPrimary,
              size: ResponsiveUtils.isWeb(context) ? 60 : 40,
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
              _buildHeader(context),
              _buildSummaryCards(context),
              _buildFilterBar(context),
              _buildVendorsList(context),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  // Custom Header without AppBar
  Widget _buildHeader(BuildContext context) {
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
                  'Vendors / Suppliers',
                  style: TextStyle(
                    fontSize: isWeb ? 20 : 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage all your vendors and suppliers',
                  style: TextStyle(
                    fontSize: isWeb ? 13 : 11,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          // Export Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.download_outlined, color: Colors.white, size: isWeb ? 22 : 20),
              onPressed: () => controller.exportVendors(),
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
                onPressed: () => _showAddVendorDialog(context),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Obx(() {
      int totalVendors = controller.vendors.length;
      int activeVendors = controller.vendors.where((v) => v.isActive).length;
      double totalOutstanding = controller.vendors.fold(0.0, (sum, v) => sum + v.outstandingBalance);
      double totalPurchases = controller.vendors.fold(0.0, (sum, v) => sum + v.totalPurchases);

      return Container(
        padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 16 : 12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildSummaryCard('Total Vendors', totalVendors.toString(), kPrimary, Icons.business, context, width: isWeb ? 200 : 160, isNumber: true),
              SizedBox(width: isWeb ? 16 : 12),
              _buildSummaryCard('Active Vendors', activeVendors.toString(), kSuccess, Icons.check_circle, context, width: isWeb ? 200 : 160, isNumber: true),
              SizedBox(width: isWeb ? 16 : 12),
              _buildSummaryCard('Total Outstanding', _formatAmount(totalOutstanding), kDanger, Icons.payment, context, width: isWeb ? 220 : 170),
              SizedBox(width: isWeb ? 16 : 12),
              _buildSummaryCard('Total Purchases', _formatAmount(totalPurchases), kPrimary, Icons.shopping_cart, context, width: isWeb ? 220 : 170),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSummaryCard(String title, String amount, Color color, IconData icon, BuildContext context, {double width = 160, bool isNumber = false}) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
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
            isNumber ? amount : amount,
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

  Widget _buildFilterBar(BuildContext context) {
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
              decoration: BoxDecoration(
                color: kBg,
                borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
                border: Border.all(color: kBorder),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(fontSize: isWeb ? 14 : 12),
                decoration: InputDecoration(
                  hintText: isWeb ? 'Search by name, email, phone, or tax ID...' : 'Search...',
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
                child: Obx(() => DropdownButton<String>(
                  value: controller.selectedFilter.value,
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

  Widget _buildVendorsList(BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Obx(() {
      final vendors = controller.filteredVendors;

      if (vendors.isEmpty) {
        return Padding(
          padding: EdgeInsets.all(isWeb ? 40 : 20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.business_outlined, size: isWeb ? 80 : 64, color: kSubText.withOpacity(0.5)),
                SizedBox(height: isWeb ? 20 : 16),
                Text(
                  'No vendors found',
                  style: TextStyle(fontSize: isWeb ? 18 : 16, color: kSubText),
                ),
                SizedBox(height: isWeb ? 20 : 16),
                ElevatedButton(
                  onPressed: () => _showAddVendorDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 12 : 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
                    ),
                  ),
                  child: Text(
                    'Add Vendor',
                    style: TextStyle(fontSize: isWeb ? 14 : 12, fontWeight: FontWeight.w600),
                  ),
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
              'Vendors',
              style: TextStyle(
                fontSize: isWeb ? 18 : 16,
                fontWeight: FontWeight.w700,
                color: kText,
              ),
            ),
          ),
          ...vendors.map((vendor) => Padding(
            padding: EdgeInsets.symmetric(horizontal: isWeb ? 20 : 12, vertical: isWeb ? 8 : 6),
            child: _buildVendorCard(vendor, context),
          )).toList(),
        ],
      );
    });
  }

  Widget _buildVendorCard(Vendor vendor, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final isMobile = ResponsiveUtils.isMobile(context);
    
    return Container(
      margin: EdgeInsets.only(bottom: isWeb ? 12 : 8),
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
          onTap: () => _showVendorDetails(vendor, context),
          borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
          child: Padding(
            padding: EdgeInsets.all(isWeb ? 16 : 12),
            child: isMobile
                ? _buildMobileVendorCard(vendor, context)
                : _buildDesktopVendorCard(vendor, context),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopVendorCard(Vendor vendor, BuildContext context) {
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
                color: vendor.isActive 
                    ? kSuccess.withOpacity(0.1) 
                    : kSubText.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
              ),
              child: Center(
                child: Text(
                  vendor.name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: isWeb ? 20 : 16,
                    fontWeight: FontWeight.w800,
                    color: vendor.isActive ? kSuccess : kSubText,
                  ),
                ),
              ),
            ),
            SizedBox(width: isWeb ? 16 : 12),
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
                            fontSize: isWeb ? 15 : 13,
                            fontWeight: FontWeight.w800,
                            color: kText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: isWeb ? 8 : 6, vertical: isWeb ? 4 : 2),
                        decoration: BoxDecoration(
                          color: vendor.isActive 
                              ? kSuccess.withOpacity(0.1) 
                              : kDanger.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(isWeb ? 6 : 4),
                        ),
                        child: Text(
                          vendor.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: isWeb ? 11 : 10,
                            color: vendor.isActive ? kSuccess : kDanger,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isWeb ? 4 : 2),
                  Text(
                    vendor.email,
                    style: TextStyle(fontSize: isWeb ? 12 : 11, color: kSubText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isWeb ? 4 : 2),
                  Text(
                    '${vendor.phone} • Tax: ${vendor.taxId}',
                    style: TextStyle(fontSize: isWeb ? 12 : 11, color: kSubText),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: isWeb ? 16 : 12),
        Container(
          padding: EdgeInsets.symmetric(vertical: isWeb ? 10 : 8),
          child: Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Purchases',
                  _formatAmount(vendor.totalPurchases),
                  Icons.shopping_cart,
                  kPrimary,
                  isWeb,
                ),
              ),
              Container(
                width: 1,
                height: isWeb ? 32 : 24,
                color: kBorder,
              ),
              Expanded(
                child: _buildStatItem(
                  'Total Paid',
                  _formatAmount(vendor.totalPaid),
                  Icons.check_circle,
                  kSuccess,
                  isWeb,
                ),
              ),
              Container(
                width: 1,
                height: isWeb ? 32 : 24,
                color: kBorder,
              ),
              Expanded(
                child: _buildStatItem(
                  'Outstanding',
                  _formatAmount(vendor.outstandingBalance),
                  Icons.payment,
                  vendor.outstandingBalance > 0 ? kDanger : kSuccess,
                  isWeb,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isWeb ? 12 : 8),
        Container(
          padding: EdgeInsets.symmetric(vertical: isWeb ? 10 : 8),
          child: Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Payment Terms',
                  vendor.paymentTerms,
                  Icons.credit_card,
                  isWeb,
                ),
              ),
              Container(
                width: 1,
                height: isWeb ? 24 : 18,
                color: kBorder,
              ),
              Expanded(
                child: _buildInfoItem(
                  'Last Purchase',
                  vendor.lastPurchaseDate != null 
                      ? DateFormat('dd MMM yyyy').format(vendor.lastPurchaseDate!)
                      : 'N/A',
                  Icons.calendar_today,
                  isWeb,
                ),
              ),
              Container(
                width: 1,
                height: isWeb ? 24 : 18,
                color: kBorder,
              ),
              Expanded(
                child: _buildInfoItem(
                  'Contact',
                  vendor.contactPerson.isEmpty ? 'N/A' : vendor.contactPerson,
                  Icons.person,
                  isWeb,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isWeb ? 16 : 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _editVendor(vendor, context),
                icon: Icon(Icons.edit, size: isWeb ? 18 : 14),
                label: Text('Edit', style: TextStyle(fontSize: isWeb ? 12 : 10)),
                style: _buttonStyle(kPrimary, isWeb),
              ),
            ),
            SizedBox(width: isWeb ? 12 : 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _viewBills(vendor, context),
                icon: Icon(Icons.receipt, size: isWeb ? 18 : 14),
                label: Text('View Bills', style: TextStyle(fontSize: isWeb ? 12 : 10)),
                style: _buttonStyle(kPrimary, isWeb),
              ),
            ),
            SizedBox(width: isWeb ? 12 : 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _recordPayment(vendor, context),
                icon: Icon(Icons.payment, size: isWeb ? 18 : 14, color: Colors.white),
                label: Text('Pay Now', style: TextStyle(fontSize: isWeb ? 12 : 10)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kSuccess,
                  padding: EdgeInsets.symmetric(vertical: isWeb ? 10 : 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isWeb ? 8 : 6),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileVendorCard(Vendor vendor, BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: vendor.isActive 
                    ? kSuccess.withOpacity(0.1) 
                    : kSubText.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  vendor.name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: vendor.isActive ? kSuccess : kSubText,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vendor.name,
                          style:  TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: kText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: vendor.isActive 
                              ? kSuccess.withOpacity(0.1) 
                              : kDanger.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          vendor.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 9,
                            color: vendor.isActive ? kSuccess : kDanger,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    vendor.email,
                    style:  TextStyle(fontSize: 10, color: kSubText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${vendor.phone}',
                    style:  TextStyle(fontSize: 10, color: kSubText),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'Purchases',
                _formatAmount(vendor.totalPurchases),
                Icons.shopping_cart,
                kPrimary,
                false,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                'Paid',
                _formatAmount(vendor.totalPaid),
                Icons.check_circle,
                kSuccess,
                false,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                'Outstanding',
                _formatAmount(vendor.outstandingBalance),
                Icons.payment,
                vendor.outstandingBalance > 0 ? kDanger : kSuccess,
                false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _editVendor(vendor, context),
                icon: Icon(Icons.edit, size: 14),
                label: const Text('Edit', style: TextStyle(fontSize: 9)),
                style: _buttonStyle(kPrimary, false),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _viewBills(vendor, context),
                icon: Icon(Icons.receipt, size: 14),
                label: const Text('Bills', style: TextStyle(fontSize: 9)),
                style: _buttonStyle(kPrimary, false),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _recordPayment(vendor, context),
                icon: Icon(Icons.payment, size: 14, color: Colors.white),
                label: const Text('Pay', style: TextStyle(fontSize: 9)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kSuccess,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color, bool isWeb) {
    return Column(
      children: [
        Icon(icon, size: isWeb ? 20 : 16, color: color),
        SizedBox(height: isWeb ? 4 : 2),
        Text(
          value,
          style: TextStyle(
            fontSize: isWeb ? 12 : 11,
            fontWeight: FontWeight.w700,
            color: kText,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: isWeb ? 11 : 9,
            color: kSubText,
          ),
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
              Text(
                label,
                style: TextStyle(
                  fontSize: isWeb ? 11 : 9,
                  color: kSubText,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: isWeb ? 11 : 9,
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

  ButtonStyle _buttonStyle(Color color, bool isWeb) {
    return OutlinedButton.styleFrom(
      foregroundColor: color,
      side: BorderSide(color: color),
      padding: EdgeInsets.symmetric(vertical: isWeb ? 10 : 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isWeb ? 8 : 6)),
    );
  }

  void _showAddVendorDialog(BuildContext ctx) {
    final isWeb = ResponsiveUtils.isWeb(ctx);
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
      context: ctx,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              width: isWeb ? 500 : double.infinity,
              constraints: BoxConstraints(maxHeight: isWeb ? 700 : 600),
              padding: EdgeInsets.all(isWeb ? 24 : 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Add New Vendor',
                    style: TextStyle(
                      fontSize: isWeb ? 20 : 18,
                      fontWeight: FontWeight.w800,
                      color: kText,
                    ),
                  ),
                  SizedBox(height: isWeb ? 20 : 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            _buildTextField('Vendor Name *', (v) => name = v, isWeb: isWeb, validator: true),
                            SizedBox(height: isWeb ? 16 : 12),
                            _buildTextField('Email *', (v) => email = v, isWeb: isWeb, validator: true),
                            SizedBox(height: isWeb ? 16 : 12),
                            _buildTextField('Phone *', (v) => phone = v, isWeb: isWeb, validator: true),
                            SizedBox(height: isWeb ? 16 : 12),
                            _buildTextField('Tax ID (NTN)', (v) => taxId = v, isWeb: isWeb),
                            SizedBox(height: isWeb ? 16 : 12),
                            _buildTextField('Address', (v) => address = v, isWeb: isWeb, maxLines: 2),
                            SizedBox(height: isWeb ? 16 : 12),
                            _buildTextField('Contact Person', (v) => contactPerson = v, isWeb: isWeb),
                            SizedBox(height: isWeb ? 16 : 12),
                            _buildTextField('Contact Person Phone', (v) => contactPersonPhone = v, isWeb: isWeb),
                            SizedBox(height: isWeb ? 16 : 12),
                            DropdownButtonFormField<String>(
                              value: paymentTerms,
                              decoration: _inputDecoration('Payment Terms', isWeb),
                              style: TextStyle(fontSize: isWeb ? 13 : 12),
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
                            SizedBox(height: isWeb ? 16 : 12),
                            _buildTextField('Notes', (v) => notes = v, isWeb: isWeb, maxLines: 2),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isWeb ? 20 : 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          child: Text('Cancel', style: TextStyle(fontSize: isWeb ? 14 : 12)),
                        ),
                      ),
                      SizedBox(width: isWeb ? 16 : 12),
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
                          child: Text('Add Vendor', style: TextStyle(fontSize: isWeb ? 14 : 12)),
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

  void _editVendor(Vendor vendor, BuildContext ctx) {
    final isWeb = ResponsiveUtils.isWeb(ctx);
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
      context: ctx,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Edit Vendor', style: TextStyle(fontSize: isWeb ? 18 : 14, fontWeight: FontWeight.w800)),
            content: SizedBox(
              width: isWeb ? 400 : 280,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      _buildTextField('Vendor Name *', (v) => name = v, isWeb: isWeb, initialValue: name, validator: true),
                      SizedBox(height: isWeb ? 16 : 12),
                      _buildTextField('Email *', (v) => email = v, isWeb: isWeb, initialValue: email, validator: true),
                      SizedBox(height: isWeb ? 16 : 12),
                      _buildTextField('Phone *', (v) => phone = v, isWeb: isWeb, initialValue: phone, validator: true),
                      SizedBox(height: isWeb ? 16 : 12),
                      _buildTextField('Tax ID', (v) => taxId = v, isWeb: isWeb, initialValue: taxId),
                      SizedBox(height: isWeb ? 16 : 12),
                      _buildTextField('Address', (v) => address = v, isWeb: isWeb, initialValue: address, maxLines: 2),
                      SizedBox(height: isWeb ? 16 : 12),
                      _buildTextField('Contact Person', (v) => contactPerson = v, isWeb: isWeb, initialValue: contactPerson),
                      SizedBox(height: isWeb ? 16 : 12),
                      _buildTextField('Contact Person Phone', (v) => contactPersonPhone = v, isWeb: isWeb, initialValue: contactPersonPhone),
                      SizedBox(height: isWeb ? 16 : 12),
                      DropdownButtonFormField<String>(
                        value: paymentTerms,
                        decoration: _inputDecoration('Payment Terms', isWeb),
                        style: TextStyle(fontSize: isWeb ? 13 : 12),
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
                      SizedBox(height: isWeb ? 16 : 12),
                      Row(
                        children: [
                          Text('Active', style: TextStyle(fontSize: isWeb ? 13 : 12)),
                          const Spacer(),
                          Switch(
                            value: isActive,
                            onChanged: (value) => setState(() => isActive = value),
                            activeColor: kSuccess,
                          ),
                        ],
                      ),
                      SizedBox(height: isWeb ? 16 : 12),
                      _buildTextField('Notes', (v) => notes = v, isWeb: isWeb, initialValue: notes, maxLines: 2),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text('Cancel', style: TextStyle(fontSize: isWeb ? 14 : 12)),
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
                child: Text('Update Vendor', style: TextStyle(fontSize: isWeb ? 14 : 12)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showVendorDetails(Vendor vendor, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    if (isWeb) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            child: _buildVendorDetailsContent(vendor, ctx),
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
          constraints: BoxConstraints(maxHeight: 85.h),
          child: _buildVendorDetailsContent(vendor, ctx),
        ),
      );
    }
  }

  Widget _buildVendorDetailsContent(Vendor vendor, BuildContext ctx) {
    final isWeb = ResponsiveUtils.isWeb(ctx);
    
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
                color: vendor.isActive 
                    ? kSuccess.withOpacity(0.1) 
                    : kSubText.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isWeb ? 14 : 10),
              ),
              child: Center(
                child: Text(
                  vendor.name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: isWeb ? 24 : 18,
                    fontWeight: FontWeight.w800,
                    color: vendor.isActive ? kSuccess : kSubText,
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
                    vendor.name,
                    style: TextStyle(
                      fontSize: isWeb ? 18 : 16,
                      fontWeight: FontWeight.w800,
                      color: kText,
                    ),
                  ),
                  Text(
                    vendor.email,
                    style: TextStyle(
                      fontSize: isWeb ? 13 : 12,
                      color: kSubText,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: isWeb ? 12 : 10, vertical: isWeb ? 6 : 4),
              decoration: BoxDecoration(
                color: vendor.isActive 
                    ? kSuccess.withOpacity(0.1) 
                    : kDanger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isWeb ? 8 : 6),
              ),
              child: Text(
                vendor.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  fontSize: isWeb ? 13 : 12,
                  color: vendor.isActive ? kSuccess : kDanger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: isWeb ? 20 : 16),
        Container(
          padding: EdgeInsets.all(isWeb ? 16 : 12),
          decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(isWeb ? 12 : 10)),
          child: Column(
            children: [
              _buildDetailRow('Phone', vendor.phone, isWeb),
              _buildDetailRow('Tax ID', vendor.taxId.isNotEmpty ? vendor.taxId : 'N/A', isWeb),
              _buildDetailRow('Address', vendor.address.isNotEmpty ? vendor.address : 'N/A', isWeb),
              _buildDetailRow('Contact Person', vendor.contactPerson.isNotEmpty ? vendor.contactPerson : 'N/A', isWeb),
              _buildDetailRow('Contact Phone', vendor.contactPersonPhone.isNotEmpty ? vendor.contactPersonPhone : 'N/A', isWeb),
              _buildDetailRow('Payment Terms', vendor.paymentTerms, isWeb),
              _buildDetailRow('Total Purchases', _formatAmount(vendor.totalPurchases), isWeb),
              _buildDetailRow('Total Paid', _formatAmount(vendor.totalPaid), isWeb),
              _buildDetailRow('Outstanding Balance', _formatAmount(vendor.outstandingBalance), isWeb),
              if (vendor.lastPurchaseDate != null)
                _buildDetailRow(
                  'Last Purchase',
                  DateFormat('dd MMM yyyy').format(vendor.lastPurchaseDate!),
                  isWeb,
                ),
              if (vendor.notes.isNotEmpty)
                _buildDetailRow('Notes', vendor.notes, isWeb),
            ],
          ),
        ),
        SizedBox(height: isWeb ? 20 : 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _editVendor(vendor, ctx);
                },
                icon: Icon(Icons.edit, size: isWeb ? 20 : 16),
                label: Text('Edit', style: TextStyle(fontSize: isWeb ? 14 : 12)),
                style: _buttonStyle(kPrimary, isWeb),
              ),
            ),
            SizedBox(width: isWeb ? 12 : 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _viewBills(vendor, ctx);
                },
                icon: Icon(Icons.receipt, size: isWeb ? 20 : 16),
                label: Text('View Bills', style: TextStyle(fontSize: isWeb ? 14 : 12)),
                style: _buttonStyle(kPrimary, isWeb),
              ),
            ),
            SizedBox(width: isWeb ? 12 : 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _recordPayment(vendor, ctx);
                },
                icon: Icon(Icons.payment, size: isWeb ? 20 : 16),
                label: Text('Pay Now', style: TextStyle(fontSize: isWeb ? 14 : 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kSuccess,
                  padding: EdgeInsets.symmetric(vertical: isWeb ? 12 : 10),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isWeb ? 120 : 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: isWeb ? 13 : 11,
                color: kSubText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isWeb ? 13 : 12,
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
    bool isWeb = false,
    String? initialValue,
    bool validator = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: _inputDecoration(label, isWeb),
      maxLines: maxLines,
      style: TextStyle(fontSize: isWeb ? 13 : 12),
      onChanged: onChanged,
      validator: validator ? (v) => v == null || v.isEmpty ? '$label required' : null : null,
    );
  }

  InputDecoration _inputDecoration(String label, bool isWeb, {String? prefix}) {
    return InputDecoration(
      labelText: label,
      prefixText: prefix,
      labelStyle: TextStyle(fontSize: isWeb ? 12 : 11),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(isWeb ? 10 : 8)),
      contentPadding: EdgeInsets.symmetric(horizontal: isWeb ? 16 : 12, vertical: isWeb ? 12 : 10),
    );
  }

  void _viewBills(Vendor vendor, BuildContext context) {
    Get.to(() => BillsScreen(vendorId: vendor.id));
  }

  void _recordPayment(Vendor vendor, BuildContext context) {
    Get.to(() => BillsScreen(vendorId: vendor.id));
  }

  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '₨ ${formatter.format(amount)}';
  }
}