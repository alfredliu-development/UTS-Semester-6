import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Utility untuk hashing password menggunakan SHA-256.
class HashHelper {
  HashHelper._();

  /// Hash sebuah string menggunakan SHA-256.
  static String hash(String value) {
    final bytes = utf8.encode(value);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
