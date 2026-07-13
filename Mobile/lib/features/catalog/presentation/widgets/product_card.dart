import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/primitives.dart';
import '../../../favorites/presentation/providers/favorites_providers.dart';
import '../../domain/entities/product.dart';

/// Grid ve yatay raylarda kullanılan ürün kartı.
class ProductCard extends ConsumerWidget {
  const ProductCard({super.key, required this.product, this.width});

  final Product product;

  /// Yatay raylarda sabit genişlik; grid'de null bırakılır.
  final double? width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isFavorite =
        ref.watch(favoritesControllerProvider).value?.contains(product.id) ??
            false;

    final card = Card(
      child: InkWell(
        onTap: () => context.push('/product/${product.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: AppNetworkImage(url: product.primaryImage),
                ),
                if (product.hasDiscount)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: DiscountBadge(percent: product.discountPercent),
                  ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Material(
                    color: theme.colorScheme.surface.withValues(alpha: 0.9),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => ref
                          .read(favoritesControllerProvider.notifier)
                          .toggle(product.id),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 20,
                          color: isFavorite
                              ? AppColors.danger
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
                if (!product.inStock)
                  Positioned.fill(
                    child: ColoredBox(
                      color: Colors.black38,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Tükendi',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${product.brand} ',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12.5,
                            ),
                          ),
                          TextSpan(
                            text: product.name,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    RatingStars(
                      rating: product.rating,
                      reviewCount: product.reviewCount,
                      size: 13,
                    ),
                    const Spacer(),
                    PriceText(
                      price: product.price,
                      originalPrice: product.originalPrice,
                      fontSize: 14.5,
                    ),
                    if (product.freeShipping || product.lowStock) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (product.freeShipping)
                            const Flexible(
                              child: Text(
                                'Kargo Bedava',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                          if (product.freeShipping && product.lowStock)
                            const SizedBox(width: 6),
                          if (product.lowStock)
                            Flexible(
                              child: Text(
                                'Son ${product.stock} ürün!',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.danger,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return width == null ? card : SizedBox(width: width, child: card);
  }
}
