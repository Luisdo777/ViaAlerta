import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../core/app_theme.dart';
import '../core/formatters.dart';
import '../models/occurrence.dart';
import '../services/location_service.dart';
import '../services/occurrence_repository.dart';
import '../widgets/occurrence_map.dart';
import 'occurrence_detail_screen.dart';

class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  final Set<OccurrenceStatus> _visible = {...OccurrenceStatus.values};
  final _distance = const Distance();
  LatLng _reference = locationService.lastKnown ?? LocationService.defaultCenter;

  @override
  void initState() {
    super.initState();
    _locate();
  }

  Future<void> _locate() async {
    final pos = await locationService.currentPosition();
    if (pos != null && mounted) setState(() => _reference = pos);
  }

  void _open(Occurrence o) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => OccurrenceDetailScreen(occurrenceId: o.id)),
    );
  }

  void _openFilter() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filtrar por status',
                  style: TextStyle(
                      color: AppColors.lightBlue, fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  for (final s in OccurrenceStatus.values)
                    FilterChip(
                      label: Text(s.label),
                      selected: _visible.contains(s),
                      selectedColor: s.background,
                      checkmarkColor: s.color,
                      labelStyle: TextStyle(
                        color: _visible.contains(s) ? s.color : AppColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                      onSelected: (on) {
                        setState(() => on ? _visible.add(s) : _visible.remove(s));
                        setSheet(() {});
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListenableBuilder(
        listenable: occurrenceRepository,
        builder: (context, _) {
          final items = occurrenceRepository.all
              .where((o) => _visible.contains(o.status))
              .toList()
            ..sort((a, b) => _distance
                .distance(_reference, a.position)
                .compareTo(_distance.distance(_reference, b.position)));

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 8, 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text('Mapa de ocorrências',
                          style: TextStyle(
                              color: AppColors.lightBlue,
                              fontSize: 22,
                              fontWeight: FontWeight.w900)),
                    ),
                    IconButton(
                      onPressed: _openFilter,
                      icon: const Icon(Icons.filter_alt_outlined, color: AppColors.lightBlue),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: OccurrenceMap(
                  center: _reference,
                  zoom: 14.5,
                  markers: [
                    for (final o in items)
                      pinMarker(o.position, o.status.color, onTap: () => _open(o)),
                  ],
                ),
              ),
              Container(
                height: 230,
                width: double.infinity,
                color: AppColors.background,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ocorrências próximas',
                        style: TextStyle(
                            color: AppColors.lightBlue, fontSize: 15, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),
                    Expanded(
                      child: items.isEmpty
                          ? const Text('Nenhuma ocorrência com esses filtros.',
                              style: TextStyle(color: AppColors.textMuted))
                          : ListView.separated(
                              padding: const EdgeInsets.only(bottom: 12),
                              itemCount: items.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (context, i) {
                                final o = items[i];
                                final meters = _distance.distance(_reference, o.position);
                                return Material(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: () => _open(o),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: AppColors.border),
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(radius: 4, backgroundColor: o.status.color),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(o.title,
                                                    style: const TextStyle(
                                                        color: AppColors.lightBlue,
                                                        fontWeight: FontWeight.w800)),
                                                Text(o.address,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        color: AppColors.textMuted, fontSize: 12)),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(o.status.label,
                                                  style: TextStyle(
                                                      color: o.status.color,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w800)),
                                              Text(formatDistance(meters),
                                                  style: const TextStyle(
                                                      color: AppColors.textMuted, fontSize: 12)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
