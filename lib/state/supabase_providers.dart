import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';
import '../models/chat_message.dart';
import '../models/driver_models.dart';
import '../models/booking_model.dart';
import '../models/wallet_model.dart';

/// Provider for the Supabase Repository
final supabaseRepoProvider = Provider<SupabaseRepository>((ref) {
  return SupabaseRepository(ref.watch(supabaseClientProvider));
});

/// Stream provider for chat messages for a specific booking
final chatMessagesProvider = StreamProvider.family<List<ChatMessage>, String>((ref, bookingId) {
  final repo = ref.watch(supabaseRepoProvider);
  return repo.getMessagesStream(bookingId);
});

/// Future provider for checking admin status
final adminStatusProvider = FutureProvider<bool>((ref) async {
  final repo = ref.watch(supabaseRepoProvider);
  return await repo.checkAdminStatus();
});

/// Future provider for fetching live deliveries (Admin only)
final liveDeliveriesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final isAdmin = await ref.watch(adminStatusProvider.future);
  if (!isAdmin) return [];
  
  final repo = ref.watch(supabaseRepoProvider);
  return await repo.fetchLiveDeliveries();
});

/// State notifier for KYC submission
class KycNotifier extends StateNotifier<AsyncValue<void>> {
  final SupabaseRepository _repo;
  KycNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<void> submit({
    required String license,
    required String aadhaar,
    required String licenseUrl,
    required String aadhaarUrl,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repo.submitKYC(
        license: license,
        aadhaar: aadhaar,
        licenseUrl: licenseUrl,
        aadhaarUrl: aadhaarUrl,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final kycSubmitProvider = StateNotifierProvider<KycNotifier, AsyncValue<void>>((ref) {
  return KycNotifier(ref.watch(supabaseRepoProvider));
});

/// Provider for current driver details
final driverDetailsProvider = FutureProvider<DriverDetails?>((ref) async {
  final repo = ref.watch(supabaseRepoProvider);
  return await repo.getDriverDetails();
});

/// Provider for available vehicles
final vehiclesProvider = FutureProvider<List<Vehicle>>((ref) async {
  final repo = ref.watch(supabaseRepoProvider);
  return await repo.getVehicles();
});
/// State notifier for adding a vehicle
class VehicleNotifier extends StateNotifier<AsyncValue<void>> {
  final SupabaseRepository _repo;
  VehicleNotifier(this._repo) : super(const AsyncValue.data(null));

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
    state = const AsyncValue.loading();
    try {
      await _repo.addVehicle(
        category: category,
        vehicleType: vehicleType,
        registrationNumber: registrationNumber,
        make: make,
        model: model,
        year: year,
        color: color,
        maxKg: maxKg,
        rcBookUrl: rcBookUrl,
        insuranceUrl: insuranceUrl,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final vehicleSubmitProvider = StateNotifierProvider<VehicleNotifier, AsyncValue<void>>((ref) {
  return VehicleNotifier(ref.watch(supabaseRepoProvider));
});

/// Stream provider for available bookings
final availableBookingsProvider = StreamProvider<List<Booking>>((ref) {
  final repo = ref.watch(supabaseRepoProvider);
  return repo.getAvailableBookingsStream();
});

/// Future provider for active booking
final activeBookingProvider = FutureProvider<Booking?>((ref) async {
  final repo = ref.watch(supabaseRepoProvider);
  return await repo.getActiveBooking();
});

/// State notifier for accepting a booking
class BookingAcceptNotifier extends StateNotifier<AsyncValue<void>> {
  final SupabaseRepository _repo;
  final Ref _ref;
  BookingAcceptNotifier(this._repo, this._ref) : super(const AsyncValue.data(null));

  Future<void> accept(String bookingId) async {
    state = const AsyncValue.loading();
    try {
      await _repo.acceptBooking(bookingId);
      _ref.invalidate(activeBookingProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final bookingAcceptProvider = StateNotifierProvider<BookingAcceptNotifier, AsyncValue<void>>((ref) {
  return BookingAcceptNotifier(ref.watch(supabaseRepoProvider), ref);
});

/// Stream provider for wallet balance
final walletProvider = StreamProvider<Wallet?>((ref) {
  final repo = ref.watch(supabaseRepoProvider);
  return repo.getWalletStream();
});

/// Future provider for wallet transactions
final walletTransactionsProvider = FutureProvider<List<WalletTransaction>>((ref) async {
  final repo = ref.watch(supabaseRepoProvider);
  return await repo.getWalletTransactions();
});
