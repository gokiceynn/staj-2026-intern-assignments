import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/feedback_widgets.dart';
import '../../../catalog/domain/entities/product.dart';
import '../providers/admin_providers.dart';

/// Satıcının kendi ürün yönetimi: listeleme + arama + ekleme/düzenleme/silme.
/// `GET /seller/products` kullanır — genel katalog değil, yalnızca bu
/// mağazanın ürünleri (bkz. `adminMyProductsProvider`).
class AdminProductsScreen extends ConsumerStatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  ConsumerState<AdminProductsScreen> createState() =>
      _AdminProductsScreenState();
}

class _AdminProductsScreenState extends ConsumerState<AdminProductsScreen> {
  String _search = '';

  Future<void> _confirmDelete(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ürünü Sil'),
        content: Text(
          '"${product.name}" kalıcı olarak silinecek. '
          'Sepet ve favorilerden de kaldırılır. Emin misin?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Sil',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false)) return;
    try {
      await ref.read(adminActionsProvider).deleteProduct(product.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ürün silindi.')),
      );
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminMyProductsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ürünlerim')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/product-form'),
        icon: const Icon(Icons.add),
        label: const Text('Yeni Ürün'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              onChanged: (value) => setState(() => _search = value),
              decoration: const InputDecoration(
                hintText: 'Ürün veya marka ara',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
            ),
          ),
          Expanded(
            child: state.when(
              data: (data) {
                final needle = _search.trim().toLowerCase();
                final items = needle.isEmpty
                    ? data
                    : data
                        .where(
                          (p) => '${p.name} ${p.brand}'
                              .toLowerCase()
                              .contains(needle),
                        )
                        .toList();
                if (data.isEmpty) {
                  return const EmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: 'Henüz ürün eklemedin',
                    message: 'Sağ alttaki butondan ilk ürününü ekle.',
                  );
                }
                if (items.isEmpty) {
                  return const EmptyState(
                    icon: Icons.search_off,
                    title: 'Aramanla eşleşen ürün yok',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final product = items[i];
                    return Card(
                      child: ListTile(
                        leading: AppNetworkImage(
                          url: product.primaryImage,
                          width: 48,
                          height: 48,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        title: Text(
                          product.brand.isEmpty
                              ? product.name
                              : '${product.brand} ${product.name}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: Formatters.price(product.price),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                              TextSpan(
                                text: product.inStock
                                    ? '  ·  Stok: ${product.stock}'
                                    : '  ·  STOK YOK',
                                style: TextStyle(
                                  color: product.inStock
                                      ? null
                                      : AppColors.danger,
                                  fontWeight: product.inStock
                                      ? FontWeight.w400
                                      : FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (action) {
                            if (action == 'edit') {
                              context.push(
                                '/admin/product-form',
                                extra: product,
                              );
                            } else {
                              _confirmDelete(product);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(Icons.edit_outlined),
                                title: Text('Düzenle'),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  Icons.delete_outline,
                                  color: AppColors.danger,
                                ),
                                title: Text(
                                  'Sil',
                                  style: TextStyle(color: AppColors.danger),
                                ),
                              ),
                            ),
                          ],
                        ),
                        onTap: () =>
                            context.push('/admin/product-form', extra: product),
                      ),
                    );
                  },
                );
              },
              loading: () => const AppLoader(),
              error: (e, _) => ErrorView(
                message: 'Ürünler yüklenemedi.',
                onRetry: () => ref.invalidate(adminMyProductsProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
