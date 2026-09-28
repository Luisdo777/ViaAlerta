import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/occurrence.dart';
import '../../services/occurrence_repository.dart';
import '../../widgets/common.dart';

class AdminChangeStatusScreen extends StatefulWidget {
  const AdminChangeStatusScreen({super.key, required this.occurrenceId});
  final String occurrenceId;

  @override
  State<AdminChangeStatusScreen> createState() => _AdminChangeStatusScreenState();
}

class _AdminChangeStatusScreenState extends State<AdminChangeStatusScreen> {
  late OccurrenceStatus _newStatus;
  final _note = TextEditingController();
  bool _saving = false;
  bool _initialized = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await occurrenceRepository.updateStatus(
      widget.occurrenceId,
      _newStatus,
      note: _note.text,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Status atualizado com sucesso.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final o = occurrenceRepository.byId(widget.occurrenceId);
    if (o == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: AppColors.background),
        body: const Center(child: Text('Ocorrência não encontrada.')),
      );
    }
    if (!_initialized) {
      _newStatus = o.status;
      _initialized = true;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: AppColors.lightBlue, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Alterar status',
            style: TextStyle(
                color: AppColors.lightBlue, fontSize: 20, fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ocorrência ${o.id}',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(o.title,
                      style: const TextStyle(
                          color: AppColors.lightBlue, fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(o.address, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text('Status atual',
                style: TextStyle(
                    color: AppColors.lightBlue, fontSize: 14, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Align(alignment: Alignment.centerLeft, child: StatusChip(o.status)),
            const SizedBox(height: 22),
            const Text('Novo status',
                style: TextStyle(
                    color: AppColors.lightBlue, fontSize: 14, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: _newStatus.background,
                borderRadius: BorderRadius.circular(28),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<OccurrenceStatus>(
                  value: _newStatus,
                  isExpanded: true,
                  dropdownColor: AppColors.surface,
                  icon: Icon(Icons.keyboard_arrow_down, color: _newStatus.color),
                  style: TextStyle(
                      color: _newStatus.color, fontSize: 15, fontWeight: FontWeight.w800),
                  items: [
                    for (final s in OccurrenceStatus.values)
                      DropdownMenuItem(
                        value: s,
                        child: Text(s.label,
                            style: TextStyle(color: s.color, fontWeight: FontWeight.w700)),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _newStatus = value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 22),
            const Text('Observação (opcional)',
                style: TextStyle(
                    color: AppColors.lightBlue, fontSize: 14, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            AppTextField(
              hint: 'Informações sobre o andamento da ocorrência...',
              controller: _note,
              maxLines: 4,
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: 'Salvar alteração',
              color: AppColors.navy,
              loading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
