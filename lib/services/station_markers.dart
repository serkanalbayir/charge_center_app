import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';

class StationMarkers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DefaultAssetBundle.of(context).loadString('assets/stations.json'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            final List<dynamic> stations = json.decode(snapshot.data.toString());
            List<Marker> markers = [];

            // JSON'daki her istasyon için bir marker oluştur
            stations.forEach((station) {
              double latitude = station['latitude'];
              double longitude = station['longitude'];

              // Her istasyon için bir marker oluştur
              Marker marker = Marker(
                width: 40.0,
                height: 40.0,
                point: LatLng(latitude, longitude),
                child: Container(
                  child: Icon(
                    Icons.ev_station, // Şarj istasyonu simgesi
                    color: Colors.green, // Simge rengi
                    size: 30.0,
                  ),
                ),
              );

              markers.add(marker);
            });

            // Oluşturulan tüm markerları döndür
            return MarkerLayer(markers: markers);
          } else {
            // Veri yoksa gösterilecek widget
            return Center(child: Text('Data not available'));
          }
        } else {
          // Yüklenirken gösterilecek widget
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
