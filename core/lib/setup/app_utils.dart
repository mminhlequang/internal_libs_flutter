

part of '../internal_core.dart';


String appImageCorrectUrl(String url, {base}) =>
    appSetup?.networkOptions?.appImageCorrectUrl(url, base: base) ?? url;

int intInRange(int min, int max) => min + Random().nextInt(max - min);

double doubleInRange(num start, num end) =>
    Random().nextDouble() * (end - start) + start;

void appHaptic() {
  HapticFeedback.lightImpact();
}

String assetpng(x) => 'assets/images/png/$x.png';

String assetjpg(x) => 'assets/images/jpg/$x.jpg';

String assetsvg(x) => 'assets/images/svg/$x.svg';

String assetjson(x) => 'assets/jsons/$x.json';

String assetvideo(x) => 'assets/videos/$x';

appDebugPrint(m) {
  if (kDebugMode) {
    if (m is! String) {
      print(m);
    } else {
      debugPrint(m);
    }
  }
}

final _logger = Logger();
appDebugTrack({required where, required text, bool onlyDebugMode = true}) {
  if (!onlyDebugMode || kDebugMode) {
    _logger.e("[appDebugTrack][$where] $text");
  }
}

Size textSize({required text, required context, required style}) {
  return (TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: 1,
          textScaleFactor: MediaQuery.of(context).textScaleFactor,
          textDirection: ui.TextDirection.ltr)
        ..layout())
      .size;
}

String currencySymbol(String? currency) {
  if (currency == null) return '';
  try {
    return NumberFormat.simpleCurrency(locale: currency).currencySymbol;
  } catch (_) {}
  try {
    return NumberFormat.simpleCurrency(name: currency).currencySymbol;
  } catch (_) {}
  return '';
}

Color hexColor(String hexColor) {
  try {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  } catch (ex) {
    return Colors.white;
  }
}

String colorToHex(Color color) {
  return '#${color.value.toRadixString(16).padLeft(8, '0')}';
}

DateTime? string2DateTime(String? dateTime,
    {String format = "yyyy-MM-ddTHH:mm:ss.SSSZ"}) {
  if (dateTime == null) return null;
  return DateFormat(format).parse(dateTime);
}

DateTime fromTimestamp(int seconds) {
  return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
}

int toTimestamp(DateTime datetime) {
  return datetime.millisecondsSinceEpoch ~/ 1000;
}
