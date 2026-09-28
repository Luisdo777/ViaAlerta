import 'dart:io';

import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/formatters.dart';
import '../models/occurrence.dart';
import '../services/occurrence_repository.dart';
import '../widgets/common.dart';
import '../widgets/occurrence_map.dart';

class OccurrenceDetailScreen extends StatelessWidget {
  const OccurrenceDetailScreen({super.key, required this.occurrenceId});
  final String occurrenceId;

  void _showProgress(BuildContext context, Occurrence o) {
    const steps = OccurrenceStatus.values;
    final current = steps.indexOf(o.status);
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle('Andamento da ocorrência'),
            const SizedBox(height: 16),
            for (var i = 0; i < steps.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      i <= current ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: i <= current ? steps[i].color : AppColors.border,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      steps[i].label,
                      style: TextStyle(
                        fontWeight: i == current ? FontWeight.w800 : FontWeight.w600,
                        color: i <= current ? Colors.white : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: occurrenceRepository,
      builder: (context, _) {
        final matches = occurrenceRepository.all.where((o) => o.id == occurrenceId);
        if (matches.isEmpty) {
          return Scaffold(
            appBar: AppBar(backgroundColor: AppColors.background),
            body: const Center(child: Text('Ocorrência não encontrada.')),
          );
        }
        final o = matches.first;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.chevron_left, color: AppColors.lightBlue, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
            titleSpacing: 0,
            title: Row(
              children: [
                Flexible(
                  child: Text('Ocorrência ${o.id}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.lightBlue, fontSize: 18, fontWeight: FontWeight.w900)),
                ),
                const SizedBox(width: 8),
                StatusChip(o.status),
              ],
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    children: [
                      Text(o.title,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 18, color: AppColors.textMuted),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(o.address,
                                    style: const TextStyle(
                                        color: AppColors.textMuted, fontSize: 14)),
                                if (o.cityLine.isNotEmpty)
                                  Text(o.cityLine,
                                      style: const TextStyle(
                                          color: AppColors.textMuted, fontSize: 14)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          height: 130,
                          child: OccurrenceMap(
                            center: o.position,
                            zoom: 16,
                            interactive: false,
                            markers: [pinMarker(o.position, AppColors.lightBlue)],
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      const SectionTitle('Descrição'),
                      const SizedBox(height: 8),
                      Text(o.description, style: const TextStyle(fontSize: 14, height: 1.45)),
                      const SizedBox(height: 22),
                      const SectionTitle('Fotos'),
                      const SizedBox(height: 10),
                      if (o.photos.isEmpty)
                        const Text('Nenhuma foto anexada.',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 13))
                      else
                        SizedBox(
                          height: 84,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: o.photos.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 10),
                            itemBuilder: (context, i) => ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(File(o.photos[i]),
                                  width: 84,
                                  height: 84,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                        width: 84,
                                        height: 84,
                                        color: AppColors.surface,
                                        child: const Icon(Icons.broken_image_outlined,
                                            color: AppColors.textMuted),
                                      )),
                            ),
                          ),
                        ),
                      const SizedBox(height: 22),
                      const SectionTitle('Histórico'),
                      const SizedBox(height: 12),
                      for (var i = 0; i < o.history.length; i++)
                        _TimelineRow(
                          entry: o.history[i],
                          isLatest: i == 0,
                          isLast: i == o.history.length - 1,
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: PrimaryButton(
                    label: 'Acompanhar status',
                    color: AppColors.navy,
                    onPressed: () => _showProgress(context, o),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.entry, required this.isLatest, required this.isLast});

  final HistoryEntry entry;
  final bool isLatest;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 20,
            child: Column(
              children: [
                const SizedBox(height: 4),
                CircleAvatar(
                  radius: 5,
                  backgroundColor: isLatest ? AppColors.green : AppColors.border,
                ),
                if (!isLast)
                  Expanded(child: Container(width: 2, color: AppColors.border)),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16, left: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(formatDateTime(entry.date),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(entry.text,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
