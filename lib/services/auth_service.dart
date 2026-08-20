import 'package:flutter/foundation.dart';

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

/// In-memory authentication service.
///
/// There is no backend wired up yet, so accounts and sessions only live for
/// the lifetime of the app. The public API (register/login/logout) is shaped
/// so it can be swapped for a real backend later without touching the UI.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final Map<String, _StoredAccount> _accountsByEmail = {};
  final ValueNotifier<AppUser?> currentUser = ValueNotifier<AppUser?>(null);

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
}

class _StoredAccount {
  _StoredAccount({required this.name, required this.email, required this.password});

  final String name;
  final String email;
  final String password;
}
