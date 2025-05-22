part of 'extensions.dart';

/// An extension on integer values to simplify creating SizedBox with height or width.
extension SizedBoxExtension on int {
  /// Returns a SizedBox with the specified height.
  SizedBox get h => SizedBox(height: toDouble());

  /// Returns a SizedBox with the specified width.
  SizedBox get w => SizedBox(width: toDouble());
}

extension CommonWidgetExtension on Widget {
  /// Returns a SizedBox with the specified height.
  Widget opacity(double opacity) => Opacity(opacity: opacity, child: this);

  /// Returns a SizedBox with the specified width.
  Widget padding(EdgeInsets padding) => Padding(padding: padding, child: this);

  Widget ignorePointer(bool ignore) =>
      IgnorePointer(ignoring: ignore, child: this);

  Widget visible(bool visible) => Visibility(visible: visible, child: this);

  Widget center() => Center(child: this);
}
