import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/auth_service.dart';
import '../../shared/widgets/app_widgets.dart';
import '../../shared/widgets/onager_logo.dart';

final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final themeMode = ref.watch(themeProvider);
    final c = Theme.of(context).colorScheme;
    final div = Theme.of(context).dividerColor;

    final name = user?.displayName ?? 'Kein Name';
    final email = user?.email ?? '';
    final initials = name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join();

    void setTheme(ThemeMode mode) async {
      ref.read(themeProvider.notifier).state = mode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme', mode.name);
    }

    return Scaffold(
      appBar: AppTopBar(
        title: 'Einstellungen',
        big: true,
        leading: AppIconButton(icon: Icons.arrow_back, onTap: () => context.pop()),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          // Profile card
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(border: Border.all(color: div)),
              child: Row(children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(color: c.surface, border: Border.all(color: div), shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: user?.photoUrl != null
                      ? ClipOval(child: Image.network(user!.photoUrl!, width: 52, height: 52, fit: BoxFit.cover))
                      : Text(initials, style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.w500, color: c.onSurface)),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name, style: GoogleFonts.cormorantGaramond(fontSize: 19, fontWeight: FontWeight.w500, color: c.onSurface)),
                  Text(email, style: GoogleFonts.ibmPlexMono(fontSize: 12, color: c.onSurface.withOpacity(0.45))),
                  const SizedBox(height: 8),
                  const Row(children: [AppPill('PRO', accent: true), SizedBox(width: 6), AppPill('Drive verbunden')]),
                ])),
                AppIconButton(icon: Icons.chevron_right, onTap: () {}),
              ]),
            ),
          ),

          // Theme
          const SectionLabel('ERSCHEINUNGSBILD'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              for (final (mode, label, bg, fg, accent) in [
                (ThemeMode.dark, 'Dunkel', const Color(0xFF0A0A0A), const Color(0xFFF4F1EA), const Color(0xFFD4AF6A)),
                (ThemeMode.light, 'Hell', const Color(0xFFF6F2E8), const Color(0xFF0A0A0A), const Color(0xFF6E5320)),
                (ThemeMode.system, 'System', Colors.transparent, const Color(0xFFD4AF6A), const Color(0xFFD4AF6A)),
              ]) ...[
                Expanded(
                  child: GestureDetector(
                    onTap: () => setTheme(mode),
                    child: Column(children: [
                      Container(
                        height: 80,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: mode == ThemeMode.system ? null : bg,
                          gradient: mode == ThemeMode.system
                              ? const LinearGradient(colors: [Color(0xFF0A0A0A), Color(0xFFF6F2E8)], begin: Alignment.centerLeft, end: Alignment.centerRight)
                              : null,
                          border: Border.all(color: themeMode == mode ? c.primary : div, width: themeMode == mode ? 2 : 1),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Aa', style: GoogleFonts.cormorantGaramond(fontSize: 14, color: fg, letterSpacing: 0.4)),
                          Container(width: 18, height: 3, color: accent),
                        ]),
                      ),
                      const SizedBox(height: 8),
                      Text(label, style: TextStyle(fontSize: 11, fontWeight: themeMode == mode ? FontWeight.w600 : FontWeight.w400, color: themeMode == mode ? c.primary : c.onSurface.withOpacity(0.5), letterSpacing: 0.4)),
                    ]),
                  ),
                ),
              ],
            ]),
          ),

          // Scan defaults
          const SectionLabel('SCAN-VOREINSTELLUNGEN'),
          const _SettingRow(icon: Icons.filter_b_and_w_outlined, label: 'Standardfilter', value: 'Dokument (S/W)'),
          const _SettingRow(icon: Icons.grid_view_outlined, label: 'Standard-Format', value: 'A4 · 300 dpi'),
          const _SettingRow(icon: Icons.flash_auto_outlined, label: 'Auto-Aufnahme', toggle: true, toggled: true),
          const _SettingRow(icon: Icons.text_fields_outlined, label: 'OCR aktivieren', toggle: true, toggled: true),
          const _SettingRow(icon: Icons.scanner_outlined, label: 'Auto-Edge-Detection', toggle: true, toggled: true),

          // Cloud
          const SectionLabel('CLOUD & SPEICHER'),
          _SettingRow(icon: Icons.cloud_outlined, label: 'Google Drive', value: email.isNotEmpty ? 'Verbunden · $email' : 'Nicht verbunden'),
          _SettingRow(icon: Icons.folder_outlined, label: 'Standardordner', value: '/Scans/${DateTime.now().year}'),
          const _SettingRow(icon: Icons.cloud_upload_outlined, label: 'Auto-Upload nach Scan', toggle: true, toggled: true),
          const _SettingRow(icon: Icons.image_outlined, label: 'Originale lokal sichern', toggle: true, toggled: false),

          // Sicherheit
          const SectionLabel('SICHERHEIT'),
          const _SettingRow(icon: Icons.lock_outline, label: 'App-Sperre (PIN / Biometrie)', toggle: true, toggled: true),
          const _SettingRow(icon: Icons.visibility_outlined, label: 'Standard-Sichtbarkeit', value: 'Nur ich'),

          // Über
          const SectionLabel('ÜBER'),
          const _SettingRow(icon: Icons.help_outline, label: 'Hilfe & Support'),
          const _SettingRow(icon: Icons.description_outlined, label: 'Nutzungsbedingungen'),
          const _SettingRow(icon: Icons.star_outline, label: 'App bewerten'),

          // Logout
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: OutlinedButton.icon(
              onPressed: () async {
                await ref.read(authServiceProvider).signOut();
                if (context.mounted) context.go('/login');
              },
              icon: const Icon(Icons.logout, size: 16),
              label: const Text('ABMELDEN', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1.8)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFB85050),
                side: BorderSide(color: div),
                minimumSize: const Size(double.infinity, 48),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
            ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(children: [
              OnagerMark(size: 28, color: c.onSurface.withOpacity(0.2)),
              const SizedBox(height: 6),
              Text('Onager Scanner · Version 1.0.0',
                  style: GoogleFonts.cormorantGaramond(fontStyle: FontStyle.italic, fontSize: 12, color: c.onSurface.withOpacity(0.25))),
              const SizedBox(height: 4),
              Text('BUILD 10001 · ANDROID',
                  style: TextStyle(fontSize: 9.5, letterSpacing: 2, color: c.onSurface.withOpacity(0.2))),
            ]),
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatefulWidget {
  final IconData icon;
  final String label;
  final String? value;
  final bool toggle;
  final bool toggled;

  const _SettingRow({
    required this.icon,
    required this.label,
    this.value,
    this.toggle = false,
    this.toggled = false,
  });

  @override
  State<_SettingRow> createState() => _SettingRowState();
}

class _SettingRowState extends State<_SettingRow> {
  late bool _toggled;

  @override
  void initState() {
    super.initState();
    _toggled = widget.toggled;
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final div = Theme.of(context).dividerColor;

    return InkWell(
      onTap: widget.toggle ? () => setState(() => _toggled = !_toggled) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: div))),
        child: Row(children: [
          SizedBox(width: 30, child: Icon(widget.icon, size: 18, color: c.onSurface.withOpacity(0.5))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: c.onSurface)),
            if (widget.value != null && !widget.toggle)
              Text(widget.value!, style: TextStyle(fontSize: 11.5, color: c.onSurface.withOpacity(0.45))),
          ])),
          if (widget.toggle)
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 38, height: 21,
              decoration: BoxDecoration(
                color: _toggled ? c.primary : c.onSurface.withOpacity(0.15),
                borderRadius: BorderRadius.circular(999),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 150),
                alignment: _toggled ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.all(3), width: 15, height: 15,
                  decoration: BoxDecoration(
                    color: _toggled ? c.onPrimary : c.onSurface.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            )
          else
            Icon(Icons.chevron_right, size: 16, color: c.onSurface.withOpacity(0.2)),
        ]),
      ),
    );
  }
}
