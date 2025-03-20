import 'package:flutter/material.dart';

import 'app_base.dart';

AppSetup? get appSetup => AppSetup._instance;
dynamic  get appColors => appSetup?.appColors;
dynamic  get appPrefs => appSetup?.appPrefs; 

BuildContext? get findAppContext => appSetup?.findAppContext?.call();

class AppSetup {
  static AppSetup? _instance;
  static initialized({required AppSetup value}) {
    _instance = value;
  }

  AppEnv env;
  dynamic appPrefs;
  dynamic appColors;
  AppTextStyleWrap? appTextStyleWrap;
  BuildContext? Function()? findAppContext;

  PNetworkOptions? networkOptions;

  AppSetup({
    required this.env,
    required this.appPrefs,
    required this.appColors,
    this.appTextStyleWrap,
    this.findAppContext,
    this.networkOptions,
  });

  AppSetup copyWith({
    AppEnv? env,
    dynamic appPrefs,
    dynamic appColors,
    AppTextStyleWrap? appTextStyleWrap,
    BuildContext? Function()? findAppContext,
    PNetworkOptions? networkOptions,
  }) {
    return AppSetup(
      env: env ?? this.env,
      appPrefs: appPrefs ?? this.appPrefs,
      appColors: appColors ?? this.appColors,
      appTextStyleWrap: appTextStyleWrap ?? this.appTextStyleWrap,
      findAppContext: findAppContext ?? this.findAppContext,
      networkOptions: networkOptions ?? this.networkOptions,
    );
  }
}
