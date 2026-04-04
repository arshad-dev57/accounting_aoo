import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/core/FixedAssets/controllers/fixed_asset_controller.dart';
import 'package:LedgerPro_app/core/FixedAssets/models/fixed_asset_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';

class FixedAssetsScreen extends StatelessWidget {
  const FixedAssetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FixedAssetController());

    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(controller),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
LoadingAnimationWidget.waveDots(
                    color: kPrimary,
                    size: 10.w,
                  )    ,            SizedBox(height: 2.h),
                Text('Loading fixed assets...', style: TextStyle(fontSize: 14.sp, color: kSubText)),
              ],
            ),
          );
        }
        return Column(
          children: [
            _buildSummaryCards(controller),
            _buildFilterBar(controller),
            Expanded(child: _buildAssetsList(controller)),
          ],
        );
      }),
      floatingActionButton: _buildFAB(controller),
    );
  }

  PreferredSizeWidget _buildAppBar(FixedAssetController controller) {
    return AppBar(
      title: Text('Fixed Assets', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: Colors.white)),
      backgroundColor: kPrimary,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(Icons.calculate_outlined, color: Colors.white, size: 5.w),
          onPressed: () => controller.runMonthlyDepreciation(),
        ),
        IconButton(
          icon: Icon(Icons.download_outlined, color: Colors.white, size: 5.w),
          onPressed: () => controller.exportAssets(),
        ),
        IconButton(
          icon: Icon(Icons.print_outlined, color: Colors.white, size: 5.w),
          onPressed: () => controller.printAssets(),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(FixedAssetController controller) {
    return Obx(() => Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildSummaryCard('Total Assets', controller.totalAssets.value.toString(), kPrimary, Icons.inventory, 25.w, isNumber: true),
            SizedBox(width: 2.w),
            _buildSummaryCard('Total Cost', controller.formatAmount(controller.totalCost.value), kPrimary, Icons.attach_money, 28.w),
            SizedBox(width: 2.w),
            _buildSummaryCard('Accumulated Depreciation', controller.formatAmount(controller.totalDepreciation.value), kWarning, Icons.trending_down, 30.w),
            SizedBox(width: 2.w),
            _buildSummaryCard('Net Book Value', controller.formatAmount(controller.totalNetBookValue.value), kSuccess, Icons.account_balance, 28.w),
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
              Expanded(child: Text(title, style: TextStyle(fontSize: 12.sp, color: kSubText, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ),
          SizedBox(height: 1.h),
          Text(isNumber ? amount : amount, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildFilterBar(FixedAssetController controller) {
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
              decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
              child: TextField(
                controller: controller.searchController,
                style: TextStyle(fontSize: 14.sp, color: kText),
                decoration: InputDecoration(
                  hintText: 'Search by name, asset code, category...',
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
    );
  }

  Widget _buildAssetsList(FixedAssetController controller) {
    if (controller.assets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_outlined, size: 15.w, color: kSubText.withOpacity(0.5)),
            SizedBox(height: 2.h),
            Text('No assets found', style: TextStyle(fontSize: 14.sp, color: kSubText, fontWeight: FontWeight.w500)),
            SizedBox(height: 2.h),
            ElevatedButton(
              onPressed: () => controller.showAddAssetDialog(),
              style: ElevatedButton.styleFrom(backgroundColor: kPrimary, padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('Add Asset', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: controller.assets.length,
      itemBuilder: (context, index) {
        final asset = controller.assets[index];
        return _buildAssetCard(controller, asset);
      },
    );
  }

  Widget _buildAssetCard(FixedAssetController controller, FixedAsset asset) {
    Color statusColor = asset.status == 'Active' ? kSuccess : asset.status == 'Fully Depreciated' ? kWarning : kDanger;
    double depreciationPercent = (asset.accumulatedDepreciation / asset.purchaseCost) * 100;
    
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
          onTap: () => controller.showAssetDetails(asset),
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
                        color: controller.getAssetCategoryColor(asset.category).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(controller.getAssetIcon(asset.category), size: 7.w, color: controller.getAssetCategoryColor(asset.category)),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(asset.name, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: kText), maxLines: 1, overflow: TextOverflow.ellipsis)),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                child: Text(asset.status, style: TextStyle(fontSize: 12.sp, color: statusColor, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          SizedBox(height: 0.5.h),
                          Text('${asset.assetCode} • ${asset.category}', style: TextStyle(fontSize: 12.sp, color: kSubText)),
                          SizedBox(height: 0.5.h),
                          Text('Location: ${asset.location}', style: TextStyle(fontSize: 12.sp, color: kSubText)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Net Book Value', style: TextStyle(fontSize: 12.sp, color: kSubText, fontWeight: FontWeight.w500)),
                        SizedBox(height: 0.5.h),
                        Text(controller.formatAmount(asset.netBookValue), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: kSuccess)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 1.h),
                  child: Row(
                    children: [
                      Expanded(child: _buildInfoItem('Purchase Date', DateFormat('dd MMM yyyy').format(asset.purchaseDate), Icons.calendar_today)),
                      Container(width: 1, height: 4.h, color: kBorder),
                      Expanded(child: _buildInfoItem('Purchase Cost', controller.formatAmount(asset.purchaseCost), Icons.attach_money)),
                      Container(width: 1, height: 4.h, color: kBorder),
                      Expanded(child: _buildInfoItem('Useful Life', '${asset.usefulLife} years', Icons.timeline)),
                    ],
                  ),
                ),
                SizedBox(height: 1.h),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 1.h),
                  child: Row(
                    children: [
                      Expanded(child: _buildInfoItem('Accumulated Depreciation', controller.formatAmount(asset.accumulatedDepreciation), Icons.trending_down)),
                      Container(width: 1, height: 4.h, color: kBorder),
                      Expanded(child: _buildInfoItem('Depreciation %', '${depreciationPercent.toStringAsFixed(1)}%', Icons.percent)),
                      Container(width: 1, height: 4.h, color: kBorder),
                      Expanded(child: _buildInfoItem('Last Depreciation', asset.lastDepreciationDate != null ? DateFormat('dd MMM yyyy').format(asset.lastDepreciationDate!) : 'N/A', Icons.update)),
                    ],
                  ),
                ),
                SizedBox(height: 1.h),
                Container(
                  height: 0.8.h,
                  width: 100.w,
                  decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(4)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: depreciationPercent / 100,
                      backgroundColor: kBg,
                      valueColor: AlwaysStoppedAnimation<Color>(depreciationPercent > 90 ? kDanger : depreciationPercent > 70 ? kWarning : kSuccess),
                      minHeight: 0.8.h,
                    ),
                  ),
                ),
                SizedBox(height: 0.5.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('0%', style: TextStyle(fontSize: 8.sp, color: kSubText)),
                    Text('Depreciation Progress', style: TextStyle(fontSize: 9.sp, color: kSubText)),
                    Text('100%', style: TextStyle(fontSize: 8.sp, color: kSubText)),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    if (asset.status == 'Active')
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => controller.depreciateAsset(asset),
                          icon: Icon(Icons.calculate, size: 4.w, color: kPrimary),
                          label: Text('Depreciate', style: TextStyle(fontSize: 12.sp, color: kPrimary)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: kPrimary, width: 1),
                            padding: EdgeInsets.symmetric(vertical: 1.2.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    if (asset.status == 'Active') SizedBox(width: 3.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => controller.showEditAssetDialog(asset),
                        icon: Icon(Icons.edit, size: 4.w, color: kPrimary),
                        label: Text('Edit', style: TextStyle(fontSize: 12.sp, color: kPrimary)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: kPrimary, width: 1),
                          padding: EdgeInsets.symmetric(vertical: 1.2.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    if (asset.status != 'Disposed') SizedBox(width: 3.w),
                    if (asset.status != 'Disposed')
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => controller.showDisposeAssetDialog(asset),
                          icon: Icon(Icons.delete_outline, size: 4.w, color: Colors.white),
                          label: Text('Dispose', style: TextStyle(fontSize: 12.sp, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kDanger,
                            padding: EdgeInsets.symmetric(vertical: 1.2.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
              Text(label, style: TextStyle(fontSize: 12.sp, color: kSubText)),
              Text(value, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: kText), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFAB(FixedAssetController controller) {
    return FloatingActionButton(
      onPressed: () => controller.showAddAssetDialog(),
      backgroundColor: kPrimary,
      child: Icon(Icons.add, color: Colors.white, size: 6.w),
      elevation: 3,
    );
  }
}