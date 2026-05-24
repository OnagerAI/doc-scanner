import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:uuid/uuid.dart';
import '../../shared/models/document.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  final List<ScannedPage> _pages = [];
  bool _scanning = false;
  final _uuid = const Uuid();

  Future<void> _scan() async {
    if (_scanning) return;
    setState(() => _scanning = true);

    try {
      final paths = await CunningDocumentScanner.getPictures(
        noOfPages: 20,
        isGalleryImportAllowed: true,
      );

      if (paths != null && paths.isNotEmpty) {
        final now = DateTime.now();
        final newPages = paths.asMap().entries.map((e) => ScannedPage(
          id: _uuid.v4(),
          imagePath: e.value,
          index: _pages.length + e.key + 1,
          createdAt: now,
        )).toList();

        setState(() => _pages.addAll(newPages));

        if (mounted && _pages.isNotEmpty) {
          context.push('/scan/review', extra: List<ScannedPage>.from(_pages));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scan-Fehler: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  @override
  void initState() {
    super.initState();
    // Kamera automatisch öffnen
    WidgetsBinding.instance.addPostFrameCallback((_) => _scan());
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;

    // Der cunning_document_scanner öffnet sein eigenes native UI.
    // Dieser Screen zeigt nur einen Loading-State bis der Scanner zurückkommt.
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(color: c.primary, strokeWidth: 2),
            ),
            const SizedBox(height: 20),
            Text(
              _scanning ? 'Scanner wird geöffnet …' : 'Bereit',
              style: const TextStyle(color: Colors.white60, fontSize: 14, letterSpacing: 0.3),
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Abbrechen', style: TextStyle(color: Colors.white38)),
            ),
          ],
        ),
      ),
    );
  }
}
