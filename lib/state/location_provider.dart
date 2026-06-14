import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../models/google_location.dart';
import '../services/supabase_service.dart';
import 'supabase_providers.dart';

abstract class LocationSearchState {}

class LocationInitial extends LocationSearchState {}

class LocationLoading extends LocationSearchState {}

class LocationLoaded extends LocationSearchState {
  final List<GoogleLocation> suggestions;
  LocationLoaded(this.suggestions);
}

class LocationError extends LocationSearchState {
  final String message;
  LocationError(this.message);
}

class LocationSelectedState extends LocationSearchState {
  final GoogleLocation location;
  LocationSelectedState(this.location);
}

class LocationNotifier extends StateNotifier<LocationSearchState> {
  final SupabaseRepository _repo;
  LocationNotifier(this._repo) : super(LocationInitial());

  Future<void> onInputChanged(String input) async {
    if (input.isEmpty) {
      state = LocationInitial();
      return;
    }
    state = LocationLoading();
    try {
      final data = await _repo.searchLocations(input);
      final suggestions = data
          .map((p) => GoogleLocation(
                placeId: p['id'].toString(),
                areaDetails: '${p['name']}, ${p['address']}',
                position: null, // RPC currently does not return lat/lng
              ))
          .toList();
      state = LocationLoaded(suggestions);
    } catch (e) {
      state = LocationError(e.toString());
    }
  }

  Future<void> selectLocation(GoogleLocation location) async {
    state = LocationSelectedState(location);
  }

  void fetchCurrentLocation(GoogleLocation location) {
    state = LocationSelectedState(location);
  }
}

final locationSearchProvider = StateNotifierProvider.autoDispose<LocationNotifier, LocationSearchState>((ref) {
  return LocationNotifier(ref.watch(supabaseRepoProvider));
});
