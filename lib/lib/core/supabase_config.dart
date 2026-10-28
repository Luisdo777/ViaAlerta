import 'package:supabase_flutter/supabase_flutter.dart';

/// Dados do seu projeto Supabase (Project Settings > API, no painel do Supabase).
///
/// Este arquivo fica fora do Git (veja o .gitignore). Para configurar numa
/// máquina nova, copie supabase_config.example.dart, renomeie para
/// supabase_config.dart e preencha os dois valores abaixo.
class SupabaseConfig {
  static const url = 'https://SEU-PROJETO.supabase.co';
  static const anonKey = 'SUA-CHAVE-ANON-PUBLICA';
}

/// Atalho para o cliente do Supabase, usado pelos serviços do app.
SupabaseClient get supabase => Supabase.instance.client;
