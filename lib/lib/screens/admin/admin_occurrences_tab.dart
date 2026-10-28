import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/formatters.dart';
import '../../models/occurrence.dart';
import '../../services/occurrence_repository.dart';
import '../../widgets/common.dart';
import 'admin_change_status_screen.dart';
import 'admin_occurrence_detail_screen.dart';

class AdminOccurrencesTab extends StatefulWidget {
  const AdminOccurrencesTab({super.key});

  @override
  State<AdminOccurrencesTab> createState() => _AdminOccurrencesTabState();
}

class _AdminOccurrencesTabState extends State<AdminOccurrencesTab> {
  final _search = TextEditingController();
  OccurrenceStatus? _filter;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListenableBuilder(
        listenable: occurrenceRepository,
        builder: (context, _) {
          final query = _search.text.trim().toLowerCase();
          final items = occurrenceRepository.all.where((o) {
            if (_filter != null && o.status != _filter) return false;
            if (query.isEmpty) return true;
            return o.title.toLowerCase().contains(query) ||
                o.id.toLowerCase().contains(query) ||
                o.address.toLowerCase().contains(query) ||
                o.citizenName.toLowerCase().contains(query);
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Text('Gerenciar ocorrências',
                    style: TextStyle(
                        color: AppColors.lightBlue, fontSize: 22, fontWeight: FontWeight.w900)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Buscar ocorrência...',
                    hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                    filled: true,
                    fillColor: const Color(0xFF1E1F21),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.lightBlue),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 58,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
                  children: [
                    _chip('Todas', null),
                    _chip('Abertas', OccurrenceStatus.open),
                    _chip('Em andamento', OccurrenceStatus.inProgress),
                    _chip('Resolvidas', OccurrenceStatus.resolved),
                  ],
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text(
                            'Nenhuma ocorrência encontrada com esses filtros.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final o = items[i];
                          return Material(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) => AdminOccurrenceDetailScreen(occurrenceId: o.id),
                                ),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(o.id,
                                            style: const TextStyle(
                                                color: AppColors.textMuted,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700)),
                                        StatusChip(o.status),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(o.title,
                                        style: const TextStyle(
                                            color: AppColors.lightBlue,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800)),
                                    const SizedBox(height: 4),
                                    Text(o.address,
                                        style: const TextStyle(
                                            color: AppColors.textMuted, fontSize: 13)),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(formatDate(o.createdAt),
                                            style: const TextStyle(
                                                color: AppColors.textMuted, fontSize: 12)),
                                        OutlinedButton(
                                          onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute<void>(
                                              builder: (_) =>
                                                  AdminChangeStatusScreen(occurrenceId: o.id),
                                            ),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: AppColors.lightBlue,
                                            side: const BorderSide(color: AppColors.border),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 6),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10)),
                                          ),
                                          child: const Text('Alterar status',
                                              style: TextStyle(
                                                  fontSize: 12, fontWeight: FontWeight.w700)),
                                        ),
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
          );
        },
      ),
    );
  }

  Widget _chip(String label, OccurrenceStatus? status) {
    final selected = _filter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _filter = status),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.navy : const Color(0xFF26272A),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
