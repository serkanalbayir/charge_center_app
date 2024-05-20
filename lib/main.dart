import 'package:bitirme/route_elevation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'services/directions_service.dart';
import 'login_page.dart';
import 'package:http/http.dart' as http;
import 'services/station_service.dart';
import 'services/station_markers.dart';
import 'dart:convert';
import 'services/estimatedTime_service.dart';


void main() => runApp(AppEntry());

class AppEntry extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Charge Center',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(), // Uygulamanın başlangıç sayfası %LoginPage%
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  List<dynamic> _allStations = [];
  String _estimatedTimeOfArrival = '';
  bool _drawerOpen = false;
  List<dynamic> stations = [];
  late LatLng _currentLocation;
  List<LatLng> _routeCoords = [];
  List<double> _routeSlopes = [];
  final MapController _mapController = MapController();
  final DirectionsService _directionsService = DirectionsService();
  final TextEditingController _destinationController = TextEditingController();
  bool _isNavigating = false; // Navigasyon modunu takip eden değişken
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late EstimatedTimeService estimatedTimeService;

  List<LatLng> stationPoints = [
    LatLng(41.049294, 29.018036),
    LatLng(41.042484, 29.032059),
  ];
  StationService stationService = StationService();
  List<dynamic> nearbyStationsWithDistance = [];

  void _getNearbyStations() async {
    var stations = await stationService.fetchStations();
    var nearbyStations = stationService.filterNearbyStations(stations, _currentLocation); // 10 km mesafedeki istasyonlar.
    setState(() {
      this.stations = nearbyStations;
    });
  }

  void _showStationDetails(dynamic station) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(station['name'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text("Type: ${station['type']}"),
                Text("Power Output: ${station['power_output']}"),
                Text("Socket Types: ${station['socket_types'].join(', ')}"),
                Text("Operating Hours: ${station['operating_hours']}"),
                Text("Status: ${station['status']}")
              ],
            ),
          );
        }
    );
  }

  @override
  void initState() {
    _loadAllStations();
    super.initState();
    estimatedTimeService = EstimatedTimeService('pk.eyJ1IjoiYXljYWRpbmRhciIsImEiOiJjbHEwdGFyZmEwMXZsMmpsZnhjOWFya2VqIn0.WerEPzO_rkFSK2PlxfzJtA');
    _determinePosition().then((position) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      _startListeningLocation();
      _getNearbyStationsWithDistance(); // yakın istasyonları ve mesafelerini alır
    }).catchError((error) {
      print('Konum bilgisi alınamadı: $error');
    });
  }

  void _getNearbyStationsWithDistance() async {
    var stationsWithDistance = await stationService.getNearbyStationsWithDrivingDistance(_currentLocation);
    if (stationsWithDistance.isNotEmpty) {
      setState(() {
        nearbyStationsWithDistance = stationsWithDistance;
      });
    } else {
      print('Yakın istasyon bulunamadı veya mesafe bilgisi alınamadı.');
    }
  }

  void _calculateETA(LatLng destination) {
    LatLng origin = _currentLocation;

    // estimatedTimeService'ı kullanarak ETA hesaplanır
    estimatedTimeService.getEstimatedTime(origin, destination).then((eta) {
      setState(() {
        _estimatedTimeOfArrival = eta;
      });
    }).catchError((error) {
      setState(() {
        _estimatedTimeOfArrival = 'ETA hesaplanamadı';
      });
    });
  }

  void _onStationTap(LatLng stationPosition) {
    print("Selected station coordinates: ${stationPosition.latitude}, ${stationPosition.longitude}");
    setState(() {
      _destinationController.text = '${stationPosition.longitude}, ${stationPosition.latitude}';
      _getRoute(stationPosition: stationPosition); // Rota çizmek için _getRoute fonksiyonunu güncellenmiş haliyle çağırır
    });

    // İstasyon konumunu ETA hesaplamak için kullan
    _calculateETA(stationPosition);
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

  Future<void> _loadAllStations() async {
    var stationService = StationService();
    var stations = await stationService.fetchStations();
    setState(() {
      _allStations = stations;
    });
  }

  Future<List<dynamic>> fetchStations() async {
    final response = await rootBundle.loadString('assets/stations.json');
    return jsonDecode(response) as List;
  }

  List<LatLng> smoothPath(List<LatLng> points) {
    List<LatLng> smoothedPoints = [];
    for (int i = 0; i < points.length - 1; i++) {
      if (i == 0) { // İlk noktayı ekle.
        smoothedPoints.add(points[i]);
      }
      LatLng current = points[i];
      LatLng next = points[i + 1];

      // İki nokta arasına 10 ara nokta ekle.
      for (int j = 1; j <= 10; j++) {
        double lat = current.latitude + (next.latitude - current.latitude) * j / 10;
        double lng = current.longitude + (next.longitude - current.longitude) * j / 10;
        smoothedPoints.add(LatLng(lat, lng));
      }

      if (i == points.length - 2) { // Son noktayı ekle.
        smoothedPoints.add(points[i + 1]);
      }
    }
    return smoothedPoints;
  }

  void _calculateSlopes(LatLng destination) async {
    LatLng origin = _currentLocation;
    RouteElevation routeElevation = RouteElevation();
    List<double> slopes = await routeElevation.getRouteSlopes(origin, destination);

    for (int i = 0; i < slopes.length; i++) {
      print("Slope at segment $i: ${slopes[i]}");
    }
  }

  Future<void> _getRoute({LatLng? stationPosition}) async {
    try {
      LatLng start = _currentLocation;
      LatLng destination;

      if (stationPosition != null) {
        destination = stationPosition;
      } else {
        var destinationStr = _destinationController.text;
        if (destinationStr.isEmpty) {
          print("Destination is empty");
          return;
        }
        destination = await _directionsService.getCoordinatesFromAddress(destinationStr);
      }

      // API'den rota bilgisi al
      Map<String, dynamic> routeData = await _directionsService.getRoute(start, destination);
      print("Raw route data: $routeData");
      if (routeData['routes'] != null && routeData['routes'].isNotEmpty) {
        // Rota verisinden polyline çözümle
        Map<String, dynamic> geometry = routeData['routes'][0]['geometry'];
        print("Geometry: $geometry");
        List<LatLng> routeCoords = _directionsService.parsePolyline(geometry);
        print('Parsed polyline points: $routeCoords');

        List<LatLng> smoothedRouteCoords = smoothPath(routeCoords);

        // Polyline koordinatlarını haritada çiz
        setState(() {
          _routeCoords = smoothedRouteCoords;
          _mapController.move(destination, 15);
        });

        // Rota boyunca eğim verilerini al
        RouteElevation routeElevation = RouteElevation();
        try {
          List<double> slopes = await routeElevation.getRouteSlopes(start, destination);

          // Eğim verilerini güncelle
          setState(() {
            _routeSlopes = slopes;
          });

          print('Route slopes: $slopes');
        } catch (e) {
          print("Elevation error: $e");
        }
      } else {
        print("No route found");
      }
    } catch (e) {
      print("Rota alınırken hata: $e");
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
    // DefaultTabController ile Drawer'ı sarmalayın.
    return DefaultTabController(
      length: 2, // 2 sekme olacak
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            'Charge Center',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.green,
          automaticallyImplyLeading: false,
        ),
        drawer: Drawer(
          child: Column(
            children: [
              Container(
                color: Colors.green,
                height: 120.0,
                width: double.infinity,
                alignment: Alignment.center,
                child: Text(
                  'Charging Stations',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const TabBar(
                tabs: [
                  Tab(text: 'Nearby'),
                  Tab(text: 'All'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    ListView.builder(
                      itemCount: nearbyStationsWithDistance.length,
                      itemBuilder: (context, index) {
                        nearbyStationsWithDistance.sort((a, b) => a['distance'].compareTo(b['distance']));
                        var station = nearbyStationsWithDistance[index];
                        var stationPosition = LatLng(station['latitude'], station['longitude']);
                        return ListTile(
                            leading: Icon(Icons.electric_car),
                            title: Text(station['name']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${station['distance'].toStringAsFixed(1)} km'),
                                Text(station['address']),
                              ],
                            ),
                            onTap: () {
                              _onStationTap(stationPosition);
                              _showStationDetails(station);
                            }
                        );
                      },
                    ),
                    ListView.builder(
                      itemCount: _allStations.length,
                      itemBuilder: (context, index){
                        var station = _allStations[index];
                        return ListTile(
                          leading: Icon(Icons.electric_car),
                          title: Text(station['name']),
                          subtitle: Text('${station['address']}'),
                          onTap: () => _showStationDetails(station),
                        );
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
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
                StationMarkers(),
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
              child:
              FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _isNavigating = !_isNavigating;
                    if (_isNavigating) {
                      if (_destinationController.text.isEmpty) {
                        // Eğer hedef alanı boşsa uyarı ver ve navigasyonu başlatma
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please enter a destination.')),
                        );
                        _isNavigating = false; // Navigasyonu durdur
                        return;
                      }
                      // Hedef girilmişse, hedef konumu al ve rota ile ETA hesapla
                      _directionsService.getCoordinatesFromAddress(_destinationController.text).then((destination) {
                        _getRoute(stationPosition: destination);
                        _calculateETA(destination);
                      }).catchError((e) {
                        print('Hedef konum bilgisi alınamadı: $e');
                        _isNavigating = false; // Hata durumunda navigasyonu durdur
                      });
                    } else {
                      // Navigasyonu durdurduğunda, ETA bilgisini temizle
                      _estimatedTimeOfArrival = '';
                    }
                  });
                },
                child: Icon(_isNavigating ? Icons.pause : Icons.navigation),
                backgroundColor: _isNavigating ? Colors.red : Colors.green,
              ),
            ),
            Positioned(
              bottom: 20.0,
              left: 20.0,
              child: FloatingActionButton(
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
                child: Icon(Icons.electric_car),
                backgroundColor: Colors.green,
              ),
            ),
            if (_isNavigating && _estimatedTimeOfArrival.isNotEmpty)
              Positioned(
                bottom: 80.0,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4.0,
                          spreadRadius: 0.5,
                          offset: Offset(0.0, 1.0),
                        ),
                      ],
                    ),
                    child: Text(
                      'Estimated time of arrival: $_estimatedTimeOfArrival',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _routeSlopes.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('Segment ${index + 1}: Slope ${_routeSlopes[index]}'),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
