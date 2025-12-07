import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

export 'widgets/widgets.dart';
export 'extensions/extensions.dart';

export 'network/network.dart';

part 'setup/app_base.dart';
part 'setup/app_setup.dart';
part 'setup/app_textstyles.dart';
part 'setup/app_utils.dart';

//// HOW TO USE

//// ==== Start point:
// internalSetup() {
//   AppSetup.initialized(
//     value: AppSetup(
//       env: AppEnv.preprod,
//       appColors: AppColors.instance,
//       appPrefs: AppPrefs.instance,
//     ),
//   );
// }

//// main.dart
// internalSetup()
