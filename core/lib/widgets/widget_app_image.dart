// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:internal_core/internal_core.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';

ImageProvider getImageProviderFromUrl(String imageUrl) {
  final correctedUrl = appImageCorrectUrl(imageUrl);

  // Check if the URL contains .avif extension
  // if (correctedUrl.toLowerCase().contains('.avif')) {
  //   return CachedNetworkAvifImageProvider(correctedUrl);
  // }

  return CachedNetworkImageProvider(correctedUrl);
}

class WidgetAppImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final dynamic radius;
  final Widget? errorWidget;
  final Widget? placeholderWidget;
  final bool assetImage;
  final bool autoPrefix;
  final BoxFit fit;
  final Color? color;
  final GlobalKey? imageGlobalKey;
  final Alignment? alignment;

  /// Set headers for the image provider, for example for authentication
  final Map<String, String>? headers;

  final int? memCacheWidth;
  final int? memCacheHeight;
  final int? maxWidthDiskCache;
  final int? maxHeightDiskCache;

  final OctoImageBuilder? imageBuilder;
  final OctoErrorBuilder? errorBuilder;

  const WidgetAppImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.radius = 0,
    this.errorWidget,
    this.placeholderWidget,
    this.assetImage = false,
    this.autoPrefix = true,
    this.fit = BoxFit.cover,
    this.color,
    this.imageGlobalKey,
    this.alignment,
    this.headers,
    this.memCacheWidth,
    this.memCacheHeight,
    this.maxWidthDiskCache,
    this.maxHeightDiskCache,
    this.imageBuilder,
    this.errorBuilder,
  });

  BorderRadius get _radius => radius is BorderRadius
      ? radius
      : radius == 0
          ? BorderRadius.zero
          : radius is int
              ? BorderRadius.circular((radius as int).toDouble())
              : BorderRadius.circular(radius);

  bool get isUrlEmpty =>
      (imageUrl ?? '').trim().isEmpty ||
      (imageUrl ?? '').trim() == appSetup?.networkOptions?.baseUrlAsset;

  Widget get error => errorWidget ?? const SizedBox();

  Widget get placeholder =>
      placeholderWidget ??
      WidgetAppImagePlaceHolder(
        width: width,
        height: height,
        borderRadius: _radius,
      );

  @override
  Widget build(BuildContext context) {
    if (isUrlEmpty) {
      return SizedBox(
        width: width,
        height: height,
        child: error,
      );
    }

    final correctImage =
        autoPrefix && !isUrlEmpty ? appImageCorrectUrl(imageUrl!) : imageUrl!;

    return ClipRRect(
      borderRadius: _radius,
      child: _buildImage(correctImage),
    );
  }

  Widget _buildImage(String correctImage) {
    final provider = (assetImage
        ? AssetImage(imageUrl!)
        : CachedNetworkImageProvider(
            correctImage,
            headers: headers,
            maxWidth: maxWidthDiskCache,
            maxHeight: maxHeightDiskCache,
          )) as ImageProvider;

    return OctoImage(
      key: imageGlobalKey,
      alignment: alignment ?? Alignment.center,
      color: color,
      image: provider,
      fit: fit,
      width: width,
      height: height,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      imageBuilder: imageBuilder ?? (_, child) => child,
      placeholderBuilder: (_) => placeholder,
      errorBuilder: errorBuilder ?? (_, __, ___) => error,
    );
  }
}

class WidgetAppImagePlaceHolder extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? baseColor;
  final Color? highlightColor;
  const WidgetAppImagePlaceHolder({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return WidgetAppShimmer(
      width: width,
      height: height,
      baseColor: baseColor,
      highlightColor: highlightColor,
      borderRadius: borderRadius,
    );
  }
}

class WidgetAppShimmer extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? child;
  final Color? baseColor;
  final Color? highlightColor;
  const WidgetAppShimmer({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.child,
    this.baseColor,
    this.highlightColor,
  });

  Color get _baseColor =>
      baseColor ?? appColors?.shimmerBaseColor ?? hexColor('#F4F6F8');

  Color get _highlightColor =>
      highlightColor ?? appColors?.shimmerHighlightColor ?? Colors.white;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _baseColor,
      highlightColor: _highlightColor,
      child: child ??
          Container(
            width: width ?? 999,
            height: height ?? 999,
            decoration:
                BoxDecoration(color: _baseColor, borderRadius: borderRadius),
          ),
    );
  }
}
