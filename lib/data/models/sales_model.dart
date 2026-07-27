class SalesModel {
  final int? id;
  final String username;
  final String email;
  final String fullName;
  final String role;

  const SalesModel({
    this.id,
    required this.username,
    required this.email,
    required this.fullName,
    this.role = 'sales',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'role': role,
    };
  }

  factory SalesModel.fromMap(Map<String, dynamic> map) {
    return SalesModel(
      id: map['id'] as int?,
      username: map['username'] as String? ?? '',
      email: map['email'] as String? ?? '',
      fullName: map['full_name'] as String? ?? '',
      role: map['role'] as String? ?? 'sales',
    );
  }

  SalesModel copyWith({
    int? id,
    String? username,
    String? email,
    String? fullName,
    String? role,
  }) {
    return SalesModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
    );
  }
}
