import 'dart:async';

import 'package:dash_flags/dash_flags.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_avif/flutter_avif.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../internal_core.dart';

class WidgetAppFlag extends StatelessWidget {
  final String? countryCode;
  final String? languageCode;
  final double height;
  final Widget? errorBuilder;
  final double radius;
  const WidgetAppFlag.languageCode({
    super.key,
    this.height = 24,
    this.errorBuilder,
    this.radius = 0,
    required this.languageCode,
  }) : countryCode = null;

  const WidgetAppFlag.countryCode({
    super.key,
    required this.countryCode,
    this.height = 24,
    this.errorBuilder,
    this.radius = 0,
  }) : languageCode = null;

  @override
  Widget build(BuildContext context) {
    Widget child = const SizedBox();
    if (languageCode != null) {
      child = LanguageFlag(
        language: Language.fromCode(languageCode!.toLowerCase()),
        height: height,
      );
    } else if (countryCode != null) {
      child = CountryFlag(
        country: Country.fromCode(countryCode!.toLowerCase()),
        height: height,
      );
    } else {
      child = errorBuilder ?? const SizedBox();
    }
    if (radius != 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: child,
      );
    }
    return child;
  }
}

class WidgetAssetImage extends StatelessWidget {
  final String _name;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit? fit;
  final String? package;
  final BorderRadius? borderRadius;

  const WidgetAssetImage(String name,
      {super.key,
      this.width,
      this.height,
      this.color,
      this.fit,
      this.package,
      this.borderRadius})
      : _name = name;

  WidgetAssetImage.png(String name,
      {super.key,
      this.width,
      this.height,
      this.color,
      this.fit,
      this.package,
      this.borderRadius})
      : _name = assetpng(name);

  WidgetAssetImage.jpg(String name,
      {super.key,
      this.width,
      this.height,
      this.color,
      this.fit,
      this.package,
      this.borderRadius})
      : _name = assetjpg(name);

  Widget get image => _name.contains('.avif')
      ? AvifImage.asset(
          _name,
          width: width,
          height: height,
          color: color,
          fit: fit,
        )
      : Image.asset(
          _name,
          width: width,
          height: height,
          color: color,
          fit: fit,
        );

  @override
  Widget build(BuildContext context) {
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }
    return image;
  }
}

class WidgetAppSVG extends StatelessWidget {
  final String asset;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;
  final String? package;
  final String? url;

  const WidgetAppSVG(
    this.asset, {
    super.key,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.contain,
    this.package,
  }) : url = null;

  const WidgetAppSVG.network(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.contain,
  })  : asset = "",
        package = null;

  @override
  Widget build(BuildContext context) {
    if (url != null) {
      return SvgPicture.network(
        url!,
        width: width,
        height: height,
        fit: fit,
        colorFilter:
            color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
      );
    }
    return SvgPicture.asset(
      asset.startsWith('assets/') ? asset : assetsvg(asset),
      package: package,
      width: width,
      height: height,
      fit: fit,
      colorFilter:
          color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
    );
  }
}

class WidgetAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius1;
  final double radius2;
  final double radius3;
  final Color? backgroundColor;
  final Color? borderColor;
  final String? errorAsset;
  final Function()? onTap;
  final bool isWithoutBorder;
  final Widget Function()? placeholderBuilder;

  const WidgetAvatar({
    super.key,
    required this.imageUrl,
    required this.radius1,
    required this.radius2,
    required this.radius3,
    this.placeholderBuilder,
    this.onTap,
    this.backgroundColor,
    this.errorAsset,
    this.borderColor,
    this.isWithoutBorder = false,
  });

  factory WidgetAvatar.withoutBorder({
    Key? key,
    required String? imageUrl,
    required double radius,
    Widget Function()? placeholderBuilder,
    Function()? onTap,
    String? errorAsset,
  }) =>
      WidgetAvatar(
        key: key,
        imageUrl: imageUrl,
        radius1: radius,
        radius2: radius,
        radius3: radius,
        placeholderBuilder: placeholderBuilder,
        onTap: onTap,
        errorAsset: errorAsset,
        isWithoutBorder: true,
        borderColor: Colors.transparent,
        backgroundColor: Colors.transparent,
      );

  @override
  Widget build(BuildContext context) {
    final child = WidgetAppImage(
      imageUrl: imageUrl,
      width: radius3 * 2,
      height: radius3 * 2,
      radius: radius3 * 2,
      placeholderWidget: placeholderBuilder?.call(),
      errorWidget: _buildErrorWidget(),
    );

    return GestureDetector(
      onTap: onTap,
      child: isWithoutBorder ? child : _buildBorderedAvatar(child),
    );
  }

  Widget _buildErrorWidget() {
    return CircleAvatar(
      backgroundColor: Colors.transparent,
      backgroundImage: AssetImage(
        errorAsset ?? assetpng('default_avatar'),
        package: errorAsset != null ? null : 'internal_core',
      ),
    );
  }

  Widget _buildBorderedAvatar(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          width: radius1 - radius2,
          color: borderColor ?? appColors?.text ?? Colors.white,
        ),
        shape: BoxShape.circle,
      ),
      width: radius1 * 2,
      height: radius1 * 2,
      padding: EdgeInsets.all(radius2 - radius3),
      child: Center(child: child),
    );
  }
}

class WidgetCircleAvatar extends StatelessWidget {
  const WidgetCircleAvatar({
    super.key,
    this.borderWidth = 2,
    this.borderColor,
    this.url,
    required this.radius,
    this.boxShadow,
    this.child,
    this.backgroundColor,
  });

  final double borderWidth;
  final Color? borderColor;
  final String? url;
  final double radius;
  final List<BoxShadow>? boxShadow;
  final Widget? child;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(borderWidth),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: borderColor ?? Colors.white,
        boxShadow: boxShadow,
      ),
      child: child != null
          ? CircleAvatar(
              radius: radius,
              backgroundColor: backgroundColor,
              child: child!,
            )
          : WidgetAppImage(
              imageUrl: url,
              height: radius * 2,
              width: radius * 2,
              radius: radius,
            ),
    );
  }
}

class WidgetToastable extends StatefulWidget {
  final bool isManually;

  final Widget Function(BuildContext context) builder;
  final Widget child;
  final bool visible;
  final Duration? duration;

  final Alignment? follower;
  final Alignment? target;

  final VoidCallback? callback;

  const WidgetToastable({
    super.key,
    this.isManually = false,
    required this.builder,
    required this.child,
    this.follower,
    this.target,
    this.visible = false,
    this.duration,
    this.callback,
  });

  @override
  State<WidgetToastable> createState() => WidgetToastableState();
}

class WidgetToastableState extends State<WidgetToastable> {
  bool _tooltip = false;
  Timer? _timer;

  void displayToast() {
    setState(() {
      _tooltip = true;
    });
    widget.callback?.call();
    _timer?.cancel();
    _timer = Timer(widget.duration ?? const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _tooltip = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PortalTarget(
      visible: _tooltip || widget.visible,
      anchor: Aligned(
          follower: widget.follower ?? Alignment.bottomCenter,
          target: widget.target ?? Alignment.topCenter,
          offset: const Offset(0, -8)),
      portalFollower: widget.builder(context),
      child: widget.isManually
          ? widget.child
          : WidgetInkWellTransparent(
              enableInkWell: false,
              onTap: displayToast,
              child: widget.child,
            ),
    );
  }
}

class WidgetTimer extends StatefulWidget {
  final Widget Function() builder;
  final Duration duration;
  const WidgetTimer(
      {super.key,
      required this.builder,
      this.duration = const Duration(seconds: 1)});

  @override
  _WidgetTimerState createState() => _WidgetTimerState();
}

class _WidgetTimerState extends State<WidgetTimer> {
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _timer?.cancel();
    _timer = null;
    _timer = Timer.periodic(widget.duration, (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
    _timer = null;
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder();
  }
}

class WidgetToolTipable extends StatelessWidget {
  final String message;
  final Widget child;
  const WidgetToolTipable({
    super.key,
    required this.message,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      child: child,
    );
  }
}

class WidgetLoadingCupertino extends StatelessWidget {
  final double size;
  final Color? color;
  const WidgetLoadingCupertino({super.key, this.color, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: size,
        width: size,
        child: CupertinoActivityIndicator(
          radius: size / 2,
          color: color ?? Colors.white,
        ),
      ),
    );
  }
}

const kSpacingHeight4 = SizedBox(height: 4);
const kSpacingHeight8 = SizedBox(height: 8);
const kSpacingHeight12 = SizedBox(height: 12);
const kSpacingHeight16 = SizedBox(height: 16);
const kSpacingHeight20 = SizedBox(height: 20);
const kSpacingHeight24 = SizedBox(height: 24);
const kSpacingHeight28 = SizedBox(height: 28);
const kSpacingHeight32 = SizedBox(height: 32);
const kSpacingHeight36 = SizedBox(height: 36);
const kSpacingHeight40 = SizedBox(height: 40);
const kSpacingHeight44 = SizedBox(height: 44);
const kSpacingHeight48 = SizedBox(height: 48);
const kSpacingHeight52 = SizedBox(height: 52);
const kSpacingHeight56 = SizedBox(height: 56);
const kSpacingHeight60 = SizedBox(height: 60);

const kSpacingWidth4 = SizedBox(width: 4);
const kSpacingWidth8 = SizedBox(width: 8);
const kSpacingWidth12 = SizedBox(width: 12);
const kSpacingWidth16 = SizedBox(width: 16);
const kSpacingWidth20 = SizedBox(width: 20);
const kSpacingWidth24 = SizedBox(width: 24);
const kSpacingWidth28 = SizedBox(width: 28);
const kSpacingWidth32 = SizedBox(width: 32);
const kSpacingWidth36 = SizedBox(width: 36);
const kSpacingWidth40 = SizedBox(width: 40);
const kSpacingWidth44 = SizedBox(width: 44);
const kSpacingWidth48 = SizedBox(width: 48);
const kSpacingWidth52 = SizedBox(width: 52);
const kSpacingWidth56 = SizedBox(width: 56);
const kSpacingWidth60 = SizedBox(width: 60);
