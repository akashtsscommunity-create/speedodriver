import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/driver_models.dart';
import '../models/chat_message.dart';
import '../models/booking_model.dart';
import '../models/wallet_model.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final supabaseRepositoryProvider = Provider<SupabaseRepository>((ref) {
  return SupabaseRepository(ref.watch(supabaseClientProvider));
});

class SupabaseRepository {
  final SupabaseClient _supabase;

  SupabaseRepository(this._supabase);

  // --- Pricing Calculation ---
  Future<int> calculatePrice(double distanceMeters, String vehicleType) async {
    try {
      final response = await _supabase.rpc('compute_price', params: {
        'distance_meters': distanceMeters,
        'vehicle_type': vehicleType,
      });
      return response as int; // price in paise
    } catch (e) {
      rethrow;
    }
  }

  // --- KYC Submission ---
  Future<void> submitKYC({
    required String license,
    required String aadhaar,
    required String licenseUrl,
    required String aadhaarUrl,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception("User not authenticated");

    await _supabase.from('driver_details').upsert({
      'id': userId,
      'license_number': license,
      'aadhaar_number': aadhaar,
      'license_url': licenseUrl,
      'aadhaar_url': aadhaarUrl,
      'kyc_status': 'pending',
    });
  }

  // --- Chat Realtime ---
  Stream<List<ChatMessage>> getMessagesStream(String bookingId) {
    return _supabase
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('booking_id', bookingId)
        .order('created_at', ascending: true)
        .map((data) => data.map((json) => ChatMessage.fromJson(json)).toList());
  }

  Future<void> sendMessage(String bookingId, String text, {String type = 'text', String? attachmentUrl}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception("User not authenticated");

    await _supabase.from('chat_messages').insert({
      'booking_id': bookingId,
      'sender_id': userId,
      'message': text,
      'type': type,
      'attachment_url': attachmentUrl,
    });
  }

  // --- Admin Lite Views ---
  Future<bool> checkAdminStatus() async {
    try {
      final response = await _supabase.rpc('is_admin');
      return response as bool;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchLiveDeliveries() async {
    try {
      final response = await _supabase.from('admin_live_deliveries').select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  // --- Driver & Vehicle ---
  Future<DriverDetails?> getDriverDetails() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _supabase
        .from('driver_details')
        .select()
        .eq('id', userId)
        .maybeSingle();
    
    if (response == null) return null;
    return DriverDetails.fromJson(response);
  }

  Future<List<Vehicle>> getVehicles() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];
    
    final response = await _supabase.from('vehicles').select().eq('driver_id', userId);
    return (response as List).map((json) => Vehicle.fromJson(json)).toList();
  }

  // --- Storage & Uploads ---
  Future<String> uploadFile(File file, String bucketName) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception("User not authenticated");

    final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    
    await _supabase.storage.from(bucketName).upload(fileName, file);
    
    return _supabase.storage.from(bucketName).getPublicUrl(fileName);
  }

  Future<void> addVehicle({
    required String category,
    required String vehicleType,
    required String registrationNumber,
    required String make,
    required String model,
    required String year,
    required String color,
    required String maxKg,
    required String rcBookUrl,
    required String insuranceUrl,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception("User not authenticated");

    await _supabase.from('vehicles').insert({
      'driver_id': userId,
      'category': category,
      'vehicle_type': vehicleType,
      'registration_number': registrationNumber,
      'make': make,
      'model': model,
      'year': year,
      'color': color,
      'max_kg': maxKg,
      'rc_book_url': rcBookUrl,
      'insurance_url': insuranceUrl,
    });
  }

  // --- Location Search ---
  Future<List<Map<String, dynamic>>> searchLocations(String query, {double? lat, double? lng}) async {
    try {
      final response = await _supabase.rpc('locations_search', params: {
        'search_query': query,
        'near_lat': lat,
        'near_lng': lng,
        'max_results': 5,
      });
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  // --- Bookings ---
  Stream<List<Booking>> getAvailableBookingsStream() {
    return _supabase
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('status', 'searching')
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => Booking.fromJson(json)).toList());
  }

  Future<void> acceptBooking(String bookingId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception("User not authenticated");

    // Use a transaction or RPC for atomic acceptance if possible
    // Here we'll do a simple update with a condition
    await _supabase.from('bookings').update({
      'driver_id': userId,
      'status': 'accepted',
    }).eq('id', bookingId).eq('status', 'searching');
  }

  Future<Booking?> getActiveBooking() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _supabase
        .from('bookings')
        .select()
        .eq('driver_id', userId)
        .inFilter('status', ['accepted', 'in_transit'])
        .maybeSingle();

    if (response == null) return null;
    return Booking.fromJson(response);
  }

  // --- Wallet ---
  Future<Wallet?> getWallet() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _supabase
        .from('wallets')
        .select()
        .eq('owner_id', userId)
        .maybeSingle();

    if (response == null) return null;
    return Wallet.fromJson(response);
  }

  Stream<Wallet?> getWalletStream() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return Stream.value(null);

    return _supabase
        .from('wallets')
        .stream(primaryKey: ['id'])
        .eq('owner_id', userId)
        .map((data) => data.isNotEmpty ? Wallet.fromJson(data.first) : null);
  }

  Future<List<WalletTransaction>> getWalletTransactions() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final wallet = await getWallet();
    if (wallet == null) return [];

    final response = await _supabase
        .from('wallet_transactions')
        .select()
        .eq('wallet_id', wallet.id)
        .order('created_at', ascending: false);

    return (response as List).map((json) => WalletTransaction.fromJson(json)).toList();
  }

  Future<void> topupWallet(int amountPaise) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception("User not authenticated");

    await _supabase.rpc('handle_wallet_topup', params: {
      'target_user_id': userId,
      'topup_amount': amountPaise,
      'payment_ref': 'app_topup_${DateTime.now().millisecondsSinceEpoch}',
    });
  }
}
