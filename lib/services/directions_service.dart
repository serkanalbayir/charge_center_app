

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class DirectionsService {
  static const String _mapboxAccessToken = '';

  Future<Map<String, dynamic>> getRoute(LatLng origin, LatLng destination) async {
    final url = Uri.parse(
      'https://api.mapbox.com/directions/v5/mapbox/driving/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}?alternatives=false&geometries=geojson&steps=true&overview=full&access_token=$_mapboxAccessToken',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load route: ${response.statusCode}');
    }
  }

  List<LatLng> parsePolyline(Map geometry) {
    List<dynamic> coordinates = geometry['coordinates'];
    List<LatLng> polylineCoordinates = coordinates.map((coordinate) =>
        LatLng(coordinate[1], coordinate[0])
    ).toList();

    return polylineCoordinates;
  }

  Future<LatLng> getCoordinatesFromAddress(String address) async {
    final url = Uri.parse(
      'https://api.mapbox.com/geocoding/v5/mapbox.places/$address.json?access_token=$_mapboxAccessToken',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      var decodedResponse = json.decode(response.body);
      var location = decodedResponse['features'][0]['center'];
      return LatLng(location[1], location[0]);
    } else {
      throw Exception('Failed to find location: ${response.body}');
    }
  }

  Future<double> getDrivingDistance(LatLng start, LatLng end) async {
    final response = await http.get(
      Uri.parse(
          'https://api.mapbox.com/directions/v5/mapbox/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?access_token=$_mapboxAccessToken'
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final distance = data['routes'][0]['distance']; // Mesafe metre cinsinden döner
      return distance / 1000.0; // Kilometre cinsinden dönüştür
    } else {
      throw Exception('Failed to load driving distance');
    }
  }
}
