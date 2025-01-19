import 'package:google_maps_flutter/google_maps_flutter.dart';

class Event {
  final DateTime date;
  final String time;
  final String location;
  final LatLng coordinates;
  final String category;

  Event({
    required this.date,
    required this.time,
    required this.location,
    required this.coordinates,
    required this.category,
  });
}
