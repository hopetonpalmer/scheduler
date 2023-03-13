import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class Syncfusion extends StatelessWidget {
  const Syncfusion({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  SfCalendar(view: CalendarView.workWeek, allowViewNavigation: true, timeSlotViewSettings: const TimeSlotViewSettings(
        startHour: 0,
        endHour: 24,
        nonWorkingDays: <int>[
          DateTime.saturday,
          DateTime.sunday,
        ],
        timeInterval: Duration(minutes: 22),
        timeIntervalHeight: 40,
        timeFormat: 'h:mm',
        dateFormat: 'd',
        dayFormat: 'EE',
        timeRulerSize: 60),
    );
  }
}
