import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scheduler/extensions/date_extensions.dart';
import 'package:scheduler/scheduler.dart';


class DayViewInterval extends StatelessWidget {
  final DateTime date;
  final double height;
  const DayViewInterval({Key? key, required this.date, required this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var schedulerSettings = Scheduler.of(context).schedulerSettings;
    var dayViewSettings = Scheduler.of(context).dayViewSettings;
    return Container(
        height: height,
        color: schedulerSettings.timebarBackgroundColor,
        padding: const EdgeInsets.only(right: 5),
        width: dayViewSettings.timebarFullWidth,
        child: !dayViewSettings.showMinutes || !date.isTopOfHour ? null : Text(
            date.isTopOfHour ? date.formatHour : DateFormat('mm').format(date),
            textAlign: TextAlign.right,
            style: TextStyle(
                height: dayViewSettings.positionTimeAtBoundaryMiddle && !date.isStartOfDay ? 0.5 : 1,
                color: date.isTopOfHour ? schedulerSettings.timebarFontColor : schedulerSettings.timebarMinuteFontColor,
                fontWeight: date.isTopOfHour ? FontWeight.normal : FontWeight.w200,
                fontFamily: schedulerSettings.fontFamily,
                fontSize: date.isTopOfHour ? dayViewSettings.timebarFontSize : dayViewSettings.timebarFontSize * .66)));
  }
}
