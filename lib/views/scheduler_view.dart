import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:scheduler/scheduler.dart';
import 'package:scheduler/services/appointment_drag_service.dart';
import 'package:scheduler/services/appointment_service.dart';

typedef SchedulerViewBuilder = Widget Function(
    BuildContext context, BoxConstraints constraints);

class SchedulerView extends StatefulWidget {
  final SchedulerViewBuilder viewBuilder;
  final Color? backgroundColor;
  const SchedulerView({Key? key, required this.viewBuilder, this.backgroundColor}) : super(key: key);

  @override
  _SchedulerViewState createState() => _SchedulerViewState();
}

class _SchedulerViewState extends State<SchedulerView> {
  @override
  Widget build(BuildContext context) {
    SchedulerSettings schedulerSettings = Scheduler.of(context).schedulerSettings;
    Intl.defaultLocale = schedulerSettings.locale;
    return Material(
      child: RawKeyboardListener(
        autofocus: true,
        focusNode: FocusNode(),
        onKey: handleKeyPress,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) => Container(
            color: widget.backgroundColor ?? schedulerSettings.getBackgroundColor(context),
            child: Scaffold(backgroundColor: Colors.transparent, body: widget.viewBuilder(context, constraints)),
          ),
        ),
      ),
    );
  }

  handleKeyPress(RawKeyEvent event) {
    if (event.isKeyPressed(LogicalKeyboardKey.delete)){
      AppointmentService.instance.deleteSelectedAppointment();
    } else if (event.isKeyPressed(LogicalKeyboardKey.escape)){
      AppointmentDragService().cancelDrag();
    }
  }

}
