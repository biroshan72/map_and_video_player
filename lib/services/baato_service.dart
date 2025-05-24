import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:maplibre_gl/maplibre_gl.dart';
import '../models/direction_response.dart';

class BaatoService {
  static const String _baseUrl = 'https://api.baato.io/api/v1';

  final  _accessToken = dotenv.env['BAATO_API_KEY'];


  Future<DirectionResponse> getDirections({
    required LatLng start,
    required LatLng end,
    String mode = 'car',
  }) async {
    try {
      final url = Uri.parse(
          '$_baseUrl/directions?key=$_accessToken&points[]=${start.latitude},${start.longitude}&points[]=${end.latitude},${end.longitude}&mode=$mode'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return DirectionResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to get directions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting directions: $e');
    }
  }
}