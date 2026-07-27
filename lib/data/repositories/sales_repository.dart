import '../../core/utils/hash_helper.dart';
import '../api/api_service.dart';
import '../models/sales_model.dart';

class SalesRepository {
  final ApiService _api = ApiService.instance;

  // ─── Login ───────────────────────────────────────────────────────────────

  /// Login dengan username + password (password di-hash SHA-256).
  /// Melempar [ApiException] jika login gagal.
  Future<SalesModel> login(String username, String password) async {
    final hashed = HashHelper.hash(password);
    final response = await _api.post(
      '/account_uas/login',
      data: {'username': username, 'password': hashed},
    );
    return SalesModel.fromMap(response.data);
  }

  // ─── Get by ID ────────────────────────────────────────────────────────────

  Future<SalesModel?> getById(int id) async {
    try {
      final response = await _api.get('/account_uas/$id');
      if (response.data == null) return null;
      return SalesModel.fromMap(response.data);
    } on ApiException {
      return null;
    }
  }

  // ─── Register ─────────────────────────────────────────────────────────────

  /// Melempar [ApiException] jika username / email sudah digunakan.
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
    return SalesModel.fromMap(response.data);
  }

  // ─── Update Account ───────────────────────────────────────────────────────

  /// Melempar [ApiException] jika username sudah dipakai akun lain.
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
