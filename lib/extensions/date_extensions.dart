import 'package:dart_date/dart_date.dart';
import 'package:intl/intl.dart';

typedef IncDate = DateTime Function(DateTime date, int delta);

extension DateExtension on DateTime {
  bool get isTopOfHour {
    return minute == 0;
  }
  DateTime get startOfQuarter {
     return DateTime(year, (quarter-1) * 3 + 1, 1);
  }

  DateTime get endOfQuarter {
     return startOfQuarter.addMonths(3).incDays(-1);
  }

  bool get isStartOfQuarter {
    return startOfQuarter == this;
  }

  bool get isEndOfQuarter {
    return endOfQuarter == this;
  }

  bool get isStartOfMonth {
    return startOfMonth == startOfDay;
  }

  bool get isStartOfWeek {
    return startOfWeek == this;
  }

  bool get isStartOfYear {
    return startOfYear == this;
  }

  bool get isStartOfDay {
    return startOfDay == this;
  }

  int get quarter {
    return (month + 2)~/3;
  }

  double get totalMinutes {
    double result = hour * 60 + minute + second / 60;
    return result;
  }

  String get formatHour {
      return DateFormat(DateFormat.HOUR).format(this);
  }

  int get daysInMonth {
     switch (month) {
       case 1: return 31;
       case 2: return isLeapYear ? 29 :28;
       case 3: return 31;
       case 4: return 30;
       case 5: return 31;
       case 6: return 30;
       case 7: return 31;
       case 8: return 31;
       case 9: return 30;
       case 10: return 31;
       case 11: return 30;
       case 12: return 31;
       default: return 0;
     }
  }

  int getDifferenceInCalendarDays(DateTime other) => other.startOfDay.differenceInDays(startOfDay);
  int getDifferenceInCalendarWeeks(DateTime other) => getWeek - other.getWeek ;
  int getDifferenceInCalendarMonths(DateTime other) => getMonth - other.getMonth ;

  DateTime getEndOfDay() {
    return startOfDay.addDays(1).subMilliseconds(1);
  }

  bool isBetween(DateTime start, DateTime end){
    return this >= start && this <= end;
  }

  bool isBetweenDay(DateTime start, DateTime end){
    return startOfDay >= start.startOfDay && this <= end.startOfDay;
  }

  bool isSameWeek(DateTime other) => other.getWeek == getWeek;

  Duration duration(DateTime later) => Duration(
    days: later.differenceInDays(startOfDay),
    minutes: later.totalMinutes.toInt() - totalMinutes.toInt());

  DateTime closestMinute(int minuteInterval, {bool before = false}) {
     if (minute == 0) {
       return this;
     }
     if (minuteInterval == 0) {
        return before ? startOfHour : incMinutes(60-minute);
     }
     List<DateTime> dates = [];
     DateTime date = startOfHour;
     while (date.isSameHour(startOfHour)){
       dates.add(date);
       date = date.incMinutes(minuteInterval);
     }
     DateTime result = closestTo(dates)!;
     if (before && result.isAfter(this)) {
       result = result.incMinutes(-minuteInterval);
     }
     return result;
  }

  DateTime getStartOfWeek(int weekStartDay) {
     int isoWeekStartDay = startOfWeek.weekday;
     if (isoWeekStartDay == weekStartDay) {
       if (weekday == startOfWeek.weekday) {
         return this;
       }
       return startOfWeek;
     }
     return startOfWeek.incDays(weekStartDay); // getPreviousDay(weekStartDay);
  }

  DateTime getPreviousDay(int dayNumber) {
     DateTime result = incDays(-1);
     while (result.weekday != dayNumber) {
        result = result.incDays(-1);
     }
     return result;
  }

  DateTime incDays(int delta, [bool endsSameDayOnLastDay = false]) {
    DateTime result = addDays(delta, true);
    if (endsSameDayOnLastDay) {
      result = result.subMilliseconds(1);
    }
    return result;
  }

  DateTime incMinutes(int delta) {
    return addMinutes(delta, true);
    // return DateTime.utc(year, month, day, hour, minute + delta, second, millisecond, microsecond);
    // return addDuration(Duration(minutes: delta));
     var result = addMinutes(delta, true);
     var totMinutes = result.totalMinutes;
     var diff = totMinutes - totalMinutes;
     if (diff != delta) {
      result = DateTime.utc(year, month, day, hour, minute + delta, second, millisecond, microsecond);
     }
     return result;
  }

  DateTime addDuration(Duration duration) {
    DateTime result = add(duration);
    if (timeZoneOffset != result.timeZoneOffset) {
      result = result.add(timeZoneOffset - result.timeZoneOffset);
    }
    return result;
  }

  DateTime incWeeks(int delta) {
    return addWeeks(delta);
  }

  DateTime incMonths(int delta) {
    return addMonths(delta);
  }

  List<DateTime> incDates(int count, IncDate incDate) {
    List<DateTime> result = [];
    for (int i = 0; i < count; i++) {
      result.add(incDate(this, i));
    }
    return result;
  }
}


