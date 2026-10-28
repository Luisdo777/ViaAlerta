import 'package:flutter/foundation.dart';

import '../core/supabase_config.dart';
import 'occurrence_repository.dart';

class AdminUser {
  const AdminUser({required this.id, required this.email});
  final String id;
  final String email;

  String get initial => email.trim().isEmpty ? 'AD' : email.trim()[0].toUpperCase();
}

/// Autenticação do painel administrativo (triagem).
/// Usa o mesmo Supabase Auth do cidadão, mas só deixa entrar quem tem
/// role = 'admin' na tabela "profiles" (definido manualmente no banco).
class AdminAuthService extends ChangeNotifier {
  AdminUser? _admin;
  AdminUser? get admin => _admin;

  Future<void> signIn({required String email, required String password}) async {
    final result = await supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    final userId = result.user?.id;
    if (userId == null) {
      throw Exception('Não foi possível entrar. Confira o e-mail e a senha.');
    }

    final row = await supabase.from('profiles').select().eq('id', userId).maybeSingle();
    final role = row?['role'] as String?;
    if (role != 'admin') {
      await supabase.auth.signOut();
      throw Exception('Esta conta não tem acesso ao painel administrativo.');
    }

    _admin = AdminUser(id: userId, email: result.user?.email ?? email.trim());
    notifyListeners();
    await occurrenceRepository.loadAll();
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
    _admin = null;
    occurrenceRepository.clear();
    notifyListeners();
  }
}

final adminAuthService = AdminAuthService();
