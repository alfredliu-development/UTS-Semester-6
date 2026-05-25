class CustomerModel {
  final int? id;
  final String name;
  final String address;
  final String phone;
  final bool isVisited;
  final String? notes;

  const CustomerModel({
    this.id,
    required this.name,
    required this.address,
    required this.phone,
    this.isVisited = false,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'is_visited': isVisited ? 1 : 0,
      'notes': notes,
    };
  }

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      address: map['address'] as String,
      phone: map['phone'] as String,
      isVisited: (map['is_visited'] as int? ?? 0) == 1,
      notes: map['notes'] as String?,
    );
  }

  CustomerModel copyWith({
    int? id,
    String? name,
    String? address,
    String? phone,
    bool? isVisited,
    String? notes,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      isVisited: isVisited ?? this.isVisited,
      notes: notes ?? this.notes,
    );
  }
}
