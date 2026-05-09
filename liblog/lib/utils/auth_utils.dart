import 'dart:convert';
import 'package:crypto/crypto.dart';

class AuthUtils {
  /// Hashes a password using SHA-256
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verifies a plain text password against a stored hash
  static bool verifyPassword(String plainTextPassword, String storedHash) {
    final newHash = hashPassword(plainTextPassword);
    return newHash == storedHash;
  }
}
