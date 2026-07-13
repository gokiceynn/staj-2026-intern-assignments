import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/profile_mock_data_source.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/address.dart';
import '../../domain/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepositoryImpl(
    ProfileMockDataSource(
      ref.watch(mockDatabaseProvider),
      ref.watch(tokenStoreProvider),
    ),
  ),
);

/// Kullanıcının adresleri; oturum değişince yeniden yüklenir.
final addressesProvider = FutureProvider<List<Address>>((ref) {
  ref.watch(authControllerProvider);
  return ref.watch(profileRepositoryProvider).getAddresses();
});

/// Adres ekleme/güncelleme/silme aksiyonları.
final addressActionsProvider = Provider<AddressActions>(AddressActions.new);

class AddressActions {
  AddressActions(this._ref);

  final Ref _ref;

  Future<Address> save(Address address) async {
    final saved =
        await _ref.read(profileRepositoryProvider).saveAddress(address);
    _ref.invalidate(addressesProvider);
    return saved;
  }

  Future<void> delete(String id) async {
    await _ref.read(profileRepositoryProvider).deleteAddress(id);
    _ref.invalidate(addressesProvider);
  }
}
