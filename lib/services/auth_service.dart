import 'package:flutter/foundation.dart';

class AppUser {
  const AppUser({required this.name, required this.email, this.phone});
  final String name;
  final String email;
  final String? phone;

  String get firstName => name.trim().split(' ').first;
  String get initial => name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
}

/// Autenticação simulada em memória.
/// Troque os métodos por chamadas ao seu backend (Supabase, Firebase, API própria).
class AuthService extends ChangeNotifier {
  final Map<String, AppUser> _registered = {};
  AppUser? _user;

  AppUser? get user => _user;

  Future<void> signIn({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final key = email.trim().toLowerCase();
    final local = key.split('@').first;
    final fallbackName =
        local.isEmpty ? 'Cidadão' : local[0].toUpperCase() + local.substring(1);
    _user = _registered[key] ?? AppUser(name: fallbackName, email: key);
    notifyListeners();
  }

  Future<void> register({
    required String name,
    required String email,
    String? phone,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final key = email.trim().toLowerCase();
    final user = AppUser(
      name: name.trim(),
      email: key,
      phone: (phone == null || phone.trim().isEmpty) ? null : phone.trim(),
    );
    _registered[key] = user;
    _user = user;
    notifyListeners();
  }

  void signOut() {
    _user = null;
    notifyListeners();
  }
}

final authService = AuthService();
