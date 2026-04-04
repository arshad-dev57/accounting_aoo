class Expense {
  final String id;
  final String expenseNumber;
  final DateTime date;
  final String expenseType;
  final String? vendorId;
  final String vendorName;
  final List<ExpenseItem> items;
  final double amount;
  final bool hasItems;
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double totalAmount;
  final String description;
  final String reference;
  final String paymentMethod;
  final String? bankAccountId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Expense({
    required this.id,
    required this.expenseNumber,
    required this.date,
    required this.expenseType,
    this.vendorId,
    required this.vendorName,
    required this.items,
    required this.amount,
    required this.hasItems,
    required this.subtotal,
    required this.taxRate,
    required this.taxAmount,
    required this.totalAmount,
    required this.description,
    required this.reference,
    required this.paymentMethod,
    this.bankAccountId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  // expense_model.dart mein
factory Expense.fromJson(Map<String, dynamic> json) {
  print("Converting expense: $json");
  return Expense(
    id: json['_id'] ?? '',
    expenseNumber: json['expenseNumber'] ?? '',
    date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
    expenseType: json['expenseType'] ?? '',
    vendorId: json['vendorId'] is Map ? json['vendorId']['_id'] : json['vendorId'],
    vendorName: json['vendorName'] ?? '',
    items: (json['items'] as List? ?? []).map((e) => ExpenseItem.fromJson(e)).toList(),
    amount: (json['amount'] ?? 0).toDouble(),
    hasItems: json['hasItems'] ?? false,
    subtotal: (json['subtotal'] ?? 0).toDouble(),
    taxRate: (json['taxRate'] ?? 0).toDouble(),
    taxAmount: (json['taxAmount'] ?? 0).toDouble(),
    totalAmount: (json['totalAmount'] ?? 0).toDouble(),
    description: json['description'] ?? '',
    reference: json['reference'] ?? '',
    paymentMethod: json['paymentMethod'] ?? 'Cash',
    bankAccountId: json['bankAccountId'],
    status: json['status'] ?? 'Draft',
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
  );
}
}

class ExpenseItem {
  final String description;
  final int quantity;
  final double unitPrice;
  final double amount;

  ExpenseItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.amount,
  });

  factory ExpenseItem.fromJson(Map<String, dynamic> json) {
    return ExpenseItem(
      description: json['description'] ?? '',
      quantity: json['quantity'] ?? 1,
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'amount': amount,
    };
  }
}