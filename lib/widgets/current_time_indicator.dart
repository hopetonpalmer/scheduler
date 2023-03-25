import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scheduler/extensions/date_extensions.dart';
import 'package:scheduler/scheduler.dart';

import '../common/scheduler_view_helper.dart';
import '../constants.dart';
import 'arrow_indicator.dart';
import 'dotted_line.dart';

class CurrentTimeIndicator extends StatelessWidget {
  final double clientWidth;
  final double clientHeight;
  final double activePos;
  final double startPos;
  final double activeLength;
  const CurrentTimeIndicator(
      {Key? key,
        required this.clientHeight,
        required this.clientWidth,
        required this.startPos,
        required this.activePos,
        required this.activeLength})
      : super(key: key);

  double getPosition(double minutes) {
    int minutesInDay = 60 * 24;
    double tick = clientHeight / minutesInDay;
    return minutes * tick;
  }

  @override
  Widget build(BuildContext context) {
    Scheduler scheduler = Scheduler.of(context);
    SchedulerSettings settings = scheduler.schedulerSettings;
    Color indicatorColor = settings.currentTimeIndicatorColor ?? Theme.of(context).colorScheme.primary;
    double lineAlpha = settings.currentTimeIndicatorEarlierDays ? .5 : 0;
    bool isSmallDevice = SchedulerViewHelper.isSmallDevice(context);
    return ValueListenableBuilder(
      valueListenable: Scheduler.of(context).clockTickNotify,
        builder: (BuildContext context, DateTime value, Widget? child) =>
       ValueListenableBuilder(
        valueListenable: scheduler.schedulerScrollPosNotify,
        builder: (BuildContext context, double scrollPos, Widget? child) =>
            Positioned(
              top: getPosition(value.totalMinutes)  - 6 - scrollPos,
              left: startPos,
              child: SizedBox(
                width: max(0,activeLength + activePos - startPos),
                child: Row(
                children: [
                  DottedLine(width: max(0,activePos-startPos), color: indicatorColor.withOpacity(lineAlpha), isVerticalFlow: true,),
                  if (!isSmallDevice)
                     Text(DateFormat(DateFormat.HOUR_MINUTE).format(value),
                     style: TextStyle(color: indicatorColor, fontSize: 9)),
                  Container(margin: EdgeInsets.only(left: isSmallDevice ? 0 : 5), width: 10, height: 10,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: indicatorColor)),
                  Expanded(child: Container(height: .75,  color: indicatorColor)),
                ]),
              ),
              ),


      ),
    );
  }
}
