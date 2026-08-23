import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A registered user of the POS system.
class AppUser {
  AppUser({required this.name, required this.email});

  final String name;
  final String email;
}

/// Result of an auth operation, carrying an optional error message.
class AuthResult {
  const AuthResult.success() : errorMessage = null;
  const AuthResult.failure(this.errorMessage);

  final String? errorMessage;
  bool get isSuccess => errorMessage == null;
}

/// Authentication service backed by local device storage.
///
/// There is no real backend yet, so accounts live in SharedPreferences on
/// this device rather than a server. The public API (register/login/logout)
/// is shaped so it can be swapped for a real backend later without touching
/// the UI. Call [init] once at app startup before relying on stored accounts.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _storageKey = 'nunipos_accounts';

  final Map<String, _StoredAccount> _accountsByEmail = {};
  final ValueNotifier<AppUser?> currentUser = ValueNotifier<AppUser?>(null);
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return;

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    decoded.forEach((email, data) {
      final fields = data as Map<String, dynamic>;
      _accountsByEmail[email] = _StoredAccount(
        name: fields['name'] as String,
        email: email,
        password: fields['password'] as String,
      );
    });
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      _accountsByEmail.map(
        (email, account) => MapEntry(email, {'name': account.name, 'password': account.password}),
      ),
    );
    await prefs.setString(_storageKey, encoded);
  }

  AuthResult register({
    required String name,
    required String email,
    required String password,
  }) {
    final normalizedEmail = email.trim().toLowerCase();
    if (_accountsByEmail.containsKey(normalizedEmail)) {
      return const AuthResult.failure('An account with this email already exists.');
    }

    _accountsByEmail[normalizedEmail] = _StoredAccount(
      name: name.trim(),
      email: normalizedEmail,
      password: password,
    );
    unawaited(_persist());
    currentUser.value = AppUser(name: name.trim(), email: normalizedEmail);
    return const AuthResult.success();
  }

  AuthResult login({required String email, required String password}) {
    final normalizedEmail = email.trim().toLowerCase();
    final account = _accountsByEmail[normalizedEmail];
    if (account == null || account.password != password) {
      return const AuthResult.failure('Incorrect email or password.');
    }

    currentUser.value = AppUser(name: account.name, email: account.email);
    return const AuthResult.success();
  }

  void logout() {
    currentUser.value = null;
  }

  /// Checks [password] against the currently signed-in user's stored
  /// credentials, without changing the active session.
  bool verifyCurrentPassword(String password) {
    final email = currentUser.value?.email;
    if (email == null) return false;
    final account = _accountsByEmail[email];
    return account != null && account.password == password;
  }
}

class _StoredAccount {
  _StoredAccount({required this.name, required this.email, required this.password});

  final String name;
  final String email;
  final String password;
}
