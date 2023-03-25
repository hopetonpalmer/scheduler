part of scheduler;

class AppointmentSettings {
  final Color? hoverBorderColor;
  final Color defaultColor;
  final Color fontColor;
  final bool fontColorShadeOfBack;
  final TextStyle? textStyle;
  final double spaceBetween;
  final Radius? cornerRadius;
  final Builder? builder;
  final Color? selectionBorderColor;
  final Duration dragDelay;
  final Duration selectionDelay;
  final int animationSpeed;
  final bool hapticFeedbackOnLongPressSelection;

  const AppointmentSettings({
    this.defaultColor = Colors.grey,
    this.fontColor = Colors.white,
    this.fontColorShadeOfBack = false,
    this.selectionBorderColor, // = Colors.blue,
    this.hoverBorderColor, // const(0xffff9800),
    this.textStyle,
    this.spaceBetween = 1.5,
    this.cornerRadius,
    this.builder,
    this.hapticFeedbackOnLongPressSelection = true,
    this.selectionDelay = kLongPressTimeout,
    this.dragDelay = kLongPressTimeout,
    this.animationSpeed = 0,
  });

  getHoverBorderColor(BuildContext context) {
    return hoverBorderColor ?? Theme.of(context).colorScheme.primary;
  }
  getSelectionBorderColor(BuildContext context) {
    return selectionBorderColor ?? Theme.of(context).colorScheme.primary;
  }
}