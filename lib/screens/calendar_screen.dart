import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../services/points_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late PointsService _pointsService;
  Set<DateTime> _completedDays = {};

  @override
  void initState() {
    super.initState();
    _pointsService = context.read<PointsService>();
    _loadCompletedDays();
    _pointsService.addListener(_loadCompletedDays); // Reload if dates change
  }

  @override
  void dispose() {
    _pointsService.removeListener(_loadCompletedDays);
    super.dispose();
  }

  void _loadCompletedDays() {
    final dateStrings = _pointsService.getCompletedDates();
    setState(() {
      _completedDays = dateStrings.map((str) => DateTime.parse(str)).toSet();
    });
  }

  // Function to determine if a day should be marked as completed
  bool _isDayCompleted(DateTime day) {
    // Normalize day to ignore time component for comparison
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _completedDays.contains(normalizedDay);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Calendar'),
        // Theme handles styling
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1), // Allow scrolling back
            lastDay: DateTime.utc(
                DateTime.now().year + 1, 12, 31), // Allow scrolling forward
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              // Optional: Logic for selecting a day
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              // Optional: Handle day selection
              // if (!isSameDay(_selectedDay, selectedDay)) {
              //   setState(() {
              //     _selectedDay = selectedDay;
              //     _focusedDay = focusedDay;
              //   });
              // }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                // Use markerBuilder to add our custom completion marker (e.g., a star)
                if (_isDayCompleted(day)) {
                  return Positioned(
                    right: 1,
                    bottom: 1,
                    child: Icon(
                      Icons.star,
                      size: 16.0,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  );
                }
                return null; // Return null if no marker needed
              },
            ),
            calendarStyle: CalendarStyle(
              // Customize appearance
              todayDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                  // Default marker style if using events (we use markerBuilder instead)
                  // color: Colors.blue,
                  // shape: BoxShape.circle,
                  ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false, // Hide format button (Month/Week)
              titleCentered: true,
            ),
          ),
          // Optional: Add a legend or summary below the calendar
        ],
      ),
    );
  }
}
