import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/occurrence.dart';
import '../../services/occurrence_repository.dart';

class AdminReportsTab extends StatelessWidget {
  const AdminReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListenableBuilder(
        listenable: occurrenceRepository,
        builder: (context, _) {
          final items = occurrenceRepository.all;
          final byDept = <ResponsibleDepartment, int>{};
          var forwarded = 0;
          for (final o in items) {
            if (o.department != null) {
              forwarded++;
              byDept[o.department!] = (byDept[o.department!] ?? 0) + 1;
            }
          }
          final avgHistorySteps = items.isEmpty
              ? 0.0
              : items.map((o) => o.history.length).reduce((a, b) => a + b) / items.length;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text('Relatórios',
                  style: TextStyle(
                      color: AppColors.lightBlue, fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 20),
              _ReportRow(label: 'Ocorrências registradas', value: '${items.length}'),
              _ReportRow(label: 'Encaminhadas a algum órgão', value: '$forwarded'),
              _ReportRow(
                  label: 'Etapas médias por ocorrência',
                  value: avgHistorySteps.toStringAsFixed(1)),
              const SizedBox(height: 24),
              const Text('Encaminhamentos por órgão',
                  style: TextStyle(
                      color: AppColors.lightBlue, fontSize: 15, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              if (byDept.isEmpty)
                const Text('Nenhuma ocorrência foi encaminhada ainda.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13))
              else
                for (final entry in byDept.entries)
                  _ReportRow(label: entry.key.label, value: '${entry.value}'),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Text(
                  'Relatórios mais detalhados (por período, por bairro, exportação em PDF ou '
                  'planilha) podem ser adicionados quando o painel estiver conectado ao backend.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.4),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReportRow extends StatelessWidget {
  const _ReportRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
        ],
      ),
    );
  }
}
