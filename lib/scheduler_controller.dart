import 'package:dart_date/dart_date.dart';
import 'package:flutter/foundation.dart';
import 'package:scheduler/extensions/date_extensions.dart';
import 'package:scheduler/scheduler.dart';

import 'date_range.dart';
import 'interval_config.dart';
import 'services/scheduler_service.dart';
import 'services/view_navigation_service.dart';

class SchedulerController extends ChangeNotifier {
  IntervalConfigProxy intervalConfigProxy = IntervalConfigProxy();
  Scheduler get scheduler => SchedulerService().scheduler;
  DateRange get visibleDateRange => scheduler.dateRange;

  SchedulerController({DateTime? date}) {
    if (date != null) {
      _startDate = date;
    }

  }

  DateTime _startDate = DateTime.now();
  DateTime get startDate {
    return _startDate;
  }
  set startDate(DateTime value) {
    if (_startDate != value) {
      _startDate = value;
      //scheduler.dataSource.se
      notifyListeners();
    }
  }

  CalendarViewType get viewType => ViewNavigationService().viewType;
  set viewType(CalendarViewType value) {
    if (value != viewType) {
      ViewNavigationService().viewType = value;
    }
  }

  goNextDate() {
    startDate = intervalConfigProxy.incrementPageDate(_startDate);
  }

  goPreviousDate() {
    startDate = intervalConfigProxy.incrementPageDate(_startDate, multiplier: -1);
  }

  goToday() {
    startDate = DateTime.now();
  }

  goDate(DateTime date) {
    startDate = intervalConfigProxy.incrementPageDate(date, multiplier: 0);
  }
}

class IntervalConfigProxy with IntervalConfig {}
