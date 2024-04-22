import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:octo_image/octo_image.dart';

import '../setup/index.dart';
import 'widget_app_image_placeholder.dart';

class WidgetAppImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final Widget? errorWidget;
  final Widget? placeholderWidget;
  final bool assetImage;
  final bool autoPrefix;
  final BoxFit boxFit;
  final Color? color;

  /// Set headers for the image provider, for example for authentication
  final Map<String, String>? headers;

  //radius
  final BorderRadius? borderRadius;
  final double radius;

  //image builder
  final Widget Function(BuildContext context, Widget child)? imageBuilder;

  const WidgetAppImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.placeholderWidget,
    this.errorWidget,
    this.assetImage = false,
    this.autoPrefix = true,
    this.boxFit = BoxFit.cover,
    this.color,
    this.headers,
    this.radius = 0,
    this.borderRadius,
    this.imageBuilder,
  });

  BorderRadius get _borderRadius =>
      borderRadius ?? BorderRadius.circular(radius);

  bool get isUrlEmpty => (imageUrl ?? '').trim().isEmpty;

  Widget get error => errorWidget ?? const SizedBox();

  Widget get placeholder =>
      placeholderWidget ??
      WidgetAppImagePlaceHolder(
        width: width,
        height: height,
        borderRadius: _borderRadius,
      );

  @override
  Widget build(BuildContext context) {
    if (isUrlEmpty) return SizedBox(width: width, height: height, child: error);
    String correctImage = imageUrl!;
    if (autoPrefix && !isUrlEmpty) {
      correctImage =
          appSetup?.networkOptions?.appImageCorrectUrl.call(correctImage) ??
              correctImage;
    }

    return ClipRRect(
        borderRadius: _borderRadius, child: _buildImage(correctImage));
  }

  Widget _buildImage(String correctImage) {
    ImageProvider provider = (assetImage
            ? AssetImage(imageUrl!)
            : CachedNetworkImageProvider(correctImage, headers: headers))
        as ImageProvider;
    return OctoImage(
      color: color,
      image: provider,
      fit: boxFit,
      width: width,
      height: height,
      imageBuilder: imageBuilder,
      placeholderBuilder: (_) => placeholder,
      errorBuilder: (_, object, trace) => error,
    );
  }
}
