import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';
import '../../models/google_location.dart';
import '../../state/location_provider.dart';

class EditLocationFrom extends ConsumerStatefulWidget {
  final String initialValue;
  final int mode;

  const EditLocationFrom({
    super.key,
    required this.initialValue,
    required this.mode,
  });

  @override
  ConsumerState<EditLocationFrom> createState() => _EditLocationFromState();
}

class _EditLocationFromState extends ConsumerState<EditLocationFrom> {
  late TextEditingController _controller;
  late MapController _mapController;
  
  LatLng selectedPosition = const LatLng(28.6139, 77.2090); // Default: Delhi
  String selectedAddress = '';
  bool isReverseGeocoding = false;
  bool showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _mapController = MapController();
    selectedAddress = widget.initialValue;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialValue.isNotEmpty) {
        _geocodeInitialAddress(widget.initialValue);
      } else {
        _getCurrentLocation();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _geocodeInitialAddress(String address) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'format': 'json',
          'q': address,
          'limit': 1,
        },
        options: Options(
          headers: {
            'User-Agent': 'SpeedoExpressApp/1.0',
          },
        ),
      );
      if (response.statusCode == 200 && (response.data as List).isNotEmpty) {
        final data = response.data[0];
        final lat = double.parse(data['lat']);
        final lon = double.parse(data['lon']);
        final latLng = LatLng(lat, lon);
        setState(() {
          selectedPosition = latLng;
          selectedAddress = address;
        });
        _mapController.move(latLng, 16);
      }
    } catch (_) {}
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    
    if (permission == LocationPermission.deniedForever) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      final latLng = LatLng(position.latitude, position.longitude);
      setState(() {
        selectedPosition = latLng;
      });
      _mapController.move(latLng, 16);
      _reverseGeocode(latLng);
    } catch (_) {}
  }

  Future<void> _reverseGeocode(LatLng position) async {
    setState(() {
      isReverseGeocoding = true;
    });
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'json',
          'lat': position.latitude,
          'lon': position.longitude,
          'zoom': 18,
          'addressdetails': 1,
        },
        options: Options(
          headers: {
            'User-Agent': 'SpeedoExpressApp/1.0',
          },
        ),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        final address = data['display_name'] ?? '${position.latitude}, ${position.longitude}';
        setState(() {
          selectedAddress = address;
          _controller.text = address;
        });
      }
    } catch (_) {
      setState(() {
        selectedAddress = '${position.latitude}, ${position.longitude}';
        _controller.text = '${position.latitude}, ${position.longitude}';
      });
    } finally {
      setState(() {
        isReverseGeocoding = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(locationSearchProvider);
    final notifier = ref.read(locationSearchProvider.notifier);

    // Listen to selections from searched suggestions to update map focus
    ref.listen<LocationSearchState>(locationSearchProvider, (previous, next) {
      if (next is LocationSelectedState) {
        final loc = next.location;
        if (loc.position != null) {
          setState(() {
            selectedPosition = loc.position!;
            selectedAddress = loc.areaDetails;
            _controller.text = loc.areaDetails;
            showSuggestions = false;
          });
          _mapController.move(loc.position!, 16);
        }
      }
    });

    return Stack(
      children: [
        // Interactive OpenStreetMap view
        Positioned.fill(
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: selectedPosition,
              initialZoom: 16.0,
              onTap: (tapPosition, point) {
                setState(() {
                  selectedPosition = point;
                  showSuggestions = false;
                });
                _reverseGeocode(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.skysoftsolutions.speedoexpress',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: selectedPosition,
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.location_on,
                      color: Color(0xFFF05C14),
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Floating Search Bar & Suggestions overlay
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: Column(
            children: [
              // Search Input Box
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(color: Colors.grey[200]!),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey[600]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: "Search for area, landmark or street...",
                          border: InputBorder.none,
                          isDense: true,
                          hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        onTap: () {
                          setState(() {
                            showSuggestions = true;
                          });
                        },
                        onChanged: (val) {
                          setState(() {
                            showSuggestions = true;
                          });
                          notifier.onInputChanged(val);
                        },
                      ),
                    ),
                    if (_controller.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _controller.clear();
                            showSuggestions = false;
                          });
                          notifier.onInputChanged("");
                        },
                        child: Icon(Icons.clear, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
              // Search Suggestions Overlay List
              if (showSuggestions && searchState is LocationLoaded) ...[
                const SizedBox(height: 6),
                Container(
                  constraints: const BoxConstraints(maxHeight: 250),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: searchState.suggestions.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    itemBuilder: (context, index) {
                      final suggestion = searchState.suggestions[index];
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.location_on, color: Color(0xFFF05C14), size: 18),
                        title: Text(
                          suggestion.areaDetails,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        onTap: () {
                          notifier.selectLocation(suggestion);
                        },
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),

        // Floating Action Buttons (Locate me / Zoom controls)
        Positioned(
          bottom: 150,
          right: 16,
          child: Column(
            children: [
              FloatingActionButton.small(
                heroTag: 'gps_btn',
                onPressed: _getCurrentLocation,
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFF05C14),
                child: const Icon(Icons.my_location),
              ),
            ],
          ),
        ),

        // Bottom Sheet Confirmation Panel
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Selected Address",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: isReverseGeocoding
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 4.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            )
                          : Text(
                              selectedAddress.isNotEmpty
                                  ? selectedAddress
                                  : "Tap map to pick location",
                              style: TextStyle(
                                fontSize: 14,
                                color: selectedAddress.isNotEmpty ? Colors.black87 : Colors.grey[500],
                                fontWeight: selectedAddress.isNotEmpty ? FontWeight.w600 : FontWeight.normal,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: selectedAddress.isNotEmpty && !isReverseGeocoding
                        ? () {
                            Navigator.pop(
                              context,
                              GoogleLocation(
                                placeId: 'place_manual_${DateTime.now().millisecondsSinceEpoch}',
                                areaDetails: selectedAddress,
                                position: selectedPosition,
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF05C14),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Confirm Location",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
