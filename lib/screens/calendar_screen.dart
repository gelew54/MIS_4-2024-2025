import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../models/event.dart';
import 'map_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late Map<DateTime, List<Event>> _events;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _events = _loadEvents();
  }

  Map<DateTime, List<Event>> _loadEvents() {
    return {
      DateTime(2025, 1, 20): [
        Event(
          date: DateTime(2025, 1, 20, 10, 0),
          time: '10:00 AM',
          location: 'Room 101',
          coordinates: LatLng(41.9981, 21.4254),
          category: 'Work',
        ),
        Event(
          date: DateTime(2025, 1, 20, 14, 0),
          time: '2:00 PM',
          location: 'Room 102',
          coordinates: LatLng(41.9985, 21.4260),
          category: 'Meeting',
        ),
      ],
      DateTime(2025, 1, 21): [
        Event(
          date: DateTime(2025, 1, 21, 12, 0),
          time: '12:00 PM',
          location: 'Room 202',
          coordinates: LatLng(41.9991, 21.4274),
          category: 'Lecture',
        ),
      ],
    };
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month - 1,
                );
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month + 1,
                );
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: SfCalendar(
              view: CalendarView.month,
              dataSource: EventDataSource(_getAllEvents()),
              onSelectionChanged: (details) {
                setState(() {
                  _selectedDate = _normalizeDate(details.date!);
                });
              },
              monthCellBuilder: (BuildContext context, MonthCellDetails details) {
                final normalizedDate = _normalizeDate(details.date);
                final today = _normalizeDate(DateTime.now());
                final hasEvents = _events[normalizedDate]?.isNotEmpty ?? false;
                final isToday = normalizedDate == today;

                return Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isToday
                        ? Colors.blueAccent.withOpacity(0.8)
                        : Colors.transparent,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        details.date.day.toString(),
                        style: TextStyle(
                          color: isToday ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (hasEvents)
                        Positioned(
                          bottom: 4,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: _events[normalizedDate]!
                                .map((e) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _getCategoryColor(e.category),
                                shape: BoxShape.circle,
                              ),
                            ))
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          Expanded(
            flex: 3,
            child: _events[_selectedDate]?.isNotEmpty == true
                ? ListView(
              children: _events[_selectedDate]!
                  .map(
                    (event) => Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: ListTile(
                    leading: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(event.category),
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(event.location,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${event.time}'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapScreen(event: event),
                        ),
                      );
                    },
                  ),
                ),
              )
                  .toList(),
            )
                : const Center(
              child: Text('No events for this day'),
            ),
          ),
        ],
      ),
    );
  }

  List<Event> _getAllEvents() {
    return _events.values.expand((eventList) => eventList).toList();
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Work':
        return Colors.blue;
      case 'Meeting':
        return Colors.green;
      case 'Lecture':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

class EventDataSource extends CalendarDataSource {
  EventDataSource(List<Event> events) {
    appointments = events;
  }

  @override
  DateTime getStartTime(int index) {
    if (appointments == null || index >= appointments!.length) {
      return DateTime.now();
    }
    return appointments![index].date;
  }

  @override
  DateTime getEndTime(int index) {
    if (appointments == null || index >= appointments!.length) {
      return DateTime.now().add(const Duration(hours: 1));
    }
    return appointments![index].date.add(const Duration(hours: 1));
  }

  @override
  String getSubject(int index) {
    if (appointments == null || index >= appointments!.length) {
      return 'No Subject';
    }
    return appointments![index].location;
  }
}
