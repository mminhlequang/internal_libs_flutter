import 'package:flutter/material.dart';

class WidgetHoverScaleAnimation extends StatelessWidget {
  final bool isHovered;
  final Widget child;
  const WidgetHoverScaleAnimation(
      {super.key, required this.isHovered, required this.child});

  @override
  Widget build(BuildContext context) {
    // return AnimatedScale(
    //   duration: const Duration(milliseconds: 100),
    //   alignment: Alignment.topLeft,
    //   scale: isHovered ? 1 : 0,
    //   child: child,
    // );
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 100),
      opacity: isHovered ? 1 : 0,
      child: child,
    );
  }
}

class WidgetHoverBuilder extends StatefulWidget {
  final Widget Function(bool isHover) builder;
  const WidgetHoverBuilder({
    super.key,
    required this.builder,
  });

  @override
  State<WidgetHoverBuilder> createState() => _WidgetHoverBuilderState();
}

class _WidgetHoverBuilderState extends State<WidgetHoverBuilder> {
  bool isHover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (details) {
        setState(() {
          isHover = true;
        });
      },
      onExit: (details) => setState(() {
        setState(() {
          isHover = false;
        });
      }),
      child: widget.builder(isHover),
    );
  }
}
