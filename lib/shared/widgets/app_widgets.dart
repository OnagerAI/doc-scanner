import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/document.dart';
import '../../core/theme/app_theme.dart';

// ─── Icon Button ────────────────────────────────────────────────
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String? label;

  const AppIconButton({super.key, required this.icon, this.onTap, this.label});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 22),
      onPressed: onTap,
      tooltip: label,
      style: IconButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

// ─── Top Bar ─────────────────────────────────────────────────────
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool big;

  const AppTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.big = false,
  });

  @override
  Size get preferredSize => Size.fromHeight(big ? 72 : 56);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: preferredSize.height,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          if (leading != null) leading!,
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: leading != null ? 4 : 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: big ? 26 : 18,
                      fontWeight: FontWeight.w500,
                      color: colors.onSurface,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.onSurface.withOpacity(0.5),
                        letterSpacing: 0.2,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ─── FAB ─────────────────────────────────────────────────────────
class ScanFAB extends StatelessWidget {
  final VoidCallback onTap;

  const ScanFAB({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final onAccent = Theme.of(context).colorScheme.onPrimary;
    return Positioned(
      bottom: 28,
      right: 20,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [BoxShadow(color: accent.withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 6))],
          ),
          child: Icon(Icons.camera_alt_outlined, color: onAccent, size: 26),
        ),
      ),
    );
  }
}

// ─── Section Label ───────────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        text,
        style: GoogleFonts.cormorantSc(
          fontSize: 10,
          letterSpacing: 0.28 * 10,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
        ),
      ),
    );
  }
}

// ─── Pill / Badge ────────────────────────────────────────────────
class AppPill extends StatelessWidget {
  final String label;
  final bool accent;
  const AppPill(this.label, {super.key, this.accent = false});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: accent ? c.primary.withOpacity(0.15) : c.surface,
        border: Border.all(color: accent ? c.primary.withOpacity(0.4) : Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
          color: accent ? c.primary : c.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }
}

// ─── Doc Thumbnail ───────────────────────────────────────────────
class DocThumbnail extends StatelessWidget {
  final String? imagePath;
  final int seed;
  final double width;
  final double height;

  const DocThumbnail({
    super.key,
    this.imagePath,
    this.seed = 0,
    this.width = 52,
    this.height = 68,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath != null) {
      return ClipRect(
        child: SizedBox(
          width: width,
          height: height,
          child: Image.asset(imagePath!, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _placeholder(context),
          ),
        ),
      );
    }
    return _placeholder(context);
  }

  Widget _placeholder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF1C1710) : const Color(0xFFE6E2D8);
    final line = isDark ? const Color(0xFF2A2520) : const Color(0xFFD0CCC0);
    return CustomPaint(
      size: Size(width, height),
      painter: _DocPlaceholderPainter(seed, base, line),
    );
  }
}

class _DocPlaceholderPainter extends CustomPainter {
  final int seed;
  final Color base;
  final Color line;
  _DocPlaceholderPainter(this.seed, this.base, this.line);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = base);
    final p = Paint()..color = line..strokeWidth = 1;
    final r = (seed % 5) + 3;
    for (int i = 0; i < r; i++) {
      final y = size.height * (0.18 + i * 0.14);
      final w = size.width * (0.55 + (seed * (i + 1) % 17) / 60.0);
      canvas.drawLine(Offset(size.width * 0.1, y), Offset(w.clamp(0, size.width * 0.88), y), p);
    }
  }

  @override
  bool shouldRepaint(_DocPlaceholderPainter old) => old.seed != seed;
}

// ─── App Switch ──────────────────────────────────────────────────
class AppSwitch extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool disabled;

  const AppSwitch({
    super.key,
    required this.label,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Opacity(
      opacity: disabled ? 0.6 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor))),
        child: Row(
          children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: c.onSurface)),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(subtitle!, style: TextStyle(fontSize: 11.5, color: c.onSurface.withOpacity(0.5))),
                  ),
              ]),
            ),
            GestureDetector(
              onTap: disabled ? null : () => onChanged?.call(!value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 40,
                height: 22,
                decoration: BoxDecoration(
                  color: value ? c.primary : c.onSurface.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 150),
                  alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.all(3),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: value ? c.onPrimary : c.onSurface.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Primary Button ──────────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool fullWidth;

  const PrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: icon != null ? Icon(icon, size: 18) : const SizedBox.shrink(),
        label: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          elevation: 0,
        ),
      ),
    );
  }
}

// ─── Ghost Button ────────────────────────────────────────────────
class GhostButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool fullWidth;

  const GhostButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: icon != null ? Icon(icon, size: 18) : const SizedBox.shrink(),
        label: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        style: OutlinedButton.styleFrom(
          foregroundColor: c.onSurface,
          side: BorderSide(color: Theme.of(context).dividerColor),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
    );
  }
}

// ─── State badge for document sync status ───────────────────────
class StateBadge extends StatelessWidget {
  final DocumentState state;
  const StateBadge(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return switch (state) {
      DocumentState.synced => Icon(Icons.cloud_done_outlined, size: 16, color: c.onSurface.withOpacity(0.35)),
      DocumentState.uploading => SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 1.5, color: c.primary),
        ),
      DocumentState.draft => Icon(Icons.edit_document, size: 16, color: c.primary),
      DocumentState.error => const Icon(Icons.error_outline, size: 16, color: AppColors.danger),
    };
  }
}
