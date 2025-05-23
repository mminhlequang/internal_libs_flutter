part of 'extensions.dart';

class ScaleInheritedStateContainer extends InheritedWidget {
  final double scaleValue;

  static ScaleInheritedStateContainer? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ScaleInheritedStateContainer>();
  }

  static ScaleInheritedStateContainer? of(BuildContext? context) {
    if (context != null) {
      final ScaleInheritedStateContainer? result = maybeOf(context);
      return result;
    }
    return null;
  }

  const ScaleInheritedStateContainer({
    super.key,
    required this.scaleValue,
    required super.child,
  });

  @override
  bool updateShouldNotify(ScaleInheritedStateContainer oldWidget) =>
      scaleValue != oldWidget.scaleValue;
}

double get _scale => 1;

extension NumExtension on num {
  double s() {
    return this *
        (ScaleInheritedStateContainer.of(findAppContext)?.scaleValue ?? _scale);
  }
}
