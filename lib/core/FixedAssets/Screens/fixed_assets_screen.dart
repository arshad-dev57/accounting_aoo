import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/Utils/responsive_utils.dart';
import 'package:LedgerPro_app/core/FixedAssets/controllers/fixed_asset_controller.dart';
import 'package:LedgerPro_app/core/FixedAssets/models/fixed_asset_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class FixedAssetsScreen extends StatelessWidget {
  const FixedAssetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FixedAssetController());

    // ✅ Scaffold for Material context
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
                Text('Loading fixed assets...', style: TextStyle(fontSize: ResponsiveUtils.isWeb(context) ? 14 : 12, color: kSubText)),
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
              _buildAssetsList(controller, context),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader(FixedAssetController controller, BuildContext context) {
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
                  'Fixed Assets',
                  style: TextStyle(
                    fontSize: isWeb ? 20 : 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage company assets and depreciation',
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
            onTap: () => controller.runMonthlyDepreciation(),
          ),
          if (!isMobile) const SizedBox(width: 8),
          _headerIconBtn(
            icon: Icons.download_outlined,
            size: isWeb ? 22 : 20,
            onTap: () => controller.exportAssets(),
          ),
          if (!isMobile) const SizedBox(width: 8),
          if (!isMobile)
            _headerIconBtn(
              icon: Icons.add,
              size: isWeb ? 22 : 20,
              onTap: () => controller.showAddAssetDialog(),
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
  Widget _buildSummaryCards(FixedAssetController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Obx(() => Container(
      padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 16 : 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildSummaryCard('Total Assets', controller.totalAssets.value.toString(), kPrimary, Icons.inventory, context, width: isWeb ? 200 : 160, isNumber: true),
            SizedBox(width: isWeb ? 16 : 12),
            _buildSummaryCard('Total Cost', controller.formatAmount(controller.totalCost.value), kPrimary, Icons.attach_money, context, width: isWeb ? 220 : 170),
            SizedBox(width: isWeb ? 16 : 12),
            _buildSummaryCard('Accumulated Depreciation', controller.formatAmount(controller.totalDepreciation.value), kWarning, Icons.trending_down, context, width: isWeb ? 250 : 200),
            SizedBox(width: isWeb ? 16 : 12),
            _buildSummaryCard('Net Book Value', controller.formatAmount(controller.totalNetBookValue.value), kSuccess, Icons.account_balance, context, width: isWeb ? 220 : 170),
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
  Widget _buildFilterBar(FixedAssetController controller, BuildContext context) {
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
                    hintText: isWeb ? 'Search by name, asset code, category...' : 'Search...',
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

  // ==================== ASSETS LIST ====================
  Widget _buildAssetsList(FixedAssetController controller, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    if (controller.assets.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(isWeb ? 40 : 20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_outlined, size: isWeb ? 80 : 64, color: kSubText.withOpacity(0.5)),
              SizedBox(height: isWeb ? 20 : 16),
              Text('No assets found', style: TextStyle(fontSize: isWeb ? 18 : 16, color: kSubText, fontWeight: FontWeight.w500)),
              SizedBox(height: isWeb ? 20 : 16),
              ElevatedButton(
                onPressed: () => controller.showAddAssetDialog(),
                style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                child: Text('Add Asset', style: TextStyle(fontSize: isWeb ? 14 : 12, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (isWeb) {
      return _buildWebAssetsTable(controller, context);
    } else {
      return _buildMobileAssetsList(controller, context);
    }
  }

  // ==================== WEB TABLE ====================
  Widget _buildWebAssetsTable(FixedAssetController controller, BuildContext context) {
    final assets = controller.assets;
    
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
                      Container(width: 120, child: const Text('Asset Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 200, child: const Text('Asset Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 120, child: const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 120, child: const Text('Purchase Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 150, child: const Text('Purchase Cost', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 150, child: const Text('Acc. Depreciation', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 150, child: const Text('Net Book Value', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 120, child: const Text('Status', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(width: 80, child: const Text('Actions', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    ],
                  ),
                ),
                ...assets.asMap().entries.map((entry) {
                  final index = entry.key;
                  final asset = entry.value;
                  final isEven = index.isEven;
                  final statusColor = asset.status == 'Active' ? kSuccess : asset.status == 'Fully Depreciated' ? kWarning : kDanger;
                  
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
                            color: controller.getAssetCategoryColor(asset.category).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(controller.getAssetIcon(asset.category), size: 22, color: controller.getAssetCategoryColor(asset.category)),
                        ),
                        // Asset Code
                        Container(
                          width: 120,
                          child: Text(asset.assetCode, style:  TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kText)),
                        ),
                        // Asset Name
                        Container(
                          width: 200,
                          child: Text(asset.name, style:  TextStyle(fontSize: 13, color: kText), overflow: TextOverflow.ellipsis),
                        ),
                        // Category
                        Container(
                          width: 120,
                          child: Text(asset.category, style:  TextStyle(fontSize: 13, color: kText), overflow: TextOverflow.ellipsis),
                        ),
                        // Purchase Date
                        Container(
                          width: 120,
                          child: Text(DateFormat('dd MMM yyyy').format(asset.purchaseDate), style:  TextStyle(fontSize: 13, color: kSubText)),
                        ),
                        // Purchase Cost
                        Container(
                          width: 150,
                          child: Text(controller.formatAmount(asset.purchaseCost), textAlign: TextAlign.right, style:  TextStyle(fontSize: 13, color: kText)),
                        ),
                        // Accumulated Depreciation
                        Container(
                          width: 150,
                          child: Text(controller.formatAmount(asset.accumulatedDepreciation), textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, color: kWarning)),
                        ),
                        // Net Book Value
                        Container(
                          width: 150,
                          child: Text(controller.formatAmount(asset.netBookValue), textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kSuccess)),
                        ),
                        // Status
                        Container(
                          width: 120,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                              child: Text(asset.status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
                            ),
                          ),
                        ),
                        // Actions
                        Container(
                          width: 80,
                          child: IconButton(
                            onPressed: () => controller.showAssetDetails(asset),
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
                _buildTableFooter(controller, assets),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableFooter(FixedAssetController controller, List<FixedAsset> assets) {
    final totalCost = assets.fold(0.0, (sum, a) => sum + a.purchaseCost);
    final totalDepreciation = assets.fold(0.0, (sum, a) => sum + a.accumulatedDepreciation);
    final totalNBV = assets.fold(0.0, (sum, a) => sum + a.netBookValue);
    
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
          Container(width: 200, child: const SizedBox()),
          Container(width: 120, child: const SizedBox()),
          Container(width: 120, child: const SizedBox()),
          Container(width: 150, child: Text(controller.formatAmount(totalCost), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold))),
          Container(width: 150, child: Text(controller.formatAmount(totalDepreciation), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, color: kWarning))),
          Container(width: 150, child: Text(controller.formatAmount(totalNBV), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, color: kSuccess))),
          Container(width: 120, child: const SizedBox()),
          Container(width: 80, child: const SizedBox()),
        ],
      ),
    );
  }

  // ==================== MOBILE LIST ====================
  Widget _buildMobileAssetsList(FixedAssetController controller, BuildContext context) {
    final assets = controller.assets;
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text('Fixed Assets', style:  TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kText)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text('${assets.length} assets', style: const TextStyle(fontSize: 11, color: kPrimary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: assets.length,
          itemBuilder: (context, index) {
            final asset = assets[index];
            final statusColor = asset.status == 'Active' ? kSuccess : asset.status == 'Fully Depreciated' ? kWarning : kDanger;
            final depreciationPercent = (asset.accumulatedDepreciation / asset.purchaseCost) * 100;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildMobileAssetCard(controller, asset, statusColor, depreciationPercent, context),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMobileAssetCard(FixedAssetController controller, FixedAsset asset, Color statusColor, double depreciationPercent, BuildContext context) {
    return Card(
      color: kCardBg,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => controller.showAssetDetails(asset),
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
                      color: controller.getAssetCategoryColor(asset.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(controller.getAssetIcon(asset.category), size: 20, color: controller.getAssetCategoryColor(asset.category)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(asset.name, style:  TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: kText), overflow: TextOverflow.ellipsis)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                              child: Text(asset.status, style: TextStyle(fontSize: 9, color: statusColor, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text('${asset.assetCode} • ${asset.category}', style:  TextStyle(fontSize: 10, color: kSubText), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                       Text('NBV', style: TextStyle(fontSize: 9, color: kSubText)),
                      const SizedBox(height: 2),
                      Text(controller.formatAmount(asset.netBookValue), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: kSuccess)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildInfoItem('Purchase', DateFormat('dd MMM yyyy').format(asset.purchaseDate), Icons.calendar_today, false)),
                  Expanded(child: _buildInfoItem('Cost', controller.formatAmount(asset.purchaseCost), Icons.attach_money, false)),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 4,
                width: double.infinity,
                decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(2)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: depreciationPercent / 100,
                    backgroundColor: kBg,
                    valueColor: AlwaysStoppedAnimation<Color>(depreciationPercent > 90 ? kDanger : depreciationPercent > 70 ? kWarning : kSuccess),
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (asset.status == 'Active')
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => controller.depreciateAsset(asset),
                        icon: const Icon(Icons.calculate, size: 14),
                        label: const Text('Depr', style: TextStyle(fontSize: 10)),
                        style: _buttonStyle(kPrimary, false),
                      ),
                    ),
                  if (asset.status == 'Active') const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.showEditAssetDialog(asset),
                      icon: const Icon(Icons.edit, size: 14),
                      label: const Text('Edit', style: TextStyle(fontSize: 10)),
                      style: _buttonStyle(kPrimary, false),
                    ),
                  ),
                  if (asset.status != 'Disposed') const SizedBox(width: 8),
                  if (asset.status != 'Disposed')
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => controller.showDisposeAssetDialog(asset),
                        icon: const Icon(Icons.delete_outline, size: 14, color: Colors.white),
                        label: const Text('Dispose', style: TextStyle(fontSize: 10)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kDanger,
                          padding: const EdgeInsets.symmetric(vertical: 8),
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