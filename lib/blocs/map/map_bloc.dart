import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/baato_service.dart';
import 'map_event.dart';
import 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final BaatoService _baatoService;

  MapBloc(this._baatoService) : super(MapInitial()) {
    on<MapInitialized>(_onMapInitialized);
    on<LocationPinned>(_onLocationPinned);
    on<RouteRequested>(_onRouteRequested);
    on<RouteCleared>(_onRouteCleared);
  }

  void _onMapInitialized(MapInitialized event, Emitter<MapState> emit) {
    emit(MapReady(controller: event.controller));
  }

  void _onLocationPinned(LocationPinned event, Emitter<MapState> emit) {
    if (state is MapReady) {
      final currentState = state as MapReady;

      if (currentState.startPoint == null) {
        // Set as start point
        emit(currentState.copyWith(
          startPoint: event.location,
          clearError: true,
        ));
      } else if (currentState.endPoint == null) {
        // Set as end point
        emit(currentState.copyWith(
          endPoint: event.location,
          clearError: true,
        ));
        // Automatically request route when both points are set
        add(RouteRequested());
      } else {
        // Reset and set new start point
        emit(currentState.copyWith(
          startPoint: event.location,
          clearEndPoint: true,
          clearRoute: true,
          clearError: true,
        ));
      }
    }
  }

  void _onRouteRequested(RouteRequested event, Emitter<MapState> emit) async {
    if (state is MapReady) {
      final currentState = state as MapReady;

      if (currentState.startPoint != null && currentState.endPoint != null) {
        emit(currentState.copyWith(isLoading: true, clearError: true));

        try {
          final route = await _baatoService.getDirections(
            start: currentState.startPoint!,
            end: currentState.endPoint!,
          );

          emit(currentState.copyWith(
            route: route,
            isLoading: false,
          ));
        } catch (e) {
          emit(currentState.copyWith(
            isLoading: false,
            error: e.toString(),
          ));
        }
      }
    }
  }

  void _onRouteCleared(RouteCleared event, Emitter<MapState> emit) {
    if (state is MapReady) {
      final currentState = state as MapReady;
      emit(currentState.copyWith(
        clearStartPoint: true,
        clearEndPoint: true,
        clearRoute: true,
        clearError: true,
      ));
    }
  }
}