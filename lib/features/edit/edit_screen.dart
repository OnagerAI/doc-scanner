import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/models/document.dart';
import '../../shared/widgets/app_widgets.dart';

const _filters = [
  (id: 'auto',  label: 'Auto',       matrix: <double>[1.05, 0, 0, 0, 0,  0, 1.05, 0, 0, 0,  0, 0, 1.05, 0, 0,  0, 0, 0, 1, 0]),
  (id: 'color', label: 'Farbe',      matrix: <double>[1, 0, 0, 0, 0,  0, 1, 0, 0, 0,  0, 0, 1, 0, 0,  0, 0, 0, 1, 0]),
  (id: 'gray',  label: 'Graustufen', matrix: <double>[0.33, 0.59, 0.11, 0, 0,  0.33, 0.59, 0.11, 0, 0,  0.33, 0.59, 0.11, 0, 0,  0, 0, 0, 1, 0]),
  (id: 'bw',    label: 'S/W',        matrix: <double>[0.55, 0.9, 0.18, 0, 0,  0.55, 0.9, 0.18, 0, 0,  0.55, 0.9, 0.18, 0, 0,  0, 0, 0, 1, 0]),
  (id: 'doc',   label: 'Dokument',   matrix: <double>[0.42, 0.72, 0.14, 0, 8,  0.42, 0.72, 0.14, 0, 8,  0.42, 0.72, 0.14, 0, 8,  0, 0, 0, 1, 0]),
  (id: 'ink',   label: 'Tinte',      matrix: <double>[0.28, 0.5, 0.1, 0, 18,  0.28, 0.5, 0.1, 0, 18,  0.28, 0.5, 0.1, 0, 18,  0, 0, 0, 1, 0]),
];

enum _Tab { crop, filter, tune, rotate, ocr }

class EditScreen extends StatefulWidget {
  final ScannedPage page;
  const EditScreen({super.key, required this.page});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  _Tab _tab = _Tab.filter;
  String _filterId = 'doc';
  double _rotation = 0;
  double _brightness = 1;
  double _contrast = 1;

  List<double> get _currentMatrix {
    final base = _filters.firstWhere((f) => f.id == _filterId).matrix;
    return base;
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final div = Theme.of(context).dividerColor;

    return Scaffold(
      appBar: AppTopBar(
        title: 'Seite bearbeiten',
        subtitle: 'Seite ${widget.page.index}',
        leading: AppIconButton(icon: Icons.arrow_back, onTap: () => context.pop()),
        trailing: TextButton(
          onPressed: () => context.pop(widget.page.copyWith(filter: _filterId, rotation: _rotation.toInt())),
          child: Text('Fertig', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1.8, color: c.primary)),
        ),
      ),
      body: Column(
        children: [
          // Preview
          Expanded(
            child: Container(
              color: c.surface,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Document preview
                  Transform.rotate(
                    angle: _rotation * 3.14159 / 180,
                    child: ColorFiltered(
                      colorFilter: ColorFilter.matrix(_currentMatrix),
                      child: widget.page.imagePath.isNotEmpty
                          ? Image.file(File(widget.page.imagePath), fit: BoxFit.contain, height: 320, width: 240)
                          : DocThumbnail(seed: widget.page.id.hashCode, width: 240, height: 320),
                    ),
                  ),

                  // Metadata overlay
                  Positioned(
                    top: 16, left: 16,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('2480 × 3508 PX', style: GoogleFonts.ibmPlexMono(fontSize: 9.5, color: c.onSurface.withOpacity(0.3))),
                      Text('300 DPI · A4', style: GoogleFonts.ibmPlexMono(fontSize: 9.5, color: c.onSurface.withOpacity(0.3))),
                      Text('● ERKANNT', style: GoogleFonts.ibmPlexMono(fontSize: 9.5, color: c.primary)),
                    ]),
                  ),

                  // Rotation indicator
                  Positioned(
                    top: 16, right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(border: Border.all(color: div)),
                      child: Text('${_rotation.toInt()}°', style: GoogleFonts.ibmPlexMono(fontSize: 10, color: c.onSurface.withOpacity(0.4))),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tab controls
          Container(
            color: c.surface,
            child: Column(
              children: [
                // Control panel
                _buildControls(c, div),
                const Divider(height: 1),
                // Tab bar
                Row(
                  children: [
                    for (final t in _Tab.values)
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _tab = t),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Column(children: [
                              Icon(_tabIcon(t), size: 20, color: _tab == t ? c.primary : c.onSurface.withOpacity(0.4)),
                              const SizedBox(height: 4),
                              Text(
                                _tabLabel(t),
                                style: TextStyle(
                                  fontSize: 9.5,
                                  letterSpacing: 1,
                                  fontWeight: _tab == t ? FontWeight.w600 : FontWeight.w400,
                                  color: _tab == t ? c.primary : c.onSurface.withOpacity(0.4),
                                ),
                              ),
                              if (_tab == t) Container(margin: const EdgeInsets.only(top: 4), width: 18, height: 2, color: c.primary),
                            ]),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(ColorScheme c, Color div) {
    return switch (_tab) {
      _Tab.filter => _FilterStrip(currentId: _filterId, onPick: (id) => setState(() => _filterId = id)),
      _Tab.rotate => _RotateControls(rotation: _rotation, onRotate: (r) => setState(() => _rotation = r)),
      _Tab.tune => _TuneControls(
          brightness: _brightness, contrast: _contrast,
          onBrightness: (v) => setState(() => _brightness = v),
          onContrast: (v) => setState(() => _contrast = v),
        ),
      _Tab.crop => _CropControls(),
      _Tab.ocr => _OcrControls(),
    };
  }

  IconData _tabIcon(_Tab t) => switch (t) {
        _Tab.crop => Icons.crop,
        _Tab.filter => Icons.filter_b_and_w_outlined,
        _Tab.tune => Icons.tune,
        _Tab.rotate => Icons.rotate_right_outlined,
        _Tab.ocr => Icons.text_fields_outlined,
      };

  String _tabLabel(_Tab t) => switch (t) {
        _Tab.crop => 'SCHNITT',
        _Tab.filter => 'FILTER',
        _Tab.tune => 'TONWERT',
        _Tab.rotate => 'DREHEN',
        _Tab.ocr => 'OCR',
      };
}

class _FilterStrip extends StatelessWidget {
  final String currentId;
  final ValueChanged<String> onPick;
  const _FilterStrip({required this.currentId, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final f = _filters[i];
          final active = currentId == f.id;
          return GestureDetector(
            onTap: () => onPick(f.id),
            child: Column(children: [
              Container(
                width: 56, height: 70,
                decoration: active ? BoxDecoration(border: Border.all(color: c.primary, width: 2)) : null,
                child: ColorFiltered(
                  colorFilter: ColorFilter.matrix(f.matrix),
                  child: const DocThumbnail(seed: 9, width: 56, height: 70),
                ),
              ),
              const SizedBox(height: 6),
              Text(f.label, style: TextStyle(fontSize: 11, fontWeight: active ? FontWeight.w600 : FontWeight.w400, color: active ? c.primary : c.onSurface.withOpacity(0.5))),
            ]),
          );
        },
      ),
    );
  }
}

class _RotateControls extends StatelessWidget {
  final double rotation;
  final ValueChanged<double> onRotate;
  const _RotateControls({required this.rotation, required this.onRotate});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          for (final (delta, icon, label) in [(-90.0, Icons.rotate_left, '90° links'), (90.0, Icons.rotate_right, '90° rechts'), (180.0, Icons.flip, '180°')])
            Expanded(
              child: GestureDetector(
                onTap: () => onRotate((rotation + delta) % 360),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(color: c.surface, border: Border.all(color: Theme.of(context).dividerColor)),
                  child: Column(children: [
                    Icon(icon, size: 18, color: c.onSurface),
                    const SizedBox(height: 6),
                    Text(label, style: TextStyle(fontSize: 11, color: c.onSurface.withOpacity(0.6))),
                  ]),
                ),
              ),
            ),
        ]),
        const SizedBox(height: 12),
        Text('FEINJUSTIERUNG', style: TextStyle(fontSize: 10, letterSpacing: 1.8, color: c.onSurface.withOpacity(0.4))),
        const SizedBox(height: 6),
        Slider(
          value: rotation > 180 ? rotation - 360 : rotation,
          min: -45, max: 45,
          activeColor: c.primary,
          onChanged: (v) => onRotate(v),
        ),
      ]),
    );
  }
}

class _TuneControls extends StatelessWidget {
  final double brightness, contrast;
  final ValueChanged<double> onBrightness, onContrast;
  const _TuneControls({required this.brightness, required this.contrast, required this.onBrightness, required this.onContrast});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Column(children: [
        _Slider(label: 'Helligkeit', value: brightness, min: 0.5, max: 1.5, display: '${((brightness - 1) * 100).round()}%', onChanged: onBrightness),
        _Slider(label: 'Kontrast', value: contrast, min: 0.5, max: 2, display: '${((contrast - 1) * 100).round()}%', onChanged: onContrast),
      ]),
    );
  }
}

class _Slider extends StatelessWidget {
  final String label, display;
  final double value, min, max;
  final ValueChanged<double> onChanged;
  const _Slider({required this.label, required this.display, required this.value, required this.min, required this.max, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label.toUpperCase(), style: TextStyle(fontSize: 10, letterSpacing: 1.6, color: c.onSurface.withOpacity(0.4))),
        Text(display, style: TextStyle(fontSize: 11, color: c.onSurface)),
      ]),
      Slider(value: value, min: min, max: max, activeColor: c.primary, onChanged: onChanged),
    ]);
  }
}

class _CropControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        children: [
          for (final (label, sub, active) in [('Erkannt', 'Auto', true), ('A4', '210×297', false), ('Letter', '8.5×11', false), ('Quadrat', '1:1', false), ('Frei', 'manuell', false)])
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: active ? c.primary : Colors.transparent,
                border: Border.all(color: active ? c.primary : Theme.of(context).dividerColor),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: active ? c.onPrimary : c.onSurface)),
                Text(sub, style: TextStyle(fontSize: 10, color: active ? c.onPrimary.withOpacity(0.75) : c.onSurface.withOpacity(0.45))),
              ]),
            ),
        ],
      ),
    );
  }
}

class _OcrControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final div = Theme.of(context).dividerColor;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: c.surface, border: Border.all(color: div)),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('OCR aktiviert', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: c.onSurface)),
              const SizedBox(height: 2),
              Text('Deutsch · läuft automatisch', style: TextStyle(fontSize: 11, color: c.onSurface.withOpacity(0.5))),
            ])),
            const AppPill('Aktiv', accent: true),
          ]),
        ),
      ]),
    );
  }
}
