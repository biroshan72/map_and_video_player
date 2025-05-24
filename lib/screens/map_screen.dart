import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import '../blocs/map/map_bloc.dart';
import '../blocs/map/map_event.dart';
import '../blocs/map/map_state.dart';
import '../models/direction_response.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapLibreMapController? _controller;
  final Set<Symbol> _symbols = {};
  final Set<Line> _lines = {};

  final  accessToken = dotenv.env['BAATO_API_KEY'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Baato Map Directions'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              context.read<MapBloc>().add(RouteCleared());
              _clearMap();
            },
          ),
        ],
      ),
      body: BlocConsumer<MapBloc, MapState>(
        listener: (context, state) {
          if (state is MapReady) {
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.error}'),
                  backgroundColor: Colors.red,
                ),
              );
            }

            if (state.route != null && _controller != null) {
              _drawRoute(state.route!);
            }

            _updateMarkers(state);
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              MapLibreMap(
                styleString: 'https://api.baato.io/api/v1/styles/breeze?key=$accessToken',

                onMapCreated: (MapLibreMapController controller) {
                  _controller = controller;
                  context.read<MapBloc>().add(MapInitialized(controller));
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(27.7172, 85.3240), // Kathmandu coordinates
                  zoom: 12.0,
                ),
                onMapClick: (point, coordinates) {
                  context.read<MapBloc>().add(LocationPinned(coordinates));
                },
                compassEnabled: true,
                myLocationEnabled: true,
              ),
              if (state is MapReady && state.isLoading)
                Container(
                  color: Colors.black26,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              _buildInfoPanel(state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoPanel(MapState state) {
    if (state is! MapReady) return SizedBox.shrink();

    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Instructions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('1. Tap on map to set start point'),
              Text('2. Tap again to set end point'),
              Text('3. Route will be drawn automatically'),
              if (state.startPoint != null) ...[
                SizedBox(height: 8),
                Text(
                  'Start: ${state.startPoint!.latitude.toStringAsFixed(4)}, ${state.startPoint!.longitude.toStringAsFixed(4)}',
                  style: TextStyle(color: Colors.green),
                ),
              ],
              if (state.endPoint != null) ...[
                Text(
                  'End: ${state.endPoint!.latitude.toStringAsFixed(4)}, ${state.endPoint!.longitude.toStringAsFixed(4)}',
                  style: TextStyle(color: Colors.red),
                ),
              ],
              if (state.route != null) ...[
                SizedBox(height: 8),
                Text(
                  'Distance: ${(state.route!.totalDistance / 1000).toStringAsFixed(2)} km',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Time: ${(state.route!.totalTime / 60000).toStringAsFixed(0)} minutes',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _updateMarkers(MapReady state) async {
    if (_controller == null) return;

    // Clear existing symbols
    for (final symbol in _symbols) {
      await _controller!.removeSymbol(symbol);
    }
    _symbols.clear();

    // Add start point marker
    if (state.startPoint != null) {
      final startSymbol = await _controller!.addSymbol(
        SymbolOptions(
          geometry: state.startPoint!,
          iconImage: 'marker_15',
          iconColor: '#00FF00', // Green
          iconSize: 2.0,
        ),
      );
      _symbols.add(startSymbol);
    }

    // Add end point marker
    if (state.endPoint != null) {
      final endSymbol = await _controller!.addSymbol(
        SymbolOptions(
          geometry: state.endPoint!,
          iconImage: 'marker_15',
          iconColor: '#FF0000', // Red
          iconSize: 2.0,
        ),
      );
      _symbols.add(endSymbol);
    }
  }

  void _drawRoute(DirectionResponse route) async {
    if (_controller == null || route.routes.isEmpty) return;

    // Ensure the route has valid coordinates
    final coordinates = route.routes.first.coordinates;
    if (coordinates.isEmpty) {
      print('No coordinates available to draw the route.');
      return;
    }

    // Clear existing lines
    for (final line in _lines) {
      await _controller!.removeLine(line);
    }
    _lines.clear();

    // Draw route polyline
    final routeLine = await _controller!.addLine(
      LineOptions(
        geometry: coordinates,
        lineColor: '#0066CC',
        lineWidth: 5.0,
        lineOpacity: 0.8,
      ),
    );
    _lines.add(routeLine);

    // Fit camera to show entire route
    await _controller!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            coordinates.map((e) => e.latitude).reduce((a, b) => a < b ? a : b),
            coordinates.map((e) => e.longitude).reduce((a, b) => a < b ? a : b),
          ),
          northeast: LatLng(
            coordinates.map((e) => e.latitude).reduce((a, b) => a > b ? a : b),
            coordinates.map((e) => e.longitude).reduce((a, b) => a > b ? a : b),
          ),
        ),
        left: 50.0,
        top: 50.0,
        right: 50.0,
        bottom: 50.0,
      ),
    );
  }

  void _clearMap() async {
    if (_controller == null) return;

    // Clear symbols
    for (final symbol in _symbols) {
      await _controller!.removeSymbol(symbol);
    }
    _symbols.clear();

    // Clear lines
    for (final line in _lines) {
      await _controller!.removeLine(line);
    }
    _lines.clear();
  }

  @override
  void dispose() {
    _clearMap();
    super.dispose();
  }
}