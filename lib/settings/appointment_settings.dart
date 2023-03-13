part of scheduler;

class AppointmentSettings {
  final Color defaultColor;
  final Color fontColor;
  final bool calcFontColor;
  final TextStyle? textStyle;
  final double spaceBetween;
  final Radius? cornerRadius;
  final Builder? builder;
  final Color selectionColor;
  final int dragDelayMilliseconds;
  final int animationSpeed;

  const AppointmentSettings({
    this.defaultColor = Colors.grey,
    this.fontColor = Colors.white,
    this.calcFontColor = true,
    this.selectionColor = Colors.blue,
    this.textStyle,
    this.spaceBetween = 1.5,
    this.cornerRadius,
    this.builder,
    this.dragDelayMilliseconds = 0,
    this.animationSpeed = 0,
  });
}