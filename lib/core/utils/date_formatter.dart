class DateFormatter {
  DateFormatter._();

  static const List<String> _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  static const List<String> _dayNames = [
    'Minggu',
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
  ];

  /// Format: 25 Mei 2026
  static String formatDate(DateTime date) {
    return '${date.day} ${_monthNames[date.month - 1]} ${date.year}';
  }

  /// Format: 25 Mei 2026, 14:30
  static String formatDateTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${formatDate(date)}, $hour:$minute';
  }

  /// Format: Senin, 25 Mei 2026
  static String formatFullDate(DateTime date) {
    return '${_dayNames[date.weekday % 7]}, ${formatDate(date)}';
  }

  /// Format: 14:30
  static String formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
