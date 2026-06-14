import 'package:latlong2/latlong.dart';

class GoogleLocation {
  final String placeId;
  final String areaDetails;
  final LatLng? position;

  GoogleLocation({
    required this.placeId,
    required this.areaDetails,
    this.position,
  });

  GoogleLocation.named({
    required this.placeId,
    required this.areaDetails,
    this.position,
  });

  GoogleLocation copyWith({
    String? placeId,
    String? areaDetails,
    LatLng? position,
  }) {
    return GoogleLocation(
      placeId: placeId ?? this.placeId,
      areaDetails: areaDetails ?? this.areaDetails,
      position: position ?? this.position,
    );
  }
}
