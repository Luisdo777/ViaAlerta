import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/formatters.dart';
import '../../models/occurrence.dart';
import '../../services/occurrence_repository.dart';
import '../../widgets/common.dart';
import '../../widgets/occurrence_map.dart';
import 'admin_change_status_screen.dart';

class AdminOccurrenceDetailScreen extends StatelessWidget {
  const AdminOccurrenceDetailScreen({super.key, required this.occurrenceId});
  final String occurrenceId;

  Future<void> _forward(BuildContext context) async {
    final department = await showModalBottomSheet<ResponsibleDepartment>(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text('Encaminhar ao órgão responsável',
                  style: TextStyle(
                      color: AppColors.lightBlue, fontSize: 16, fontWeight: FontWeight.w800)),
            ),
            for (final d in ResponsibleDepartment.values)
              ListTile(
                leading: const Icon(Icons.account_balance_outlined, color: AppColors.lightBlue),
                title: Text(d.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                onTap: () => Navigator.pop(ctx, d),
              ),
          ],
        ),
      ),
    );
    if (department == null) return;
    await occurrenceRepository.forwardTo(occurrenceId, department);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocorrência encaminhada para ${department.label}.')),
      );
    }
  }

  Future<void> _addNote(BuildContext context) async {
    final controller = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Observação interna'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Escreva uma observação para a equipe...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    if (note == null || note.trim().isEmpty) return;
    await occurrenceRepository.addNote(occurrenceId, note);
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Observação registrada.')));
    }
  }

  void _moreActions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.send_outlined, color: AppColors.lightBlue),
              title: const Text('Encaminhar ao órgão responsável'),
              onTap: () {
                Navigator.pop(ctx);
                _forward(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.note_add_outlined, color: AppColors.lightBlue),
              title: const Text('Adicionar observação interna'),
              onTap: () {
                Navigator.pop(ctx);
                _addNote(context);
              },
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
        final o = occurrenceRepository.byId(occurrenceId);
        if (o == null) {
          return Scaffold(
            appBar: AppBar(backgroundColor: AppColors.background),
            body: const Center(child: Text('Ocorrência não encontrada.')),
          );
        }

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
                      const SectionTitle('Cidadão'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.navy,
                            child: Text(
                              o.citizenName.isEmpty ? '?' : o.citizenName[0].toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(o.citizenName,
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                              Text(o.citizenEmail,
                                  style: const TextStyle(
                                      color: AppColors.textMuted, fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                      if (o.department != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0x333B82F6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.account_balance_outlined,
                                  size: 16, color: AppColors.blue),
                              const SizedBox(width: 8),
                              Text('Encaminhada para ${o.department!.label}',
                                  style: const TextStyle(
                                      color: AppColors.blue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ],
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
                  child: Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          label: 'Alterar status',
                          color: AppColors.navy,
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => AdminChangeStatusScreen(occurrenceId: o.id),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlineButtonX(
                          label: 'Mais ações',
                          borderColor: AppColors.lightBlue,
                          textColor: AppColors.lightBlue,
                          onPressed: () => _moreActions(context),
                        ),
                      ),
                    ],
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
