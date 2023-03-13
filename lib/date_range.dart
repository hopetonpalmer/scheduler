import 'package:flutter/foundation.dart';
import 'package:dart_date/dart_date.dart';
import 'package:scheduler/extensions/date_extensions.dart';

class DateRange extends ChangeNotifier {

  DateRange([DateTime? start, DateTime? end]) {
    if (start != null || end != null) {
      setRange(start!.startOfDay, end!.getEndOfDay());
    }
  }

  DateRange.same(DateTime date){
    setRange(date.startOfDay, date.startOfDay);
  }

  List<DateTime> _dates = [];
  List<DateTime> get dates => _dates;

  Duration get duration => dates.isEmpty ? const Duration() : Duration(minutes: dates.last.differenceInMinutes(dates.first));

  bool get isEmpty {
    return _dates.isEmpty;
  }

  bool inRange(DateTime date) {
    return _dates.isNotEmpty && date.isWithinRange(_dates.first , _dates.last);
  }

  void clearRange() {
    _dates.clear();
    notifyListeners();
  }

  void setRange(DateTime start, DateTime end){
    _dates = [start, end];
    _dates.sort((a,b) => a.compareTo(b));
    notifyListeners();
  }


}