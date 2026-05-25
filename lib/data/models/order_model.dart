enum OrderStatus { draft, sent, done }

extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.draft:
        return 'Draft';
      case OrderStatus.sent:
        return 'Terkirim';
      case OrderStatus.done:
        return 'Selesai';
    }
  }

  String get value {
    switch (this) {
      case OrderStatus.draft:
        return 'draft';
      case OrderStatus.sent:
        return 'sent';
      case OrderStatus.done:
        return 'done';
    }
  }

  static OrderStatus fromString(String value) {
    switch (value) {
      case 'sent':
        return OrderStatus.sent;
      case 'done':
        return OrderStatus.done;
      default:
        return OrderStatus.draft;
    }
  }
}

class OrderModel {
  final int? id;
  final int customerId;
  final String customerName;
  final double totalAmount;
  final OrderStatus status;
  final String? notes;
  final DateTime createdAt;

  const OrderModel({
    this.id,
    required this.customerId,
    required this.customerName,
    required this.totalAmount,
    this.status = OrderStatus.draft,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'customer_name': customerName,
      'total_amount': totalAmount,
      'status': status.value,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] as int?,
      customerId: map['customer_id'] as int,
      customerName: map['customer_name'] as String,
      totalAmount: (map['total_amount'] as num).toDouble(),
      status: OrderStatusExtension.fromString(
        map['status'] as String? ?? 'draft',
      ),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  OrderModel copyWith({
    int? id,
    int? customerId,
    String? customerName,
    double? totalAmount,
    OrderStatus? status,
    String? notes,
    DateTime? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
