import 'package:flutter/material.dart';
import 'package:scheduler/services/view_navigation_service.dart';

import '../../constants.dart';
import '../../scheduler.dart';

class PopupNavigationEx extends StatefulWidget {
  final Function(CalendarViewType viewType) selectView;
  final bool showSelection;
  const PopupNavigationEx({Key? key, required this.selectView, this.showSelection = true}) : super(key: key);

  @override
  _PopupNavigationExState createState() => _PopupNavigationExState();
}

class _PopupNavigationExState extends State<PopupNavigationEx> {
  late CalendarViewType selectedViewType;

  get selectionText => kViewCaptions[(kViewTypes.indexOf(selectedViewType))];

  @override
  void initState() {
    selectedViewType = ViewNavigationService().viewType;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<CalendarViewType>(
      tooltip: "View selection",
      child: DropdownSelector(selectionText, !widget.showSelection),
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

class DropdownSelector extends StatelessWidget{
  final String selection;
  final bool isCompact;
  const DropdownSelector(this.selection, this.isCompact, {super.key});

  @override
  Widget build(BuildContext context) {
     return isCompact
         ? const Icon(Icons.more_vert)
         : Row(children: [Text(selection), const Icon(Icons.arrow_drop_down) ]);
  }
}