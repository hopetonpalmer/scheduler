import 'package:dart_date/dart_date.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scheduler/scheduler.dart';

class DateHeader extends StatefulWidget {
  final DateTime date;
  final bool showDivider;
  final String dateFormat;
  final Color? backgroundColor;
  final Color? fontColor;
  final double? fontSize;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final TextAlign textAlign;
  final DateHeaderType headerType;
  final BoxDecoration? decoration;
  final int? minuteInterval;
  final bool isSelected;
  final TextStyle? textStyle;
  final String? style;
  final bool isFirstInSeries;
  final bool circleWhenNow;
  final bool dateVisible;
  final bool isLongText;
  const DateHeader(
      {Key? key,
      required this.date,
      required this.headerType,
      this.dateFormat = DateFormat.ABBR_MONTH_DAY,
      this.circleWhenNow = false,
      this.decoration,
      this.isSelected = false,
      this.minuteInterval,
      this.backgroundColor,
      this.fontColor,
      this.fontSize,
      this.height,
      this.width,
      this.padding,
      this.style,
      this.isLongText = false,
      this.textStyle,
      this.isFirstInSeries = false,
      this.dateVisible = true,
      this.textAlign = TextAlign.center,
      this.showDivider = false})
      : super(key: key);

  @override
  _DateHeaderState createState() => _DateHeaderState();
}

class _DateHeaderState extends State<DateHeader> {
  late SchedulerSettings schedulerSettings;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    schedulerSettings = Scheduler.of(context).schedulerSettings;
    return ValueListenableBuilder(
      valueListenable: Scheduler.of(context).clockTickNotify,
      builder: (BuildContext context, value, Widget? child) =>
      Container(
          padding: widget.padding,
          decoration: widget.decoration ?? BoxDecoration(color: getHeaderColor(),
              border: !widget.showDivider ? null : Border(
                  left: BorderSide(
                      color: schedulerSettings.dividerLineColor,
                      width: schedulerSettings.dividerLineWidth))),
          height: widget.height,
          width: widget.width,
          child: !widget.dateVisible ? null : widget.headerType == DateHeaderType.allDay ? null : widgetOfStyle() ??
                dateText(format: widget.dateFormat,  circleCurrentDate: widget.circleWhenNow)),
    );
  }

  Color? getHeaderColor() {
/*    if (widget.isSelected || isCurrentDate(DateTime.now())) {
      return schedulerSettings.selectionBackgroundColor;
    }*/
    return widget.backgroundColor ?? schedulerSettings.headerBackgroundColor;
  }

  Widget? widgetOfStyle(){
    if (widget.style == 'dayStyle1') {
      return dayStyle1();
    } else if (widget.style == 'dayStyle2') {
      return dayStyle2();
    } else if (widget.style == 'dayStyle3') {
      return dayStyle3();
    }
    return null;
  }

  Widget dayStyle1() {
     return SizedBox(
       child: Column(children:[
          dateText(format: widget.date.isFirstDayOfMonth || widget.isFirstInSeries
              ? DateFormat.ABBR_MONTH_DAY : DateFormat.DAY, size: 30),
          dateText(format: DateFormat.WEEKDAY, size: 11)
       ]),
     );
  }

  Widget dayStyle2() {
    return Column(children:[
      dateText(format: DateFormat.DAY, size: 25, circleCurrentDate: true),
      dateText(format: DateFormat.WEEKDAY, size: 12,  matchFontColorWhenSelected: true)
    ]);
  }

  Widget dayStyle3() {
    return Column(children:[
      dateText(formattedDate: DateFormat(DateFormat.ABBR_WEEKDAY).format(widget.date).toUpperCase(),
          size: 13, matchFontColorWhenSelected: true),
      dateText(format: DateFormat.DAY, size: 25, circleCurrentDate: true)
    ]);
  }

  Widget dateText({String? format, double? size, bool circleCurrentDate = false,
    bool matchFontColorWhenSelected = false, String? formattedDate}) {
    String text = formattedDate ?? DateFormat(format).format(widget.date);
    ThemeData theme = Theme.of(context);

    Widget headerText([forCircle = false]) {
      return Text(
          text,
          textAlign: widget.textAlign,
          style: widget.textStyle ?? theme.textTheme.headlineMedium!.copyWith(
              overflow: TextOverflow.ellipsis,
              color: getFontColor(forCircle ? theme.colorScheme.onPrimary : theme.colorScheme.primary), //widget.isLongText || !circleCurrentDate || matchFontColorWhenSelected),
              fontSize: size ?? widget.fontSize,
              fontFamily: schedulerSettings.fontFamily)
      );
    }

    return SizedBox(
      width: widget.width,
      // height: widget.height,
      child: !widget.isLongText && circleCurrentDate
          ? CircleAvatar(backgroundColor: getCircleColor() ,
          radius: 20, child: headerText(true)) /*Container(
              child: Center(child: headerText()),
              padding:  const EdgeInsets.all(5),
              decoration: ShapeDecoration(shape: widget.isLongText
                 ? const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))
                 : const CircleBorder() ,
              color: schedulerSettings.currentDateBackgroundColor))*/
          : headerText()
    );
  }

  Color getCircleColor() {
    if (isCurrentDate()) {
      return schedulerSettings.currentDateBackgroundColor ?? Theme.of(context).colorScheme.primary;
    }
    return Colors.transparent;
  }

  Color? getFontColor(Color themeColor) {
    var dateCurrent = isCurrentDate();
    if (widget.isSelected && !dateCurrent){
      return schedulerSettings.selectionFontColor;
    }
    Color? result =  widget.fontColor ?? schedulerSettings.headerFontColor;
    if (dateCurrent) {
      result = schedulerSettings.currentDateFontColor ?? themeColor; // useBackground ? schedulerSettings.currentDateBackgroundColor : schedulerSettings.currentDateFontColor;
    }
    return result;
  }

  bool isCurrentDate() {
    final date = DateTime.now();
    bool isCurrentDate = false;
    switch (widget.headerType) {
      case DateHeaderType.minute:
        if (widget.date.isSameHour(date)) {
          List<DateTime> dates = [];
          var minutes = widget.minuteInterval!;
          var parts = 60 / minutes;
          for (var i = 0; i < parts; i++) {
            dates.add(widget.date.startOfHour.addMinutes(minutes * i));
          }
          isCurrentDate = date.closestTo(dates)!.minute == widget.date.minute ;
        }
        break;
      case DateHeaderType.hour:
        isCurrentDate = widget.date.isSameHour(date);
        break;
      case DateHeaderType.day:
        isCurrentDate = widget.date.isSameDay(date);
        break;
      case DateHeaderType.month:
        isCurrentDate = widget.date.isSameMonth(date);
        break;
      default:
        isCurrentDate = false;
    }
    return isCurrentDate;
  }
}
