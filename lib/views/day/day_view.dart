part of scheduler;

class DayView extends StatefulWidget {
  final int days;
  const DayView({
    Key? key,
    this.days = 1,
  }) : super(key: key);

  @override
  _DayViewState createState() => _DayViewState();
}

class _DayViewState extends State<DayView> with IntervalConfig {
  late SchedulerSettings schedulerSettings;
  late DayViewSettings dayViewSettings;

  @override
  void initState() {
    intervalMinute = SchedulerService().dayViewSettings.intervalMinute;
    schedulerSettings = SchedulerService().schedulerSettings; // Scheduler.of(context).schedulerSettings;
    dayViewSettings = SchedulerService().dayViewSettings; // Scheduler.of(context).dayViewSettings;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var bodyKey = GlobalKey();
/*    return Material(
      child: SchedulerView(
        viewBuilder: (BuildContext context, BoxConstraints constraints) => SchedulerGrid(
            cols: widget.days,
            rows: 24
        )
      )
    );*/
    return Material(
      child: SchedulerView(
        viewBuilder: (BuildContext context, BoxConstraints constraints) => Stack(
          children: [
            Column(
              children: [
                Container(
                  color: schedulerSettings.headerBackgroundColor,
                  child: IntrinsicHeight(
                    child: Row(
                      children: buildDayHeaders(
                        constraints.maxWidth,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) =>
                     Container(
                      color: schedulerSettings.backgroundColor,
                      child: DayViewBody(
                        key: bodyKey,
                        date: startDate,
                        days: widget.days,
                        constraints: constraints,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildDayHeaders(double maxWidth) {
    List<Widget> result = [];
    var dayWidth = (maxWidth - dayViewSettings.timebarWidth) / widget.days;
    DateTime initialDate = startDate;
    for (int i = 0; i < widget.days; i++) {
      DateTime date = initialDate.incDays(i);

      //-- all day
      if (i == 0) {
        result.add(Column(
          children: [
            Expanded(
              child: SizedBox(
                height: dayViewSettings.headerHeight,
                width: dayViewSettings.timebarWidth,
              ),
            ),
            SizedBox(
              height: 20,
              width: dayViewSettings.timebarWidth,
              child: Text(
                dayViewSettings.allDayCaption,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: schedulerSettings.timebarFontColor,
                ),
              ),
            ),
/*            Container(
              color: schedulerSettings.timebarBackgroundColor,
              height: 5,
              width: dayViewSettings.timebarWidth,
            ), */// extra margin
          ],
        ));
      }
      result.add(
        Column(
          children: [
            Expanded(
              child: DateHeader(
                isFirstInSeries: i == 0,
                headerType: DateHeaderType.day,
                style: dayViewSettings.headerStyleName,
                width: dayWidth,
                height: dayViewSettings.headerHeight,
                dateVisible: true,
                date: date,
                showDivider: true,
                padding: const EdgeInsets.all(8),
              ),
            ),
            DateHeader(
                headerType: DateHeaderType.allDay,
                date: date,
                width: dayWidth,
                height: 20,
                showDivider: true),
        /*    DateHeader(
                //not really an allday header; spacer to give the first time (12 AM) in the ruler a margin at the top
                headerType: DateHeaderType.allDay,
                date: date,
                width: dayWidth,
                height: 5,
                backgroundColor: schedulerSettings.backgroundColor,
                showDivider: true)
*/          ],
        ),
      );
    }
    return result;
  }
}
