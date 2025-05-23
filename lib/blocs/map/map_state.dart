import 'package:equatable/equatable.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import '../../models/direction_response.dart';

abstract class MapState extends Equatable {
  const MapState();

  @override
  List<Object?> get props => [];
}

class MapInitial extends MapState {}

class MapReady extends MapState {
  final MaplibreMapController? controller;
  final LatLng? startPoint;
  final LatLng? endPoint;
  final DirectionResponse? route;
  final bool isLoading;
  final String? error;

  const MapReady({
    this.controller,
    this.startPoint,
    this.endPoint,
    this.route,
    this.isLoading = false,
    this.error,
  });

  MapReady copyWith({
    MaplibreMapController? controller,
    LatLng? startPoint,
    LatLng? endPoint,
    DirectionResponse? route,
    bool? isLoading,
    String? error,
    bool clearStartPoint = false,
    bool clearEndPoint = false,
    bool clearRoute = false,
    bool clearError = false,
  }) {
    return MapReady(
      controller: controller ?? this.controller,
      startPoint: clearStartPoint ? null : (startPoint ?? this.startPoint),
      endPoint: clearEndPoint ? null : (endPoint ?? this.endPoint),
      route: clearRoute ? null : (route ?? this.route),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [controller, startPoint, endPoint, route, isLoading, error];
}