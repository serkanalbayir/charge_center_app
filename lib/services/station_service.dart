// station_service.dart
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StationService {
  static const double maxDistance = 8000; // 8 km yarıçap
  final String _mapboxAccessToken = ''; // Mapbox Access Token'inizi buraya girin

  Future<List<dynamic>> fetchStations() async {
    final response = await rootBundle.loadString('assets/stations.json');
    return jsonDecode(response) as List;
  }

  double calculateDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
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
      throw Exception('Mapbox API\'dan mesafe bilgisi alınamadı.');
    }
  }
  List<dynamic> filterNearbyStations(List<dynamic> stations, LatLng currentLocation) {
    return stations.where((station) {
      var stationLocation = LatLng(station['latitude'], station['longitude']);
      double distance = calculateDistance(currentLocation, stationLocation);
      return distance <=
          maxDistance; // maxDistanceInMeters yerine sınıf düzeyinde tanımlanan maxDistance kullanılır
    }).toList();
  }

  Future<List<dynamic>> getNearbyStationsWithDrivingDistance(LatLng currentLocation) async {
    var stations = await fetchStations();
    var nearbyStations = filterNearbyStations(stations, currentLocation);

    List<dynamic> stationsWithDrivingDistance = [];

    for (var station in nearbyStations) {
      var stationLocation = LatLng(station['latitude'], station['longitude']);
      double distance = await getDrivingDistance(currentLocation, stationLocation);
      station['distance'] = distance; // İstasyon bilgilerine mesafeyi ekleyin
      stationsWithDrivingDistance.add(station);
    }

    return stationsWithDrivingDistance;
  }
}
