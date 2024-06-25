import 'package:flutter/material.dart';
import 'package:bitirme/models/_station.dart';
import 'package:latlong2/latlong.dart';

void showStationDetails(BuildContext context, Station station, Future<void> Function({LatLng? stationPosition}) getRouteFunction) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: EdgeInsets.all(16),
        // Height'i kaldırıyoruz çünkü içerik ekrana sığmalı
        child: SingleChildScrollView( // Scrollable yapısını ekliyoruz
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(station.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8), // Araya boşluk ekleme
              Text("Address: ${station.address}"),
              SizedBox(height: 8), // Araya boşluk ekleme
              Text("Type: ${station.type.join(', ')}"), // Listeyi virgülle ayırarak gösterme
              SizedBox(height: 8), // Araya boşluk ekleme
              Text("Power Output: ${station.powerOutput}"),
              SizedBox(height: 8), // Araya boşluk ekleme
              Text("Socket Types: ${station.socketTypes.join(', ')}"),
              SizedBox(height: 8), // Araya boşluk ekleme
              Text("Operating Hours: ${station.operatingHours}"),
              SizedBox(height: 8), // Araya boşluk ekleme
              Text("Status: ${station.status}"),
              SizedBox(height: 16), // Buton için boşluk ekleme
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        print('Route button clicked for station: ${station.name}');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen, // Butonun arka plan rengini mavi yapma
                      ),
                      child: Text('Route'),
                    ),
                  ),
                  SizedBox(width: 16), // Butonlar arasında boşluk ekleme
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        print('Add Review button clicked for station: ${station.name}');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange, // Butonun arka plan rengini kırmızı yapma
                      ),
                      child: Text('Add Review'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
