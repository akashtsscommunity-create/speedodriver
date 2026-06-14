class Booking {
  final String id;
  final String customerId;
  final String? driverId;
  final String status; // 'searching', 'accepted', 'in_transit', 'completed', 'cancelled'
  final String vehicleType;
  final String category;
  final double price;
  final Map<String, dynamic> pickup;
  final List<Map<String, dynamic>> drops;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.customerId,
    this.driverId,
    required this.status,
    required this.vehicleType,
    required this.category,
    required this.price,
    required this.pickup,
    required this.drops,
    required this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      customerId: json['customer_id'],
      driverId: json['driver_id'],
      status: json['status'],
      vehicleType: json['vehicle_type'],
      category: json['category'],
      price: (json['price'] as num).toDouble(),
      pickup: json['pickup'] as Map<String, dynamic>,
      drops: (json['drops'] as List).cast<Map<String, dynamic>>(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'driver_id': driverId,
      'status': status,
      'vehicle_type': vehicleType,
      'category': category,
      'price': price,
      'pickup': pickup,
      'drops': drops,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
