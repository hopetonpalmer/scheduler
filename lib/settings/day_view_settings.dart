part of scheduler;

@immutable
class DayViewSettings with Diagnosticable {
  final bool showMinutes;
  final bool positionTimeAtBoundaryMiddle;
  final double timebarWidth;
  final double timebarFontSize;
  final double? headerHeight;
  final String timebarHourFormat;
  final Color? allDayBackgroundColor;
  final String allDayCaption;
  final String? headerStyleName;
  final IntervalMinute intervalMinute;
  final double intervalMinHeight;

  const DayViewSettings({
    this.intervalMinute = IntervalMinute.min30,
    this.intervalMinHeight = 40,
    this.showMinutes = false,
    this.positionTimeAtBoundaryMiddle = true,
    this.timebarWidth = 65,
    this.timebarFontSize = 10.5,
    this.headerHeight,
    this.timebarHourFormat = 'j',
    this.allDayBackgroundColor, // = const Color(0xff9e9e9e),
    this.allDayCaption = 'all-day',
    this.headerStyleName = 'dayStyle2',
  });
}