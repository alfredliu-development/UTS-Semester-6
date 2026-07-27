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
    // is_visited bisa bool (dari Django) atau int (dari SQLite lama)
    final visited = map['is_visited'];
    bool isVisited = false;
    if (visited is bool) {
      isVisited = visited;
    } else if (visited is int) {
      isVisited = visited == 1;
    }

    return CustomerModel(
      id: map['id'] as int?,
      name: map['name']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      isVisited: isVisited,
      notes: map['notes']?.toString(),
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
