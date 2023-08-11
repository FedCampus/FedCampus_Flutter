import 'package:fedcampus/utility/log.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

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
    // in general, `day` and `focusedDay` are the same, with few exceptions:
    // if you tap a day in previous month that is visable from current month,
    // `focusedDay` is first day of this month, while `day` is the actual day
    // tapped. The same applies to next month.
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ValueListenableBuilder<DateTime>(
          valueListenable: _focusedDay,
          builder: (context, value, child) => Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            child: Text(
              ' ${DateFormat.yMMMM('en_US').format(value)}',
              style:
                  TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
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
                final text = DateFormat.E().format(day);
                if (day.weekday == DateTime.sunday ||
                    day.weekday == DateTime.saturday) {
                  return Center(
                    child: Text(
                      text,
                      style: TextStyle(
                        color: widget.primaryColor,
                      ),
                    ),
                  );
                }
                return Center(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                );
              },
            ),
            shouldFillViewport: true,
            headerVisible: false,
            calendarStyle: CalendarStyle(
              // FIXME: https://github.com/aleksanderwozniak/table_calendar/issues/583
              // because I override deoration with rectangle, I need to set every decoration mannually,
              // not sure if any issues persist
              defaultDecoration: textDecoration(
                  Theme.of(context).colorScheme.background),
              weekendDecoration: textDecoration(Theme.of(context).colorScheme.background),
              todayDecoration: textDecoration(
                  Theme.of(context).colorScheme.onSecondaryContainer),
              selectedDecoration: textDecoration(widget.primaryColor),
              defaultTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
              selectedTextStyle: TextStyle(color: Theme.of(context).colorScheme.background),
              weekendTextStyle: TextStyle(color: widget.primaryColor),
            ),
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

  BoxDecoration textDecoration(color) {
    return BoxDecoration(
      color: color,
      shape: BoxShape.rectangle,
      borderRadius: BorderRadius.circular(5),
    );
  }
}
