import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/feedback_widgets.dart';
import '../../../catalog/presentation/widgets/product_card.dart';
import '../providers/favorites_providers.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(favoriteProductsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Favorilerim')),
      body: state.when(
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.favorite_border,
              title: 'Henüz favorin yok',
              message:
                  'Beğendiğin ürünlerin kalbine dokunarak onları burada topla.',
              actionLabel: 'Ürünleri Keşfet',
              onAction: () => context.go('/home'),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.56,
            ),
            itemCount: items.length,
            itemBuilder: (_, i) => ProductCard(product: items[i]),
          );
        },
        loading: () => const SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: ProductGridSkeleton(),
        ),
        error: (e, _) => ErrorView(
          message: 'Favoriler yüklenemedi.',
          onRetry: () => ref.invalidate(favoriteProductsProvider),
        ),
      ),
    );
  }
}
