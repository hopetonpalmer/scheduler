import 'package:vector_math/vector_math_64.dart';
import 'package:flutter/material.dart';

class TextExtra extends StatefulWidget {
  final Widget? child;
  const TextExtra({Key? key, this.child}):super(key: key);

  @override
  _TextExtraState createState() => _TextExtraState();
}

class _TextExtraState extends State<TextExtra> {
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance!.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final RenderObject? renderBox = _key.currentContext?.findRenderObject();
    final height = renderBox?.paintBounds.height ?? 0;
    return Baseline(
      baseline: 0,
      baselineType: TextBaseline.ideographic,
      key: _key,
      child: Transform(
        transform: Matrix4.translation(
          Vector3(0, height, 0),
        ),
        child: widget.child,
      ),
    );
  }
}
