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
        hoverColor: hoverColor ??
           appColors?.hoverColor ,
        child: child,
      ),
    );
  }
}

class WidgetRippleButton extends StatelessWidget {
  const WidgetRippleButton({
    super.key,
    this.title = '',
    this.color,
    this.hoverColor,
    this.radius = 26,
    this.elevation = 0,
    this.onTap,
    this.height,
    this.width,
    this.border,
    this.titleStyle,
    this.borderRadius,
    this.child,
    this.shadowColor,
  });

  const WidgetRippleButton.child({
    required this.child,
    this.color,
    this.hoverColor,
    this.elevation = 0,
    this.borderRadius,
    this.radius = 26,
    this.onTap,
    this.titleStyle,
    this.shadowColor,
    super.key,
  })  : border = null,
        height = null,
        width = null,
        title = '';

  final String title;
  final Color? color;
  final Color? hoverColor;
  final Color? shadowColor;
  final double elevation;
  final BorderRadius? borderRadius;
  final double radius;
  final VoidCallback? onTap;
  final Widget? child;
  final double? height;
  final double? width;
  final BoxBorder? border;
  final TextStyle? titleStyle;

  BorderRadius get _borderRadius =>
      borderRadius ?? BorderRadius.circular(radius);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation,
      shadowColor: shadowColor,
      color: color ?? Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: _borderRadius),
      child: InkWell(
        borderRadius: _borderRadius,
        onTap: onTap,
        hoverColor: hoverColor,
        child: child ??
            Container(
              height: height ?? 50,
              width: width ?? 311,
              decoration: BoxDecoration(
                borderRadius: _borderRadius,
                border: border,
              ),
              alignment: Alignment.center,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: titleStyle ??
                    w400TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
              ),
            ),
      ),
    );
  }
}
