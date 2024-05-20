// estimatedTime_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';


class EstimatedTimeService {
  final String mapboxAccessToken;

  EstimatedTimeService(this.mapboxAccessToken);

  Future<String> getEstimatedTime(LatLng origin, LatLng destination) async {
    final response = await http.get(
      Uri.parse(
        'https://api.mapbox.com/directions/v5/mapbox/driving/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}?access_token=$mapboxAccessToken',
      ),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      print('Mapbox Response: $jsonResponse');
      final durationSeconds = jsonResponse['routes'][0]['duration'];
      final durationMinutes = durationSeconds / 60;
      print('Duration in minutes: $durationMinutes');
      return '${durationMinutes.round()} min';
    } else {
      throw Exception('Failed to load estimated time of arrival');
    }
  }
}
