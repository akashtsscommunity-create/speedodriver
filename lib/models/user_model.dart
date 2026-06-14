class UserModel {
  final String id;
  final String fullName;
  final String? dateOfBirth;
  final String? mobileNumber;
  final String? emailAddress;
  final bool isVerified;
  final String? role; // 'customer', 'driver', or 'fleet'

  UserModel({
    required this.id,
    required this.fullName,
    this.dateOfBirth,
    this.mobileNumber,
    this.emailAddress,
    this.isVerified = false,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      fullName: json['full_name'] as String? ?? '',
      dateOfBirth: json['date_of_birth']?.toString(),
      mobileNumber: json['mobile_number']?.toString(),
      emailAddress: json['email_address']?.toString(),
      isVerified: json['is_verified'] == true || 
                  json['is_verified'] == 1 || 
                  json['is_verified'] == "1",
      role: json['role'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'date_of_birth': dateOfBirth,
      'mobile_number': mobileNumber,
      'email_address': emailAddress,
      'is_verified': isVerified,
      'role': role,
    };
  }
}
