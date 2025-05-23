import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:maplibre_gl/maplibre_gl.dart';
import '../models/direction_response.dart';

class BaatoService {
  static const String _baseUrl = 'https://api.baato.io/api/v1';
  static const String _accessToken = 'bpk.nMaAdtNAPD2vjKNgasqVRQKccb2sfZeLal_Px6kwl_kA'; // Replace with your token

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