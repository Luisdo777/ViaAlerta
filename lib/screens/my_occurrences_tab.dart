import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/occurrence.dart';
import '../services/occurrence_repository.dart';
import '../widgets/common.dart';
import 'occurrence_detail_screen.dart';

class MyOccurrencesTab extends StatefulWidget {
  const MyOccurrencesTab({super.key});

  @override
  State<MyOccurrencesTab> createState() => _MyOccurrencesTabState();
}

class _MyOccurrencesTabState extends State<MyOccurrencesTab> {
  final _search = TextEditingController();
  OccurrenceStatus? _filter; // null = todas
  bool _searching = false;

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
                o.address.toLowerCase().contains(query);
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text('Minhas ocorrências',
                          style: TextStyle(
                              color: AppColors.lightBlue,
                              fontSize: 24,
                              fontWeight: FontWeight.w900)),
                    ),
                    IconButton(
                      onPressed: () => setState(() {
                        _searching = !_searching;
                        if (!_searching) _search.clear();
                      }),
                      icon: Icon(_searching ? Icons.close : Icons.search,
                          color: AppColors.lightBlue),
                    ),
                  ],
                ),
              ),
              if (_searching)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: TextField(
                    controller: _search,
                    autofocus: true,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Buscar por tipo, endereço ou protocolo',
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
                        itemBuilder: (context, i) => OccurrenceCard(
                          occurrence: items[i],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => OccurrenceDetailScreen(occurrenceId: items[i].id),
                            ),
                          ),
                        ),
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
