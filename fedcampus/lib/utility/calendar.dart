DateTime findWeekFirstDay(DateTime dateTime) {
  int weekDay = dateTime.weekday;
  return dateTime.subtract(Duration(days: weekDay - 1));
}

DateTime findWeekLastDay(DateTime dateTime) {
  int weekDay = dateTime.weekday;
  return dateTime.add(Duration(days: -weekDay + 7));
}

int dateTimeToInt(DateTime dateTime) {
  return dateTime.year * 10000 + dateTime.month * 100 + dateTime.day;
}

DateTime intToDateTime(int dateCode) {
  return DateTime(dateCode ~/ 10000, (dateCode % 10000) ~/ 100, dateCode % 100);
}
