import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/core/journalEntries/Controllers/journal_entries_exportservice.dart';
import 'package:LedgerPro_app/core/journalEntries/Controllers/journal_entry_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';

class JournalEntriesScreen extends StatelessWidget {
  const JournalEntriesScreen({super.key});

  // RepaintBoundary key for image capture
  static final GlobalKey _repaintKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(JournalEntryController());

    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(controller),
      body: Obx(() {
        if (controller.isLoading.value && controller.journalEntries.isEmpty) {
          return Center(
              child: LoadingAnimationWidget.waveDots(
            color: kPrimary,
            size: 10.w,
          ));
        }

        return RepaintBoundary(
          key: _repaintKey,
          child: Column(
            children: [
              _buildFilterBar(controller),
              _buildSummaryCards(controller),
              Expanded(
                child: _buildJournalEntriesList(controller),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddJournalEntryDialog(context, controller),
        backgroundColor: kPrimary,
        child: Icon(Icons.add, color: Colors.white),
        elevation: 2,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(JournalEntryController controller) {
    return AppBar(
      title:Text(
        'Journal Entries',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      backgroundColor: kPrimary,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: Colors.white),
          onPressed: () => _showSearchDialog(Get.context!, controller),
        ),
        IconButton(
          icon: Icon(Icons.filter_alt_outlined, color: Colors.white),
          onPressed: () => _showFilterDialog(Get.context!, controller),
        ),
        // ── Export Button ──
        IconButton(
          icon: Icon(Icons.download_outlined, color: Colors.white),
          tooltip: 'Export',
          onPressed: () => _showExportBottomSheet(Get.context!, controller),
        ),
      ],
    );
  }
// ─────────────────────── EXPORT BOTTOM SHEET ───────────────────────
void _showExportBottomSheet(
    BuildContext context, JournalEntryController controller) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    backgroundColor: kCardBg,
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: kBorder, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
           Text(
            'Export Journal Entries',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: kText),
          ),
          const SizedBox(height: 6),
          Text(
            '${controller.journalEntries.length} entries will be exported',
            style:   TextStyle(fontSize: 13, color: kSubText),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              // PDF Button
              Expanded(
                child: _exportOptionCard(
                  icon: Icons.picture_as_pdf_outlined,
                  label: 'PDF',
                  subtitle: 'Formatted report',
                  color: const Color(0xFFE53935),
                  bgColor: const Color(0xFFFFEBEE),
                  onTap: () async {
                    // Close bottom sheet
                    Navigator.pop(ctx);
                    await Future.delayed(const Duration(milliseconds: 100));
                    // Show loading
                    _showExportingLoader('Generating PDF...');
                    
                    try {
                      final summary = {
                        'totalDebit': controller.totalDebit.value,
                        'totalCredit': controller.totalCredit.value,
                        'difference': controller.difference.value,
                        'postedCount': controller.postedCount.value,
                        'draftCount': controller.draftCount.value,
                      };
                      await JournalExportService.exportToPdf(
                          controller.journalEntries, summary);
                    } catch (e) {
                      print('Export error: $e');
                      Get.snackbar('Error', 'Failed to export PDF: $e');
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Image Button
              // Expanded(
              //   child: _exportOptionCard(
              //     icon: Icons.image_outlined,
              //     label: 'Image',
              //     subtitle: 'PNG screenshot',
              //     color: const Color(0xFF7B1FA2),
              //     bgColor: const Color(0xFFF3E5F5),
              //     onTap: () async {
              //       // Close bottom sheet
              //       Navigator.pop(ctx);
              //       await Future.delayed(const Duration(milliseconds: 100));
              //       _showExportingLoader('Capturing image...');
                    
              //       try {
              //         await JournalExportService.exportToImage(
              //             _repaintKey, controller.journalEntries);
              //       } catch (e) {
              //         print('Export error: $e');
              //         Get.snackbar('Error', 'Failed to export image: $e');
              //       }
              //     },
              //   ),
              // ),
              // const SizedBox(width: 12),
              // Excel Button
              Expanded(
                child: _exportOptionCard(
                  icon: Icons.table_chart_outlined,
                  label: 'Excel',
                  subtitle: 'Spreadsheet',
                  color: const Color(0xFF2E7D32),
                  bgColor: const Color(0xFFE8F5E9),
                  onTap: () async {
                    // Close bottom sheet
                    Navigator.pop(ctx);
                    await Future.delayed(const Duration(milliseconds: 100));
                    _showExportingLoader('Building Excel...');
                    
                    try {
                      final summary = {
                        'totalDebit': controller.totalDebit.value,
                        'totalCredit': controller.totalCredit.value,
                        'difference': controller.difference.value,
                        'postedCount': controller.postedCount.value,
                        'draftCount': controller.draftCount.value,
                      };
                      await JournalExportService.exportToExcel(
                          controller.journalEntries, summary);
                    } catch (e) {
                      print('Export error: $e');
                      Get.snackbar('Error', 'Failed to export Excel: $e');
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
  Widget _exportOptionCard({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 10),
            Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: color)),
            const SizedBox(height: 2),
            Text(subtitle,
                style:
                    TextStyle(fontSize: 10, color: color.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }

  void _showExportingLoader(String message) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LoadingAnimationWidget.waveDots(color: kPrimary, size: 48),
            const SizedBox(height: 16),
            Text(message,
                style:  TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500, color: kText)),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  // ─────────────── Rest of the screen ────────────────

  Widget _buildFilterBar(JournalEntryController controller) {
    void showDateRangePicker_(JournalEntryController c) async {
      final picked = await showDateRangePicker(
        context: Get.context!,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
      );
      if (picked != null) c.setDateRange(picked);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: kCardBg,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: kBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kBorder),
                  ),
                  child: TextField(
                    onChanged: (v) => controller.searchEntries(v),
                    decoration:  InputDecoration(
                      hintText: 'Search by ID, description, or reference...',
                      prefixIcon:
                          Icon(Icons.search, size: 20, color: kSubText),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 45,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: kBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: Obx(() => DropdownButton<String>(
                        value: controller.selectedFilter.value,
                        icon: Icon(Icons.arrow_drop_down),
                        items: const [
                          DropdownMenuItem(value: 'All', child: Text('All')),
                          DropdownMenuItem(
                              value: 'Posted', child: Text('Posted')),
                          DropdownMenuItem(
                              value: 'Draft', child: Text('Draft')),
                          DropdownMenuItem(
                              value: 'Custom Range',
                              child: Text('Custom Range')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            if (value == 'Custom Range') {
                              showDateRangePicker_(controller);
                            } else {
                              controller.changeFilter(value);
                            }
                          }
                        },
                      )),
                ),
              ),
            ],
          ),
          Obx(() {
            if (controller.selectedDateRange.value != null) {
              final range = controller.selectedDateRange.value!;
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Icon(Icons.date_range,
                            size: 16, color: kPrimary),
                        const SizedBox(width: 8),
                        Text(
                          '${DateFormat('MMM dd, yyyy').format(range.start)} - ${DateFormat('MMM dd, yyyy').format(range.end)}',
                          style:  TextStyle(
                              fontSize: 12,
                              color: kPrimary,
                              fontWeight: FontWeight.w500),
                        ),
                      ]),
                      GestureDetector(
                        onTap: () => controller.setDateRange(null),
                        child: Icon(Icons.close,
                            size: 16, color: kPrimary),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(JournalEntryController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        Expanded(
          child: _buildSummaryCard('Total Debit',
              _formatAmount(controller.totalDebit.value), kSuccess, Icons.trending_up),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard('Total Credit',
              _formatAmount(controller.totalCredit.value), kDanger, Icons.trending_down),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
              'Difference',
              _formatAmount(controller.difference.value),
              controller.difference.value < 0.01 ? kSuccess : kWarning,
              Icons.balance),
        ),
      ]),
    );
  }

  Widget _buildSummaryCard(
      String title, String amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(title,
              style:  TextStyle(
                  fontSize: 11,
                  color: kSubText,
                  fontWeight: FontWeight.w500)),
        ]),
        const SizedBox(height: 8),
        Text(amount,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w800, color: color)),
      ]),
    );
  }

  Widget _buildJournalEntriesList(JournalEntryController controller) {
    if (controller.journalEntries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined,
                size: 64, color: kSubText.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('No journal entries found',
                style: TextStyle(
                    fontSize: 16,
                    color: kSubText,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () =>
                  _showAddJournalEntryDialog(Get.context!, controller),
              child:Text('Create your first journal entry'),
            ),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels >=
            scrollInfo.metrics.maxScrollExtent - 100) {
          if (controller.hasMore.value && !controller.isLoadingMore.value) {
            controller.loadMoreJournalEntries();
          }
        }
        return false;
      },
      child: ListView.builder(
        controller: controller.scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: controller.journalEntries.length +
            (controller.hasMore.value ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == controller.journalEntries.length) {
            return _buildLoadingMoreIndicator();
          }
          final entry = controller.journalEntries[index];
          return _buildJournalEntryCard(entry, controller);
        },
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
          child: LoadingAnimationWidget.waveDots(color: kPrimary, size: 10.w)),
    );
  }

  Widget _buildJournalEntryCard(
      JournalEntry entry, JournalEntryController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: entry.status == 'Posted'
                ? kSuccess.withOpacity(0.05)
                : kWarning.withOpacity(0.05),
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: entry.status == 'Posted'
                                ? kSuccess.withOpacity(0.2)
                                : kWarning.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(entry.entryNumber,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: entry.status == 'Posted'
                                      ? kSuccess
                                      : kWarning)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: entry.status == 'Posted'
                                ? kSuccess.withOpacity(0.1)
                                : kWarning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                    entry.status == 'Posted'
                                        ? Icons.check_circle_outline
                                        : Icons.edit_outlined,
                                    size: 12,
                                    color: entry.status == 'Posted'
                                        ? kSuccess
                                        : kWarning),
                                const SizedBox(width: 4),
                                Text(entry.status,
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: entry.status == 'Posted'
                                            ? kSuccess
                                            : kWarning)),
                              ]),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      Text(entry.description,
                          style:  TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: kText)),
                    ]),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: kBg, borderRadius: BorderRadius.circular(6)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                     Icon(Icons.calendar_today,
                        size: 12, color: kSubText),
                    const SizedBox(width: 4),
                    Text(DateFormat('dd MMM yyyy').format(entry.date),
                        style:  TextStyle(fontSize: 11, color: kSubText)),
                  ]),
                ),
                const SizedBox(height: 8),
                if (entry.reference.isNotEmpty)
                  Text('Ref: ${entry.reference}',
                      style:
                           TextStyle(fontSize: 11, color: kSubText)),
              ]),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: kBorder, width: 1))),
              child: Row(children:  [
                Expanded(
                    flex: 3,
                    child: Text('Account',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: kSubText))),
                Expanded(
                    flex: 2,
                    child: Text('Debit',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: kSubText))),
                Expanded(
                    flex: 2,
                    child: Text('Credit',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: kSubText))),
              ]),
            ),
            ...entry.lines
                .map((line) => Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: kBorder.withOpacity(0.5)))),
                      child: Row(children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(line.accountName,
                                    style:  TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: kText)),
                                Text(line.accountCode,
                                    style:  TextStyle(
                                        fontSize: 10, color: kSubText)),
                              ]),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                              line.debit > 0
                                  ? _formatAmount(line.debit)
                                  : '-',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: line.debit > 0
                                      ? kSuccess
                                      : kSubText)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                              line.credit > 0
                                  ? _formatAmount(line.credit)
                                  : '-',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: line.credit > 0
                                      ? kDanger
                                      : kSubText)),
                        ),
                      ]),
                    ))
                .toList(),
            Container(
              padding: const EdgeInsets.only(top: 12),
              child: Row(children: [
                 Expanded(
                    flex: 3,
                    child: Text('Total',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: kText))),
                Expanded(
                    flex: 2,
                    child: Text(_formatAmount(entry.totalDebit),
                        textAlign: TextAlign.right,
                        style:  TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: kSuccess))),
                Expanded(
                    flex: 2,
                    child: Text(_formatAmount(entry.totalCredit),
                        textAlign: TextAlign.right,
                        style:  TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: kDanger))),
              ]),
            ),
          ]),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: kBg,
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Icon(Icons.person_outline, size: 14, color: kSubText),
                const SizedBox(width: 4),
                Text(entry.createdBy,
                    style:  TextStyle(fontSize: 11, color: kSubText)),
                const SizedBox(width: 12),
                Icon(Icons.access_time, size: 14, color: kSubText),
                const SizedBox(width: 4),
                Text(DateFormat('hh:mm a').format(entry.createdAt),
                    style:  TextStyle(fontSize: 11, color: kSubText)),
              ]),
              Row(children: [
                if (entry.status == 'Draft')
                  TextButton.icon(
                    onPressed: () => _postJournalEntry(entry, controller),
                    icon: Icon(Icons.check_circle, size: 18),
                    label:Text('Post'),
                    style:
                        TextButton.styleFrom(foregroundColor: kSuccess),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _viewJournalEntryDetails(entry),
                  icon: Icon(Icons.remove_red_eye, size: 20),
                  tooltip: 'View Details',
                ),
                if (entry.status == 'Draft')
                  IconButton(
                    onPressed: () =>
                        _deleteJournalEntry(entry, controller),
                    icon: Icon(Icons.delete_outline,
                        size: 20, color: kDanger),
                    tooltip: 'Delete',
                  ),
              ]),
            ],
          ),
        ),
      ]),
    );
  }

  void _showAddJournalEntryDialog(
      BuildContext context, JournalEntryController controller) {
    showDialog(
      context: context,
      builder: (context) =>
          AddJournalEntryDialog(controller: controller),
    );
  }

  void _postJournalEntry(
      JournalEntry entry, JournalEntryController controller) {
    Get.dialog(AlertDialog(
      title:Text('Post Journal Entry'),
      content:Text(
          'Are you sure you want to post this journal entry? This action cannot be undone.'),
      actions: [
        TextButton(onPressed: () => Get.back(), child:Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            Get.back();
            await controller.postJournalEntry(entry.id);
            await controller.fetchJournalEntries();
          },
          style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
          child:Text('Post Entry'),
        ),
      ],
    ));
  }

  void _deleteJournalEntry(
      JournalEntry entry, JournalEntryController controller) {
    Get.dialog(AlertDialog(
      title:Text('Delete Journal Entry'),
      content:Text(
          'Are you sure you want to delete this journal entry?'),
      actions: [
        TextButton(onPressed: () => Get.back(), child:Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            Get.back();
            await controller.deleteJournalEntry(entry.id);
          },
          style: ElevatedButton.styleFrom(backgroundColor: kDanger),
          child:Text('Delete'),
        ),
      ],
    ));
  }

  void _viewJournalEntryDetails(JournalEntry entry) {
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => JournalEntryDetailsSheet(
            entry: entry, scrollController: scrollController),
      ),
    );
  }

  void _showSearchDialog(
      BuildContext context, JournalEntryController controller) {
    TextEditingController searchController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:Text('Search Journal Entries'),
        content: TextField(
          controller: searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter journal ID, description, or reference',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (value) {
            controller.searchEntries(value);
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child:Text('Cancel')),
          TextButton(
            onPressed: () {
              controller.searchEntries(searchController.text);
              Navigator.pop(context);
            },
            child:Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(
      BuildContext context, JournalEntryController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:Text('Filter Journal Entries'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: Icon(Icons.date_range),
            title:Text('Date Range'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () async {
              Navigator.pop(context);
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) controller.setDateRange(picked);
            },
          ),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child:Text('Cancel')),
        ],
      ),
    );
  }

  String _formatAmount(double amount) =>
      '₨ ${amount.toStringAsFixed(2)}';
}

// ==================== ADD JOURNAL ENTRY DIALOG ====================
class AddJournalEntryDialog extends StatefulWidget {
  final JournalEntryController controller;
  const AddJournalEntryDialog({super.key, required this.controller});

  @override
  State<AddJournalEntryDialog> createState() => _AddJournalEntryDialogState();
}

class _AddJournalEntryDialogState extends State<AddJournalEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  String _description = '';
  String _reference = '';
  List<JournalLineInput> _lines = [];

  @override
  void initState() {
    super.initState();
    _addLine();
  }

  void _addLine() => setState(() => _lines.add(JournalLineInput()));
  void _removeLine(int index) => setState(() => _lines.removeAt(index));

  @override
  Widget build(BuildContext context) {
    double totalDebit =
        _lines.fold(0, (sum, line) => sum + line.debit);
    double totalCredit =
        _lines.fold(0, (sum, line) => sum + line.credit);
    bool isBalanced = (totalDebit - totalCredit).abs() < 0.01;

    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kPrimary,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: const Row(children: [
              Icon(Icons.add_task, color: Colors.white),
              SizedBox(width: 12),
              Text('New Journal Entry',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
            ]),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.calendar_today,
                            color: kPrimary),
                        title:Text('Journal Date'),
                        subtitle: Text(DateFormat('EEEE, MMMM d, yyyy')
                            .format(_selectedDate)),
                        onTap: () async {
                          final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now());
                          if (picked != null)
                            setState(() => _selectedDate = picked);
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'Description *',
                            hintText: 'Enter journal description',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.description)),
                        maxLines: 2,
                        onChanged: (v) => _description = v,
                        validator: (v) => v == null || v.isEmpty
                            ? 'Description required'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'Reference Number',
                            hintText: 'e.g., INV-001, BILL-002',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.receipt)),
                        onChanged: (v) => _reference = v,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                           Text('Journal Lines',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: kText)),
                          TextButton.icon(
                            onPressed: _addLine,
                            icon: Icon(Icons.add, size: 18),
                            label:Text('Add Line'),
                            style: TextButton.styleFrom(
                                foregroundColor: kPrimary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ..._lines.asMap().entries.map((entry) {
                        final index = entry.key;
                        final line = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: kBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: kBorder)),
                          child: Column(children: [
                            Row(children: [
                              Expanded(
                                child: Obx(() =>
                                    DropdownButtonFormField<String>(
                                      decoration: const InputDecoration(
                                          labelText: 'Account *',
                                          border: OutlineInputBorder()),
                                      value: line.accountId.isEmpty
                                          ? null
                                          : line.accountId,
                                      items: widget.controller.accounts
                                          .map((account) =>
                                              DropdownMenuItem<String>(
                                                value: account['_id']
                                                    .toString(),
                                                child: Text(
                                                    '${account['code']} - ${account['name']}'),
                                              ))
                                          .toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          line.accountId = value!;
                                          final selected = widget
                                              .controller.accounts
                                              .firstWhere((a) =>
                                                  a['_id'].toString() ==
                                                  value);
                                          line.accountName =
                                              selected['name'];
                                          line.accountCode =
                                              selected['code'];
                                        });
                                      },
                                    )),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                icon: Icon(Icons.delete,
                                    color: kDanger),
                                onPressed: () => _removeLine(index),
                              ),
                            ]),
                            const SizedBox(height: 12),
                            Row(children: [
                              Expanded(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                      labelText: 'Debit',
                                      border: OutlineInputBorder(),
                                      prefixText: '₨ '),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setState(() {
                                      double val =
                                          double.tryParse(value) ?? 0;
                                      line.debit = val;
                                      if (line.debit > 0) line.credit = 0;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                      labelText: 'Credit',
                                      border: OutlineInputBorder(),
                                      prefixText: '₨ '),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setState(() {
                                      double val =
                                          double.tryParse(value) ?? 0;
                                      line.credit = val;
                                      if (line.credit > 0) line.debit = 0;
                                    });
                                  },
                                ),
                              ),
                            ]),
                          ]),
                        );
                      }).toList(),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isBalanced
                              ? kSuccess.withOpacity(0.1)
                              : kDanger.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                           Text('Total Debit = Total Credit?',
                                style:
                                    TextStyle(fontWeight: FontWeight.w600)),
                            Row(children: [
                              Icon(
                                  isBalanced
                                      ? Icons.check_circle
                                      : Icons.warning,
                                  color:
                                      isBalanced ? kSuccess : kDanger,
                                  size: 20),
                              const SizedBox(width: 8),
                              Text(
                                  isBalanced
                                      ? 'Balanced'
                                      : 'Not Balanced',
                                  style: TextStyle(
                                      color: isBalanced ? kSuccess : kDanger,
                                      fontWeight: FontWeight.w600)),
                            ]),
                          ],
                        ),
                      ),
                    ]),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration:
                BoxDecoration(border: Border(top: BorderSide(color: kBorder))),
            child: Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12)),
                  child:Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate() &&
                        _lines.isNotEmpty) {
                      final linesData = _lines
                          .map((line) => ({
                                'accountId': line.accountId,
                                'debit': line.debit,
                                'credit': line.credit,
                              }))
                          .toList();
                      Navigator.pop(context);
                      await widget.controller.createJournalEntry(
                          date: _selectedDate,
                          description: _description,
                          reference: _reference,
                          lines: linesData,
                          postNow: false);
                    } else {
                      Get.snackbar(
                          'Error', 'Please add at least one journal line');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      padding:
                          const EdgeInsets.symmetric(vertical: 12)),
                  child:Text('Save as Draft'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate() &&
                        _lines.isNotEmpty) {
                      if (isBalanced) {
                        final linesData = _lines
                            .map((line) => ({
                                  'accountId': line.accountId,
                                  'debit': line.debit,
                                  'credit': line.credit,
                                }))
                            .toList();
                        Navigator.pop(context);
                        await widget.controller.createJournalEntry(
                            date: _selectedDate,
                            description: _description,
                            reference: _reference,
                            lines: linesData,
                            postNow: true);
                      } else {
                        Get.snackbar(
                            'Error', 'Total Debit must equal Total Credit');
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: kSuccess,
                      padding:
                          const EdgeInsets.symmetric(vertical: 12)),
                  child:Text('Post Entry'),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class JournalLineInput {
  String accountId = '';
  String accountName = '';
  String accountCode = '';
  double debit = 0.0;
  double credit = 0.0;
}

// ==================== JOURNAL ENTRY DETAILS SHEET ====================
class JournalEntryDetailsSheet extends StatelessWidget {
  final JournalEntry entry;
  final ScrollController scrollController;

  const JournalEntryDetailsSheet(
      {super.key, required this.entry, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             Text('Journal Entry Details',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: kText)),
            IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close)),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView(
            controller: scrollController,
            children: [
              _buildInfoCard(),
              const SizedBox(height: 20),
              _buildLinesTable(),
              const SizedBox(height: 20),
              _buildAuditInfo(),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorder)),
      child: Column(children: [
        _buildDetailRow('Journal ID', entry.entryNumber),
        _buildDetailRow('Date',
            DateFormat('EEEE, MMMM d, yyyy').format(entry.date)),
        _buildDetailRow('Description', entry.description),
        _buildDetailRow('Reference',
            entry.reference.isEmpty ? 'N/A' : entry.reference),
        _buildDetailRow('Status', entry.status),
      ]),
    );
  }

  Widget _buildLinesTable() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
         Text('Journal Lines',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: kText)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: kBorder))),
          child: Row(children: const [
            Expanded(
                flex: 3,
                child: Text('Account',
                    style: TextStyle(fontWeight: FontWeight.w600))),
            Expanded(
                flex: 2,
                child: Text('Debit', textAlign: TextAlign.right)),
            Expanded(
                flex: 2,
                child: Text('Credit', textAlign: TextAlign.right)),
          ]),
        ),
        ...entry.lines
            .map((line) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(children: [
                    Expanded(
                        flex: 3,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(line.accountName,
                                  style:  TextStyle(
                                      fontWeight: FontWeight.w500)),
                              Text(line.accountCode,
                                  style:  TextStyle(
                                      fontSize: 11, color: kSubText)),
                            ])),
                    Expanded(
                        flex: 2,
                        child: Text(
                            line.debit > 0
                                ? _formatAmount(line.debit)
                                : '-',
                            textAlign: TextAlign.right,
                            style:  TextStyle(
                                fontWeight: FontWeight.w600))),
                    Expanded(
                        flex: 2,
                        child: Text(
                            line.credit > 0
                                ? _formatAmount(line.credit)
                                : '-',
                            textAlign: TextAlign.right,
                            style:  TextStyle(
                                fontWeight: FontWeight.w600))),
                  ]),
                ))
            .toList(),
        const Divider(),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(children: [
            const Expanded(
                flex: 3,
                child: Text('Total',
                    style: TextStyle(fontWeight: FontWeight.w800))),
            Expanded(
                flex: 2,
                child: Text(_formatAmount(entry.totalDebit),
                    textAlign: TextAlign.right,
                    style:  TextStyle(
                        fontWeight: FontWeight.w800, color: kSuccess))),
            Expanded(
                flex: 2,
                child: Text(_formatAmount(entry.totalCredit),
                    textAlign: TextAlign.right,
                    style:  TextStyle(
                        fontWeight: FontWeight.w800, color: kDanger))),
          ]),
        ),
      ]),
    );
  }

  Widget _buildAuditInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
         Text('Audit Information',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: kText)),
        const SizedBox(height: 12),
        _buildDetailRow('Created By', entry.createdBy),
        _buildDetailRow('Created At',
            DateFormat('dd MMM yyyy, hh:mm a').format(entry.createdAt)),
        if (entry.postedBy != null) ...[
          _buildDetailRow('Posted By', entry.postedBy!),
          _buildDetailRow('Posted At',
              DateFormat('dd MMM yyyy, hh:mm a').format(entry.postedAt!)),
        ],
      ]),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 100,
          child: Text(label,
              style:  TextStyle(
                  fontSize: 13,
                  color: kSubText,
                  fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: Text(value,
              style:  TextStyle(
                  fontSize: 13,
                  color: kText,
                  fontWeight: FontWeight.w500)),
        ),
      ]),
    );
  }

  String _formatAmount(double amount) =>
      '₨ ${amount.toStringAsFixed(2)}';
}