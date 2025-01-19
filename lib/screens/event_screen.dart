import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/event.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  List<Event> eventList = [];

  DateTime eventDate = DateTime.now();
  String eventTime = '10:00 AM';
  String eventLocation = 'Room 101';
  LatLng eventCoordinates = const LatLng(41.9981, 21.4254);

  void addEvent() {
    setState(() {
      eventList.add(
        Event(
          date: eventDate,
          time: eventTime,
          location: eventLocation,
          coordinates: eventCoordinates, category: '',
        ),
      );
    });
  }

  void showEvents() {
    for (var event in eventList) {
      debugPrint('Event Date: ${event.date}');
      debugPrint('Event Time: ${event.time}');
      debugPrint('Event Location: ${event.location}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: addEvent,
            child: const Text('Add Event'),
          ),
          ElevatedButton(
            onPressed: showEvents,
            child: const Text('Show Events'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: eventList.length,
              itemBuilder: (context, index) {
                final event = eventList[index];
                return ListTile(
                  title: Text(event.location),
                  subtitle: Text('${event.date.toLocal()} - ${event.time}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
