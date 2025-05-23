import 'package:baato_maps/baato_maps.dart';
import 'package:equatable/equatable.dart';

class DirectionResponse extends Equatable {
  final List<RouteGeometry> routes;
  final double totalDistance;
  final double totalTime;

  const DirectionResponse({
    required this.routes,
    required this.totalDistance,
    required this.totalTime,
  });

  factory DirectionResponse.fromJson(Map<String, dynamic> json) {
    return DirectionResponse(
      routes: (json['data'] as List?)
          ?.map((route) => RouteGeometry.fromJson(route))
          .toList() ?? [],
      totalDistance: (json['data']?[0]?['distanceInMeters'] ?? 0).toDouble(),
      totalTime: (json['data']?[0]?['timeInMs'] ?? 0).toDouble(),
    );
  }

  @override
  List<Object?> get props => [routes, totalDistance, totalTime];
}

class RouteGeometry extends Equatable {
  final String encodedPolyline;
  final List<LatLng> coordinates;
  final double distance;
  final double time;

  const RouteGeometry({
    required this.encodedPolyline,
    required this.coordinates,
    required this.distance,
    required this.time,
  });

  factory RouteGeometry.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'] as String? ?? '';
    final coordinates = _decodePolyline(geometry);

    return RouteGeometry(
      encodedPolyline: geometry,
      coordinates: coordinates,
      distance: (json['distanceInMeters'] ?? 0).toDouble(),
      time: (json['timeInMs'] ?? 0).toDouble(),
    );
  }

  static List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  @override
  List<Object?> get props => [encodedPolyline, coordinates, distance, time];
}