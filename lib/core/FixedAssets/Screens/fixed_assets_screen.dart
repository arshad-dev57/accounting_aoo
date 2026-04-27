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

    return Container(
      color: kBg,
      child: Obx(() {
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
        
        // Single ScrollView that scrolls everything together
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

  // Custom Header without AppBar
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
                ),
              ],
            ),
          ),
          // Calculate Depreciation Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.calculate_outlined, color: Colors.white, size: isWeb ? 22 : 20),
              onPressed: () => controller.runMonthlyDepreciation(),
            ),
          ),
          if (!isMobile) const SizedBox(width: 8),
          // Export Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.download_outlined, color: Colors.white, size: isWeb ? 22 : 20),
              onPressed: () => controller.exportAssets(),
            ),
          ),
          if (!isMobile) const SizedBox(width: 8),
          // Print Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.print_outlined, color: Colors.white, size: isWeb ? 22 : 20),
              onPressed: () => controller.printAssets(),
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
                onPressed: () => controller.showAddAssetDialog(),
              ),
            ),
        ],
      ),
    );
  }

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
              Expanded(child: Text(title, style: TextStyle(fontSize: isWeb ? 12 : 11, color: kSubText, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ),
          SizedBox(height: isWeb ? 8 : 6),
          Text(isNumber ? amount : amount, style: TextStyle(fontSize: isWeb ? 18 : 14, fontWeight: FontWeight.w800, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildFilterBar(FixedAssetController controller, BuildContext context) {
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
          Expanded(
            flex: isWeb ? 2 : 1,
            child: Container(
              height: isWeb ? 45 : 40,
              decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(isWeb ? 12 : 10), border: Border.all(color: kBorder)),
              child: Obx(() => DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.selectedFilter.value,
                  icon: Icon(Icons.arrow_drop_down, size: isWeb ? 24 : 20, color: kText),
                  padding: EdgeInsets.symmetric(horizontal: isWeb ? 16 : 12),
                  isExpanded: true,
                  style: TextStyle(fontSize: isWeb ? 13 : 12, color: kText),
                  dropdownColor: kCardBg,
                  items: controller.filterOptions.map((filter) {
                    return DropdownMenuItem(value: filter, child: Text(filter, style: TextStyle(color: kText, fontSize: isWeb ? 13 : 12)));
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
    );
  }

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
                style: ElevatedButton.styleFrom(backgroundColor: kPrimary, padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 12 : 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isWeb ? 12 : 10))),
                child: Text('Add Asset', style: TextStyle(fontSize: isWeb ? 14 : 12, fontWeight: FontWeight.w600, color: Colors.white)),
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
            'Fixed Assets',
            style: TextStyle(
              fontSize: isWeb ? 18 : 16,
              fontWeight: FontWeight.w700,
              color: kText,
            ),
          ),
        ),
        ...controller.assets.map((asset) => Padding(
          padding: EdgeInsets.symmetric(horizontal: isWeb ? 20 : 12, vertical: isWeb ? 8 : 6),
          child: _buildAssetCard(controller, asset, context),
        )).toList(),
      ],
    );
  }

  Widget _buildAssetCard(FixedAssetController controller, FixedAsset asset, BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final isMobile = ResponsiveUtils.isMobile(context);
    
    Color statusColor = asset.status == 'Active' ? kSuccess : asset.status == 'Fully Depreciated' ? kWarning : kDanger;
    double depreciationPercent = (asset.accumulatedDepreciation / asset.purchaseCost) * 100;
    
    return Container(
      margin: EdgeInsets.only(bottom: isWeb ? 12 : 8),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.showAssetDetails(asset),
          borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
          child: Padding(
            padding: EdgeInsets.all(isWeb ? 16 : 12),
            child: isMobile
                ? _buildMobileAssetCard(controller, asset, statusColor, depreciationPercent, context)
                : _buildDesktopAssetCard(controller, asset, statusColor, depreciationPercent, context),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopAssetCard(FixedAssetController controller, FixedAsset asset, Color statusColor, double depreciationPercent, BuildContext context) {
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
                color: controller.getAssetCategoryColor(asset.category).withOpacity(0.1),
                borderRadius: BorderRadius.circular(isWeb ? 12 : 10),
              ),
              child: Icon(controller.getAssetIcon(asset.category), size: isWeb ? 24 : 20, color: controller.getAssetCategoryColor(asset.category)),
            ),
            SizedBox(width: isWeb ? 16 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(asset.name, style: TextStyle(fontSize: isWeb ? 15 : 13, fontWeight: FontWeight.w800, color: kText), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: isWeb ? 8 : 6, vertical: isWeb ? 4 : 2),
                        decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(isWeb ? 6 : 4)),
                        child: Text(asset.status, style: TextStyle(fontSize: isWeb ? 11 : 10, color: statusColor, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  SizedBox(height: isWeb ? 4 : 2),
                  Text('${asset.assetCode} • ${asset.category}', style: TextStyle(fontSize: isWeb ? 12 : 11, color: kSubText)),
                  SizedBox(height: isWeb ? 4 : 2),
                  Text('Location: ${asset.location}', style: TextStyle(fontSize: isWeb ? 12 : 11, color: kSubText)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Net Book Value', style: TextStyle(fontSize: isWeb ? 11 : 10, color: kSubText, fontWeight: FontWeight.w500)),
                SizedBox(height: isWeb ? 4 : 2),
                Text(controller.formatAmount(asset.netBookValue), style: TextStyle(fontSize: isWeb ? 16 : 14, fontWeight: FontWeight.w800, color: kSuccess)),
              ],
            ),
          ],
        ),
        SizedBox(height: isWeb ? 16 : 12),
        Container(
          padding: EdgeInsets.symmetric(vertical: isWeb ? 10 : 8),
          child: Row(
            children: [
              Expanded(child: _buildInfoItem('Purchase Date', DateFormat('dd MMM yyyy').format(asset.purchaseDate), Icons.calendar_today, isWeb)),
              Container(width: 1, height: isWeb ? 32 : 24, color: kBorder),
              Expanded(child: _buildInfoItem('Purchase Cost', controller.formatAmount(asset.purchaseCost), Icons.attach_money, isWeb)),
              Container(width: 1, height: isWeb ? 32 : 24, color: kBorder),
              Expanded(child: _buildInfoItem('Useful Life', '${asset.usefulLife} years', Icons.timeline, isWeb)),
            ],
          ),
        ),
        SizedBox(height: isWeb ? 8 : 6),
        Container(
          padding: EdgeInsets.symmetric(vertical: isWeb ? 10 : 8),
          child: Row(
            children: [
              Expanded(child: _buildInfoItem('Accumulated Depreciation', controller.formatAmount(asset.accumulatedDepreciation), Icons.trending_down, isWeb)),
              Container(width: 1, height: isWeb ? 32 : 24, color: kBorder),
              Expanded(child: _buildInfoItem('Depreciation %', '${depreciationPercent.toStringAsFixed(1)}%', Icons.percent, isWeb)),
              Container(width: 1, height: isWeb ? 32 : 24, color: kBorder),
              Expanded(child: _buildInfoItem('Last Depreciation', asset.lastDepreciationDate != null ? DateFormat('dd MMM yyyy').format(asset.lastDepreciationDate!) : 'N/A', Icons.update, isWeb)),
            ],
          ),
        ),
        SizedBox(height: isWeb ? 12 : 8),
        Container(
          height: isWeb ? 6 : 4,
          width: double.infinity,
          decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(isWeb ? 4 : 2)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isWeb ? 4 : 2),
            child: LinearProgressIndicator(
              value: depreciationPercent / 100,
              backgroundColor: kBg,
              valueColor: AlwaysStoppedAnimation<Color>(depreciationPercent > 90 ? kDanger : depreciationPercent > 70 ? kWarning : kSuccess),
              minHeight: isWeb ? 6 : 4,
            ),
          ),
        ),
        SizedBox(height: isWeb ? 4 : 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0%', style: TextStyle(fontSize: isWeb ? 8 : 7, color: kSubText)),
            Text('Depreciation Progress', style: TextStyle(fontSize: isWeb ? 9 : 8, color: kSubText)),
            Text('100%', style: TextStyle(fontSize: isWeb ? 8 : 7, color: kSubText)),
          ],
        ),
        SizedBox(height: isWeb ? 16 : 12),
        Row(
          children: [
            if (asset.status == 'Active')
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.depreciateAsset(asset),
                  icon: Icon(Icons.calculate, size: isWeb ? 18 : 14, color: kPrimary),
                  label: Text('Depreciate', style: TextStyle(fontSize: isWeb ? 12 : 10, color: kPrimary)),
                  style: _buttonStyle(kPrimary, isWeb),
                ),
              ),
            if (asset.status == 'Active') SizedBox(width: isWeb ? 12 : 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => controller.showEditAssetDialog(asset),
                icon: Icon(Icons.edit, size: isWeb ? 18 : 14, color: kPrimary),
                label: Text('Edit', style: TextStyle(fontSize: isWeb ? 12 : 10, color: kPrimary)),
                style: _buttonStyle(kPrimary, isWeb),
              ),
            ),
            if (asset.status != 'Disposed') SizedBox(width: isWeb ? 12 : 8),
            if (asset.status != 'Disposed')
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => controller.showDisposeAssetDialog(asset),
                  icon: Icon(Icons.delete_outline, size: isWeb ? 18 : 14, color: Colors.white),
                  label: Text('Dispose', style: TextStyle(fontSize: isWeb ? 12 : 10, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kDanger,
                    padding: EdgeInsets.symmetric(vertical: isWeb ? 10 : 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isWeb ? 8 : 6)),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileAssetCard(FixedAssetController controller, FixedAsset asset, Color statusColor, double depreciationPercent, BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      Expanded(
                        child: Text(asset.name, style:  TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: kText), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text(asset.status, style: TextStyle(fontSize: 9, color: statusColor, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('${asset.assetCode} • ${asset.category}', style:  TextStyle(fontSize: 10, color: kSubText)),
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
        const SizedBox(height: 8),
        Row(
          children: [
            if (asset.status == 'Active')
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.depreciateAsset(asset),
                  icon: Icon(Icons.calculate, size: 14, color: kPrimary),
                  label: const Text('Depr', style: TextStyle(fontSize: 9, color: kPrimary)),
                  style: _buttonStyle(kPrimary, false),
                ),
              ),
            if (asset.status == 'Active') const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => controller.showEditAssetDialog(asset),
                icon: Icon(Icons.edit, size: 14, color: kPrimary),
                label: const Text('Edit', style: TextStyle(fontSize: 9, color: kPrimary)),
                style: _buttonStyle(kPrimary, false),
              ),
            ),
            if (asset.status != 'Disposed') const SizedBox(width: 8),
            if (asset.status != 'Disposed')
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => controller.showDisposeAssetDialog(asset),
                  icon: Icon(Icons.delete_outline, size: 14, color: Colors.white),
                  label: const Text('Dispose', style: TextStyle(fontSize: 9, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kDanger,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ),
          ],
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
              Text(label, style: TextStyle(fontSize: isWeb ? 11 : 8, color: kSubText)),
              Text(value, style: TextStyle(fontSize: isWeb ? 11 : 9, fontWeight: FontWeight.w600, color: kText), maxLines: 1, overflow: TextOverflow.ellipsis),
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
}