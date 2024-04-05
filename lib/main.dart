import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'services/directions_service.dart';
import 'login_page.dart';



void main() => runApp(AppEntry());

class AppEntry extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Navigasyon Uygulaması',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(), // Uygulamanın başlangıç sayfası artık LoginPage
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late LatLng _currentLocation;
  List<LatLng> _routeCoords = [];
  final MapController _mapController = MapController();
  final DirectionsService _directionsService = DirectionsService();
  final TextEditingController _destinationController = TextEditingController();
  bool _isNavigating = false; // Navigasyon modunu takip eden değişken

  @override
  void initState() {
    super.initState();
    _determinePosition().then((position) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      _startListeningLocation();
    }).catchError((error) {
      print('Konum bilgisi alınamadı: $error');
    });
  }

  void _startListeningLocation() {
    final locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });

        if (_isNavigating) {
          // Navigasyon modundayken rota güncellemeleri
          _getRoute();
        } else {
          _mapController.move(_currentLocation, 16);
        }
      },
    ).onError((e) {
      print('Konum izleme hatası: $e');
    });
  }

  Future<void> _getRoute() async {
    try {
      var destinationStr = _destinationController.text;
      if (destinationStr.isEmpty) {
        return;
      }
      LatLng destination = await _directionsService.getCoordinatesFromAddress(destinationStr);

      Map<String, dynamic> routeData = await _directionsService.getRoute(_currentLocation, destination);
      List<LatLng> routeCoords = _directionsService.parsePolyline(routeData['routes'][0]['geometry']);

      setState(() {
        _routeCoords = routeCoords;
      });

      if (!_isNavigating) {
        _mapController.move(destination, 14);
      } else {
        // Navigasyon modundayken kullanıcıya rotayı sürekli olarak göster
        _mapController.move(_currentLocation, 16);
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
      ));
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Konum servisleri devre dışı.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Konum izinleri reddedildi.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Konum izinleri kalıcı olarak reddedildi, izinleri ayarlardan açın.');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentLocation == null) {
      return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text('Charge Center'),
          ),
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Charge Center')),
        body: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentLocation,
                initialZoom: 16.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://api.mapbox.com/styles/v1/aycadindar/clte7lvwx00mb01qng59z2cig/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiYXljYWRpbmRhciIsImEiOiJjbHEwdGFyZmEwMXZsMmpsZnhjOWFya2VqIn0.WerEPzO_rkFSK2PlxfzJtA',
                  additionalOptions: {
                    'accessToken': 'pk.eyJ1IjoiYXljYWRpbmRhciIsImEiOiJjbHEwdGFyZmEwMXZsMmpsZnhjOWFya2VqIn0.WerEPzO_rkFSK2PlxfzJtA',
                    'id': 'mapbox.mapbox-streets-v8',
                  },
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: _currentLocation,
                      child: Container(
                        child: Icon(Icons.location_on, color: Colors.red,),
                      ),
                    ),
                  ],
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routeCoords,
                      strokeWidth: 4.0,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              top: 10.0,
              right: 15.0,
              left: 15.0,
              child: Container(
                color: Colors.white,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        controller: _destinationController,
                        textInputAction: TextInputAction.go,
                        onFieldSubmitted: (value) => _getRoute(),
                        decoration: InputDecoration(
                          hintText: "Enter Destination",
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () => _getRoute(),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20.0,
              right: 10.0,
              child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _isNavigating = !_isNavigating;
                    if (_isNavigating) {
                      _getRoute();
                    }
                  });
                },
                child: Icon(_isNavigating ? Icons.pause : Icons.navigation),
                backgroundColor: _isNavigating ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
