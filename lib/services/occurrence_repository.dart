import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../models/occurrence.dart';

/// Repositório em memória com dados de exemplo (os mesmos do protótipo).
/// Para conectar ao backend, mantenha esta interface e troque a implementação.
class OccurrenceRepository extends ChangeNotifier {
  OccurrenceRepository() {
    _items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  int _nextSeq = 124;

  final List<Occurrence> _items = [
    Occurrence(
      id: '#2024-000123',
      type: OccurrenceType.pothole,
      description:
          'Buraco grande no meio da via, dificultando a passagem de veículos.',
      address: 'Av. Almirante Barroso, 1234',
      cityLine: 'Nazaré, Belém - PA',
      position: const LatLng(-1.4508, -48.4815),
      status: OccurrenceStatus.open,
      createdAt: DateTime(2024, 5, 12, 10, 30),
      citizenName: 'Guilherme Silva',
      citizenEmail: 'guilherme@email.com',
      history: [
        HistoryEntry(DateTime(2024, 5, 12, 10, 30), 'Ocorrência registrada'),
      ],
    ),
    Occurrence(
      id: '#2024-000122',
      type: OccurrenceType.trafficLight,
      description: 'Semáforo do cruzamento está apagado desde a noite passada.',
      address: 'Tv. Quintino Bocaiúva, 567',
      cityLine: 'Nazaré, Belém - PA',
      position: const LatLng(-1.4540, -48.4850),
      status: OccurrenceStatus.inProgress,
      createdAt: DateTime(2024, 5, 10, 8, 15),
      citizenName: 'Marina Costa',
      citizenEmail: 'marina.costa@email.com',
      department: ResponsibleDepartment.traffic,
      history: [
        HistoryEntry(DateTime(2024, 5, 11, 14, 0), 'Em andamento'),
        HistoryEntry(DateTime(2024, 5, 10, 16, 40),
            'Encaminhada para Secretaria de Trânsito'),
        HistoryEntry(DateTime(2024, 5, 10, 8, 15), 'Ocorrência registrada'),
      ],
    ),
    Occurrence(
      id: '#2024-000121',
      type: OccurrenceType.damagedSign,
      description: 'Placa de sinalização caída e amassada na esquina.',
      address: 'Rua João Balbi, 890',
      cityLine: 'Nazaré, Belém - PA',
      position: const LatLng(-1.4480, -48.4790),
      status: OccurrenceStatus.resolved,
      createdAt: DateTime(2024, 5, 8, 9, 0),
      citizenName: 'Pedro Nascimento',
      citizenEmail: 'pedro.nascimento@email.com',
      department: ResponsibleDepartment.traffic,
      history: [
        HistoryEntry(DateTime(2024, 5, 9, 17, 20), 'Resolvida'),
        HistoryEntry(DateTime(2024, 5, 8, 15, 5), 'Em andamento'),
        HistoryEntry(DateTime(2024, 5, 8, 9, 0), 'Ocorrência registrada'),
      ],
    ),
    Occurrence(
      id: '#2024-000120',
      type: OccurrenceType.streetLight,
      description: 'Poste sem iluminação em todo o quarteirão.',
      address: 'Av. Gentil Bittencourt, 45',
      cityLine: 'Nazaré, Belém - PA',
      position: const LatLng(-1.4555, -48.4770),
      status: OccurrenceStatus.open,
      createdAt: DateTime(2024, 5, 5, 19, 45),
      citizenName: 'Ana Beatriz Lima',
      citizenEmail: 'ana.lima@email.com',
      history: [
        HistoryEntry(DateTime(2024, 5, 5, 19, 45), 'Ocorrência registrada'),
      ],
    ),
    Occurrence(
      id: '#2024-000119',
      type: OccurrenceType.damagedSidewalk,
      description: 'Calçada quebrada, com risco de queda para pedestres.',
      address: 'Rua dos Caripunas, 120',
      cityLine: 'Batista Campos, Belém - PA',
      position: const LatLng(-1.4590, -48.4880),
      status: OccurrenceStatus.inProgress,
      createdAt: DateTime(2024, 5, 1, 7, 30),
      citizenName: 'João Vitor Souza',
      citizenEmail: 'joao.souza@email.com',
      department: ResponsibleDepartment.publicWorks,
      history: [
        HistoryEntry(DateTime(2024, 5, 3, 10, 0), 'Em andamento'),
        HistoryEntry(DateTime(2024, 5, 1, 7, 30), 'Ocorrência registrada'),
      ],
    ),
  ];

  List<Occurrence> get all => List.unmodifiable(_items);

  Occurrence? byId(String id) {
    for (final o in _items) {
      if (o.id == id) return o;
    }
    return null;
  }

  Future<Occurrence> create({
    required OccurrenceType type,
    required String description,
    required LatLng position,
    required String address,
    required String cityLine,
    required List<String> photos,
    required String citizenName,
    required String citizenEmail,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final now = DateTime.now();
    final occurrence = Occurrence(
      id: '#${now.year}-${_nextSeq.toString().padLeft(6, '0')}',
      type: type,
      description: description,
      address: address,
      cityLine: cityLine,
      position: position,
      status: OccurrenceStatus.open,
      createdAt: now,
      photos: photos,
      citizenName: citizenName,
      citizenEmail: citizenEmail,
      history: [HistoryEntry(now, 'Ocorrência registrada')],
    );
    _nextSeq++;
    _items.insert(0, occurrence);
    notifyListeners();
    return occurrence;
  }

  int _indexOf(String id) => _items.indexWhere((o) => o.id == id);

  /// Usado pela triagem para mudar o status de uma ocorrência.
  Future<void> updateStatus(String id, OccurrenceStatus status, {String? note}) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final i = _indexOf(id);
    if (i == -1) return;
    final current = _items[i];
    var text = status.label;
    if (note != null && note.trim().isNotEmpty) {
      text = '$text - ${note.trim()}';
    }
    final history = [HistoryEntry(DateTime.now(), text), ...current.history];
    _items[i] = current.copyWith(status: status, history: history);
    notifyListeners();
  }

  /// Usado pela triagem para encaminhar ao órgão responsável.
  Future<void> forwardTo(String id, ResponsibleDepartment department) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final i = _indexOf(id);
    if (i == -1) return;
    final current = _items[i];
    final history = [
      HistoryEntry(DateTime.now(), 'Encaminhada para ${department.label}'),
      ...current.history,
    ];
    _items[i] = current.copyWith(department: department, history: history);
    notifyListeners();
  }

  /// Usado pela triagem para registrar uma observação interna.
  Future<void> addNote(String id, String note) async {
    if (note.trim().isEmpty) return;
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final i = _indexOf(id);
    if (i == -1) return;
    final current = _items[i];
    final history = [
      HistoryEntry(DateTime.now(), 'Observação: ${note.trim()}'),
      ...current.history,
    ];
    _items[i] = current.copyWith(history: history);
    notifyListeners();
  }
}

final occurrenceRepository = OccurrenceRepository();
