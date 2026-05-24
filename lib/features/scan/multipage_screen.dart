import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/models/document.dart';
import '../../shared/widgets/app_widgets.dart';

class MultipageScreen extends StatefulWidget {
  final List<ScannedPage> pages;
  const MultipageScreen({super.key, required this.pages});

  @override
  State<MultipageScreen> createState() => _MultipageScreenState();
}

class _MultipageScreenState extends State<MultipageScreen> {
  late List<ScannedPage> _pages;

  @override
  void initState() {
    super.initState();
    _pages = List.from(widget.pages);
  }

  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final p = _pages.removeAt(oldIndex);
      _pages.insert(newIndex, p);
      for (int i = 0; i < _pages.length; i++) {
        _pages[i] = _pages[i].copyWith(index: i + 1);
      }
    });
  }

  void _deletePage(String id) {
    setState(() {
      _pages.removeWhere((p) => p.id == id);
      for (int i = 0; i < _pages.length; i++) {
        _pages[i] = _pages[i].copyWith(index: i + 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: 'Seiten prüfen',
        subtitle: '${_pages.length} ${_pages.length == 1 ? "Seite" : "Seiten"} aufgenommen',
        leading: AppIconButton(icon: Icons.arrow_back, onTap: () => context.pop()),
        trailing: AppIconButton(icon: Icons.more_vert_outlined, onTap: () {}),
      ),
      body: Stack(
        children: [
          ReorderableListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
            itemCount: _pages.length + 1,
            onReorder: _reorder,
            buildDefaultDragHandles: false,
            itemBuilder: (context, index) {
              if (index == _pages.length) {
                return _AddMoreCard(key: const ValueKey('add'), onTap: () => context.pop());
              }
              final page = _pages[index];
              return ReorderableDragStartListener(
                key: ValueKey(page.id),
                index: index,
                child: _PageCard(
                  page: page,
                  onEdit: () => context.push('/edit', extra: page),
                  onDelete: () => _deletePage(page.id),
                ),
              );
            },
          ),

          // Bottom action bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Theme.of(context).scaffoldBackgroundColor, Theme.of(context).scaffoldBackgroundColor.withOpacity(0)],
                ),
              ),
              child: Row(children: [
                Expanded(
                  child: GhostButton(
                    label: 'Weiter scannen',
                    icon: Icons.add_a_photo_outlined,
                    onTap: () => context.pop(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: PrimaryButton(
                    label: 'Weiter zum Export',
                    icon: Icons.arrow_forward,
                    onTap: _pages.isEmpty ? null : () => context.push('/export', extra: _pages),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageCard extends StatelessWidget {
  final ScannedPage page;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PageCard({required this.page, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          GestureDetector(
            onTap: onEdit,
            child: AspectRatio(
              aspectRatio: 0.75,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DocThumbnail(imagePath: page.imagePath, seed: page.id.hashCode, width: double.infinity, height: double.infinity),
                  ),
                  // Page number badge
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      color: c.onSurface,
                      child: Text(
                        page.index.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600,
                          letterSpacing: 0.4, color: c.surface,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                  // Drag handle
                  Positioned(
                    top: 6, right: 6,
                    child: Container(
                      width: 24, height: 24,
                      color: Colors.black.withOpacity(0.6),
                      child: const Icon(Icons.drag_handle, size: 14, color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(children: [
              Text('A4 · 200 dpi', style: TextStyle(fontSize: 11, color: c.onSurface.withOpacity(0.4), letterSpacing: 0.1)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.tune, size: 15),
                onPressed: onEdit,
                style: IconButton.styleFrom(foregroundColor: c.onSurface.withOpacity(0.5), minimumSize: const Size(28, 28)),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 15),
                onPressed: onDelete,
                style: IconButton.styleFrom(foregroundColor: const Color(0xFFB85050), minimumSize: const Size(28, 28)),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _AddMoreCard extends StatelessWidget {
  final VoidCallback onTap;
  const _AddMoreCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 0.75,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: c.onSurface.withOpacity(0.2), width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: c.surface, shape: BoxShape.circle),
                child: Icon(Icons.add, size: 24, color: c.primary),
              ),
              const SizedBox(height: 10),
              Text('Seite hinzufügen', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: c.onSurface.withOpacity(0.6))),
              const SizedBox(height: 4),
              Text('KAMERA', style: TextStyle(fontSize: 10, letterSpacing: 1.8, color: c.onSurface.withOpacity(0.3))),
            ],
          ),
        ),
      ),
    );
  }
}
