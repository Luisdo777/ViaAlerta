import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../core/supabase_config.dart';
import '../models/occurrence.dart';

/// Repositório de ocorrências, usando as tabelas do Supabase:
/// occurrences, occurrence_history e occurrence_photos (veja supabase/schema.sql).
///
/// Para simplificar o código, toda alteração (criar, mudar status, encaminhar,
/// adicionar observação) recarrega a lista inteira do servidor depois de salvar.
/// Isso evita ter que atualizar o estado local "na mão" e é suficiente para o
/// volume de dados de um projeto como este.
class OccurrenceRepository extends ChangeNotifier {
  List<Occurrence> _items = [];
  bool loading = false;

  List<Occurrence> get all => List.unmodifiable(_items);

  Occurrence? byId(String id) {
    for (final o in _items) {
      if (o.id == id) return o;
    }
    return null;
  }

  /// Busca as ocorrências visíveis para o usuário logado (o banco já filtra
  /// isso sozinho: cidadão vê só as suas, admin vê todas — veja o schema.sql).
  Future<void> loadAll() async {
    loading = true;
    notifyListeners();
    try {
      final rows = await supabase
          .from('occurrences')
          .select('*, occurrence_history(*), occurrence_photos(*)')
          .order('created_at', ascending: false);
      _items = (rows as List).map((row) => _fromRow(row as Map<String, dynamic>)).toList();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Limpa os dados locais, usado ao fazer logout.
  void clear() {
    _items = [];
    notifyListeners();
  }

  Occurrence _fromRow(Map<String, dynamic> row) {
    final historyRows = List<Map<String, dynamic>>.from(
        row['occurrence_history'] as List? ?? const [])
      ..sort((a, b) => (b['created_at'] as String).compareTo(a['created_at'] as String));
    final photoRows =
        List<Map<String, dynamic>>.from(row['occurrence_photos'] as List? ?? const []);

    return Occurrence(
      recordId: row['id'] as String,
      id: row['protocol'] as String,
      type: OccurrenceType.values.firstWhere((t) => t.name == row['type']),
      description: row['description'] as String,
      address: row['address'] as String,
      cityLine: row['city_line'] as String,
      position: LatLng(
        (row['latitude'] as num).toDouble(),
        (row['longitude'] as num).toDouble(),
      ),
      status: OccurrenceStatus.values.firstWhere((s) => s.name == row['status']),
      createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
      citizenName: row['citizen_name'] as String,
      citizenEmail: row['citizen_email'] as String,
      department: row['department'] == null
          ? null
          : ResponsibleDepartment.values.firstWhere((d) => d.name == row['department']),
      photos: [for (final p in photoRows) p['url'] as String],
      history: [
        for (final h in historyRows)
          HistoryEntry(DateTime.parse(h['created_at'] as String).toLocal(), h['text'] as String),
      ],
    );
  }

  Future<Occurrence> create({
    required OccurrenceType type,
    required String description,
    required LatLng position,
    required String address,
    required String cityLine,
    required List<String> localPhotoPaths,
    required String citizenId,
    required String citizenName,
    required String citizenEmail,
  }) async {
    final inserted = await supabase
        .from('occurrences')
        .insert({
          'type': type.name,
          'description': description,
          'address': address,
          'city_line': cityLine,
          'latitude': position.latitude,
          'longitude': position.longitude,
          'citizen_id': citizenId,
          'citizen_name': citizenName,
          'citizen_email': citizenEmail,
        })
        .select()
        .single();

    final occurrenceDbId = inserted['id'] as String;
    final protocol = inserted['protocol'] as String;

    await supabase.from('occurrence_history').insert({
      'occurrence_id': occurrenceDbId,
      'text': 'Ocorrência registrada',
    });

    for (var i = 0; i < localPhotoPaths.length; i++) {
      final file = File(localPhotoPaths[i]);
      final storagePath = '$occurrenceDbId/${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
      await supabase.storage.from('occurrence-photos').upload(storagePath, file);
      final url = supabase.storage.from('occurrence-photos').getPublicUrl(storagePath);
      await supabase.from('occurrence_photos').insert({
        'occurrence_id': occurrenceDbId,
        'url': url,
      });
    }

    await loadAll();
    return byId(protocol)!;
  }

  /// Usado pela triagem para mudar o status de uma ocorrência.
  Future<void> updateStatus(String id, OccurrenceStatus status, {String? note}) async {
    final occ = byId(id);
    if (occ == null) return;

    await supabase.from('occurrences').update({'status': status.name}).eq('id', occ.recordId);

    var text = status.label;
    if (note != null && note.trim().isNotEmpty) {
      text = '$text - ${note.trim()}';
    }
    await supabase.from('occurrence_history').insert({
      'occurrence_id': occ.recordId,
      'text': text,
    });

    await loadAll();
  }

  /// Usado pela triagem para encaminhar ao órgão responsável.
  Future<void> forwardTo(String id, ResponsibleDepartment department) async {
    final occ = byId(id);
    if (occ == null) return;

    await supabase
        .from('occurrences')
        .update({'department': department.name}).eq('id', occ.recordId);
    await supabase.from('occurrence_history').insert({
      'occurrence_id': occ.recordId,
      'text': 'Encaminhada para ${department.label}',
    });

    await loadAll();
  }

  /// Usado pela triagem para registrar uma observação interna.
  Future<void> addNote(String id, String note) async {
    if (note.trim().isEmpty) return;
    final occ = byId(id);
    if (occ == null) return;

    await supabase.from('occurrence_history').insert({
      'occurrence_id': occ.recordId,
      'text': 'Observação: ${note.trim()}',
    });

    await loadAll();
  }
}

final occurrenceRepository = OccurrenceRepository();
