import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/feedback_widgets.dart';
import '../../domain/entities/product_query.dart';
import '../providers/catalog_providers.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/product_card.dart';

/// Kategori, arama sonucu ve kampanya listeleri için ortak ekran.
/// Sonsuz kaydırma + sıralama + filtreleme.
class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({
    super.key,
    required this.initialQuery,
    this.title,
  });

  final ProductQuery initialQuery;
  final String? title;

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  late ProductQuery _query = widget.initialQuery;

  String get _title {
    if (widget.title != null && widget.title!.isNotEmpty) return widget.title!;
    if (_query.q != null && _query.q!.isNotEmpty) return '"${_query.q}"';
    return 'Ürünler';
  }

  Future<void> _openSortSheet() async {
    final selected = await showModalBottomSheet<ProductSort>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final sort in ProductSort.values)
              ListTile(
                title: Text(sort.label),
                trailing: sort == _query.sort
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                selected: sort == _query.sort,
                onTap: () => Navigator.pop(context, sort),
              ),
          ],
        ),
      ),
    );
    if (selected != null && selected != _query.sort) {
      setState(() => _query = _query.copyWith(sort: selected, page: 1));
    }
  }

  Future<void> _openFilterSheet() async {
    final updated = await FilterSheet.show(context, _query);
    if (updated != null) {
      setState(() => _query = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productListProvider(_query));

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
            tooltip: 'Ara',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openSortSheet,
                    icon: const Icon(Icons.swap_vert, size: 18),
                    label: Text(
                      _query.sort.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openFilterSheet,
                    icon: Icon(
                      _query.hasActiveFilters
                          ? Icons.filter_alt
                          : Icons.tune,
                      size: 18,
                    ),
                    label: Text(
                      _query.hasActiveFilters ? 'Filtre (aktif)' : 'Filtrele',
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: state.when(
              data: (data) {
                if (data.items.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'Sonuç bulunamadı',
                    message:
                        'Filtreleri değiştirmeyi veya farklı bir arama yapmayı dene.',
                    actionLabel:
                        _query.hasActiveFilters ? 'Filtreleri Temizle' : null,
                    onAction: _query.hasActiveFilters
                        ? () => setState(
                              () => _query = ProductQuery(
                                q: _query.q,
                                categoryId: _query.categoryId,
                                flashDealsOnly: _query.flashDealsOnly,
                                featuredOnly: _query.featuredOnly,
                                sort: _query.sort,
                              ),
                            )
                        : null,
                  );
                }
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${data.totalItems} ürün listeleniyor',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification.metrics.pixels >=
                              notification.metrics.maxScrollExtent - 400) {
                            ref
                                .read(productListProvider(_query).notifier)
                                .loadMore();
                          }
                          return false;
                        },
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.56,
                          ),
                          itemCount:
                              data.items.length + (data.loadingMore ? 2 : 0),
                          itemBuilder: (context, i) {
                            if (i >= data.items.length) {
                              return const SkeletonBox(
                                width: double.infinity,
                                height: double.infinity,
                                borderRadius: 14,
                              );
                            }
                            return ProductCard(product: data.items[i]);
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: ProductGridSkeleton(),
              ),
              error: (e, _) => ErrorView(
                message: e is Exception ? e.toString() : 'Beklenmedik hata',
                onRetry: () => ref.invalidate(productListProvider(_query)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
