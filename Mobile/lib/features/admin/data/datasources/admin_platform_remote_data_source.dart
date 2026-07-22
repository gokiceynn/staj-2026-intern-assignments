import '../../../../core/network/dio_client.dart';
import '../../domain/entities/platform_stats.dart';

/// Backend'in `AdminController`'ına (platform geneli, salt-okunur denetim)
/// bağlı gerçek Admin ekranları — mağaza yönetiminden (`AdminRemoteDataSource`
/// → `/seller/*`) tamamen ayrı. Yalnızca gerçek "Admin" rolündeki hesaplar
/// bu uçlara erişebilir.
class AdminPlatformRemoteDataSource {
  AdminPlatformRemoteDataSource(this._client);

  final DioClient _client;

  Future<PlatformStats> getDashboard() async {
    try {
      final response =
          await _client.dio.get<Map<String, dynamic>>('/admin/dashboard');
      final d = response.data!;
      return PlatformStats(
        userCount: (d['userCount'] as num).toInt(),
        customerCount: (d['customerCount'] as num).toInt(),
        sellerCount: (d['sellerCount'] as num).toInt(),
        activeProductCount: (d['activeProductCount'] as num).toInt(),
        orderCount: (d['orderCount'] as num).toInt(),
        grossSalesAmount: (d['grossSalesAmount'] as num).toDouble(),
        currency: (d['currency'] ?? 'TRY').toString(),
      );
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }

  Future<List<PlatformUser>> getUsers({String? query}) async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        '/admin/users',
        queryParameters: {
          'page': 1,
          'size': 50,
          if (query != null && query.isNotEmpty) 'q': query,
        },
      );
      final items = response.data!['items'] as List;
      return items.cast<Map<String, dynamic>>().map((json) {
        return PlatformUser(
          id: json['id'].toString(),
          email: (json['email'] ?? '').toString(),
          fullName: (json['fullName'] ?? '').toString(),
          role: (json['role'] ?? '').toString(),
          isActive: json['isActive'] as bool? ?? true,
          isEmailVerified: json['isEmailVerified'] as bool? ?? false,
        );
      }).toList();
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }

  Future<List<PlatformSeller>> getSellers({String? query}) async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        '/admin/sellers',
        queryParameters: {
          'page': 1,
          'size': 50,
          if (query != null && query.isNotEmpty) 'q': query,
        },
      );
      final items = response.data!['items'] as List;
      return items.cast<Map<String, dynamic>>().map((json) {
        return PlatformSeller(
          id: json['id'].toString(),
          storeName: (json['storeName'] ?? '').toString(),
          email: (json['email'] ?? '').toString(),
          rating: (json['rating'] as num?)?.toDouble() ?? 0,
          isActive: json['isActive'] as bool? ?? true,
          productCount: (json['productCount'] as num?)?.toInt() ?? 0,
        );
      }).toList();
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }
}
