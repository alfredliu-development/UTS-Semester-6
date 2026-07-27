/// Konfigurasi koneksi ke backend Flask (XAMPP MySQL).
///
/// Ganti [baseUrl] sesuai environment:
///   - Android Emulator  : http://10.0.2.2:8080
///   - iOS Simulator     : http://127.0.0.1:8080
///   - Device fisik      : http://<IP_KOMPUTER_LAN>:8080
///                         contoh: http://192.168.1.5:8080
///   - Web (debug)       : http://localhost:8080
class AppConstants {
  AppConstants._();

  // ─── Ganti sesuai environment ──────────────────────────────────────────────

  /// URL base backend. Ganti ke IP LAN jika test di device fisik.
  ///
  /// Android Emulator  → http://10.0.2.2:8080        (sudah di-set)
  /// Device fisik LAN  → http://192.168.0.101:8080   (IP komputer saat ini)
  /// iOS Simulator     → http://127.0.0.1:8080
  /// Web debug         → http://localhost:8080
  static const String baseUrl = 'http://10.0.2.2:8080';

  // ─── Timeout ───────────────────────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);

  // ─── Retry ─────────────────────────────────────────────────────────────────
  /// Jumlah maksimal percobaan ulang ketika koneksi gagal.
  static const int maxRetries = 2;

  // ─── Endpoint paths ────────────────────────────────────────────────────────
  static const String health = '/health';

  // Auth
  static const String login = '/account_uas/login';
  static const String register = '/account_uas/register';
  static String userById(int id) => '/account_uas/$id';

  // Customers
  static const String customers = '/customers';
  static const String customerSearch = '/customers/search';
  static const String customersTotalVisited = '/customers/stats/total-visited';
  static String customerById(int id) => '/customers/$id';
  static String customerVisit(int id) => '/customers/$id/visit';

  // Products
  static const String products = '/products';
  static const String productSearch = '/products/search';
  static const String productCategories = '/products/categories';
  static String productById(int id) => '/products/$id';

  // Orders
  static const String orders = '/orders';
  static const String ordersToday = '/orders/today';
  static const String ordersTodayTotal = '/orders/stats/today-total';
  static const String ordersTodayCount = '/orders/stats/today-count';
  static String orderItems(int id) => '/orders/$id/items';
  static String orderStatus(int id) => '/orders/$id/status';
}
