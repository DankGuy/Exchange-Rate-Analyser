import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarView extends StatefulWidget {
  final ValueChanged<DateTime> onDaySelected;

  const CalendarView({super.key, required this.onDaySelected});

  @override
  State<CalendarView> createState() => _CalendarViewState();

  // to provide method for other class to access the state
  // ignore: library_private_types_in_public_api
  static _CalendarViewState? of(BuildContext context) {
    return context.findAncestorStateOfType<_CalendarViewState>();
  }
}

class _CalendarViewState extends State<CalendarView> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      headerStyle: const HeaderStyle(titleCentered: true),
      firstDay: DateTime.utc(2010, 1, 1),
      lastDay: DateTime.now(),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });

        // Call the callback and pass the selected day
        widget.onDaySelected(selectedDay);
      },
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
    );
  }

  DateTime get selectedDay => _selectedDay!;
}
