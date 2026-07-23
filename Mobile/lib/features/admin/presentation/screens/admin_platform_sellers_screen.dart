import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/feedback_widgets.dart';
import '../providers/admin_platform_providers.dart';

class AdminPlatformSellersScreen extends ConsumerWidget {
  const AdminPlatformSellersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(platformSellersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Satıcılar')),
      body: state.when(
        data: (sellers) {
          if (sellers.isEmpty) {
            return const EmptyState(
              icon: Icons.storefront_outlined,
              title: 'Satıcı bulunamadı',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(platformSellersProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sellers.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final seller = sellers[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.warning.withValues(alpha: 0.15),
                      child: const Icon(
                        Icons.storefront_outlined,
                        color: AppColors.warning,
                      ),
                    ),
                    title: Text(
                      seller.storeName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      '${seller.email} · ${seller.productCount} ürün',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, size: 14, color: AppColors.warning),
                            const SizedBox(width: 2),
                            Text(
                              seller.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        if (!seller.isActive)
                          const Text(
                            'Pasif',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.danger,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const AppLoader(),
        error: (e, _) => ErrorView(
          message: 'Satıcılar yüklenemedi.',
          onRetry: () => ref.invalidate(platformSellersProvider),
        ),
      ),
    );
  }
}
