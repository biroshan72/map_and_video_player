import 'package:equatable/equatable.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

class MapInitialized extends MapEvent {
  final MaplibreMapController controller;

  const MapInitialized(this.controller);

  @override
  List<Object?> get props => [controller];
}

class LocationPinned extends MapEvent {
  final LatLng location;

  const LocationPinned(this.location);

  @override
  List<Object?> get props => [location];
}

class RouteRequested extends MapEvent {}

class RouteCleared extends MapEvent {}