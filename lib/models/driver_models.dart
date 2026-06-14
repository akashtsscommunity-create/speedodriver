enum KycStatus { pending, approved, rejected }

class DriverDetails {
  final String id;
  final String? licenseNumber;
  final String? aadhaarNumber;
  final KycStatus status;
  final String? rejectionReason;
  final String? licenseUrl;
  final String? aadhaarUrl;

  DriverDetails({
    required this.id,
    this.licenseNumber,
    this.aadhaarNumber,
    required this.status,
    this.rejectionReason,
    this.licenseUrl,
    this.aadhaarUrl,
  });

  factory DriverDetails.fromJson(Map<String, dynamic> json) {
    return DriverDetails(
      id: json['id'],
      licenseNumber: json['license_number'],
      aadhaarNumber: json['aadhaar_number'],
      status: KycStatus.values.firstWhere(
        (e) => e.name == (json['kyc_status'] ?? 'pending'),
        orElse: () => KycStatus.pending,
      ),
      rejectionReason: json['rejection_reason'],
      licenseUrl: json['license_url'],
      aadhaarUrl: json['aadhaar_url'],
    );
  }
}

class Vehicle {
  final String id;
  final String vehicleType;
  final String registrationNumber;
  final bool isVerified;

  Vehicle({
    required this.id,
    required this.vehicleType,
    required this.registrationNumber,
    required this.isVerified,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      vehicleType: json['vehicle_type'],
      registrationNumber: json['registration_number'],
      isVerified: json['is_verified'] ?? false,
    );
  }
}
