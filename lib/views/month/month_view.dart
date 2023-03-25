part of scheduler;

class MonthView extends StatefulWidget {
  const MonthView({Key? key}) : super(key: key);

  @override
  _MonthViewState createState() => _MonthViewState();
}

class _MonthViewState extends State<MonthView> with IntervalConfig {
  late SchedulerSettings schedulerSettings;
  late MonthViewSettings settings;
  late double weekNumberWidth = 0;
  late double dayWidth;
  late double daysWidth;

  @override
  Widget build(BuildContext context) {
    schedulerSettings = Scheduler.of(context).schedulerSettings;
    settings = Scheduler.of(context).monthViewSettings;
    return SchedulerView(viewBuilder: buildMonthView);
  }

  Widget buildMonthView(BuildContext context, BoxConstraints constraints) {
    weekNumberWidth = settings.showWeekNumber ? settings.weekNumberWidth : 0;
    daysWidth = constraints.maxWidth - weekNumberWidth;
    dayWidth = daysWidth / DateTime.daysPerWeek;
    return Column(children: [buildMonthHeader(context), buildWeeks()]);
  }

  Widget buildMonthHeader(BuildContext context) {
    List<Widget> headers = [];
    for (int i = 0; i < DateTime.daysPerWeek; i++) {
      DateTime date = startDate.incDays(i);
      if (i == 0) {
        headers.add(SizedBox(width: weekNumberWidth));
      }
      headers.add(
        Expanded(
          child: DateHeader(
              headerType: DateHeaderType.day,
              date: date,
              fontSize: 14,
              textAlign: TextAlign.center,
              padding: const EdgeInsets.all(10.0),
              dateFormat: settings.calcHeaderFormat(MediaQuery.of(context).size.width)),
        ),
      );
    }
    return Container(
        width: daysWidth + weekNumberWidth,
        color: schedulerSettings.headerBackgroundColor,
        child: Row(children: headers));
  }

  Widget buildWeeks() {
    List<Widget> weeks = [];
    DateTime endOfFirstWeek = startDate.incDays(6);
    DateTime date = endOfFirstWeek.startOfWeek;
    int currentMonth = endOfFirstWeek.month;
    while (true) {
      weeks.add(buildWeek(date, currentMonth));
      date = date.incDays(7);
      if (!date.isSameMonth(endOfFirstWeek)) {
        break;
      }
    }
    return Expanded(child: Column(children: weeks));
  }

  Widget buildWeek(DateTime startOfWeek, int currentMonth) {
    List<Widget> days = [];

    Color? cellColor(DateTime date) {
      if (date.month == currentMonth) {
        return Colors.transparent;
      }
      return date.month < currentMonth
          ? settings.leadingDaysBackgroundColor
          : settings.trailingDaysBackgroundColor;
    }

    for (int i = 0; i < DateTime.daysPerWeek; i++) {
      DateTime date = startOfWeek.incDays(i);
      DateTime endDate = date.incDays(1).subMilliseconds(100);
      bool isSameMonth = date.month == currentMonth;
      bool isDisabled = !settings.showLeadingAndTrailingDates && !isSameMonth;
      if (i == 0 && settings.showWeekNumber) {
        days.add(buildWeekNumber(date));
      }
      GlobalKey key = GlobalKey();
      TimeSlot timeSlot = TimeSlot(date,endDate,CalendarViewType.month,IntervalType.day, dayWidth);
      days.add(
        Expanded(
          child: TimeslotCell(
            builder: (context, isSelected) => buildDayCell(date, currentMonth, isSelected, isDisabled),
            timeSlot: timeSlot,
            showDivider: false,
            showBorders: true,
            showBottomBorder: true,
            isGroupEnd: true,
            width: dayWidth,
            disabled: isDisabled,
            backgroundColor: cellColor(date),
            flowOrientation: FlowOrientation.horizontal,
            key: key,
          ),
        ),
      );
    }
    return Expanded(child: Row(children: days));
  }

  Widget buildDayCell(
      DateTime date, int currentMonth, bool isSelected, bool disabled) {
    bool isLongDate = date == startDate || date.isFirstDayOfMonth;

    Color? fontColor(DateTime date) {
      if (date.month == currentMonth) {
        return null; //Colors.black;
      }
      return date.month < currentMonth
          ? settings.leadingDaysTextStyle != null ? settings.leadingDaysTextStyle!.color : null
          : settings.trailingDaysTextStyle != null ? settings.trailingDaysTextStyle!.color : null;
    }


    String monthDateFormat() {
      String result = 'd';
      if (isLongDate){
        result = 'MMM d';
        if (MediaQuery.of(context).size.width <= kSmallDevice) {
          result = 'Md';
        }
      }
      return result;
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      DateHeader(
          height: isLongDate ? null : 40,
          width: isLongDate ? 80 : 40,
          isSelected: isSelected,
          backgroundColor: Colors.transparent,
          headerType: DateHeaderType.day,
          circleWhenNow: true,
          isLongText: isLongDate,
          date: date,
          fontSize: 14,
          dateVisible: !disabled,
          fontColor: fontColor(date),
          textAlign: TextAlign.center,
          padding: const EdgeInsets.all(5.0),
          dateFormat: monthDateFormat()),
      Expanded(child: Container())
    ]);
  }

  Widget buildWeekNumber(DateTime date) {
    String weekNumber = date.getWeek.toString();
    String caption = settings.rotateWeekNumber
        ? '${settings.weekNumberCaption} $weekNumber'
        : weekNumber;
    return Container(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: RotatedBox(
        quarterTurns: settings.rotateWeekNumber ? 3 : 0,
        child: Center(
          child: FittedBox(child: Text(caption)),
        ),
      ),
      width: weekNumberWidth,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
              color: schedulerSettings.getIntervalLineColor(context),
              width: schedulerSettings.dividerLineWidth),
        ),
      ),
    );
  }
}
