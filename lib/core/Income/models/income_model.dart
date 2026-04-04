class Income {
  final String id;
  final String incomeNumber;
  final DateTime date;
  final String incomeType;
  final String? customerId;
  final String customerName;
  final List<IncomeItem> items;
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

  Income({
    required this.id,
    required this.incomeNumber,
    required this.date,
    required this.incomeType,
    this.customerId,
    required this.customerName,
    required this.items,
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

  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      id: json['_id'] ?? '',
      incomeNumber: json['incomeNumber'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      incomeType: json['incomeType'] ?? '',
      customerId: json['customerId'] is Map ? json['customerId']['_id'] : json['customerId'],
      customerName: json['customerName'] ?? '',
      items: (json['items'] as List? ?? []).map((e) => IncomeItem.fromJson(e)).toList(),
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

class IncomeItem {
  final String description;
  final int quantity;
  final double unitPrice;
  final double amount;

  IncomeItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.amount,
  });

  factory IncomeItem.fromJson(Map<String, dynamic> json) {
    return IncomeItem(
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