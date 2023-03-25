import 'package:flutter/material.dart';

class VirtualPageView extends StatefulWidget {
  final Function(int virtualIndex)? afterScroll;
  final Function(int virtualIndex, int index)? onPageChanged;
  final int virtualCount;
  final Widget? Function(BuildContext, int) itemBuilder;
  const VirtualPageView({
    Key? key,
    this.afterScroll,
    this.onPageChanged,
    this.virtualCount = 1000000,
    required this.itemBuilder,
  }) : super(key: key);

  @override
  _VirtualPageViewState createState() => _VirtualPageViewState();
}

class _VirtualPageViewState extends State<VirtualPageView> {
  late PageController _controller;
  int initialPage = 0;

  @override
  void initState() {
    initialPage = (widget.virtualCount / 2).floor();
    _controller = PageController(initialPage: initialPage);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      pageSnapping: true,
      scrollDirection: Axis.horizontal,
      itemCount: widget.virtualCount,
      controller: _controller,
      onPageChanged: (index)=> widget.onPageChanged?.call(index, index - initialPage),
      itemBuilder: (context, index) {
        int virtualIndex = index - initialPage;
        Widget? item = widget.itemBuilder(context, virtualIndex);
        widget.afterScroll?.call(virtualIndex);
        return item;
      },
    );
  }
}
