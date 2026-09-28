import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/formatters.dart';
import '../services/auth_service.dart';
import '../services/occurrence_repository.dart';
import 'home_shell.dart';
import 'new_occurrence_screen.dart';
import 'occurrence_detail_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([authService, occurrenceRepository]),
      builder: (context, _) {
        final user = authService.user;
        final recent = occurrenceRepository.all.take(3).toList();

        return Column(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.navy,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Bem-vindo de volta,',
                                    style: TextStyle(color: AppColors.lightBlue, fontSize: 13)),
                                Text('Olá, ${user?.firstName ?? 'cidadão'}!',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                              ],
                            ),
                          ),
                          CircleAvatar(
                            radius: 19,
                            backgroundColor: AppColors.orange,
                            child: Text(user?.initial ?? '?',
                                style: const TextStyle(fontWeight: FontWeight.w800)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('Como podemos ajudar hoje?',
                          style: TextStyle(
                              color: AppColors.lightBlue, fontSize: 15, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(builder: (_) => const NewOccurrenceScreen()),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Registrar ocorrência',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _ActionCard(
                    icon: Icons.description_outlined,
                    iconBg: AppColors.background,
                    iconColor: AppColors.lightBlue,
                    title: 'Minhas ocorrências',
                    subtitle: 'Acompanhe seus chamados',
                    onTap: () => shellTabIndex.value = 1,
                  ),
                  const SizedBox(height: 12),
                  _ActionCard(
                    icon: Icons.map_outlined,
                    iconBg: const Color(0x33C2500A),
                    iconColor: AppColors.orangeText,
                    title: 'Mapa de ocorrências',
                    subtitle: 'Veja problemas próximos',
                    onTap: () => shellTabIndex.value = 2,
                  ),
                  const SizedBox(height: 24),
                  const Text('Atividade recente',
                      style: TextStyle(
                          color: AppColors.lightBlue, fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  if (recent.isEmpty)
                    const Text('Você ainda não registrou nenhuma ocorrência.',
                        style: TextStyle(color: AppColors.textMuted)),
                  for (final o in recent) ...[
                    Material(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                              builder: (_) => OccurrenceDetailScreen(occurrenceId: o.id)),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 5, right: 10),
                                child: CircleAvatar(radius: 4, backgroundColor: o.status.color),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(o.title,
                                        style: const TextStyle(
                                            fontSize: 15, fontWeight: FontWeight.w800)),
                                    const SizedBox(height: 3),
                                    Text(o.address,
                                        style: const TextStyle(
                                            color: AppColors.textMuted, fontSize: 12)),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(o.status.label,
                                            style: TextStyle(
                                                color: o.status.color,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700)),
                                        Text(formatDate(o.createdAt),
                                            style: const TextStyle(
                                                color: AppColors.textMuted, fontSize: 12)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: AppColors.lightBlue, fontSize: 15, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
