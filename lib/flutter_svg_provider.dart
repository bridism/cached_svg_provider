library flutter_svg_provider;

import 'dart:io';
import 'dart:async';
import 'dart:ui' as ui show Image, Picture;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Get svg string.
typedef SvgStringGetter = Future<String?> Function(SvgImageKey key);

/// An [Enum] of the possible image path sources.
enum SvgSource {
  file,
  asset,
  network,
}

/// Rasterizes given svg picture for displaying in [Image] widget:
///
/// ```dart
/// Image(
///   width: 32,
///   height: 32,
///   image: Svg('assets/my_icon.svg'),
/// )
/// ```
class Svg extends ImageProvider<SvgImageKey> {
  /// Path to svg file or asset
  final String path;

  /// Size in logical pixels to render.
  /// Useful for [DecorationImage].
  /// If not specified, will use size from [Image].
  /// If [Image] not specifies size too, will use default size 100x100.
  final Size? size;

  /// Color to tint the SVG
  final Color? color;

  /// Source of svg image
  final SvgSource source;

  /// Image scale.
  final double? scale;

  /// Get svg string.
  /// Override the default get method.
  /// When returning null, use the default method.
  final SvgStringGetter? svgGetter;

  /// Width and height can also be specified from [Image] constructor.
  /// Default size is 100x100 logical pixels.
  /// Different size can be specified in [Image] parameters
  const Svg(
    this.path, {
    this.size,
    this.scale,
    this.color,
    this.source = SvgSource.asset,
    this.svgGetter,
  });

  @override
  Future<SvgImageKey> obtainKey(ImageConfiguration configuration) {
    final Color color = this.color ?? Colors.transparent;
    final double scale = this.scale ?? configuration.devicePixelRatio ?? 1.0;
    final double logicWidth = size?.width ?? configuration.size?.width ?? 100;
    final double logicHeight = size?.height ?? configuration.size?.width ?? 100;

    return SynchronousFuture<SvgImageKey>(
      SvgImageKey(
        path: path,
        scale: scale,
        color: color,
        source: source,
        pixelWidth: (logicWidth * scale).round(),
        pixelHeight: (logicHeight * scale).round(),
        svgGetter: svgGetter,
      ),
    );
  }

  @override
  ImageStreamCompleter load(SvgImageKey key, nil) {
    return OneFrameImageStreamCompleter(_loadAsync(key));
  }

  static Future<String> _getSvgString(SvgImageKey key) async {
    if (key.svgGetter != null) {
      final rawSvg = await key.svgGetter!.call(key);
      if (rawSvg != null) {
        return rawSvg;
      }
    }
    switch (key.source) {
      case SvgSource.network:
        return await http.read(Uri.parse(key.path));
      case SvgSource.asset:
        return await rootBundle.loadString(key.path);
      case SvgSource.file:
        return await File(key.path).readAsString();
    }
  }

  static Future<ImageInfo> _loadAsync(SvgImageKey key) async {
    final stream = DefaultCacheManager().getImageFile(key.path, key: key.path);
    FileInfo? res;
    await for (var result in stream) {
      if (result is FileInfo) {
        res = result;
        break;
      }
    }

    if (res == null) {
      final String rawSvg =
          '''<svg width="68" height="68" viewBox="0 0 68 68" fill="none" xmlns="http://www.w3.org/2000/svg">
<circle cx="34" cy="34" r="34" fill="#E5E9ED"/>
<path d="M40.5107 32.5239C42.8847 32.5239 44.8092 28.9776 44.8092 24.603C44.8092 20.2284 42.8847 16.6821 40.5107 16.6821C38.1367 16.6821 36.2122 20.2284 36.2122 24.603C36.2122 28.9776 38.1367 32.5239 40.5107 32.5239Z" fill="#E5E9ED"/>
<path fill-rule="evenodd" clip-rule="evenodd" d="M38.0707 19.3273C37.3568 20.6427 36.8943 22.5067 36.8943 24.6029C36.8943 26.6991 37.3568 28.5631 38.0707 29.8785C38.799 31.2205 39.6921 31.8418 40.5108 31.8418C41.3294 31.8418 42.2226 31.2205 42.9509 29.8785C43.6648 28.5631 44.1273 26.6991 44.1273 24.6029C44.1273 22.5067 43.6648 20.6427 42.9509 19.3273C42.2226 17.9852 41.3294 17.364 40.5108 17.364C39.6921 17.364 38.799 17.9852 38.0707 19.3273ZM36.8719 18.6767C37.6993 17.1519 38.9554 16 40.5108 16C42.0662 16 43.3223 17.1519 44.1497 18.6767C44.9916 20.228 45.4913 22.3245 45.4913 24.6029C45.4913 26.8813 44.9916 28.9778 44.1497 30.5291C43.3223 32.0539 42.0662 33.2058 40.5108 33.2058C38.9554 33.2058 37.6993 32.0539 36.8719 30.5291C36.03 28.9778 35.5303 26.8813 35.5303 24.6029C35.5303 22.3245 36.03 20.228 36.8719 18.6767Z" fill="#C0C6CD"/>
<path d="M42.4186 30.5644C44.0075 30.5644 45.2956 27.9917 45.2956 24.8181C45.2956 21.6445 44.0075 19.0718 42.4186 19.0718C40.8296 19.0718 39.5415 21.6445 39.5415 24.8181C39.5415 27.9917 40.8296 30.5644 42.4186 30.5644Z" fill="#C0C6CD"/>
<path d="M27.4838 32.5239C29.8578 32.5239 31.7824 28.9776 31.7824 24.603C31.7824 20.2284 29.8578 16.6821 27.4838 16.6821C25.1098 16.6821 23.1853 20.2284 23.1853 24.603C23.1853 28.9776 25.1098 32.5239 27.4838 32.5239Z" fill="#E5E9ED"/>
<path fill-rule="evenodd" clip-rule="evenodd" d="M25.0438 19.3273C24.33 20.6427 23.8674 22.5067 23.8674 24.6029C23.8674 26.6991 24.33 28.5631 25.0438 29.8785C25.7721 31.2205 26.6653 31.8418 27.4839 31.8418C28.3026 31.8418 29.1957 31.2205 29.924 29.8785C30.6379 28.5631 31.1005 26.6991 31.1005 24.6029C31.1005 22.5067 30.6379 20.6427 29.924 19.3273C29.1957 17.9852 28.3026 17.364 27.4839 17.364C26.6653 17.364 25.7721 17.9852 25.0438 19.3273ZM23.845 18.6767C24.6725 17.1519 25.9286 16 27.4839 16C29.0393 16 30.2954 17.1519 31.1229 18.6767C31.9648 20.228 32.4645 22.3245 32.4645 24.6029C32.4645 26.8813 31.9648 28.9778 31.1229 30.5291C30.2954 32.0539 29.0393 33.2058 27.4839 33.2058C25.9286 33.2058 24.6725 32.0539 23.845 30.5291C23.0031 28.9778 22.5034 26.8813 22.5034 24.6029C22.5034 22.3245 23.0031 20.228 23.845 18.6767Z" fill="#C0C6CD"/>
<path d="M29.3907 30.5644C30.9797 30.5644 32.2678 27.9917 32.2678 24.8181C32.2678 21.6445 30.9797 19.0718 29.3907 19.0718C27.8018 19.0718 26.5137 21.6445 26.5137 24.8181C26.5137 27.9917 27.8018 30.5644 29.3907 30.5644Z" fill="#C0C6CD"/>
<path d="M14.4381 38.0755L16.019 37.895C16.2145 37.873 16.416 37.8569 16.6245 37.8489C16.832 37.8399 17.0074 37.8369 17.1498 37.8379C17.2921 37.8379 17.3824 37.8389 17.4214 37.8389L17.4184 37.8138L14.3559 37.3427L14.2306 36.24L17.1017 35.0861L17.0987 35.061C17.0606 35.0691 16.9743 35.0911 16.838 35.1262C16.7017 35.1613 16.5323 35.1984 16.3277 35.2395C16.1232 35.2796 15.9237 35.3117 15.7283 35.3337L14.1474 35.5142L14 34.22L18.3858 33.7197L18.6124 35.7086L16.1573 36.66L16.1603 36.685L18.7658 37.053L18.9843 38.9717L14.5985 39.4719L14.4391 38.0755H14.4381Z" fill="#C0C6CD"/>
<path d="M19.0865 38.916L20.5751 42.4317L19.6007 42.8447L18.6654 40.6353L18.104 40.8728L18.905 42.7635L17.9717 43.1585L17.1707 41.2678L16.5502 41.5305L17.5036 43.781L16.5292 44.194L15.0234 40.6373L19.0885 38.916H19.0865Z" fill="#C0C6CD"/>
<path d="M20.5812 42.4073L22.8748 45.4588L22.0287 46.0944L20.5872 44.1756L20.1 44.5415L21.333 46.1826L20.523 46.7911L19.29 45.1501L18.7516 45.5551L20.2203 47.5089L19.3742 48.1444L17.0544 45.0568L20.5832 42.4053L20.5812 42.4073Z" fill="#C0C6CD"/>
<path d="M24.1319 47.9201L22.0557 50.4653L20.957 49.5691L23.0332 47.0238L21.9094 46.1076L22.6231 45.2324L25.9634 47.9581L25.2496 48.8333L24.1309 47.9211L24.1319 47.9201Z" fill="#C0C6CD"/>
<path d="M29.3949 53.9839L29.8651 52.4641C29.9232 52.2767 29.9904 52.0852 30.0656 51.8917C30.1407 51.6983 30.2079 51.5359 30.266 51.4065C30.3242 51.2772 30.3613 51.194 30.3763 51.1589L30.3523 51.1509L28.6902 53.7664L27.6295 53.4386L27.7268 50.3459L27.7027 50.3379C27.6957 50.376 27.6807 50.4642 27.6576 50.6025C27.6346 50.7409 27.6015 50.9123 27.5564 51.1148C27.5112 51.3183 27.4601 51.5138 27.402 51.7013L26.9318 53.221L25.6877 52.8361L26.992 48.6187L28.9047 49.2101L28.7894 51.8406L28.8135 51.8486L30.1969 49.6101L32.0414 50.1805L30.7372 54.3979L29.3949 53.9829V53.9839Z" fill="#C0C6CD"/>
<path d="M34.7211 54.4964L33.3036 54.5115L33.2846 52.7983L31.5032 50.1166L33.1322 50.0986L33.9953 51.5582H34.0214L34.8524 50.0795L36.3983 50.0625L34.7021 52.7822L34.7211 54.4954V54.4964Z" fill="#C0C6CD"/>
<path d="M37.6733 49.7676L41.0366 48.5776L41.3895 49.5761L39.3635 50.2929L39.6161 51.0066L41.3584 50.3901L41.6963 51.3455L39.954 51.962L40.4823 53.4557L39.146 53.9288L37.6743 49.7676H37.6733Z" fill="#C0C6CD"/>
<path d="M45.3983 48.1928C45.3973 48.4555 45.3091 48.7061 45.1337 48.9447L46.9712 49.9452L45.6439 50.8223L44.1031 49.9101L43.664 50.1998L44.5522 51.5431L43.3693 52.325L40.9353 48.6429L43.1889 47.1533C43.4525 46.9788 43.7122 46.8806 43.9668 46.8585C44.2214 46.8365 44.453 46.8806 44.6625 46.9909C44.871 47.1011 45.0434 47.2585 45.1778 47.462C45.3261 47.6866 45.4003 47.9302 45.3993 48.1928H45.3983ZM43.7493 48.1297C43.643 48.1076 43.5427 48.1277 43.4495 48.1888L42.6736 48.7021L43.1227 49.3818L43.8986 48.8685C43.9908 48.8074 44.048 48.7221 44.069 48.6139C44.0901 48.5056 44.069 48.4034 44.0049 48.3071C43.9407 48.2109 43.8555 48.1517 43.7493 48.1297Z" fill="#C0C6CD"/>
<path d="M47.5165 49.3113L44.4329 46.1535L45.4474 45.1631L48.531 48.3209L47.5165 49.3113Z" fill="#C0C6CD"/>
<path d="M45.7041 45.0189L47.9176 41.9082L48.7797 42.5217L47.3883 44.4765L47.8845 44.8294L49.0744 43.1563L49.9005 43.7437L48.7106 45.4169L49.2599 45.8078L50.6774 43.8159L51.5395 44.4294L49.3 47.5762L45.7031 45.0169L45.7041 45.0189Z" fill="#C0C6CD"/>
<path d="M53.1597 40.532L50.5072 41.5274L52.5171 42.2703L52.065 43.4923L47.9248 41.9615L48.3539 40.8006L51.0365 39.8162L48.9965 39.0623L49.4486 37.8403L53.5888 39.3711L53.1597 40.532Z" fill="#C0C6CD"/>
<path d="M51.9629 33.717C53.4295 33.8293 54.1042 34.6553 53.9869 36.1951L53.8406 38.1018L49.4397 37.765L49.5851 35.8583C49.7023 34.3185 50.4953 33.6047 51.9619 33.717H51.9629ZM52.8932 36.6061L52.9293 36.139C52.9744 35.5465 52.6797 35.2257 52.0441 35.1766L51.6602 35.1475C51.0246 35.0994 50.6838 35.3711 50.6387 35.9636L50.6026 36.4307L52.8932 36.6061Z" fill="#C0C6CD"/>
</svg>''';
      final DrawableRoot svgRoot = await svg.fromSvgString(rawSvg, rawSvg);
      final Picture picture = svgRoot.toPicture();
      final image = await picture.toImage(100, 100);
      return ImageInfo(
        image: image,
        scale: key.scale,
      );
    }

    var file = res.file;
    var bytes = await file.readAsBytes();
    final DrawableRoot svgRoot = await svg.fromSvgBytes(bytes, key.path);
    final ui.Picture picture = svgRoot.toPicture(
      size: Size(
        key.pixelWidth.toDouble(),
        key.pixelHeight.toDouble(),
      ),
      clipToViewBox: false,
      colorFilter: ColorFilter.mode(
        getFilterColor(key.color),
        BlendMode.srcATop,
      ),
    );
    final ui.Image image = await picture.toImage(
      key.pixelWidth,
      key.pixelHeight,
    );

    return ImageInfo(
      image: image,
      scale: key.scale,
    );
  }

  // Note: == and hashCode not overrided as changes in properties
  // (width, height and scale) are not observable from the here.
  // [SvgImageKey] instances will be compared instead.
  @override
  String toString() => '$runtimeType(${describeIdentity(path)})';

  // Running on web with Colors.transparent may throws the exception `Expected a value of type 'SkDeletable', but got one of type 'Null'`.
  static Color getFilterColor(color) {
    if (kIsWeb && color == Colors.transparent) {
      return const Color(0x01ffffff);
    } else {
      return color ?? Colors.transparent;
    }
  }
}

@immutable
class SvgImageKey {
  const SvgImageKey({
    required this.path,
    required this.pixelWidth,
    required this.pixelHeight,
    required this.scale,
    required this.source,
    this.color,
    this.svgGetter,
  });

  /// Path to svg asset.
  final String path;

  /// Width in physical pixels.
  /// Used when raterizing.
  final int pixelWidth;

  /// Height in physical pixels.
  /// Used when raterizing.
  final int pixelHeight;

  /// Color to tint the SVG
  final Color? color;

  /// Image source.
  final SvgSource source;

  /// Used to calculate logical size from physical, i.e.
  /// logicalWidth = [pixelWidth] / [scale],
  /// logicalHeight = [pixelHeight] / [scale].
  /// Should be equal to [MediaQueryData.devicePixelRatio].
  final double scale;

  /// Svg string getter.
  final SvgStringGetter? svgGetter;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is SvgImageKey &&
        other.path == path &&
        other.pixelWidth == pixelWidth &&
        other.pixelHeight == pixelHeight &&
        other.scale == scale &&
        other.source == source &&
        other.svgGetter == svgGetter;
  }

  @override
  int get hashCode => Object.hash(path, pixelWidth, pixelHeight, scale, source, svgGetter);

  @override
  String toString() => '${objectRuntimeType(this, 'SvgImageKey')}'
      '(path: "$path", pixelWidth: $pixelWidth, pixelHeight: $pixelHeight, scale: $scale, source: $source)';
}
