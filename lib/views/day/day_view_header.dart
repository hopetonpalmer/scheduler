import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:scheduler/scheduler.dart';

class DayViewHeader extends StatefulWidget {
  final DateTime date;
  final String dateFormat;
  final bool isLongDate;
  final double height;
  final double maxWidth;
  final int days;
  const DayViewHeader(
      {Key? key,
      this.height = 80,
      required this.date,
      required this.maxWidth,
      required this.days,
      this.dateFormat = 'MMM d',
      this.isLongDate = true})
      : super(key: key);

  @override
  _DayViewHeaderState createState() => _DayViewHeaderState();
}

class _DayViewHeaderState extends State<DayViewHeader> {
  @override
  Widget build(BuildContext context) {
    var schedulerSettings = Scheduler.of(context).schedulerSettings;
    return Container(
      height: widget.height,
      color: schedulerSettings.headerBackgroundColor,
      padding: const EdgeInsets.all(5),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.ideographic,
          children: dateParts()),
    );
  }

  List<Widget> dateParts() {
    final date = widget.date;
    var schedulerSettings = Scheduler.of(context).schedulerSettings;
    double fontSize = widget.maxWidth >= 500 ? 26.0 : 18.00; //--Responsive; need to refactor and use size constants
    TextStyle textStyle = TextStyle(
        fontFamily: schedulerSettings.fontFamily,
        fontSize: fontSize,
        color: schedulerSettings.headerFontColor,
        fontWeight: FontWeight.w300);

    List<Widget> parts = [];
    if (date.day == 1 || widget.isLongDate) {
      parts.add(dateText(DateFormat('MMM').format(widget.date),
          style: textStyle));
      parts.add(const SizedBox(width: 8));
    }
    parts.add(dateText(DateFormat('d').format(widget.date),
        style: textStyle));
    parts.add(const SizedBox(width: 10));
    parts.add(dateText(DateFormat('EEE').format(widget.date),
        style: textStyle.copyWith(
            fontSize: fontSize * .60, fontWeight: FontWeight.w200)));
    return parts;
  }

  Widget dateText(String value, {TextStyle? style}) {
    return Text(value, style: style, maxLines: 1);
  }
}
