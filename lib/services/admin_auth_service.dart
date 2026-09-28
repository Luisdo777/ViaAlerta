import 'package:flutter/foundation.dart';

class AdminUser {
  const AdminUser({required this.email});
  final String email;

  String get initial => email.trim().isEmpty ? 'AD' : email.trim()[0].toUpperCase();
}

/// Autenticação simulada do painel administrativo (triagem).
/// Troque por uma chamada real ao backend, com um papel (role) de triagem.
class AdminAuthService extends ChangeNotifier {
  AdminUser? _admin;
  AdminUser? get admin => _admin;

  Future<void> signIn({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _admin = AdminUser(email: email.trim().toLowerCase());
    notifyListeners();
  }

  void signOut() {
    _admin = null;
    notifyListeners();
  }
}

final adminAuthService = AdminAuthService();
