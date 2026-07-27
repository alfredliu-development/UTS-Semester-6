import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/api/api_service.dart';
import '../../data/models/sales_model.dart';
import '../../data/repositories/sales_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SalesRepository _repository;

  AuthCubit({SalesRepository? repository})
    : _repository = repository ?? SalesRepository(),
      super(AuthInitial());

  // ─── Login ───────────────────────────────────────────────────────────────

  Future<void> login(String username, String password) async {
    if (username.trim().isEmpty || password.trim().isEmpty) {
      emit(AuthFailure('Username dan password tidak boleh kosong'));
      return;
    }

    emit(AuthLoading());

    try {
      final sales = await _repository.login(username.trim(), password.trim());
      await _saveSession(sales);
      emit(AuthSuccess(sales));
    } on ApiException catch (e) {
      // 401 = credentials salah, lainnya = error koneksi/server
      emit(AuthFailure(e.message));
    } catch (e, stackTrace) {
      // ignore: avoid_print
      print('[AUTH ERROR] $e\n$stackTrace');
      emit(AuthFailure('Terjadi kesalahan: $e'));
    }
  }

  // ─── Register ────────────────────────────────────────────────────────────

  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    emit(AuthLoading());

    try {
      final sales = await _repository.register(
        username: username.trim(),
        email: email.trim(),
        password: password, // repository akan hash ini
        fullName: fullName.trim(),
      );

      // Simpan credentials plain-text ke SharedPreferences untuk pre-fill login
      await _saveCredentials(username: sales.username, password: password);

      // Langsung buat session aktif
      await _saveSession(sales);

      emit(
        AuthRegisterSuccess(
          sales: sales,
          savedUsername: sales.username,
          savedPassword: password,
        ),
      );
    } on ApiException catch (e) {
      // 409 = username/email duplikat, pesan langsung dari server
      emit(AuthFailure(e.message));
    } catch (_) {
      emit(AuthFailure('Registrasi gagal. Silakan coba lagi.'));
    }
  }

  // ─── Session ─────────────────────────────────────────────────────────────

  Future<void> checkSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final salesId = prefs.getInt('sales_id');

      if (salesId == null) {
        emit(AuthLoggedOut());
        return;
      }

      final sales = await _repository.getById(salesId);
      if (sales == null) {
        emit(AuthLoggedOut());
        return;
      }

      emit(AuthSuccess(sales));
    } catch (_) {
      emit(AuthLoggedOut());
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sales_id');
    // Keep saved credentials so login form stays pre-filled
    emit(AuthLoggedOut());
  }

  // ─── Saved credentials (for login form pre-fill) ─────────────────────────

  /// Returns the last saved [username, password] pair, or empty strings.
  Future<(String, String)> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('saved_username') ?? '';
    final password = prefs.getString('saved_password') ?? '';
    return (username, password);
  }

  // ─── Private helpers ─────────────────────────────────────────────────────

  Future<void> _saveSession(SalesModel sales) async {
    final prefs = await SharedPreferences.getInstance();
    // Hanya simpan jika id tidak null
    if (sales.id != null) {
      await prefs.setInt('sales_id', sales.id!);
    }
  }

  Future<void> _saveCredentials({
    required String username,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_username', username);
    await prefs.setString('saved_password', password);
  }
}
