import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';
import '../../core/services/drive_service.dart';
import '../../shared/models/document.dart';
import '../../shared/widgets/app_widgets.dart';

const _suggestedTags = ['Vertrag', 'Rechnung', 'Steuer', 'Versicherung', 'Wichtig', 'Privat'];

class ExportScreen extends ConsumerStatefulWidget {
  final List<ScannedPage> pages;
  const ExportScreen({super.key, required this.pages});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  String _format = 'pdf';
  String _name = '';
  List<String> _tags = ['Vertrag'];
  String _quality = 'high';
  bool _pwd = false;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _name = 'Dokument ${DateFormat('yyyy-MM-dd').format(DateTime.now())}';
  }

  double get _sizeEst {
    final base = widget.pages.length * (_quality == 'high' ? 0.42 : _quality == 'med' ? 0.22 : 0.11);
    return _format == 'pdf' ? base : base * 1.15;
  }

  void _toggleTag(String t) {
    setState(() {
      if (_tags.contains(t)) {
        _tags = _tags.where((x) => x != t).toList();
      } else {
        _tags = [..._tags, t];
      }
    });
  }

  Future<void> _upload() async {
    setState(() => _uploading = true);

    // PDF erstellen
    final pdf = pw.Document();
    for (final page in widget.pages) {
      final file = File(page.imagePath);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        final image = pw.MemoryImage(bytes);
        pdf.addPage(pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (_) => pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain)),
        ));
      } else {
        pdf.addPage(pw.Page(pageFormat: PdfPageFormat.a4, build: (_) => pw.Container()));
      }
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${const Uuid().v4()}.pdf');
    await file.writeAsBytes(await pdf.save());

    // Dokument in DB speichern
    final now = DateTime.now();
    final doc = Document(
      id: const Uuid().v4(),
      title: _name,
      pages: widget.pages,
      tags: _tags,
      state: DocumentState.uploading,
      createdAt: now,
      updatedAt: now,
      format: _format,
      quality: _quality,
      passwordProtected: _pwd,
    );
    await AppDatabase().upsertDocument(doc);

    if (!mounted) return;

    // Drive-Upload Sheet zeigen
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DriveSheet(
        doc: doc,
        file: file,
        onDone: () {
          Navigator.pop(context);
          if (mounted) {
            context.go('/');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Dokument erfolgreich in Google Drive gespeichert.')),
            );
          }
        },
      ),
    );

    setState(() => _uploading = false);
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final div = Theme.of(context).dividerColor;

    return Scaffold(
      appBar: AppTopBar(
        title: 'Exportieren',
        subtitle: '${widget.pages.length} ${widget.pages.length == 1 ? "Seite" : "Seiten"} · ${widget.pages.length * 487} Wörter (OCR)',
        leading: AppIconButton(icon: Icons.arrow_back, onTap: () => context.pop()),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Filename preview
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Stack(children: [
                    DocThumbnail(
                      imagePath: widget.pages.isNotEmpty ? widget.pages.first.imagePath : null,
                      seed: 42, width: 72, height: 96,
                    ),
                    if (widget.pages.length > 1)
                      Positioned(
                        bottom: 4, right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          color: c.onSurface,
                          child: Text('×${widget.pages.length}', style: GoogleFonts.ibmPlexMono(fontSize: 10, fontWeight: FontWeight.w600, color: c.surface)),
                        ),
                      ),
                  ]),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('DATEINAME', style: TextStyle(fontSize: 10, letterSpacing: 2.2, color: c.onSurface.withOpacity(0.4))),
                      const SizedBox(height: 6),
                      TextField(
                        controller: TextEditingController(text: _name),
                        onChanged: (v) => _name = v,
                        style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w500, color: c.onSurface),
                        decoration: InputDecoration(
                          filled: false,
                          border: UnderlineInputBorder(borderSide: BorderSide(color: div)),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: div)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: c.primary)),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('$_name.$_format · ~${_sizeEst.toStringAsFixed(1)} MB',
                          style: GoogleFonts.ibmPlexMono(fontSize: 11, color: c.onSurface.withOpacity(0.3))),
                    ]),
                  ),
                ]),
              ),

              // Format
              const SectionLabel('FORMAT'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  for (final (id, label, sub, icon) in [('pdf', 'PDF', 'Mehrseitig · OCR durchsuchbar', Icons.picture_as_pdf_outlined), ('jpg', 'JPG', 'Eine Datei je Seite', Icons.image_outlined)])
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _format = id),
                        child: Container(
                          margin: id == 'jpg' ? const EdgeInsets.only(left: 10) : null,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _format == id ? c.primary.withOpacity(0.08) : Colors.transparent,
                            border: Border.all(color: _format == id ? c.primary : div),
                          ),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Icon(icon, size: 18, color: _format == id ? c.primary : c.onSurface),
                              const SizedBox(width: 8),
                              Text(label, style: GoogleFonts.cormorantGaramond(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: _format == id ? c.primary : c.onSurface)),
                              const Spacer(),
                              if (_format == id)
                                Container(
                                  width: 18, height: 18,
                                  decoration: BoxDecoration(color: c.primary, shape: BoxShape.circle),
                                  child: Icon(Icons.check, size: 12, color: c.onPrimary),
                                ),
                            ]),
                            const SizedBox(height: 4),
                            Text(sub, style: TextStyle(fontSize: 11, color: (_format == id ? c.primary : c.onSurface).withOpacity(0.65))),
                          ]),
                        ),
                      ),
                    ),
                ]),
              ),

              // Quality
              const SectionLabel('QUALITÄT'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(border: Border.all(color: div)),
                  child: Row(
                    children: [
                      for (int i = 0; i < 3; i++) ...[
                        if (i > 0) Container(width: 1, height: 50, color: div),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _quality = ['low', 'med', 'high'][i]),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              color: _quality == ['low', 'med', 'high'][i] ? c.onSurface : Colors.transparent,
                              child: Column(children: [
                                Text(['Niedrig', 'Mittel', 'Hoch'][i], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _quality == ['low', 'med', 'high'][i] ? c.surface : c.onSurface)),
                                Text(['150 dpi', '200 dpi', '300 dpi'][i], style: TextStyle(fontSize: 10, color: (_quality == ['low', 'med', 'high'][i] ? c.surface : c.onSurface).withOpacity(0.6))),
                              ]),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Tags
              const SectionLabel('SCHLAGWORTE'),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Wrap(spacing: 7, runSpacing: 7, children: [
                  for (final t in _suggestedTags)
                    GestureDetector(
                      onTap: () => _toggleTag(t),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: _tags.contains(t) ? c.onSurface : Colors.transparent,
                          border: Border.all(color: _tags.contains(t) ? c.onSurface : div),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          if (_tags.contains(t)) ...[Icon(Icons.check, size: 11, color: c.surface), const SizedBox(width: 5)],
                          Text(t, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _tags.contains(t) ? c.surface : c.onSurface.withOpacity(0.5))),
                        ]),
                      ),
                    ),
                ]),
              ),

              // Options
              const SectionLabel('OPTIONEN'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(children: [
                  AppSwitch(label: 'Passwort schützen', subtitle: 'Schützt das PDF vor unbefugtem Öffnen', value: _pwd, onChanged: (v) => setState(() => _pwd = v)),
                  const AppSwitch(label: 'Suchbarer Text (OCR)', subtitle: 'Wird in Drive-Volltextsuche indexiert', value: true, disabled: true),
                  const AppSwitch(label: 'Original-Bilder behalten', subtitle: 'Aufnahmen bleiben lokal gespeichert', value: false),
                ]),
              ),
            ]),
          ),

          // Upload button
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter, end: Alignment.topCenter,
                  colors: [Theme.of(context).scaffoldBackgroundColor, Theme.of(context).scaffoldBackgroundColor.withOpacity(0)],
                ),
              ),
              child: Column(children: [
                PrimaryButton(
                  label: 'In Google Drive hochladen',
                  icon: Icons.cloud_upload_outlined,
                  onTap: _uploading ? null : _upload,
                  fullWidth: true,
                ),
                const SizedBox(height: 8),
                Text('Standardordner: Scans / ${DateTime.now().year} / ${_monthName()}',
                    style: TextStyle(fontSize: 11, color: c.onSurface.withOpacity(0.35))),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _monthName() {
    const m = ['Jan','Feb','Mär','Apr','Mai','Jun','Jul','Aug','Sep','Okt','Nov','Dez'];
    return m[DateTime.now().month - 1];
  }
}

// ─── Drive Upload Bottom Sheet ────────────────────────────────────
class _DriveSheet extends ConsumerStatefulWidget {
  final Document doc;
  final File file;
  final VoidCallback onDone;

  const _DriveSheet({required this.doc, required this.file, required this.onDone});

  @override
  ConsumerState<_DriveSheet> createState() => _DriveSheetState();
}

class _DriveSheetState extends ConsumerState<_DriveSheet> {
  double _progress = 0;
  String _stage = 'uploading';

  @override
  void initState() {
    super.initState();
    _startUpload();
  }

  Future<void> _startUpload() async {
    final stream = ref.read(driveServiceProvider).uploadDocument(widget.doc, widget.file);
    await for (final p in stream) {
      if (!mounted) break;
      setState(() {
        _progress = p.progress;
        _stage = p.stage;
      });
      if (p.stage == 'done') {
        if (p.fileId != null && p.drivePath != null) {
          await AppDatabase().updateDriveInfo(widget.doc.id, p.fileId!, p.drivePath!);
        }
        await Future.delayed(const Duration(milliseconds: 400));
        if (mounted) widget.onDone();
      } else if (p.stage == 'error') {
        await AppDatabase().updateState(widget.doc.id, DocumentState.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final div = Theme.of(context).dividerColor;

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 26),
      decoration: BoxDecoration(color: c.surface, border: Border(top: BorderSide(color: div))),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Grabber
        Container(width: 36, height: 3, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: div, borderRadius: BorderRadius.circular(999))),

        // Header
        Row(children: [
          _DriveIcon(),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('GOOGLE DRIVE', style: TextStyle(fontSize: 11, letterSpacing: 2.2, color: c.onSurface.withOpacity(0.45))),
            const SizedBox(height: 2),
            Text(widget.doc.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: c.onSurface)),
          ]),
        ]),
        const SizedBox(height: 18),

        // File info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: c.surface, border: Border.all(color: div)),
          child: Row(children: [
            Icon(Icons.picture_as_pdf_outlined, size: 26, color: c.primary),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${widget.doc.title}.${widget.doc.format}', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: c.onSurface), overflow: TextOverflow.ellipsis),
              Text('${widget.doc.pageCount} Seiten · ${(widget.doc.pageCount * 0.42).toStringAsFixed(1)} MB',
                  style: GoogleFonts.ibmPlexMono(fontSize: 11, color: c.onSurface.withOpacity(0.4))),
            ])),
            if (_stage == 'done') const Icon(Icons.check_circle_outline, size: 22, color: Color(0xFF5A9E6A)),
          ]),
        ),
        const SizedBox(height: 18),

        // Progress
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            if (_stage != 'done')
              SizedBox(
                width: 12, height: 12,
                child: CircularProgressIndicator(strokeWidth: 1.5, color: _stage == 'indexing' ? const Color(0xFF5A7EA0) : c.primary),
              )
            else
              Container(width: 8, height: 8, margin: const EdgeInsets.only(right: 4), decoration: const BoxDecoration(color: Color(0xFF5A9E6A), shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(
              switch (_stage) { 'uploading' => 'Übertragung …', 'indexing' => 'OCR-Indexierung', _ => 'Erfolgreich gesichert' },
              style: TextStyle(fontSize: 11, letterSpacing: 1.6, color: c.onSurface),
            ),
          ]),
          Text('${(_progress * 100).round()}%', style: GoogleFonts.ibmPlexMono(fontSize: 11, color: c.onSurface.withOpacity(0.5))),
        ]),
        const SizedBox(height: 8),
        ClipRect(
          child: Container(height: 4, color: c.surface,
            child: Align(
              alignment: Alignment.centerLeft,
              child: AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 140),
                widthFactor: _progress,
                child: Container(color: _stage == 'done' ? const Color(0xFF5A9E6A) : c.primary),
              ),
            ),
          ),
        ),

        const SizedBox(height: 18),
        // Metadata strip
        Row(children: [
          for (final (label, value) in [('Verschlüsselt', 'AES-256'), ('OCR', 'Deutsch'), ('Sichtbar für', 'Nur ich')])
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label.toUpperCase(), style: TextStyle(fontSize: 10, letterSpacing: 1.8, color: c.onSurface.withOpacity(0.4))),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.onSurface)),
            ])),
        ]),
      ]),
    );
  }
}

class _DriveIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36, height: 32,
      child: CustomPaint(painter: _DriveIconPainter()),
    );
  }
}

class _DriveIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..style = PaintingStyle.fill;
    final w = s.width; final h = s.height;
    p.color = const Color(0xFF4285F4);
    canvas.drawPath(Path()..moveTo(w*0.07,h*0.88)..lineTo(w*0.11,h*0.97)..lineTo(w*0.38,h*0.97)..lineTo(w*0.32,h*0.7)..close(), p);
    p.color = const Color(0xFF34A853);
    canvas.drawPath(Path()..moveTo(w*0.5,h*0.33)..lineTo(w*0.34,h*0.02)..lineTo(w*0.01,h*0.65)..lineTo(w*0.32,h*0.7)..close(), p);
    p.color = const Color(0xFFFBBC04);
    canvas.drawPath(Path()..moveTo(w*0.84,h*0.35)..lineTo(w*0.99,h*0.65)..lineTo(w*0.68,h*0.7)..lineTo(w*0.75,h*0.97)..lineTo(w*0.86,h*0.88)..close(), p);
    p.color = const Color(0xFFEA4335);
    canvas.drawPath(Path()..moveTo(w*0.5,h*0.33)..lineTo(w*0.65,h*0.02)..lineTo(w*0.34,h*0.02)..close(), p);
    p.color = const Color(0xFF188038);
    canvas.drawPath(Path()..moveTo(w*0.32,h*0.7)..lineTo(w*0.16,h*0.97)..lineTo(w*0.75,h*0.97)..lineTo(w*0.68,h*0.7)..close(), p);
    p.color = const Color(0xFF1967D2);
    canvas.drawPath(Path()..moveTo(w*0.84,h*0.35)..lineTo(w*0.69,h*0.06)..lineTo(w*0.5,h*0.33)..lineTo(w*0.68,h*0.7)..lineTo(w*0.99,h*0.65)..close(), p);
  }
  @override bool shouldRepaint(_) => false;
}
