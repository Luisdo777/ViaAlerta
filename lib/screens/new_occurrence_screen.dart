import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../core/app_theme.dart';
import '../models/occurrence.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';
import '../services/occurrence_repository.dart';
import '../widgets/common.dart';
import '../widgets/occurrence_map.dart';
import 'success_screen.dart';

class NewOccurrenceScreen extends StatefulWidget {
  const NewOccurrenceScreen({super.key});

  @override
  State<NewOccurrenceScreen> createState() => _NewOccurrenceScreenState();
}

class _NewOccurrenceScreenState extends State<NewOccurrenceScreen> {
  static const _maxPhotos = 5;

  final _formKey = GlobalKey<FormState>();
  final _description = TextEditingController();
  final _picker = ImagePicker();

  OccurrenceType? _type;
  LatLng? _position; // posição escolhida (GPS ou toque no mapa)
  LatLng _mapCenter = locationService.lastKnown ?? LocationService.defaultCenter;
  int _mapKey = 0;
  ResolvedAddress? _resolved;
  bool _locating = false;
  bool _submitting = false;
  final List<String> _photos = [];

  @override
  void initState() {
    super.initState();
    _useCurrentLocation(silent: true);
  }

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _useCurrentLocation({bool silent = false}) async {
    setState(() => _locating = true);
    final pos = await locationService.currentPosition();
    if (!mounted) return;
    if (pos == null) {
      setState(() => _locating = false);
      if (!silent) {
        _snack('Não foi possível obter sua localização. Toque no mapa para marcar o local.');
      }
      return;
    }
    setState(() {
      _position = pos;
      _mapCenter = pos;
      _mapKey++;
    });
    await _resolveAddress(pos);
  }

  Future<void> _resolveAddress(LatLng p) async {
    final resolved = await locationService.addressFor(p);
    if (!mounted) return;
    setState(() {
      _resolved = resolved;
      _locating = false;
    });
  }

  void _pickOnMap(LatLng p) {
    setState(() => _position = p);
    _resolveAddress(p);
  }

  Future<void> _pickType() async {
    final chosen = await showModalBottomSheet<OccurrenceType>(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            for (final t in OccurrenceType.values)
              ListTile(
                leading: Icon(t.icon, color: AppColors.lightBlue),
                title: Text(t.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                trailing: t == _type
                    ? const Icon(Icons.check, color: AppColors.orangeText)
                    : null,
                onTap: () => Navigator.pop(ctx, t),
              ),
          ],
        ),
      ),
    );
    if (chosen != null) setState(() => _type = chosen);
  }

  Future<void> _addPhoto() async {
    if (_photos.length >= _maxPhotos) {
      _snack('Você pode anexar até $_maxPhotos fotos.');
      return;
    }
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined, color: AppColors.lightBlue),
              title: const Text('Tirar foto'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.lightBlue),
              title: const Text('Escolher da galeria'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    try {
      final file = await _picker.pickImage(source: source, imageQuality: 80, maxWidth: 1600);
      if (file != null && mounted) setState(() => _photos.add(file.path));
    } catch (_) {
      if (mounted) _snack('Não foi possível acessar a câmera ou a galeria. Verifique as permissões do app.');
    }
  }

  Future<void> _submit() async {
    final formOk = _formKey.currentState!.validate();
    if (!formOk) return;
    if (_position == null) {
      _snack('Marque a localização da ocorrência no mapa.');
      return;
    }
    setState(() => _submitting = true);
    final resolved = _resolved ?? await locationService.addressFor(_position!);
    final user = authService.user;
    final created = await occurrenceRepository.create(
      type: _type!,
      description: _description.text.trim(),
      position: _position!,
      address: resolved.address,
      cityLine: resolved.cityLine,
      photos: List.of(_photos),
      citizenName: user?.name ?? 'Cidadão',
      citizenEmail: user?.email ?? '-',
    );
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(builder: (_) => SuccessScreen(protocol: created.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: AppColors.lightBlue, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Nova ocorrência',
            style: TextStyle(
                color: AppColors.lightBlue, fontSize: 20, fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              _label('Tipo de ocorrência', required: true),
              FormField<OccurrenceType>(
                validator: (_) => _type == null ? 'Selecione o tipo de ocorrência' : null,
                builder: (state) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () async {
                        await _pickType();
                        state.didChange(_type);
                        if (_type != null) state.validate();
                      },
                      child: Container(
                        height: 54,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1F21),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: state.hasError ? AppColors.red : AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _type?.label ?? 'Selecione o tipo',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _type == null ? AppColors.textMuted : Colors.white,
                                ),
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
                          ],
                        ),
                      ),
                    ),
                    if (state.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 4),
                        child: Text(state.errorText!,
                            style: const TextStyle(color: AppColors.red, fontSize: 12)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _label('Descrição do problema', required: true),
              AppTextField(
                hint: 'Descreva o problema...',
                controller: _description,
                maxLines: 5,
                maxLength: 500,
                keyboardType: TextInputType.multiline,
                validator: (v) =>
                    (v ?? '').trim().length < 5 ? 'Descreva o problema com mais detalhes' : null,
              ),
              const SizedBox(height: 12),
              _label('Localização'),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 150,
                  child: Stack(
                    children: [
                      OccurrenceMap(
                        key: ValueKey(_mapKey),
                        center: _mapCenter,
                        zoom: 16,
                        onTap: _pickOnMap,
                        markers: [
                          if (_position != null) pinMarker(_position!, AppColors.lightBlue),
                        ],
                      ),
                      if (_position == null)
                        const Positioned(
                          left: 0,
                          right: 0,
                          bottom: 10,
                          child: Center(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Color(0xCC000000),
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                child: Text('Toque no mapa para marcar o local',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (_resolved != null) ...[
                const SizedBox(height: 8),
                Text(
                  [_resolved!.address, _resolved!.cityLine].where((s) => s.isNotEmpty).join(' - '),
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _locating ? null : _useCurrentLocation,
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                  child: Text(
                    _locating ? 'Buscando localização...' : 'Usar minha localização atual',
                    style: const TextStyle(
                        color: AppColors.orangeText, fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _label('Fotos (opcional)'),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (var i = 0; i < _photos.length; i++)
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(File(_photos[i]),
                              width: 92, height: 92, fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: -6,
                          right: -6,
                          child: GestureDetector(
                            onTap: () => setState(() => _photos.removeAt(i)),
                            child: const CircleAvatar(
                              radius: 11,
                              backgroundColor: AppColors.red,
                              child: Icon(Icons.close, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (_photos.length < _maxPhotos)
                    InkWell(
                      onTap: _addPhoto,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, color: AppColors.textMuted),
                            SizedBox(height: 2),
                            Text('Adicionar',
                                style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Você pode anexar até 5 fotos',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Enviar ocorrência',
                color: AppColors.navy,
                loading: _submitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          text: text,
          style: const TextStyle(
              color: AppColors.lightBlue, fontSize: 14, fontWeight: FontWeight.w800),
          children: [
            if (required)
              const TextSpan(text: ' *', style: TextStyle(color: AppColors.red)),
          ],
        ),
      ),
    );
  }
}
