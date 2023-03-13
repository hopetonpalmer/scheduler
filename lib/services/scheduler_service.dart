import 'package:scheduler/scheduler.dart';

class SchedulerService {
  static final SchedulerService _schedulerService = SchedulerService._internal();
  Scheduler? _scheduler;
  factory SchedulerService({Scheduler? scheduler}) {
    if (scheduler != null){
      _schedulerService._scheduler = scheduler;
    }
    return _schedulerService;
  }
  SchedulerService._internal();

  Scheduler get scheduler => _scheduler!;
  SchedulerSettings get schedulerSettings => scheduler.schedulerSettings;
  DayViewSettings get dayViewSettings => scheduler.dayViewSettings;
  MonthViewSettings get monthViewSettings => scheduler.monthViewSettings;
  TimelineViewSettings get timelineViewSettings => scheduler.timelineViewSettings;
  AppointmentSettings get appointmentSettings => scheduler.appointmentSettings;
}