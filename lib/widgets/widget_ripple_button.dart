import 'package:flutter/material.dart';

import '../internal_core.dart';

class WidgetInkWellTransparent extends StatelessWidget {
  const WidgetInkWellTransparent({
    super.key,
    this.onTap,
    required this.child,
    this.borderRadius,
    this.radius,
    this.hoverColor,
    this.onTapDown,
    this.enableInkWell = true,
  });

  final bool enableInkWell;
  final Color? hoverColor;
  final Widget child;
  final VoidCallback? onTap;
  final dynamic onTapDown;
  final BorderRadius? borderRadius;
  final double? radius;

  BorderRadius get _borderRadius =>
      borderRadius ?? BorderRadius.circular(radius ?? 999);

  @override
  Widget build(BuildContext context) {
    if (onTap == null) return child;
    if (!enableInkWell) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: ColoredBox(color: Colors.transparent, child: child),
        ),
      );
    }
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: _borderRadius),
      child: InkWell(
        borderRadius: _borderRadius,
        onTap: onTap,
        onTapDown: onTapDown,
        hoverColor: hoverColor ?? appColors?.hoverColor,
        child: child,
      ),
    );
  }
}

class WidgetRippleButton extends StatelessWidget {
  const WidgetRippleButton({
    super.key,
    this.color,
    this.disabledColor,
    this.elevation = 0,
    this.onTap,
    this.child,
    this.shadowColor,
    this.enable = true,
    this.radius = 99,
    this.borderSide = BorderSide.none,
  });

  final bool enable;
  final Color? color;
  final Color? disabledColor;
  final Color? shadowColor;
  final double elevation;
  final VoidCallback? onTap;
  final Widget? child;
  final double radius;
  final BorderSide borderSide;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation,
      shadowColor: shadowColor ?? appColors?.text.withValues(alpha: .1),
      color: enable
          ? (color ?? Colors.white)
          : disabledColor ?? hexColor('#F2F2F2'),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: borderSide,
      ),
      clipBehavior: Clip.none,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: enable && onTap != null
            ? () {
                appHaptic();
                onTap!.call();
              }
            : null,
        child: child,
      ),
    );
  }
}
