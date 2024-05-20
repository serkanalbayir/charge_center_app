import 'package:latlong2/latlong.dart';
import 'services/directions_service.dart';
import 'services/elevation_service.dart';
import 'dart:math' as math;

class RouteElevation {
  final DirectionsService _directionsService = DirectionsService();
  final ElevationService _elevationService = ElevationService();

  Future<List<double>> getRouteSlopes(LatLng start, LatLng destination) async {
    // Rota bilgilerini al
    Map<String, dynamic> routeData = await _directionsService.getRoute(start, destination);

    if (routeData['routes'] == null || routeData['routes'].isEmpty) {
      throw Exception('No routes found');
    }

    // Rota üzerindeki koordinatları al
    List<LatLng> routeCoords = _directionsService.parsePolyline(routeData['routes'][0]['geometry']);

    List<double> slopes = [];

    for (int i = 0; i < routeCoords.length - 1; i++) {
      LatLng current = routeCoords[i];
      LatLng next = routeCoords[i + 1];

      try {
        // Yükseklik verilerini al
        double elevation1 = await _elevationService.getElevation(current.latitude, current.longitude);
        double elevation2 = await _elevationService.getElevation(next.latitude, next.longitude);

        print('Elevation at current location ${current.latitude}, ${current.longitude}: $elevation1');
        print('Elevation at next point ${next.latitude}, ${next.longitude}: $elevation2');

        // Yatay mesafe hesaplama
        double deltaLat = next.latitude - current.latitude;
        double deltaLon = next.longitude - current.longitude;

        double metersPerDegLat = 111320;
        double metersPerDegLon = 111320 * math.cos(_radians(current.latitude));

        double deltaLatM = deltaLat * metersPerDegLat;
        double deltaLonM = deltaLon * metersPerDegLon;

        double horizontalDistance = math.sqrt(deltaLatM * deltaLatM + deltaLonM * deltaLonM);

        // Yükseklik farkı
        double deltaHeight = elevation1 - elevation2;

        // Eğim açısını hesapla
        double slopeAngle = _degrees(math.atan(deltaHeight / horizontalDistance));
        slopes.add(slopeAngle);
      } catch (e) {
        print("Elevation error for segment $i: $e");
        slopes.add(0.0); // Yükseklik verisi alınamazsa eğimi 0 olarak ayarla
      }
    }

    return slopes;
  }

  double _degrees(double radians) => radians * 180 / math.pi;
  double _radians(double degrees) => degrees * math.pi / 180;
}