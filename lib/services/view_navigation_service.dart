import 'package:dart_date/dart_date.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import '/extensions/date_extensions.dart';
import 'package:scheduler/scheduler.dart';

import 'scheduler_service.dart';

class ViewNavigationService with ChangeNotifier {
  static final ViewNavigationService instance =
      ViewNavigationService._internal();
  factory ViewNavigationService({CalendarViewType? viewType}) {
    if (viewType != null) {
      instance.viewType = viewType;
    }
    return instance;
  }
  ViewNavigationService._internal();

  final ValueNotifier<int> pageChangedNotify = ValueNotifier<int>(0);
  final ValueNotifier<CalendarViewType> viewChangeNotify =
      ValueNotifier<CalendarViewType>(CalendarViewType.day);
  final ChangeNotifier scrollPreviousNotify = ChangeNotifier();
  final ChangeNotifier scrollNextNotify = ChangeNotifier();

  CalendarViewType get viewType => viewChangeNotify.value;

  Widget? _currentView;
  Widget? get currentView {
    _currentView ??= _viewOfViewType(viewType);
    return _currentView;
  }

  set viewType(CalendarViewType value) {
    if (viewChangeNotify.value != value || currentView == null) {
      _currentView = _viewOfViewType(value);
      viewChangeNotify.value = value;
    }
  }

  invalidateNavigation() {
    notifyListeners();
  }

  scrollPrevious() {
    scrollPreviousNotify.notifyListeners();
  }

  scrollNext() {
    scrollNextNotify.notifyListeners();
  }

  notifyScrollToToDate() {
    scrollNextNotify.notifyListeners();
  }
  viewPageChanged(int index){
    pageChangedNotify.value = index;
  }

  Widget _viewOfViewType(CalendarViewType value) {
    switch (value) {
      case CalendarViewType.day:
        return const DayView();
      case CalendarViewType.week:
        return const WeekView();
      case CalendarViewType.workWeek:
        return const WeekView(isWorkWeek: true);
      case CalendarViewType.month:
        return const MonthView();
      case CalendarViewType.timelineDay:
        return const TimelineView();
      case CalendarViewType.timelineWeek:
        return const TimelineView();
      case CalendarViewType.timelineWorkWeek:
        return const TimelineView();
      case CalendarViewType.timelineMonth:
        return const TimelineView();
      case CalendarViewType.year:
        return const TimelineView();
      case CalendarViewType.quarter:
        return const TimelineView();
      default:
        return const DayView();
    }
  }

  String navigationRangeToString(DateTime date) {
    switch (viewType) {
      case CalendarViewType.day:
      case CalendarViewType.timelineDay:
        return DateFormat('MMMM d, yyyy').format(date);
      case CalendarViewType.week:
      case CalendarViewType.workWeek:
      case CalendarViewType.timelineWeek:
      case CalendarViewType.timelineWorkWeek:
        return DateFormat('MMMM yyyy').format(date);
      case CalendarViewType.month:
      case CalendarViewType.timelineMonth:
        return DateFormat('MMMM yyyy').format(date.incDays(7).startOfMonth);
      case CalendarViewType.year:
      case CalendarViewType.quarter:
        return DateFormat('MMMM yyyy').format(date) +
            " - " +
            DateFormat('MMMM yyyy').format(date);
      default:
        return DateFormat('MMMM d, yyyy').format(date);
    }
  }
}

ViewNavigationService get viewNavigationService => ViewNavigationService.instance;