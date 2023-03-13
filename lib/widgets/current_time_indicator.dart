import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scheduler/extensions/date_extensions.dart';
import 'package:scheduler/scheduler.dart';

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
    Color indicatorColor = scheduler.schedulerSettings.currentTimeIndicatorColor;
    int lineAlpha = scheduler.schedulerSettings.currentTimeIndicatorEarlierDays ? 50 : 0;
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
                  Container(width: max(0,activePos-startPos), height: 1.25,  color: indicatorColor.withAlpha(lineAlpha)),
                  Text(DateFormat(DateFormat.HOUR_MINUTE).format(value),
                      style: TextStyle(color: indicatorColor, fontSize: 9)),
                  Container(margin: const EdgeInsets.only(left: 5), width: 9, height: 9,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: indicatorColor)),
                  Expanded(child: Container(height: 1.25,  color: indicatorColor)),
                ]),
              ),
              ),


      ),
    );
  }
}
