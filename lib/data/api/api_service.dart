import 'package:dio/dio.dart';

import '../../core/constants/app_constants.dart';

/// Singleton HTTP client berbasis [Dio].
///
/// Semua request ke backend Flask (XAMPP MySQL) dilakukan lewat class ini.
/// Konfigurasi URL ada di [AppConstants.baseUrl] — tinggal ganti satu tempat
/// untuk switch environment (emulator / device fisik / web).
class ApiService {
  ApiService._init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        sendTimeout: AppConstants.sendTimeout,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Log setiap request & response (aktif hanya di debug mode)
    assert(() {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: false,
          responseHeader: false,
          logPrint: (o) => print('[API] $o'),
        ),
      );
      return true;
    }());
  }

  static final ApiService instance = ApiService._init();
  late final Dio _dio;

  // ─── GET ───────────────────────────────────────────────────────────────────

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _execute(() => _dio.get(path, queryParameters: queryParameters));
  }

  // ─── POST ──────────────────────────────────────────────────────────────────

  Future<Response> post(String path, {dynamic data}) async {
    return _execute(() => _dio.post(path, data: data));
  }

  // ─── PUT ───────────────────────────────────────────────────────────────────

  Future<Response> put(String path, {dynamic data}) async {
    return _execute(() => _dio.put(path, data: data));
  }

  // ─── DELETE ────────────────────────────────────────────────────────────────

  Future<Response> delete(String path) async {
    return _execute(() => _dio.delete(path));
  }

  // ─── Health check ──────────────────────────────────────────────────────────

  /// Cek apakah server dan database bisa dijangkau.
  /// Returns `true` jika server merespons dengan status ok.
  Future<bool> isServerReachable() async {
    try {
      final response = await _dio.get(
        AppConstants.health,
        options: Options(receiveTimeout: const Duration(seconds: 5)),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ─── Internal executor dengan retry ───────────────────────────────────────

  /// Jalankan [request] dengan otomatis retry hingga [AppConstants.maxRetries]
  /// kali jika terjadi connection timeout atau network error.
  Future<Response> _execute(Future<Response> Function() request) async {
    DioException? lastError;
    for (int attempt = 0; attempt <= AppConstants.maxRetries; attempt++) {
      try {
        return await request();
      } on DioException catch (e) {
        lastError = e;
        // Hanya retry untuk error jaringan / timeout, bukan error HTTP 4xx/5xx
        final shouldRetry =
            attempt < AppConstants.maxRetries &&
            (e.type == DioExceptionType.connectionTimeout ||
                e.type == DioExceptionType.sendTimeout ||
                e.type == DioExceptionType.receiveTimeout ||
                e.type == DioExceptionType.connectionError);
        if (!shouldRetry) break;

        // Tunggu sebentar sebelum retry (exponential backoff sederhana)
        await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
      }
    }
    throw _parseError(lastError!);
  }

  // ─── Error parser ──────────────────────────────────────────────────────────

  /// Ubah [DioException] menjadi [ApiException] dengan pesan yang ramah.
  ApiException _parseError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          'Koneksi ke server timeout. Pastikan backend sudah berjalan.',
          statusCode: null,
        );

      case DioExceptionType.connectionError:
        return ApiException(
          'Tidak dapat terhubung ke server.\n'
          'Pastikan:\n'
          '  1. XAMPP MySQL sudah aktif\n'
          '  2. Backend Python sudah dijalankan (python app.py)\n'
          '  3. URL server sudah benar di AppConstants.baseUrl',
          statusCode: null,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = _extractMessage(error.response);
        return ApiException(message, statusCode: statusCode);

      default:
        return ApiException(
          error.message ?? 'Terjadi kesalahan yang tidak diketahui',
          statusCode: null,
        );
    }
  }

  /// Ambil pesan error dari body response JSON (key "message").
  String _extractMessage(Response? response) {
    if (response == null) return 'Tidak ada respons dari server';
    final data = response.data;
    if (data is Map && data.containsKey('message')) {
      return data['message'].toString();
    }
    return 'Error ${response.statusCode}';
  }
}

// ══════════════════════════════════════════════════════════════════════════════
/// Exception yang dilempar oleh [ApiService] ketika request gagal.
// ══════════════════════════════════════════════════════════════════════════════
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;

  /// HTTP status code, atau `null` jika error terjadi sebelum mendapat respons.
  final int? statusCode;

  /// `true` jika error disebabkan oleh input tidak valid (400).
  bool get isBadRequest => statusCode == 400;

  /// `true` jika credentials salah (401).
  bool get isUnauthorized => statusCode == 401;

  /// `true` jika resource tidak ditemukan (404).
  bool get isNotFound => statusCode == 404;

  /// `true` jika data duplikat / konflik (409).
  bool get isConflict => statusCode == 409;

  /// `true` jika error berasal dari server (5xx).
  bool get isServerError => statusCode != null && statusCode! >= 500;

  /// `true` jika tidak dapat terhubung sama sekali (null statusCode).
  bool get isConnectionError => statusCode == null;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
