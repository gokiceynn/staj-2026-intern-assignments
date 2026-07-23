import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/feedback_widgets.dart';
import '../../domain/entities/address.dart';
import '../providers/profile_providers.dart';

class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Address address,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adresi Sil'),
        content: Text('"${address.title}" adresi silinecek. Emin misin?'),
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
    if (confirmed ?? false) {
      await ref.read(addressActionsProvider).delete(address.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addressesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Adreslerim')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/addresses/new'),
        icon: const Icon(Icons.add),
        label: const Text('Yeni Adres'),
      ),
      body: state.when(
        data: (addresses) {
          if (addresses.isEmpty) {
            return const EmptyState(
              icon: Icons.location_off_outlined,
              title: 'Kayıtlı adresin yok',
              message:
                  'Hızlı ödeme için teslimat adreslerini buraya ekleyebilirsin.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            itemCount: addresses.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final address = addresses[i];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              address.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${address.fullName} · ${address.phone}',
                              style: const TextStyle(fontSize: 12.5),
                            ),
                            Text(
                              address.summary,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: () =>
                            context.push('/addresses/edit', extra: address),
                        tooltip: 'Düzenle',
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: AppColors.danger,
                        ),
                        onPressed: () => _confirmDelete(context, ref, address),
                        tooltip: 'Sil',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const AppLoader(),
        error: (e, _) => ErrorView(
          message: e is AppException ? e.message : 'Adresler yüklenemedi.',
          onRetry: () => ref.invalidate(addressesProvider),
        ),
      ),
    );
  }
}
