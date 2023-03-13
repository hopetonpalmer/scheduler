part of scheduler;

class TimelineViewSettings {
  final double timebarFontSize;
  final IntervalMinute intervalMinute;

  const TimelineViewSettings({
    this.timebarFontSize = 12.5,
    this.intervalMinute = IntervalMinute.min15,
  });
}