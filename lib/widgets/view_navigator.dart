part of scheduler;

class ViewNavigator extends StatefulWidget {
  final bool isDropdown;
  const ViewNavigator({Key? key, this.isDropdown = true}) : super(key: key);

  @override
  _ViewNavigatorState createState() => _ViewNavigatorState();
}

class _ViewNavigatorState extends State<ViewNavigator> with IntervalConfig {
  final SchedulerController controller =
      SchedulerService().scheduler.controller;
  final Scheduler scheduler = SchedulerService().scheduler;
  final isSelected = <bool>[
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];

  String selectedDropdown = '';

  selectView(CalendarViewType viewType) {
    var index = viewTypes.indexOf(viewType);
    if (isSelected[index]) {
      return;
    }
    for (int i = 0; i < isSelected.length; i++) {
      isSelected[i] = false;
    }
    setState(() {
      isSelected[index] = true;
    });
    controller.viewType = viewType;
    selectedDropdown = viewCaptions[index];
  }

  @override
  initState() {
    selectView(controller.viewType);
    super.initState();
    //ViewNavigationService().viewChangeNotify.addListener(() => mounted ? setState(() {}) : null);
    controller.addListener(() => mounted ? setState(() {}) : null);
  }

  @override
  dispose() {
    controller.removeListener(() {});
    super.dispose();
  }

  selectDate(GlobalKey key) async {
    RenderBox box = key.currentContext?.findRenderObject() as RenderBox;
    Offset position = box.localToGlobal(Offset.zero); //this is global position
    var selectedDate = await showDatePicker(
      context: context,
      initialDatePickerMode: DatePickerMode.day,
      initialDate: startDate,
      initialEntryMode: DatePickerEntryMode.calendar,
      firstDate: DateTime.now().addYears(-100),
      lastDate: DateTime.now().addYears(100),
      // locale: Locale(scheduler.schedulerSettings.locale)
    );
    if (selectedDate != null) {
      controller.goDate(selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey dateSelectionKey = GlobalKey();
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 0.5, color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: TextButton(
                  onPressed: () => controller.goToday(),
                  child: const Text("Today"))),
          IconButton(
            iconSize: 20.0,
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => controller.goPreviousDate(),
          ),
          IconButton(
            iconSize: 20.0,
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: () => controller.goNextDate(),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Text(
                ViewNavigationService().navigationRangeToString(startDate),
                key: dateSelectionKey),
          ),
          IconButton(
            iconSize: 20.0,
            icon: const Icon(Icons.arrow_drop_down),
            onPressed: () => selectDate(dateSelectionKey),
          ),
        ]),
        if (widget.isDropdown)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontSize: 12),
                focusColor: Colors.transparent,
                isDense: false,
                value: selectedDropdown,
                items: viewCaptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? value) {
                  var index = viewCaptions.indexOf(value!);
                  selectView(viewTypes[index]);
                  //setState(() {});
                }),
          )
        else
          Flexible(
            child: Scrollbar(
              child: SingleChildScrollView(
                primary: true,
                scrollDirection: Axis.horizontal,
                child: ToggleButtons(
                  textStyle: const TextStyle(fontSize: 12),
                  isSelected: isSelected,
                  onPressed: (index) => selectView(viewTypes[index]),
                  children: [
                    for (int i = 0; i < viewCaptions.length; i++)
                      ViewButton(caption: viewCaptions[i])
                  ],
                ),
              ),
            ),
          )
      ]),
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
