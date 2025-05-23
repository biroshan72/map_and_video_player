import 'package:equatable/equatable.dart';
import 'location.dart';

class RouteData extends Equatable {
  final List<Location> coordinates;
  final double distance;
  final int duration;
  final String geometry;

  const RouteData({
    required this.coordinates,
    required this.distance,
    required this.duration,
    required this.geometry,
  });

  @override
  List<Object> get props => [coordinates, distance, duration, geometry];

  factory RouteData.fromJson(Map<String, dynamic> json) {
    final List<dynamic> coords = json['geometry']['coordinates'] ?? [];
    final List<Location> locations = coords.map((coord) {
      return Location(
        longitude: coord[0]?.toDouble() ?? 0.0,
        latitude: coord[1]?.toDouble() ?? 0.0,
      );
    }).toList();

    return RouteData(
      coordinates: locations,
      distance: json['distance']?.toDouble() ?? 0.0,
      duration: json['duration']?.toInt() ?? 0,
      geometry: json['geometry']['coordinates'].toString(),
    );
  }
}