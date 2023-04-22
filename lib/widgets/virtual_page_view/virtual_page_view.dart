import 'package:flutter/material.dart';

import '../../interval_config.dart';
import '../../scheduler_scroll_behavior.dart';
import '../../services/scheduler_service.dart';
import '../../services/view_navigation_service.dart';

class VirtualPageView extends StatefulWidget {
  final Function(int virtualIndex)? afterScroll;
  final Function(int virtualIndex)? beforeScroll;
  final Function(int virtualIndex, int index)? onPageChanged;
  final int virtualCount;
  final Widget? Function(BuildContext context, DateTime pageDate, int index) itemBuilder;
  final DateTime initialDate;
  const VirtualPageView({
    Key? key,
    this.beforeScroll,
    this.afterScroll,
    this.onPageChanged,
    this.virtualCount = 1000000,
    required this.initialDate,
    required this.itemBuilder,
  }) : super(key: key);

  @override
  _VirtualPageViewState createState() => _VirtualPageViewState();
}

class _VirtualPageViewState extends State<VirtualPageView> with IntervalConfig{
  late PageController _controller;
  int initialPage = 0;
  int virtualInitialPage = 0;
  int pageOffset = 0;

  @override
  void initState() {
    initialPage = (widget.virtualCount / 2).floor();
    virtualInitialPage = initialPage;
    _controller = PageController(initialPage: initialPage);
    subscribeToNavServiceScrolling();
    super.initState();
  }

  subscribeToNavServiceScrolling() {
    Duration duration = const Duration(milliseconds: 500);
    Curve curve = Curves.decelerate;
    viewNavigationService.scrollNextNotify.addListener(() => {
      if (_controller.positions.isNotEmpty)
         _controller.nextPage(duration: duration, curve: curve)});
    viewNavigationService.scrollPreviousNotify.addListener(() => {
      if (_controller.positions.isNotEmpty)
         _controller.previousPage(duration: duration, curve: curve)});
  }

  @override
  void dispose() {
    viewNavigationService.scrollPreviousNotify.removeListener(() { });
    viewNavigationService.scrollNextNotify.removeListener(() { });
    super.dispose();
  }

  DateTime calcPageDate(int index){
    int virtualPageIndex = index - initialPage;
    DateTime result = incrementPageDate(startDate, multiplier: virtualPageIndex);
    return result;
  }


  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      allowImplicitScrolling: false,
      scrollBehavior: SchedulerScrollBehavior(),
      pageSnapping: true,
      scrollDirection: Axis.horizontal,
      itemCount: widget.virtualCount,
      controller: _controller,
      onPageChanged: (index) {
        int virtualPageIndex = index - virtualInitialPage;
        viewNavigationService.viewPageChanged(virtualPageIndex);
        widget.onPageChanged?.call(virtualPageIndex, index);
        schedulerService.scheduler.controller.setNavDate(calcPageDate(index));
        initialPage = index;
      },
      itemBuilder: (context, index) {
        int virtualPageIndex = index - initialPage;
        widget.beforeScroll?.call(virtualPageIndex);
        Widget? item = widget.itemBuilder(context, calcPageDate(index), virtualPageIndex);
        widget.afterScroll?.call(virtualPageIndex);
        return item;
      },
    );
  }

}
