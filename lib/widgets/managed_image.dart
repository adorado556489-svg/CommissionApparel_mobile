import 'package:flutter/material.dart';

import '../utils/image_url.dart';

/// Network image with consistent loading, error and empty states.
///
/// Only `http(s)` URLs are rendered from the network; anything else (null,
/// empty, legacy local/asset paths) shows the [placeholderIcon] instead of
/// crashing on a missing asset.
///
/// Images are requested at the size they are shown (Cloudinary resize at the
/// CDN) and decoded at that size (`cacheWidth`), so long lists of previews do
/// not exhaust device memory.
class AppImage extends StatelessWidget {
  final String? url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final IconData placeholderIcon;
  final BorderRadius? borderRadius;

  const AppImage(
    this.url, {
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholderIcon = Icons.image_outlined,
    this.borderRadius,
  });

  static bool isRenderable(String? url) =>
      url != null && (url.startsWith('https://') || url.startsWith('http://'));

  @override
  Widget build(BuildContext context) {
    final Widget child = isRenderable(url)
        ? LayoutBuilder(builder: (context, constraints) => _network(context, constraints))
        : _box(context, Icon(placeholderIcon, size: 36, color: Theme.of(context).disabledColor));

    return borderRadius == null
        ? child
        : ClipRRect(borderRadius: borderRadius!, child: child);
  }

  Widget _network(BuildContext context, BoxConstraints constraints) {
    final dpr = MediaQuery.maybeOf(context)?.devicePixelRatio ?? 2.0;
    final logical = (width != null && width!.isFinite)
        ? width!
        : (constraints.hasBoundedWidth && constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 400.0);
    final decodePx = (logical * dpr).round().clamp(100, 1200);

    return Image.network(
      ImageUrls.optimized(url!, width: decodePx),
      fit: fit,
      width: width,
      height: height,
      cacheWidth: decodePx,
      gaplessPlayback: true,
      loadingBuilder: (context, img, progress) => progress == null
          ? img
          : _box(
              context,
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
      errorBuilder: (context, error, stack) {
        debugPrint('AppImage: failed to load $url ($error)');
        return _box(
          context,
          Icon(Icons.broken_image_outlined, color: Theme.of(context).disabledColor),
        );
      },
    );
  }

  Widget _box(BuildContext context, Widget child) => Container(
        width: width,
        height: height,
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        alignment: Alignment.center,
        child: child,
      );
}
