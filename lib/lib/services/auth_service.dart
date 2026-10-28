import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/supabase_config.dart';
import 'occurrence_repository.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
  });

  final String id;
  final String name;
  final String email;
  final String? phone;

  String get firstName => name.trim().isEmpty ? 'cidadão' : name.trim().split(' ').first;
  String get initial => name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
}

/// Autenticação do cidadão, usando o Supabase Auth + tabela "profiles".
class AuthService extends ChangeNotifier {
  AppUser? _user;
  AppUser? get user => _user;

  AuthService() {
    // Mantém o app sincronizado com a sessão (login ao abrir de novo, logout etc.).
    supabase.auth.onAuthStateChange.listen((data) => _syncFromSession(data.session));
    _syncFromSession(supabase.auth.currentSession);
  }

  Future<void> _syncFromSession(Session? session) async {
    final authUser = session?.user;
    if (authUser == null) {
      _user = null;
      notifyListeners();
      return;
    }
    final row = await supabase
        .from('profiles')
        .select()
        .eq('id', authUser.id)
        .maybeSingle();
    _user = AppUser(
      id: authUser.id,
      name: (row?['name'] as String?) ?? (authUser.email?.split('@').first ?? 'Cidadão'),
      email: authUser.email ?? '',
      phone: row?['phone'] as String?,
    );
    notifyListeners();
    // Carrega as ocorrências visíveis para este usuário assim que ele entra.
    unawaited(occurrenceRepository.loadAll());
  }

  Future<void> signIn({required String email, required String password}) async {
    await supabase.auth.signInWithPassword(email: email.trim(), password: password);
    await _syncFromSession(supabase.auth.currentSession);
  }

  Future<void> register({
    required String name,
    required String email,
    String? phone,
    required String password,
  }) async {
    await supabase.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'name': name.trim(),
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
      },
    );
    await _syncFromSession(supabase.auth.currentSession);
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
    _user = null;
    occurrenceRepository.clear();
    notifyListeners();
  }
}

final authService = AuthService();
