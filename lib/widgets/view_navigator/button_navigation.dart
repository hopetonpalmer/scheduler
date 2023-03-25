import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../scheduler.dart';
import '../../services/view_navigation_service.dart';

class ButtonNavigation extends StatefulWidget {
  final Function(CalendarViewType viewType) selectView;
  const ButtonNavigation({Key? key, required this.selectView})
      : super(key: key);

  @override
  _ButtonNavigationState createState() => _ButtonNavigationState();
}

class _ButtonNavigationState extends State<ButtonNavigation> {
  final isSelected = <bool>[];

  selectView(int index) {
    if (isSelected[index]) {
      return;
    }
    for (int i = 0; i < isSelected.length; i++) {
      isSelected[i] = false;
    }
    setState(() {
      isSelected[index] = true;
    });
    widget.selectView(kViewTypes[index]);
  }

  @override
  initState() {
    for (var viewType in kViewTypes) {
      isSelected.add(viewType == ViewNavigationService().viewType);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Scrollbar(
        child: SingleChildScrollView(
          primary: true,
          scrollDirection: Axis.horizontal,
          child: ToggleButtons(
            textStyle: const TextStyle(fontSize: 12),
            isSelected: isSelected,
            onPressed: (index) => selectView(index),
            children: [
              for (int i = 0; i < kViewCaptions.length; i++)
                ViewButton(caption: kViewCaptions[i])
            ],
          ),
        ),
      ),
    );
  }
}

class ViewButton extends StatelessWidget {
  const ViewButton({
    Key? key,
    required this.caption,
  }) : super(key: key);

  final String caption;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Text(
        caption,
        softWrap: true,
        textAlign: TextAlign.center,
      ),
    );
  }
}
