import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';


class DirectionsService {
  static const String _mapboxAccessToken = 'pk.eyJ1IjoiYXljYWRpbmRhciIsImEiOiJjbHEwdGFyZmEwMXZsMmpsZnhjOWFya2VqIn0.WerEPzO_rkFSK2PlxfzJtA';

  Future<Map<String, dynamic>> getRoute(LatLng origin, LatLng destination) async {
    final url = Uri.parse(

      'https://api.mapbox.com/directions/v5/mapbox/driving/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}?alternatives=false&geometries=geojson&steps=true&overview=full&access_token=$_mapboxAccessToken',
    );

    final response = await http.get(url);
    print('API Response: ${response.body}');

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
    print('API Response: ${response.body}');

    if (response.statusCode == 200) {
      var decodedResponse = json.decode(response.body);
      // İlk eşleşen adresi alın, gerçek uygulamada kullanıcıya seçenek sunulabilir
      var location = decodedResponse['features'][0]['center'];
      return LatLng(location[1], location[0]);
    } else {
      throw Exception('Failed to find location: ${response.body}');
    }
  }


}
