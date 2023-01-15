import 'package:intl/intl.dart';

DateTime getDateFromDateTime(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day);
}

bool isSameDate(DateTime dt1, DateTime dt2) {
  return getDateFromDateTime(dt1).compareTo(getDateFromDateTime(dt2)) == 0;
}

DateTime getFirstDayOfCurrentWeek() {
  final dateTime = DateTime.now();

  return dateTime.subtract(Duration(days: dateTime.weekday - 1));
}

DateTime getLastDayOfNextWeek() {
  final fstDayCurrWeek = getFirstDayOfCurrentWeek();

  return fstDayCurrWeek.add(Duration(days: 13));
}

String getDayNameFromDateTime(DateTime dateTime) {
  return DateFormat('EEEE').format(dateTime);
}
