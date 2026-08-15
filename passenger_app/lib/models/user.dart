/// User profile — fields from OpenAPI `#/components/schemas/User`.
class User {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String role;
  final String? createdAt;
  final String? updatedAt;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.role,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString(),
      role: json['role']?.toString() ?? 'passenger',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'email': email,
        'phone_number': phoneNumber,
        'role': role,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}
