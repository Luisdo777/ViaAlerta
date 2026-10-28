import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/occurrence.dart';
import '../../services/admin_auth_service.dart';
import '../../services/occurrence_repository.dart';
import '../../widgets/pie_chart.dart';
import 'admin_shell.dart';

const _typeColors = [
  AppColors.lightBlue,
  AppColors.orangeText,
  Color(0xFF3B82F6),
  AppColors.green,
  AppColors.amber,
  Color(0xFF9C6ADE),
  Color(0xFFEF4444),
  Color(0xFF6B7280),
];

class AdminDashboardTab extends StatelessWidget {
  const AdminDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([occurrenceRepository, adminAuthService]),
      builder: (context, _) {
        final items = occurrenceRepository.all;
        final total = items.length;
        final open = items.where((o) => o.status == OccurrenceStatus.open).length;
        final inProgress =
            items.where((o) => o.status == OccurrenceStatus.inProgress).length;
        final resolved = items.where((o) => o.status == OccurrenceStatus.resolved).length;

        final byType = <OccurrenceType, int>{};
        for (final o in items) {
          byType[o.type] = (byType[o.type] ?? 0) + 1;
        }
        final sortedTypes = byType.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final slices = <PieSlice>[
          for (var i = 0; i < sortedTypes.length; i++)
            PieSlice(sortedTypes[i].key.label, sortedTypes[i].value.toDouble(),
                _typeColors[i % _typeColors.length]),
        ];

        return Column(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.navy,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Painel administrativo',
                                style: TextStyle(color: AppColors.lightBlue, fontSize: 13)),
                            Text('Dashboard',
                                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 19,
                        backgroundColor: AppColors.orange,
                        child: Text(adminAuthService.admin?.initial ?? 'AD',
                            style: const TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.check_circle_outline,
                          iconColor: AppColors.lightBlue,
                          value: '$total',
                          label: 'Total de ocorrências',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.warning_amber_rounded,
                          iconColor: AppColors.amber,
                          value: '$open',
                          label: 'Abertas',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.autorenew,
                          iconColor: const Color(0xFF9C6ADE),
                          value: '$inProgress',
                          label: 'Em andamento',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.check_circle,
                          iconColor: AppColors.green,
                          value: '$resolved',
                          label: 'Resolvidas',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (slices.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Ocorrências por tipo',
                              style: TextStyle(
                                  color: AppColors.lightBlue,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800)),
                          const SizedBox(height: 14),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SimplePieChart(slices: slices, size: 120),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (final s in slices)
                                      PieLegendRow(
                                        slice: s,
                                        percent: ((s.value / total) * 100).round(),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => adminTabIndex.value = 1,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Gerenciar ocorrências',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(
                  color: AppColors.lightBlue, fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ],
      ),
    );
  }
}
