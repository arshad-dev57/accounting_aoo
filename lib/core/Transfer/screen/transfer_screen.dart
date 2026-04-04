import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/core/transfer/controller/transfer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class TransferScreen extends StatelessWidget {
  const TransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TransferController());

    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: kPrimary,
              strokeWidth: 3.w,
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            children: [
              _buildHeader(),
              SizedBox(height: 2.h),
              _buildFromAccountCard(controller),
              SizedBox(height: 2.h),
              _buildArrowIcon(),
              SizedBox(height: 2.h),
              _buildToAccountCard(controller),
              SizedBox(height: 3.h),
              _buildAmountField(controller),
              SizedBox(height: 2.h),
              _buildDateField(controller),
              SizedBox(height: 2.h),
              _buildReferenceField(controller),
              SizedBox(height: 2.h),
              _buildDescriptionField(controller),
              SizedBox(height: 3.h),
              _buildTransferButton(controller),
              SizedBox(height: 2.h),
              _buildExchangeRateInfo(controller),
            ],
          ),
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Transfer Money',
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      backgroundColor: kPrimary,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white, size: 5.5.w),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2.5.w),
            ),
            child: Icon(
              Icons.swap_horiz,
              size: 5.w,
              color: kPrimary,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transfer Between Accounts',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: kText,
                  ),
                ),
                Text(
                  'Move money from one bank account to another',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: kSubText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFromAccountCard(TransferController controller) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(4.w),
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
              Icon(Icons.arrow_upward, size: 4.w, color: kDanger),
              SizedBox(width: 2.w),
              Text(
                'From Account',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: kDanger,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Obx(() => DropdownButtonFormField<String>(
            value: controller.fromAccountId.value.isEmpty 
                ? null 
                : controller.fromAccountId.value,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(2.w),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
            ),
            style: TextStyle(fontSize: 13.sp),
            hint: Text(
              'Select account to transfer from',
              style: TextStyle(fontSize: 12.sp, color: kSubText),
            ),
            items: controller.bankAccounts.map((account) {
              return DropdownMenuItem(
                value: account.id,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${account.number} • Balance: ${_formatAmount(account.balance)} ${account.currency}',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: kSubText,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) controller.setFromAccount(value);
            },
          )),
          if (controller.fromAccountId.value.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 1.5.h),
              child: _buildAccountBalance(controller.getFromAccount()),
            ),
        ],
      ),
    );
  }

  Widget _buildToAccountCard(TransferController controller) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(4.w),
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
              Icon(Icons.arrow_downward, size: 4.w, color: kSuccess),
              SizedBox(width: 2.w),
              Text(
                'To Account',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: kSuccess,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Obx(() => DropdownButtonFormField<String>(
            value: controller.toAccountId.value.isEmpty 
                ? null 
                : controller.toAccountId.value,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(2.w),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
            ),
            style: TextStyle(fontSize: 13.sp),
            hint: Text(
              'Select account to transfer to',
              style: TextStyle(fontSize: 12.sp, color: kSubText),
            ),
            items: controller.bankAccounts
                .where((account) => account.id != controller.fromAccountId.value)
                .map((account) {
              return DropdownMenuItem(
                value: account.id,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${account.number} • Balance: ${_formatAmount(account.balance)} ${account.currency}',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: kSubText,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) controller.setToAccount(value);
            },
          )),
          if (controller.toAccountId.value.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 1.5.h),
              child: _buildAccountBalance(controller.getToAccount()),
            ),
        ],
      ),
    );
  }

  Widget _buildAccountBalance(BankAccountForTransfer? account) {
    if (account == null) return const SizedBox.shrink();
    
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: kBg,
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Available Balance',
            style: TextStyle(
              fontSize: 11.sp,
              color: kSubText,
            ),
          ),
          Text(
            _formatAmount(account.balance),
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: kSuccess,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrowIcon() {
    return Container(
      width: 8.w,
      height: 8.w,
      decoration: BoxDecoration(
        color: kCardBg,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        Icons.arrow_downward,
        size: 4.w,
        color: kPrimary,
      ),
    );
  }

  Widget _buildAmountField(TransferController controller) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(4.w),
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
          Text(
            'Amount',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: kText,
            ),
          ),
          SizedBox(height: 1.5.h),
          TextFormField(
            onChanged: (value) => controller.setAmount(value),
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800),
            decoration: InputDecoration(
              prefixText: '₨ ',
              prefixStyle: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: kPrimary,
              ),
              hintText: '0.00',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(2.w),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
            ),
          ),
          Obx(() {
            if (controller.amount.value > 0) {
              final fromAccount = controller.getFromAccount();
              if (fromAccount != null && controller.amount.value > fromAccount.balance) {
                return Padding(
                  padding: EdgeInsets.only(top: 1.h),
                  child: Text(
                    'Insufficient balance! Available: ${_formatAmount(fromAccount.balance)}',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: kDanger,
                    ),
                  ),
                );
              }
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildDateField(TransferController controller) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(4.w),
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
          Text(
            'Transfer Date',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: kText,
            ),
          ),
          SizedBox(height: 1.5.h),
          Obx(() => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.calendar_today, size: 5.w, color: kPrimary),
            title: Text(
              DateFormat('EEEE, MMMM d, yyyy').format(controller.selectedDate.value),
              style: TextStyle(fontSize: 13.sp),
            ),
            trailing: Icon(Icons.arrow_forward_ios, size: 4.w, color: kSubText),
            onTap: () async {
              final picked = await showDatePicker(
                context: Get.context!,
                initialDate: controller.selectedDate.value,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                controller.setDate(picked);
              }
            },
          )),
        ],
      ),
    );
  }

  Widget _buildReferenceField(TransferController controller) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(4.w),
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
          Text(
            'Reference (Optional)',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: kText,
            ),
          ),
          SizedBox(height: 1.5.h),
          TextFormField(
            onChanged: (value) => controller.setReference(value),
            decoration: InputDecoration(
              hintText: 'e.g., TRANS-001, Salary Transfer',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(2.w),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
            ),
            style: TextStyle(fontSize: 13.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionField(TransferController controller) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(4.w),
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
          Text(
            'Description (Optional)',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: kText,
            ),
          ),
          SizedBox(height: 1.5.h),
          TextFormField(
            onChanged: (value) => controller.setDescription(value),
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Add a note about this transfer',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(2.w),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
            ),
            style: TextStyle(fontSize: 13.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferButton(TransferController controller) {
    return Obx(() => SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.isTransferring.value ? null : controller.transfer,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimary,
          padding: EdgeInsets.symmetric(vertical: 1.8.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.w),
          ),
        ),
        child: controller.isTransferring.value
            ? SizedBox(
                width: 5.w,
                height: 5.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2.w,
                  color: Colors.white,
                ),
              )
            : Text(
                'Transfer Money',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    ));
  }

  Widget _buildExchangeRateInfo(TransferController controller) {
    return Obx(() {
      final fromAccount = controller.getFromAccount();
      final toAccount = controller.getToAccount();
      
      if (fromAccount != null && toAccount != null && 
          fromAccount.currency != toAccount.currency && 
          controller.amount.value > 0) {
        return Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: kWarning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(2.w),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 4.w, color: kWarning),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Different currencies detected. Exchange rate will be applied at current market rate.',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: kWarning,
                  ),
                ),
              ),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '₨ ${formatter.format(amount)}';
  }
}