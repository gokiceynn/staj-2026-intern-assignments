import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/feedback_widgets.dart';
import '../providers/admin_platform_providers.dart';

class AdminPlatformUsersScreen extends ConsumerWidget {
  const AdminPlatformUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(platformUsersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kullanıcılar')),
      body: state.when(
        data: (users) {
          if (users.isEmpty) {
            return const EmptyState(
              icon: Icons.people_outline,
              title: 'Kullanıcı bulunamadı',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(platformUsersProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final user = users[i];
                final roleColor = switch (user.role.toLowerCase()) {
                  'admin' => AppColors.secondary,
                  'seller' => AppColors.warning,
                  _ => AppColors.primary,
                };
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: roleColor.withValues(alpha: 0.15),
                      child: Text(
                        user.fullName.isNotEmpty
                            ? user.fullName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: roleColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    title: Text(
                      user.fullName.isEmpty ? user.email : user.fullName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      user.email,
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: roleColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            user.role,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: roleColor,
                            ),
                          ),
                        ),
                        if (!user.isActive)
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
          message: 'Kullanıcılar yüklenemedi.',
          onRetry: () => ref.invalidate(platformUsersProvider),
        ),
      ),
    );
  }
}
