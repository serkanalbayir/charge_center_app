import 'package:http/http.dart' as http;
import 'dart:convert';

class ElevationService {
  final String apiKey = '';

  Future<double> getElevation(double latitude, double longitude) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/elevation/json?locations=$latitude,$longitude&key=$apiKey');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final elevation = jsonResponse['results'][0]['elevation'];
      return elevation;
    } else {
      throw Exception('Failed to load elevation data');
    }
  }
}
