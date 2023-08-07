import 'package:fedcampus/utility/log.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  // TODO: keep tha paged version for now because of potential unexpected overridden
  // bahevior, and I might need to come back to this.
  const CalendarPage({
    super.key,
    required this.onDateChange,
  });

  final void Function(DateTime selectedDate) onDateChange;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final ValueNotifier<DateTime> _focusedDay = ValueNotifier(DateTime.now());
  void _onDateSelected(DateTime day, DateTime focusedDay) {
    // in general, `day` and `focusedDay` are the same, with few exceptions:
    // if you tap a day in previous month that is visable from current month,
    // `focusedDay` is first day of this month, while `day` is the actual day
    // tapped. The same applies to next month.
    logger.d(day);
    logger.d(focusedDay);
    widget.onDateChange(focusedDay);
    setState(() {
      _focusedDay.value = focusedDay;
    });
  }

  void _onPageChanged(DateTime day) {
    logger.d(day);
    // you should not use setState() in onPageChanged because focusedDay changes,
    // and if you call setState(), it triggers more updates than expectd: you
    // do not want your focus change on page change.
    _focusedDay.value = day;
    // here I use the same implementation under the hood as the source code of table_calendar,
    // the ValueNotifier is needed because the title should be notified while
    // others should not be triggered a rebuild.
    // you do not need to provide a ValueNotifier if you don't need to imeplement
    // a customized title.
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
              ValueListenableBuilder<DateTime>(
                valueListenable: _focusedDay,
                builder: (context, value, child) => Text(' ${value.month}'),
              ),
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
    required this.primaryColor,
  });

  final void Function(DateTime selectedDate) onDateChange;
  final Color primaryColor;

  @override
  State<CalendarDialog> createState() => _CalendarDialogState();
}

class _CalendarDialogState extends State<CalendarDialog> {
  late final ValueNotifier<DateTime> _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = ValueNotifier(DateTime.now());
  }

  @override
  void dispose() {
    _focusedDay.dispose();
    super.dispose();
  }

  void _onDateSelected(DateTime day, DateTime focusedDay) {
    widget.onDateChange(focusedDay);
    setState(() {
      _focusedDay.value = focusedDay;
    });
  }

  void _onPageChanged(DateTime day) {
    _focusedDay.value = day;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ValueListenableBuilder<DateTime>(
          valueListenable: _focusedDay,
          builder: (context, value, child) => Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Text(
              ' ${DateFormat.yMMMM('en_US').format(value)}',
              style:
                  TextStyle(color: Theme.of(context).colorScheme.surfaceTint),
            ),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        SizedBox(
          height: 200,
          child: TableCalendar(
            calendarBuilders: CalendarBuilders(
              dowBuilder: (context, day) {
                if (day.weekday == DateTime.sunday ||
                    day.weekday == DateTime.saturday) {
                  final text = DateFormat.E().format(day);
                  return Center(
                    child: Text(
                      text,
                      style: TextStyle(
                        color: widget.primaryColor,
                      ),
                    ),
                  );
                }
              },
            ),
            shouldFillViewport: true,
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
                // FIXME: https://github.com/aleksanderwozniak/table_calendar/issues/583
                // because I override deoration with rectangle, I need to set every decoration mannually,
                // not sure if any issues persist
                defaultDecoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5),
                ),
                weekendDecoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5),
                ),
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5),
                ),
                selectedDecoration: BoxDecoration(
                  color: widget.primaryColor,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5),
                ),
                weekendTextStyle: TextStyle(
                    color: widget.primaryColor),
                weekNumberTextStyle: TextStyle(color: Colors.amber)),
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            onFormatChanged: (format) => {},
            selectedDayPredicate: (day) => isSameDay(_focusedDay.value, day),
            focusedDay: _focusedDay.value,
            onDaySelected: _onDateSelected,
            onPageChanged: _onPageChanged,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Selected date:'),
            Text('${_focusedDay.value.month}/${_focusedDay.value.day}'),
          ],
        ),
      ],
    );
  }
}
