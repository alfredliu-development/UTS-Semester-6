import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

      if (sales == null) {
        emit(AuthFailure('Username atau password salah'));
        return;
      }

      await _saveSession(sales);
      emit(AuthSuccess(sales));
    } catch (_) {
      emit(AuthFailure('Terjadi kesalahan. Silakan coba lagi.'));
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
        password: password,
        fullName: fullName.trim(),
      );

      // Auto-save credentials to SharedPreferences right after register
      await _saveCredentials(username: sales.username, password: password);

      // Also start a session so the user is logged in immediately
      await _saveSession(sales);

      emit(
        AuthRegisterSuccess(
          sales: sales,
          savedUsername: sales.username,
          savedPassword: password,
        ),
      );
    } on RegisterException catch (e) {
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
    await prefs.setInt('sales_id', sales.id!);
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
