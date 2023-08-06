import 'package:fedcampus/utility/log.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({
    super.key,
    required this.onDateChange,
  });

  final void Function(DateTime selectedDate) onDateChange;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime today = DateTime.now();
  // DateTime focusDay = DateTime.now();
  late final ValueNotifier<DateTime> _focusedDay =
      ValueNotifier(DateTime.now());
  void _onDateSelected(DateTime day, DateTime focusedDay) {
    // logger.d(today);
    // logger.d(day);
    // logger.d(focusedDay);
    widget.onDateChange(day);
    setState(() {
      // focusDay = day;
      _focusedDay.value = focusedDay;
    });
  }

  void _onPageChanged(DateTime day) {
    logger.d(day);
    _focusedDay.value = day;

    // focusDay = day;
    // setState(() {});
    // setState(() {
    //   focusDay = day;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Column(
        children: [
          TableCalendar(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              onFormatChanged: (format) => {},
              selectedDayPredicate: (day) => isSameDay(day, _focusedDay.value),
              focusedDay: _focusedDay.value,
              onPageChanged: _onPageChanged,
              onDaySelected: _onDateSelected),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Selected date:'),
              Text('${_focusedDay.value.month}/${_focusedDay.value.day}'),
              Text('   ${_focusedDay.value.month}'),
              ValueListenableBuilder<DateTime>(
                valueListenable: _focusedDay,
                builder: (context, value, child) => Text('   ${value.month}'),
              )
            ],
          ),
          ElevatedButton(
              onPressed: Navigator.of(context).pop,
              child: const Text('Confirm'))
        ],
      ),
    );
  }
}

class CalendarDialog extends StatefulWidget {
  const CalendarDialog({
    super.key,
    required this.onDateChange,
  });

  final void Function(DateTime selectedDate) onDateChange;

  @override
  State<CalendarDialog> createState() => _CalendarDialogState();
}

class _CalendarDialogState extends State<CalendarDialog> {
  DateTime today = DateTime.now();
  DateTime focusDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  void _onDateSelected(DateTime day, DateTime focusedDay) {
    logger.d(day);
    logger.d(focusedDay);
    widget.onDateChange(day);
    // setState(() {
    //   today = day;
    // });
  }

  void _onPageChanged(DateTime day) {
    setState(() {
      focusDay = day;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
            child: Text(_focusedDay.month.toString())),
        TableCalendar(
          headerVisible: false,
          // headerStyle: HeaderStyle(
          //     titleCentered: true,
          //     formatButtonVisible: false,
          //     leftChevronVisible: false,
          //     rightChevronVisible: false,
          //     titleTextStyle: TextStyle(
          //         color: Theme.of(context).colorScheme.background,
          //         backgroundColor:
          //             Theme.of(context).colorScheme.primaryContainer)),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                shape: BoxShape.circle),
            selectedDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle),
          ),
          firstDay: DateTime.utc(2010, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          onFormatChanged: (format) => {},
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          // focusedDay: today,
          focusedDay: _focusedDay,
          // onPageChanged: _onPageChanged,
          onPageChanged: (focusedDay) {
            // No need to call `setState()` here
            setState(() {
              _focusedDay = focusedDay;
            });
          },
          // onDaySelected: _onDateSelected,
          onDaySelected: (selectedDay, focusedDay) {
            if (!isSameDay(_selectedDay, selectedDay)) {
              // Call `setState()` when updating the selected day
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            }
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Selected date:'),
            Text('${_focusedDay.month}/${_focusedDay.day}'),
          ],
        ),
      ],
    );
  }
}

class TableBasicsExample extends StatefulWidget {
  @override
  _TableBasicsExampleState createState() => _TableBasicsExampleState();
}

class _TableBasicsExampleState extends State<TableBasicsExample> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TableCalendar - Basics'),
      ),
      body: TableCalendar(
        firstDay: DateTime.utc(2010, 10, 16),
        lastDay: DateTime.utc(2030, 3, 14),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) {
          // Use `selectedDayPredicate` to determine which day is currently selected.
          // If this returns true, then `day` will be marked as selected.

          // Using `isSameDay` is recommended to disregard
          // the time-part of compared DateTime objects.
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay, selectedDay)) {
            // Call `setState()` when updating the selected day
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          }
        },
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            // Call `setState()` when updating calendar format
            setState(() {
              _calendarFormat = format;
            });
          }
        },
        onPageChanged: (focusedDay) {
          // No need to call `setState()` here
          _focusedDay = focusedDay;
        },
      ),
    );
  }
}
