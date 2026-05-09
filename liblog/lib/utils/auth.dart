/// lib/utils/auth.dart
/// SHA-256 password hashing and role-based helpers.
import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Returns a lowercase hex SHA-256 digest of [input].
String hashPassword(String input) {
  final bytes = utf8.encode(input);
  return sha256.convert(bytes).toString();
}

/// Derives avatar initials from a full name (max 2 chars, uppercase).
String getAvatarInitials(String fullName) {
  final parts = fullName.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts[0][0].toUpperCase();
  return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
}

/// Returns the max borrow limit based on user role.
int getMaxBorrow(String role) {
  switch (role) {
    case 'faculty': return 10;
    case 'visitor': return 1;
    default:        return 3; // student
  }
}

/// Returns the borrow period in days based on user role.
int getBorrowDays(String role) {
  switch (role) {
    case 'faculty': return 30;
    case 'visitor': return 7;
    default:        return 14; // student
  }
}
