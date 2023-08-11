import 'package:fedcampus/view/widgets/widget.dart';
import 'package:flutter/material.dart';

import '../calendar.dart';

class Date extends StatelessWidget {
  const Date({
    super.key,
    required this.fem,
    required this.date,
    required this.onDateChange,
  });

  final double fem;
  final DateTime date;
  final void Function(DateTime selectedDate) onDateChange;

  @override
  Widget build(BuildContext context) {
    Future<bool?> calendarDialog() {
      return showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Select a day"),
            content: CalendarDialog(
              onDateChange: onDateChange,
              primaryColor: Theme.of(context).colorScheme.primaryContainer,
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("Confirm"),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow,
            offset: Offset(0 * fem, 4 * fem),
            blurRadius: 2 * fem,
          ),
          BoxShadow(
            color: Theme.of(context).colorScheme.outline,
            offset: Offset(0 * fem, -1 * fem),
            blurRadius: 1 * fem,
          ),
          BoxShadow(
            color: Theme.of(context).colorScheme.outline,
            offset: Offset(0 * fem, 4 * fem),
            blurRadius: 2 * fem,
          ),
        ],
      ),
      child: TextButton(
        onPressed: () => Future.delayed(const Duration(milliseconds: 140))
            .then((value) => calendarDialog()),
        style: TextButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.background,
          padding: EdgeInsets.fromLTRB(14 * fem, 18 * fem, 14 * fem, 17 * fem),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            FedIcon(fem: fem, imagePath: 'assets/images/health_nav_icon.png'),
            SizedBox(
              width: 11 * fem,
            ),
            SizedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin:
                        EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 5 * fem),
                    child: Text(
                      '${date.month}/${date.day}',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary),
                    ),
                  ),
                  Text(
                    '2023',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
