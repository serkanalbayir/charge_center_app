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
import 'review_page.dart';
import 'models/_station.dart';
import 'widgets/station_details_bottom_sheet.dart';
import 'filter_page.dart';

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
  List<Station> _allStations = [];
  String _estimatedTimeOfArrival = '';
  bool _drawerOpen = false;
  List<dynamic> stations = [];
  late LatLng _currentLocation;
  List<LatLng> _routeCoords = [];
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

  Future<void> showStationDetails(BuildContext context, Station station, Future<void> Function({LatLng? stationPosition}) getRouteFunction, TextEditingController destinationController) async {
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
                        onPressed: () async {
                          print('Route button clicked for station: ${station.name}');
                          Navigator.pop(context); // BottomSheet'i kapat
                          destinationController.text = '${station.longitude}, ${station.latitude}'; // Koordinatları destinationController'a atama
                          await getRouteFunction(stationPosition: LatLng(station.latitude, station.longitude)); // Rota oluştur
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightGreen,
                        ),
                        child: Text('Route'),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MyHomePage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
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

  @override
  void initState() {
    _loadAllStations();
    super.initState();
    estimatedTimeService = EstimatedTimeService('');
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
      _allStations = stations.map((station) => Station.fromJson(station)).toList();
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
          _mapController.move(_currentLocation, 16);
        });

        // Rota boyunca eğim verilerini al
        // Eğim verilerini güncelle
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

  Future<void> _showStationDetails(BuildContext context, Station station, Future<void> Function({LatLng? stationPosition}) getRouteFunction, TextEditingController destinationController) async {
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
                        onPressed: () async {
                          print('Route button clicked for station: ${station.name}');
                          Navigator.pop(context); // BottomSheet'i kapat
                          destinationController.text = '${station.longitude}, ${station.latitude}'; // Koordinatları destinationController'a atama
                          await getRouteFunction(stationPosition: LatLng(station.latitude, station.longitude)); // Rota oluştur
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightGreen,
                        ),
                        child: Text('Route'),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          print('Add Review button clicked for station: ${station.name}');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
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
          actions: [
            IconButton(
              icon: Icon(Icons.filter_list),
              color: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            )
          ],
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
                            showStationDetails(
                              context,
                              Station.fromJson(station),
                              _getRoute,
                              _destinationController,
                            ); // `showStationDetails` fonksiyonunu çağır
                          },
                        );
                      },
                    ),
                    ListView.builder(
                      itemCount: _allStations.length,
                      itemBuilder: (context, index){
                        var station = _allStations[index];
                        return ListTile(
                          leading: Icon(Icons.electric_car),
                          title: Text(station.name),
                          subtitle: Text(station.address),
                          onTap: () => showStationDetails(context, station, _getRoute, _destinationController), // `showStationDetails` fonksiyonunu çağır
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
                  urlTemplate: 'https://api.mapbox.com/styles/v1/aycadindar/clte7lvwx00mb01qng59z2cig/tiles/256/{z}/{x}/{y}@2x?access_token=',
                  additionalOptions: {
                    'accessToken': '',
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
                        child: Icon(
                          Icons.location_on,
                          size: 50,
                          color: Colors.red,),
                      ),
                    ),
                  ],
                ),
                StationMarkers(
                  stations: _allStations,
                  onMarkerTap: (station) => showStationDetails(context, station, _getRoute, _destinationController),
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
                      _mapController.move(_currentLocation, 16);

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
          ],
        ),
      ),
    );
  }
}
