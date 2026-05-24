import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/database/app_database.dart';
import '../../core/services/auth_service.dart';
import '../../shared/models/document.dart';
import '../../shared/widgets/app_widgets.dart';
import '../../shared/widgets/onager_logo.dart';

final _docsProvider = FutureProvider<List<Document>>((ref) => AppDatabase().getAllDocuments());
final _statsProvider = FutureProvider<(int, int, int)>((ref) async {
  final db = AppDatabase();
  return (await db.getTotalDocuments(), await db.getTotalPages(), await db.getSyncedCount());
});

const _filters = ['Alle', 'Verträge', 'Finanzen', 'Ausweise', 'Protokolle'];

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _filter = 'Alle';
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final docs = ref.watch(_docsProvider);
    final stats = ref.watch(_statsProvider);
    final c = Theme.of(context).colorScheme;
    final div = Theme.of(context).dividerColor;

    final initials = user?.displayName?.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join() ?? '?';

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: Row(
                    children: [
                      Row(children: [
                        OnagerMark(size: 28, color: c.onSurface),
                        const SizedBox(width: 10),
                        OnagerWordmark(size: 18, color: c.onSurface),
                      ]),
                      const Spacer(),
                      AppIconButton(icon: Icons.search_outlined, onTap: () {}, label: 'Suchen'),
                      AppIconButton(icon: Icons.notifications_none_outlined, onTap: () {}, label: 'Benachrichtigungen'),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => context.push('/settings'),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: c.surface,
                            border: Border.all(color: div),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            initials,
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.4, color: c.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Title
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('BIBLIOTHEK', style: GoogleFonts.cormorantSc(fontSize: 10, letterSpacing: 2.8, color: c.onSurface.withOpacity(0.45))),
                    const SizedBox(height: 6),
                    Text('Meine Dokumente', style: GoogleFonts.cormorantGaramond(fontSize: 34, fontWeight: FontWeight.w500, color: c.onSurface, height: 1)),
                  ]),
                ),

                // Stats strip
                stats.when(
                  data: (s) => Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Container(
                      decoration: BoxDecoration(border: Border.all(color: div)),
                      child: Row(
                        children: [
                          _Stat('Dokumente', '${s.$1}', first: true),
                          _Stat('Seiten', '${s.$2}'),
                          _Stat('In Drive', '${s.$3}'),
                        ],
                      ),
                    ),
                  ),
                  loading: () => const SizedBox(height: 60),
                  error: (_, __) => const SizedBox(height: 60),
                ),

                // Search
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(color: c.surface, border: Border.all(color: div)),
                    child: Row(children: [
                      Icon(Icons.search, size: 16, color: c.onSurface.withOpacity(0.4)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          onChanged: (v) => setState(() => _search = v),
                          style: TextStyle(fontSize: 13.5, color: c.onSurface),
                          decoration: InputDecoration.collapsed(
                            hintText: 'Dokumente und Texte durchsuchen …',
                            hintStyle: TextStyle(fontSize: 13.5, color: c.onSurface.withOpacity(0.35)),
                          ),
                        ),
                      ),
                      const AppPill('OCR', accent: false),
                    ]),
                  ),
                ),

                // Filter chips
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    itemCount: _filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final f = _filters[i];
                      final active = _filter == f;
                      return GestureDetector(
                        onTap: () => setState(() => _filter = f),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: active ? c.onSurface : Colors.transparent,
                            border: Border.all(color: active ? c.onSurface : div),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            f,
                            style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500,
                              color: active ? c.surface : c.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // Doc list
                Expanded(
                  child: docs.when(
                    data: (list) {
                      final filtered = list.where((d) {
                        if (_search.isNotEmpty && !d.title.toLowerCase().contains(_search.toLowerCase())) return false;
                        return true;
                      }).toList();

                      if (filtered.isEmpty) {
                        return Center(
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.document_scanner_outlined, size: 56, color: c.onSurface.withOpacity(0.15)),
                            const SizedBox(height: 16),
                            Text('Keine Dokumente', style: GoogleFonts.cormorantGaramond(fontSize: 22, color: c.onSurface.withOpacity(0.4))),
                            const SizedBox(height: 8),
                            Text('Tippe auf + um dein erstes Dokument zu scannen', style: TextStyle(fontSize: 13, color: c.onSurface.withOpacity(0.3))),
                          ]),
                        );
                      }

                      final today = filtered.where((d) => _isToday(d.updatedAt)).toList();
                      final earlier = filtered.where((d) => !_isToday(d.updatedAt)).toList();

                      return ListView(
                        padding: const EdgeInsets.only(bottom: 100),
                        children: [
                          if (today.isNotEmpty) ...[
                            const SectionLabel('HEUTE'),
                            ...today.map((d) => _DocRow(doc: d)),
                          ],
                          if (earlier.isNotEmpty) ...[
                            const SectionLabel('FRÜHER'),
                            ...earlier.map((d) => _DocRow(doc: d)),
                          ],
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Text(
                              '— Ende der Bibliothek —',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cormorantGaramond(fontSize: 13, fontStyle: FontStyle.italic, color: c.onSurface.withOpacity(0.2)),
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Fehler: $e')),
                  ),
                ),
              ],
            ),
            ScanFAB(onTap: () => context.push('/scan')),
          ],
        ),
      ),
    );
  }

  bool _isToday(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final bool first;

  const _Stat(this.label, this.value, {this.first = false});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final div = Theme.of(context).dividerColor;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          border: first ? null : Border(left: BorderSide(color: div)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: GoogleFonts.cormorantGaramond(fontSize: 24, fontWeight: FontWeight.w500, color: c.onSurface, height: 1)),
          const SizedBox(height: 4),
          Text(label.toUpperCase(), style: TextStyle(fontSize: 10, letterSpacing: 2, color: c.onSurface.withOpacity(0.4))),
        ]),
      ),
    );
  }
}

class _DocRow extends StatelessWidget {
  final Document doc;
  const _DocRow({required this.doc});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final div = Theme.of(context).dividerColor;

    String dateLabel;
    final now = DateTime.now();
    if (doc.updatedAt.day == now.day && doc.updatedAt.month == now.month) {
      dateLabel = 'Heute, ${DateFormat('HH:mm').format(doc.updatedAt)}';
    } else if (doc.updatedAt.day == now.subtract(const Duration(days: 1)).day) {
      dateLabel = 'Gestern';
    } else {
      dateLabel = DateFormat('d. MMM', 'de_DE').format(doc.updatedAt);
    }

    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: div))),
        child: Row(children: [
          DocThumbnail(
            imagePath: doc.pages.isNotEmpty ? doc.pages.first.imagePath : null,
            seed: doc.id.hashCode,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                doc.title,
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500, color: c.onSurface),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(children: [
                Text(dateLabel, style: TextStyle(fontSize: 12, color: c.onSurface.withOpacity(0.45))),
                _dot(c),
                Text('${doc.pageCount} ${doc.pageCount == 1 ? "Seite" : "Seiten"}', style: TextStyle(fontSize: 12, color: c.onSurface.withOpacity(0.45))),
                if (doc.tagLabel.isNotEmpty) ...[_dot(c), Text(doc.tagLabel, style: TextStyle(fontSize: 12, color: c.onSurface.withOpacity(0.45)))],
              ]),
            ]),
          ),
          const SizedBox(width: 8),
          StateBadge(doc.state),
        ]),
      ),
    );
  }

  Widget _dot(ColorScheme c) => Container(
        width: 3, height: 3, margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(color: c.onSurface.withOpacity(0.2), shape: BoxShape.circle),
      );
}
