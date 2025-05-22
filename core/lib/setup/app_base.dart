part of '../internal_core.dart';

enum AppEnv { preprod, prod }

const String keyAccessToken = "accessToken";
const String keyRefreshToken = "refreshToken";
const String keyThemeMode = "themeMode";
const String keyThemeModeDark = "themeModeDark";
const String keyThemeModeLight = "themeModeLight";
const String keyLanguageCode = "languageCode";

class AppTextStyleWrap {
  TextStyle Function(TextStyle style) fontWrap;
  double Function()? fontSize;
  double Function()? height;

  AppTextStyleWrap({
    required this.fontWrap,
    this.height,
    this.fontSize,
  });
}

abstract class PNetworkOptions {
  final String baseUrl;
  final String baseUrlAsset;
  final String? mqttUrl;
  final int? mqttPort;

  String appImageCorrectUrl(String url, {base}) {
    if (url.trim().indexOf('http') != 0) {
      if ((base ?? baseUrlAsset ?? '').endsWith('/')) {
        if (url.startsWith('/')) {
          return (base ?? baseUrlAsset ?? '') + url.substring(1);
        } else {
          return (base ?? baseUrlAsset ?? '') + url;
        }
      } else {
        if (url.startsWith('/')) {
          return (base ?? baseUrlAsset ?? '') + url;
        } else {
          return (base ?? baseUrlAsset ?? '') + '/' + url;
        }
      }
    }
    return url;
  }

  PNetworkOptions({
    required this.baseUrl,
    required this.baseUrlAsset,
    this.mqttUrl,
    this.mqttPort,
  });

  @override
  String toString() {
    return 'PNetworkOptions(baseUrl: $baseUrl, baseUrlAsset: $baseUrlAsset, mqttUrl: $mqttUrl, mqttPort: $mqttPort)';
  }
}

class PNetworkOptionsOther extends PNetworkOptions {
  PNetworkOptionsOther({super.baseUrl = '', super.baseUrlAsset = ''});
}
