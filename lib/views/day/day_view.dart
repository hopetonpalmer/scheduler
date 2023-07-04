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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SchedulerView(
        viewBuilder: (BuildContext context, BoxConstraints constraints) => buildView(constraints),
      ),
    );
  }

  Widget buildView(BoxConstraints constraints) {
    return VirtualPageView(
      initialDate: startDate,
      itemBuilder: (BuildContext context, pageDate,_) =>
          Column(
            children: [
              Container(
                color: schedulerSettings.headerBackgroundColor,
                child: IntrinsicHeight(
                  child: Row(
                    children: buildDayHeaders(
                      pageDate,
                      constraints.maxWidth,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    double height = constraints.maxHeight;
                    int interval = schedulerService.dayViewSettings.intervalMinute.value;
                    int slotsPerHour = 60 ~/ interval;
                    int intervalCount = slotsPerHour * 24;
                    double intervalHeight = max(
                      schedulerService.dayViewSettings.intervalMinHeight,
                      height / intervalCount,
                    ).ceilToDouble();

                    return Container (
                      color: schedulerSettings.backgroundColor,
                      child: EventGrid(
                        date: pageDate,
                        days: widget.days,
                        constraints: constraints,
                        intervalHeight: intervalHeight,
                        intervalWidth: 0,
                        showCurrentTimeIndicator: true,
                        orientation: Axis.vertical,
                        intervalType: IntervalType.minute,
                        headerThickness: dayViewSettings.timebarFullWidth,
                        calendarViewType: CalendarViewType.day,
                     ),
                    );

                    return Container(
                        color: schedulerSettings.backgroundColor,
                        child: DayEventGrid(
                          key: GlobalKey(),
                          date: pageDate,
                          days: widget.days,
                          //scrollController: scrollController,
                          constraints: constraints,
                        ),
                      );
                     },
                ),
              ),
            ],
          ),
    );

  }

  List<Widget> buildDayHeaders(DateTime initialDate, double maxWidth) {
    List<Widget> result = [];
    var dayWidth = (maxWidth - dayViewSettings.timebarFullWidth) / widget.days;
    //DateTime initialDate = startDate;
    for (int i = 0; i < widget.days; i++) {
      DateTime date = initialDate.incDays(i);

      //-- all day
      if (i == 0) {
        result.add(Column(
          children: [
            Expanded(
              child: SizedBox(
                height: dayViewSettings.headerHeight,
                width: dayViewSettings.timebarFullWidth,
              ),
            ),
            SizedBox(
              height: 20,
              width: dayViewSettings.timebarFullWidth,
              child: Visibility(
                visible: !SchedulerViewHelper.isMobileLayout(context),
                child: Text(
                  dayViewSettings.allDayCaption,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: schedulerSettings.timebarFontColor,
                  ),
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
                showDivider: true,),
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
