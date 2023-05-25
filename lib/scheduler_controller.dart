import 'package:flutter/foundation.dart';
import 'package:scheduler/scheduler.dart';

import 'date_range.dart';
import 'interval_config.dart';
import 'services/scheduler_service.dart';
import 'services/view_navigation_service.dart';

class SchedulerController extends ChangeNotifier {
  IntervalConfigProxy intervalConfigProxy = IntervalConfigProxy();
  Scheduler get scheduler => SchedulerService().scheduler;
  SchedulerSettings get schedulerSettings => scheduler.schedulerSettings;
  DateRange get visibleDateRange => scheduler.dateRange;

  final ValueNotifier<DateTime> startDateChangeNotify = ValueNotifier<DateTime>(DateTime.now());
  final ValueNotifier<DateTime> selectedDateChangeNotify = ValueNotifier<DateTime>(DateTime.now());

  SchedulerController({DateTime? date}) {
    if (date != null) {
      _startDate = date;
    }
    startDateChangeNotify.value = _startDate;
    selectedDateChangeNotify.value = _startDate;
  }

  DateTime _startDate = DateTime.now();
  DateTime get startDate {
    return _startDate;
  }
  set startDate(DateTime value) {
    if (_startDate != value) {
      _startDate = value;
      startDateChangeNotify.value = value;
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
    schedulerSettings.navigationScroll ? ViewNavigationService().scrollNext() :
    startDate = intervalConfigProxy.incrementPageDate(_startDate);
  }

  goPreviousDate() {
    schedulerSettings.navigationScroll ? ViewNavigationService().scrollPrevious() :
    startDate = intervalConfigProxy.incrementPageDate(_startDate, multiplier: -1);
  }

  goToday() {
    startDate = DateTime.now();
  }

  goDate(DateTime date) {
    startDate = intervalConfigProxy.incrementPageDate(date, multiplier: 0);
  }

  /// Update the start date but only invalidate the navigation view
  setNavDate(DateTime date) {
    _startDate = intervalConfigProxy.incrementPageDate(date, multiplier: 0);
    ViewNavigationService().invalidateNavigation();
    startDateChangeNotify.value = startDate;
  }


}

class IntervalConfigProxy with IntervalConfig {}
