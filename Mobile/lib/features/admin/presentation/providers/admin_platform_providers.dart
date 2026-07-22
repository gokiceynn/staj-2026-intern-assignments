import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../data/datasources/admin_platform_remote_data_source.dart';
import '../../domain/entities/platform_stats.dart';

final adminPlatformRemoteDataSourceProvider =
    Provider<AdminPlatformRemoteDataSource>(
  (ref) => AdminPlatformRemoteDataSource(ref.watch(dioClientProvider)),
);

final platformStatsProvider = FutureProvider<PlatformStats>(
  (ref) => ref.watch(adminPlatformRemoteDataSourceProvider).getDashboard(),
);

final platformUsersProvider = FutureProvider<List<PlatformUser>>(
  (ref) => ref.watch(adminPlatformRemoteDataSourceProvider).getUsers(),
);

final platformSellersProvider = FutureProvider<List<PlatformSeller>>(
  (ref) => ref.watch(adminPlatformRemoteDataSourceProvider).getSellers(),
);
