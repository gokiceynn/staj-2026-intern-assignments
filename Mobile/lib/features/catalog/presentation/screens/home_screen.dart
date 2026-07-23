import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/feedback_widgets.dart';
import '../../../../core/widgets/primitives.dart';
import '../../domain/entities/product.dart';
import '../providers/catalog_providers.dart';
import '../widgets/category_visuals.dart';
import '../widgets/product_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref
              ..invalidate(categoriesProvider)
              ..invalidate(flashDealsProvider)
              ..invalidate(featuredProductsProvider)
              ..invalidate(topRatedProductsProvider);
          },
          child: ListView(
            children: [
              const _HomeHeader(),
              const _BannerCarousel(),
              const _QuickCategoryGrid(),
              const _PromoCardsRow(),
              const _CategoryStrip(),
              SectionHeader(
                title: '⚡ Süper Fırsatlar',
                onSeeAll: () => context.push(
                  '/products?flash=1&title=S%C3%BCper%20F%C4%B1rsatlar',
                ),
              ),
              _ProductRail(state: ref.watch(flashDealsProvider)),
              SectionHeader(
                title: 'Öne Çıkanlar',
                onSeeAll: () =>
                    context.push('/products?title=%C3%96ne%20%C3%87%C4%B1kanlar'),
              ),
              _ProductRail(state: ref.watch(featuredProductsProvider)),
              const SectionHeader(title: 'En Beğenilenler'),
              const _TopRatedGrid(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.shopping_bag_rounded,
                color: AppColors.primary,
                size: 26,
              ),
              const SizedBox(width: 6),
              Text(
                AppConfig.appName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Arama çubuğu — dokununca arama ekranına gider.
          InkWell(
            onTap: () => context.push('/search'),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerTheme.color ??
                      AppColors.outline,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ürün, kategori veya marka ara',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Banner {
  const _Banner({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.route,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final String route;
}

class _BannerCarousel extends StatefulWidget {
  const _BannerCarousel();

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  static const _banners = [
    _Banner(
      title: 'Süper Fiyat Günleri',
      subtitle: "Seçili ürünlerde %40'a varan indirim",
      icon: Icons.bolt_rounded,
      colors: [Color(0xFFFF6000), Color(0xFFFF8F3C)],
      route: '/products?flash=1&title=S%C3%BCper%20F%C4%B1rsatlar',
    ),
    _Banner(
      title: 'VB10 koduyla %10 indirim',
      subtitle: 'Kupon kodunu sepette kullan',
      icon: Icons.percent_rounded,
      colors: [Color(0xFF5D3EBC), Color(0xFF8B6FE8)],
      route: '/cart',
    ),
    _Banner(
      title: '500 TL üzeri kargo bedava',
      subtitle: 'Sepetini doldur, kargoyu düşünme',
      icon: Icons.local_shipping_rounded,
      colors: [Color(0xFF0BA45C), Color(0xFF3BC98A)],
      route: '/products?title=T%C3%BCm%20%C3%9Cr%C3%BCnler',
    ),
  ];

  final _controller = PageController();
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_controller.hasClients) return;
      final next = (_index + 1) % _banners.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _controller,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final banner = _banners[i];
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: InkWell(
                  onTap: () {
                    if (banner.route == '/cart') {
                      context.go(banner.route);
                    } else {
                      context.push(banner.route);
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: banner.colors,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                banner.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                banner.subtitle,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          banner.icon,
                          size: 56,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _banners.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _index ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _index
                      ? AppColors.primary
                      : Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _QuickLink {
  const _QuickLink({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.query,
    this.badge,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final Map<String, String> query;
  final String? badge;
}

/// Web ana sayfasındaki renkli hızlı kategori kartlarının (Süper Fırsat,
/// Elektronik, Moda, Ev & Yaşam, Yüksek Puan, Yeni Gelenler) mobil karşılığı.
class _QuickCategoryGrid extends StatelessWidget {
  const _QuickCategoryGrid();

  static const _links = [
    _QuickLink(
      label: 'Süper Fırsat',
      icon: Icons.bolt_rounded,
      background: Color(0xFFFEF3C7),
      foreground: Color(0xFFD97706),
      query: {'flash': '1', 'title': 'Süper Fırsatlar'},
    ),
    _QuickLink(
      label: 'Elektronik',
      icon: Icons.smartphone_rounded,
      background: Color(0xFFDBEAFE),
      foreground: Color(0xFF2563EB),
      query: {'category': 'elektronik', 'title': 'Elektronik'},
    ),
    _QuickLink(
      label: 'Moda',
      icon: Icons.checkroom_rounded,
      background: Color(0xFFFCE7F3),
      foreground: AppColors.deal,
      query: {'category': 'giyim', 'title': 'Moda'},
    ),
    _QuickLink(
      label: 'Ev & Yaşam',
      icon: Icons.chair_rounded,
      background: Color(0xFFD1FAE5),
      foreground: AppColors.success,
      query: {'category': 'ev-yasam', 'title': 'Ev & Yaşam'},
    ),
    _QuickLink(
      label: 'Yüksek Puan',
      icon: Icons.star_rounded,
      background: Color(0xFFEDE9FE),
      foreground: AppColors.secondary,
      query: {'sortBy': 'rating_desc', 'title': 'Yüksek Puan'},
    ),
    _QuickLink(
      label: 'Yeni Gelenler',
      icon: Icons.auto_awesome_rounded,
      background: Color(0xFFE0E7FF),
      foreground: Color(0xFF4338CA),
      badge: 'YENİ',
      query: {'sortBy': 'newest', 'title': 'Yeni Gelenler'},
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          for (final link in _links)
            Expanded(
              child: InkWell(
                onTap: () => context.push(
                  Uri(path: '/products', queryParameters: link.query)
                      .toString(),
                ),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: link.background,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              link.icon,
                              color: link.foreground,
                              size: 22,
                            ),
                          ),
                          if (link.badge != null)
                            Positioned(
                              top: -4,
                              right: -6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  link.badge!,
                                  style: const TextStyle(
                                    fontSize: 7,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        link.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Web hero bölümündeki pembe "Flaş Fırsat" ve "Favorilerim" kartlarının
/// mobil karşılığı.
class _PromoCardsRow extends StatelessWidget {
  const _PromoCardsRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => context.push(
                '/products?flash=1&title=En%20Be%C4%9Fenilenler',
              ),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 84,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.deal, Color(0xFFF472B6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'FLAŞ FIRSAT',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'En Beğenilenler',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () => context.push('/favorites'),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 84,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color:
                        Theme.of(context).dividerTheme.color ??
                        AppColors.outline,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.favorite_rounded,
                          size: 14,
                          color: AppColors.danger,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Favorilerim',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Listeni Oluştur',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryStrip extends ConsumerWidget {
  const _CategoryStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    return SizedBox(
      height: 92,
      child: categories.when(
        data: (items) => ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: 14),
          itemBuilder: (context, i) {
            final category = items[i];
            return InkWell(
              onTap: () => context.push(
                Uri(
                  path: '/products',
                  queryParameters: {
                    'category': category.id,
                    'title': category.name,
                  },
                ).toString(),
              ),
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 64,
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        categoryIcon(category.icon),
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10.5),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        loading: () => ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: 6,
          separatorBuilder: (_, _) => const SizedBox(width: 14),
          itemBuilder: (_, _) => const Column(
            children: [
              SkeletonBox(width: 48, height: 48, borderRadius: 24),
              SizedBox(height: 6),
              SkeletonBox(width: 52, height: 10),
            ],
          ),
        ),
        error: (_, _) => const SizedBox.shrink(),
      ),
    );
  }
}

/// Yatay ürün rayı (Süper Fırsatlar / Öne Çıkanlar).
class _ProductRail extends StatelessWidget {
  const _ProductRail({required this.state});

  final AsyncValue<List<Product>> state;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: state.when(
        data: (items) => ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (_, i) => ProductCard(product: items[i], width: 165),
        ),
        loading: () => ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 3,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (_, _) =>
              const SkeletonBox(width: 165, height: 300, borderRadius: 14),
        ),
        error: (e, _) => Center(
          child: Text(
            'Ürünler yüklenemedi',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _TopRatedGrid extends ConsumerWidget {
  const _TopRatedGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(topRatedProductsProvider);
    return state.when(
      data: (items) => GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.56,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) => ProductCard(product: items[i]),
      ),
      loading: () => const ProductGridSkeleton(itemCount: 4),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
