class CurrencyFormatter {
  CurrencyFormatter._();

  /// Format angka ke format Rupiah: Rp 1.000.000
  static String format(double amount) {
    final parts = amount.toStringAsFixed(0).split('');
    final buffer = StringBuffer();
    int count = 0;

    for (int i = parts.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(parts[i]);
      count++;
    }

    return 'Rp ${buffer.toString().split('').reversed.join()}';
  }

  /// Format angka ke format singkat: Rp 1,5 Jt
  static String formatShort(double amount) {
    if (amount >= 1000000000) {
      return 'Rp ${(amount / 1000000000).toStringAsFixed(1)} M';
    } else if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)} Jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)} Rb';
    }
    return format(amount);
  }
}
