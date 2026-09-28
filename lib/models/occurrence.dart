import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../core/app_theme.dart';

enum OccurrenceStatus {
  open('Aberta', AppColors.green, Color(0x3322C55E)),
  inProgress('Em andamento', AppColors.amber, Color(0x33F59E0B)),
  resolved('Resolvida', AppColors.blue, Color(0x333B82F6));

  const OccurrenceStatus(this.label, this.color, this.background);
  final String label;
  final Color color;
  final Color background;
}

enum OccurrenceType {
  pothole('Buraco na via', Icons.warning_amber_rounded),
  trafficLight('Semáforo apagado', Icons.traffic_outlined),
  damagedSign('Placa danificada', Icons.signpost_outlined),
  streetLight('Iluminação pública', Icons.lightbulb_outline),
  damagedSidewalk('Calçada danificada', Icons.directions_walk),
  drainage('Bueiro ou drenagem', Icons.water_drop_outlined),
  roadMarking('Sinalização apagada', Icons.edit_road_outlined),
  other('Outros', Icons.more_horiz);

  const OccurrenceType(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// Órgão que pode receber o encaminhamento de uma ocorrência.
enum ResponsibleDepartment {
  publicWorks('Secretaria de Obras'),
  streetLighting('Secretaria de Iluminação Pública'),
  traffic('Secretaria de Trânsito'),
  civilDefense('Defesa Civil'),
  sanitation('Saneamento e Drenagem'),
  other('Outro órgão');

  const ResponsibleDepartment(this.label);
  final String label;
}

class HistoryEntry {
  const HistoryEntry(this.date, this.text);
  final DateTime date;
  final String text;
}

class Occurrence {
  const Occurrence({
    required this.id,
    required this.type,
    required this.description,
    required this.address,
    required this.cityLine,
    required this.position,
    required this.status,
    required this.createdAt,
    required this.history,
    required this.citizenName,
    required this.citizenEmail,
    this.photos = const [],
    this.department,
  });

  /// Número de protocolo, ex.: #2024-000123
  final String id;
  final OccurrenceType type;
  final String description;
  final String address;
  final String cityLine;
  final LatLng position;
  final OccurrenceStatus status;
  final DateTime createdAt;
  final List<HistoryEntry> history;
  final List<String> photos;

  /// Cidadão que abriu o chamado.
  final String citizenName;
  final String citizenEmail;

  /// Órgão responsável, quando já encaminhada.
  final ResponsibleDepartment? department;

  String get title => type.label;

  Occurrence copyWith({
    OccurrenceStatus? status,
    List<HistoryEntry>? history,
    ResponsibleDepartment? department,
  }) {
    return Occurrence(
      id: id,
      type: type,
      description: description,
      address: address,
      cityLine: cityLine,
      position: position,
      status: status ?? this.status,
      createdAt: createdAt,
      history: history ?? this.history,
      citizenName: citizenName,
      citizenEmail: citizenEmail,
      photos: photos,
      department: department ?? this.department,
    );
  }
}
