import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../models/event.dart';

class MapScreen extends StatefulWidget {
  final Event event;

  const MapScreen({super.key, required this.event});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapController _mapController;
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  Future<void> _getCurrentLocation(BuildContext context) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar(context, 'Please enable location services.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar(context, 'Location permission denied.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar(context, 'Location permissions are permanently denied.');
        return;
      }


      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
        ),
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });


      _mapController.move(_currentLocation!, 15.0);
      _showSnackBar(context, 'Current Location: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      _showSnackBar(context, 'Failed to get current location: $e');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: LatLng(widget.event.coordinates.latitude, widget.event.coordinates.longitude),
          zoom: 15.0,
          onTap: (tapPosition, point) {
            debugPrint('Map tapped at: $point');
          },
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(widget.event.coordinates.latitude, widget.event.coordinates.longitude),
                width: 80,
                height: 80,
                builder: (context) => Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              if (_currentLocation != null)
                Marker(
                  point: _currentLocation!,
                  width: 80,
                  height: 80,
                  builder: (context) => Icon(
                    Icons.my_location,
                    color: Colors.blue,
                    size: 40,
                  ),
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _getCurrentLocation(context),
        child: Icon(Icons.navigation),
      ),
    );
  }
}
