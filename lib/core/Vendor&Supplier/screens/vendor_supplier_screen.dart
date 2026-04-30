import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/Utils/responsive_utils.dart';
import 'package:LedgerPro_app/core/Bills/Screen/bill_Screen.dart';
import 'package:LedgerPro_app/core/Vendor&Supplier/Controller/vendor_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class VendorsScreen extends StatefulWidget {
  const VendorsScreen({super.key});

  @override
  State<VendorsScreen> createState() => _VendorsScreenState();
}

class _VendorsScreenState extends State<VendorsScreen> {
  final VendorsController controller = Get.put(VendorsController());
  final TextEditingController _searchController = TextEditingController();

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
    // ✅ Scaffold for Material context
    return Scaffold(
      backgroundColor: kBg,
      body: Obx(() {
        if (controller.isLoading.value) {
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

  // ==================== HEADER ====================
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
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _headerIconBtn(
            icon: Icons.download_outlined,
            size: isWeb ? 22 : 20,
            onTap: () => controller.exportVendors(),
          ),
          if (!isMobile) const SizedBox(width: 8),
          if (!isMobile)
            _headerIconBtn(
              icon: Icons.add,
              size: isWeb ? 22 : 20,
              onTap: () => _showAddVendorDialog(context),
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
  Widget _buildSummaryCards(BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Obx(() {
      final int totalVendors = controller.vendors.length;
      final int activeVendors = controller.vendors.where((v) => v.isActive).length;
      final double totalOutstanding = controller.vendors.fold(0.0, (sum, v) => sum + v.outstandingBalance);
      final double totalPurchases = controller.vendors.fold(0.0, (sum, v) => sum + v.totalPurchases);

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
  Widget _buildFilterBar(BuildContext context) {
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
            SizedBox(
              width: isWeb ? 150 : 120,
              height: isWeb ? 45 : 40,
              child: Container(
                decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(isWeb ? 12 : 10), border: Border.all(color: kBorder)),
                child: DropdownButtonHideUnderline(
                  child: Obx(() => DropdownButton<String>(
                    value: controller.selectedFilter.value,
                    icon: Icon(Icons.arrow_drop_down, size: isWeb ? 24 : 20),
                    padding: EdgeInsets.symmetric(horizontal: isWeb ? 12 : 8),
                    isExpanded: true,
                    style: TextStyle(fontSize: isWeb ? 13 : 12, color: kText),
                    items: _filterOptions.map((filter) {
                      return DropdownMenuItem(value: filter, child: Text(filter, overflow: TextOverflow.ellipsis));
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
      ),
    );
  }

  // ==================== VENDORS LIST ====================
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
                Text('No vendors found', style: TextStyle(fontSize: isWeb ? 18 : 16, color: kSubText)),
                SizedBox(height: isWeb ? 20 : 16),
                ElevatedButton(
                  onPressed: () => _showAddVendorDialog(context),
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                  child: Text('Add Vendor', style: TextStyle(fontSize: isWeb ? 14 : 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        );
      }

      if (isWeb) {
        return _buildWebVendorsTable(vendors, context);
      } else {
        return _buildMobileVendorsList(vendors, context);
      }
    });
  }

  // ==================== WEB TABLE ====================
  Widget _buildWebVendorsTable(List<Vendor> vendors, BuildContext context) {
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
                      Container(width: 200, child: const Text('Vendor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 180, child: const Text('Contact', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 150, child: const Text('Phone', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 200, child: const Text('Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 100, child: const Text('Actions', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    ],
                  ),
                ),
                ...vendors.asMap().entries.map((entry) {
                  final index = entry.key;
                  final vendor = entry.value;
                  final isEven = index.isEven;
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: isEven ? Colors.transparent : kPrimary.withOpacity(0.01),
                      border: Border(top: BorderSide(color: kBorder.withOpacity(0.5))),
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 60,
                          height: 44,
                          decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: Center(child: Text(vendor.name[0].toUpperCase(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kPrimary))),
                        ),
                        // Vendor Name
                        Container(
                          width: 200,
                          child: Text(vendor.name, style:  TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kText), overflow: TextOverflow.ellipsis),
                        ),
                        // Contact Person
                        Container(
                          width: 180,
                          child: Text(vendor.contactPerson.isEmpty ? '-' : vendor.contactPerson, style:  TextStyle(fontSize: 13, color: kText), overflow: TextOverflow.ellipsis),
                        ),
                        // Phone
                        Container(
                          width: 150,
                          child: Text(vendor.phone.isEmpty ? '-' : vendor.phone, style:  TextStyle(fontSize: 13, color: kText), overflow: TextOverflow.ellipsis),
                        ),
                        // Email
                        Container(
                          width: 200,
                          child: Text(vendor.email.isEmpty ? '-' : vendor.email, style:  TextStyle(fontSize: 13, color: kText), overflow: TextOverflow.ellipsis),
                        ),
                        // Actions
                        Container(
                          width: 100,
                          child: IconButton(
                            onPressed: () => _showVendorDetails(vendor, context),
                            icon: const Icon(Icons.remove_red_eye, size: 18),
                            padding: EdgeInsets.zero,
                            color: kPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== MOBILE LIST ====================
  Widget _buildMobileVendorsList(List<Vendor> vendors, BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text('Vendors', style:  TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kText)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text('${vendors.length} vendors', style: const TextStyle(fontSize: 11, color: kPrimary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: vendors.length,
          itemBuilder: (context, index) {
            final vendor = vendors[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildMobileVendorCard(vendor, context),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMobileVendorCard(Vendor vendor, BuildContext context) {
    return Card(
      color: kCardBg,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showVendorDetails(vendor, context),
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
                      color: vendor.isActive ? kSuccess.withOpacity(0.1) : kSubText.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(child: Text(vendor.name[0].toUpperCase(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: vendor.isActive ? kSuccess : kSubText))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(vendor.name, style:  TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: kText), overflow: TextOverflow.ellipsis)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: vendor.isActive ? kSuccess.withOpacity(0.1) : kDanger.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                              child: Text(vendor.isActive ? 'Active' : 'Inactive', style: TextStyle(fontSize: 9, color: vendor.isActive ? kSuccess : kDanger, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(vendor.email, style:  TextStyle(fontSize: 10, color: kSubText), overflow: TextOverflow.ellipsis),
                        Text(vendor.phone, style:  TextStyle(fontSize: 10, color: kSubText)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildStatItem('Purchases', _formatAmount(vendor.totalPurchases), Icons.shopping_cart, kPrimary, false)),
                  Expanded(child: _buildStatItem('Paid', _formatAmount(vendor.totalPaid), Icons.check_circle, kSuccess, false)),
                  Expanded(child: _buildStatItem('Outstanding', _formatAmount(vendor.outstandingBalance), Icons.payment, vendor.outstandingBalance > 0 ? kDanger : kSuccess, false)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _editVendor(vendor, context),
                      icon: const Icon(Icons.edit, size: 14),
                      label: const Text('Edit', style: TextStyle(fontSize: 10)),
                      style: _buttonStyle(kPrimary, false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _viewBills(vendor, context),
                      icon: const Icon(Icons.receipt, size: 14),
                      label: const Text('Bills', style: TextStyle(fontSize: 10)),
                      style: _buttonStyle(kPrimary, false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _recordPayment(vendor, context),
                      icon: const Icon(Icons.payment, size: 14, color: Colors.white),
                      label: const Text('Pay', style: TextStyle(fontSize: 10)),
                      style: ElevatedButton.styleFrom(backgroundColor: kSuccess, padding: const EdgeInsets.symmetric(vertical: 8)),
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

  Widget _buildStatItem(String label, String value, IconData icon, Color color, bool isWeb) {
    return Column(
      children: [
        Icon(icon, size: isWeb ? 20 : 16, color: color),
        SizedBox(height: isWeb ? 4 : 2),
        Text(value, style: TextStyle(fontSize: isWeb ? 12 : 11, fontWeight: FontWeight.w700, color: kText), overflow: TextOverflow.ellipsis),
        Text(label, style: TextStyle(fontSize: isWeb ? 11 : 9, color: kSubText)),
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

  // ==================== DIALOGS ====================
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
              width: isWeb ? 500 : MediaQuery.of(context).size.width * 0.9,
              constraints: BoxConstraints(maxHeight: isWeb ? 700 : 600),
              padding: EdgeInsets.all(isWeb ? 24 : 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Add New Vendor', style: TextStyle(fontSize: isWeb ? 20 : 18, fontWeight: FontWeight.w800, color: kText)),
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
                      Expanded(child: OutlinedButton(onPressed: () => Get.back(), child: Text('Cancel', style: TextStyle(fontSize: isWeb ? 14 : 12)))),
                      SizedBox(width: isWeb ? 16 : 12),
                      Expanded(child: ElevatedButton(
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
                      )),
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
                          Switch(value: isActive, onChanged: (value) => setState(() => isActive = value), activeColor: kSuccess),
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
              TextButton(onPressed: () => Get.back(), child: Text('Cancel', style: TextStyle(fontSize: isWeb ? 14 : 12))),
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
                    decoration: BoxDecoration(color: vendor.isActive ? kSuccess.withOpacity(0.1) : kSubText.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                    child: Center(child: Text(vendor.name[0].toUpperCase(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: vendor.isActive ? kSuccess : kSubText))),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(vendor.name, style:  TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kText)),
                      Text(vendor.email, style:  TextStyle(fontSize: 13, color: kSubText)),
                    ]),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: vendor.isActive ? kSuccess.withOpacity(0.1) : kDanger.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(vendor.isActive ? 'Active' : 'Inactive', style: TextStyle(fontSize: 13, color: vendor.isActive ? kSuccess : kDanger, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    _buildDetailRow('Phone', vendor.phone.isEmpty ? 'N/A' : vendor.phone, isWeb),
                    _buildDetailRow('Tax ID', vendor.taxId.isEmpty ? 'N/A' : vendor.taxId, isWeb),
                    _buildDetailRow('Address', vendor.address.isEmpty ? 'N/A' : vendor.address, isWeb),
                    _buildDetailRow('Contact Person', vendor.contactPerson.isEmpty ? 'N/A' : vendor.contactPerson, isWeb),
                    _buildDetailRow('Contact Phone', vendor.contactPersonPhone.isEmpty ? 'N/A' : vendor.contactPersonPhone, isWeb),
                    _buildDetailRow('Payment Terms', vendor.paymentTerms, isWeb),
                    _buildDetailRow('Total Purchases', _formatAmount(vendor.totalPurchases), isWeb),
                    _buildDetailRow('Total Paid', _formatAmount(vendor.totalPaid), isWeb),
                    _buildDetailRow('Outstanding Balance', _formatAmount(vendor.outstandingBalance), isWeb),
                    if (vendor.lastPurchaseDate != null)
                      _buildDetailRow('Last Purchase', DateFormat('dd MMM yyyy').format(vendor.lastPurchaseDate!), isWeb),
                    if (vendor.notes.isNotEmpty) _buildDetailRow('Notes', vendor.notes, isWeb),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () { Navigator.pop(ctx); _editVendor(vendor, ctx); },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit', style: TextStyle(fontSize: 12)),
                      style: _buttonStyle(kPrimary, isWeb),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () { Navigator.pop(ctx); _viewBills(vendor, ctx); },
                      icon: const Icon(Icons.receipt, size: 18),
                      label: const Text('View Bills', style: TextStyle(fontSize: 12)),
                      style: _buttonStyle(kPrimary, isWeb),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () { Navigator.pop(ctx); _recordPayment(vendor, ctx); },
                      icon: const Icon(Icons.payment, size: 18),
                      label: const Text('Pay Now', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(backgroundColor: kSuccess),
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

  // ==================== HELPER METHODS ====================
  TextFormField _buildTextField(String label, Function(String) onChanged, {bool isWeb = false, String? initialValue, bool validator = false, int maxLines = 1}) {
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

  void _viewBills(Vendor vendor, BuildContext context) {
    Get.to(() => BillsScreen(vendorId: vendor.id));
  }

  void _recordPayment(Vendor vendor, BuildContext context) {
    Get.to(() => BillsScreen(vendorId: vendor.id));
  }

  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '\$ ${formatter.format(amount)}';
  }
}