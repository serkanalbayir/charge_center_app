import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:bitirme/models/_station.dart';
import 'package:bitirme/widgets/station_details_bottom_sheet.dart';

class StationMarkers extends StatelessWidget {
  final List<Station> stations;
  final void Function(Station) onMarkerTap; // Bu değişkeni ekleyelim

  StationMarkers({required this.stations, required this.onMarkerTap}); // Bu constructor'ı güncelleyelim

  @override
  Widget build(BuildContext context) {
    List<Marker> markers = [];

    // JSON'daki her istasyon için bir marker oluştur
    stations.forEach((station) {
      double latitude = station.latitude;
      double longitude = station.longitude;

      // Her istasyon için bir marker oluştur
      Marker marker = Marker(
        width: 40.0,
        height: 40.0,
        point: LatLng(latitude, longitude),
        child: GestureDetector(
          onTap: () {
            onMarkerTap(station); // Bu fonksiyonu çağır
          },
          child: Container(
            child: Icon(
              Icons.ev_station, // Şarj istasyonu simgesi
              color: Colors.green, // Simge rengi
              size: 45.0,
            ),
          ),
        ),
      );

      markers.add(marker);
    });

    // Oluşturulan tüm markerları döndür
    return MarkerLayer(markers: markers);
  }
}
