import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Ürün görselleri için tek giriş noktası.
///
/// Mobilde (Android/iOS) disk cache'li [CachedNetworkImage], masaüstünde
/// [Image.network] kullanır (cache manager'ın sqflite bağımlılığı masaüstünü
/// desteklemiyor). Yükleniyor ve hata durumları her platformda aynı görünür.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
  });

  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  static bool get _useDiskCache =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  Widget build(BuildContext context) {
    final Widget image;
    if (_useDiskCache) {
      image = CachedNetworkImage(
        imageUrl: url,
        fit: fit,
        width: width,
        height: height,
        placeholder: (_, _) => const _ImageFallback(loading: true),
        errorWidget: (_, _, _) => const _ImageFallback(loading: false),
      );
    } else {
      image = Image.network(
        url,
        fit: fit,
        width: width,
        height: height,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : const _ImageFallback(loading: true),
        errorBuilder: (_, _, _) => const _ImageFallback(loading: false),
      );
    }

    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({required this.loading});

  final bool loading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
      alignment: Alignment.center,
      child: Icon(
        loading ? Icons.image_outlined : Icons.broken_image_outlined,
        size: 28,
        color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
    );
  }
}
