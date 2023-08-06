import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Calendar extends ChangeNotifier {
  var calendar = 20230805;

  void changeCalendar(int calendarNew) {
    this.calendar = calendarNew;
    notifyListeners();
  }
}

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    // throw UnimplementedError();
    return ChangeNotifierProvider(
        create: (context) => Calendar(),
        child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            body: Center(
                child: Column(
              children: [Text("report page"), CalendarWidget()],
            ))));
  }
}

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({super.key});

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
    print("disposed");
  }

  void changeCalendar(Calendar calendarState) {
    int value = int.parse(myController.value.text);
    calendarState.changeCalendar(value);
  }

  @override
  Widget build(BuildContext context) {
    var calendarState = context.watch<Calendar>();
    // TODO: implement build
    return Column(
      children: [
        Text(calendarState.calendar.toString()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextFormField(
            controller: myController,
            onEditingComplete: () => {changeCalendar(calendarState)},
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Enter calendar',
            ),
          ),
        ),
      ],
    );
  }
}
