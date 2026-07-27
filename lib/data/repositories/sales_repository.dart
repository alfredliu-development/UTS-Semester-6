import '../../core/utils/hash_helper.dart';
import '../api/api_service.dart';
import '../models/sales_model.dart';

class SalesRepository {
  final ApiService _api = ApiService.instance;

  // ─── Login ───────────────────────────────────────────────────────────────

  Future<SalesModel> login(String username, String password) async {
    final hashed = HashHelper.hash(password);
    final response = await _api.post(
      '/account_uas/login',
      data: {'username': username, 'password': hashed},
    );

    // Pastikan data adalah Map sebelum parsing
    final data = response.data;
    if (data == null) {
      throw ApiException('Server tidak mengembalikan data', statusCode: 500);
    }
    final map = Map<String, dynamic>.from(data as Map);
    return SalesModel.fromMap(map);
  }

  // ─── Get by ID ────────────────────────────────────────────────────────────

  Future<SalesModel?> getById(int id) async {
    try {
      final response = await _api.get('/account_uas/$id');
      if (response.data == null) return null;
      final map = Map<String, dynamic>.from(response.data as Map);
      return SalesModel.fromMap(map);
    } on ApiException {
      return null;
    } catch (_) {
      return null;
    }
  }

  // ─── Register ─────────────────────────────────────────────────────────────

  Future<SalesModel> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    final hashedPassword = HashHelper.hash(password);
    final response = await _api.post(
      '/account_uas/register',
      data: {
        'username': username,
        'email': email,
        'password': hashedPassword,
        'full_name': fullName,
        'role': 'sales',
      },
    );
    final map = Map<String, dynamic>.from(response.data as Map);
    return SalesModel.fromMap(map);
  }

  // ─── Update Account ───────────────────────────────────────────────────────

  Future<void> updateAccount({
    required int id,
    required String fullName,
    required String username,
  }) async {
    await _api.put(
      '/account_uas/$id',
      data: {'full_name': fullName, 'username': username},
    );
  }
}
