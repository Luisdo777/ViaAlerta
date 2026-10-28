import 'package:supabase_flutter/supabase_flutter.dart';

/// Modelo para o supabase_config.dart (que não vai para o Git).
/// Copie este arquivo, renomeie para supabase_config.dart e preencha
/// com os dados do seu projeto: Supabase > Project Settings > API.
class SupabaseConfig {
  static const url = 'https://SEU-PROJETO.supabase.co';
  static const anonKey = 'SUA-CHAVE-ANON-PUBLICA';
}

SupabaseClient get supabase => Supabase.instance.client;
