import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/feedback_widgets.dart';
import '../../../../core/widgets/primitives.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../favorites/presentation/providers/favorites_providers.dart';
import '../../domain/entities/product.dart';
import '../providers/catalog_providers.dart';
import '../widgets/product_card.dart';
import '../widgets/review_section.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _imageIndex = 0;
  bool _addingToCart = false;

  Future<void> _addToCart(Product product) async {
    setState(() => _addingToCart = true);
    try {
      await ref.read(cartControllerProvider.notifier).add(product.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Ürün sepete eklendi 🛒'),
          backgroundColor: AppColors.success,
          // Bu ekranın özel alt barı var; floating SnackBar alçak
          // pencerelerde (masaüstü) taşma hatası verdiği için fixed.
          behavior: SnackBarBehavior.fixed,
          action: SnackBarAction(
            label: 'Sepete Git',
            textColor: Colors.white,
            onPressed: () => context.go('/cart'),
          ),
        ),
      );
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.danger),
      );
    } finally {
      if (mounted) setState(() => _addingToCart = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productDetailProvider(widget.productId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: state.value == null ? null : Text(state.value!.brand),
        actions: [
          if (state.value != null)
            Consumer(
              builder: (context, ref, _) {
                final isFavorite = ref
                        .watch(favoritesControllerProvider)
                        .value
                        ?.contains(widget.productId) ??
                    false;
                return IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? AppColors.danger : null,
                  ),
                  onPressed: () => ref
                      .read(favoritesControllerProvider.notifier)
                      .toggle(widget.productId),
                  tooltip: 'Favorilere ekle/çıkar',
                );
              },
            ),
        ],
      ),
      body: state.when(
        data: (product) => ListView(
          children: [
            SizedBox(
              height: 320,
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: product.images.length,
                    onPageChanged: (i) => setState(() => _imageIndex = i),
                    itemBuilder: (_, i) => AppNetworkImage(
                      url: product.images[i],
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (product.hasDiscount)
                    Positioned(
                      top: 12,
                      left: 12,
                      child:
                          DiscountBadge(percent: product.discountPercent),
                    ),
                  if (product.images.length > 1)
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var i = 0; i < product.images.length; i++)
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 3),
                              width: i == _imageIndex ? 16 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: i == _imageIndex
                                    ? AppColors.primary
                                    : Colors.white70,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.brand,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Satıcı: ${product.seller}',
                          style: const TextStyle(fontSize: 11.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RatingStars(
                    rating: product.rating,
                    reviewCount: product.reviewCount,
                    size: 16,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (product.isFlashDeal)
                        const _InfoChip(
                          icon: Icons.bolt,
                          label: 'Süper Fırsat',
                          color: AppColors.primary,
                        ),
                      if (product.freeShipping)
                        const _InfoChip(
                          icon: Icons.local_shipping_outlined,
                          label: 'Kargo Bedava',
                          color: AppColors.success,
                        ),
                      if (product.lowStock)
                        _InfoChip(
                          icon: Icons.warning_amber_rounded,
                          label: 'Son ${product.stock} ürün!',
                          color: AppColors.danger,
                        ),
                      if (!product.inStock)
                        const _InfoChip(
                          icon: Icons.block,
                          label: 'Stokta yok',
                          color: AppColors.inkSoft,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  PriceText(
                    price: product.price,
                    originalPrice: product.originalPrice,
                    fontSize: 26,
                    compact: true,
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ürün Açıklaması',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
            const Divider(),
            ReviewSection(productId: product.id),
            const Divider(),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Benzer Ürünler',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
            _SimilarProducts(
              categoryId: product.categoryId,
              excludeId: product.id,
            ),
            const SizedBox(height: 16),
          ],
        ),
        loading: () => const AppLoader(),
        error: (e, _) => ErrorView(
          message: e is AppException ? e.message : 'Ürün yüklenemedi.',
          onRetry: () =>
              ref.invalidate(productDetailProvider(widget.productId)),
        ),
      ),
      bottomNavigationBar: state.value == null
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: theme.dividerTheme.color ?? AppColors.outline,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: PriceText(
                        price: state.value!.price,
                        originalPrice: state.value!.originalPrice,
                        fontSize: 19,
                      ),
                    ),
                    SizedBox(
                      width: 180,
                      child: ElevatedButton.icon(
                        onPressed: (!state.value!.inStock || _addingToCart)
                            ? null
                            : () => _addToCart(state.value!),
                        icon: _addingToCart
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.shopping_cart_outlined),
                        label: Text(
                          state.value!.inStock ? 'Sepete Ekle' : 'Tükendi',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SimilarProducts extends ConsumerWidget {
  const _SimilarProducts({required this.categoryId, required this.excludeId});

  final String categoryId;
  final String excludeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(
      similarProductsProvider((categoryId: categoryId, excludeId: excludeId)),
    );
    return SizedBox(
      height: 300,
      child: state.when(
        data: (items) => items.isEmpty
            ? const SizedBox.shrink()
            : ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, i) =>
                    ProductCard(product: items[i], width: 165),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const SizedBox.shrink(),
      ),
    );
  }
}
