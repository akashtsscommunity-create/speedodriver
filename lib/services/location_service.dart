import 'package:dio/dio.dart';

class LocationService {
  static final Dio _dio = Dio();

  static Future<List<Map<String, dynamic>>> getSuggestions(String input) async {
    if (input.trim().isEmpty) return [];

    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'format': 'json',
          'q': input,
          'limit': 5,
          'addressdetails': 1,
        },
        options: Options(
          headers: {
            'User-Agent': 'SpeedoExpressApp/1.0',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) {
          return {
            'description': item['display_name']?.toString() ?? '',
            'place_id': item['place_id']?.toString() ?? '',
            'lat': item['lat']?.toString() ?? '0.0',
            'lon': item['lon']?.toString() ?? '0.0',
          };
        }).toList();
      }
    } catch (_) {}
    return [];
  }
}
