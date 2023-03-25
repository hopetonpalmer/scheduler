import 'package:flutter/material.dart';
import 'package:scheduler/services/view_navigation_service.dart';

import '../../constants.dart';
import '../../scheduler.dart';

class CompactPopupNavigation extends StatefulWidget {
  final Function(CalendarViewType viewType) selectView;
  const CompactPopupNavigation({Key? key, required this.selectView}) : super(key: key);

  @override
  _CompactPopupNavigationState createState() => _CompactPopupNavigationState();
}

class _CompactPopupNavigationState extends State<CompactPopupNavigation> {
  late CalendarViewType selectedViewType;

  @override
  void initState() {
    selectedViewType = ViewNavigationService().viewType;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<CalendarViewType>(
      icon: const Icon(Icons.more_vert),
      initialValue: selectedViewType,
      onSelected: (CalendarViewType viewType) {
        setState((){
          selectedViewType = viewType;
          widget.selectView(viewType);
        });
      },
      itemBuilder: (BuildContext context) => kViewTypes.map((viewType) {
        return PopupMenuItem(
          value: viewType,
          child: Text(kViewCaptions[(kViewTypes.indexOf(viewType))]),
        );
      }).toList(),
    );
  }
}
