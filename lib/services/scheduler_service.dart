import 'package:flutter/widgets.dart';
import 'package:scheduler/scheduler.dart';

class SchedulerService {
  static final SchedulerService instance = SchedulerService._internal();
  Scheduler? _scheduler;
  factory SchedulerService({Scheduler? scheduler}) {
    if (scheduler != null){
      instance._scheduler = scheduler;
    }

    return instance;
  }
  SchedulerService._internal();

  Scheduler get scheduler => _scheduler!;
  SchedulerSettings get schedulerSettings => scheduler.schedulerSettings;
  DayViewSettings get dayViewSettings => scheduler.dayViewSettings;
  MonthViewSettings get monthViewSettings => scheduler.monthViewSettings;
  TimelineViewSettings get timelineViewSettings => scheduler.timelineViewSettings;
  AppointmentSettings get appointmentSettings => scheduler.appointmentSettings;
  BuildContext? currentContext;
}

SchedulerService get schedulerService => SchedulerService.instance;