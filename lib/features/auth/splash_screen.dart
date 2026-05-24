import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/widgets/onager_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) context.go('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final text = Theme.of(context).colorScheme.onSurface;
    final border = Theme.of(context).dividerColor;
    final accent = Theme.of(context).colorScheme.primary;
    final dim = text.withOpacity(0.25);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Decorative top lines
          Positioned(top: 60, left: 32, right: 32, child: Divider(color: border, height: 1, thickness: 1)),
          Positioned(top: 65, left: 32, right: 32, child: Divider(color: border.withOpacity(0.4), height: 1, thickness: 1)),
          Positioned(bottom: 60, left: 32, right: 32, child: Divider(color: border, height: 1, thickness: 1)),
          Positioned(bottom: 65, left: 32, right: 32, child: Divider(color: border.withOpacity(0.4), height: 1, thickness: 1)),

          // Center content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                OnagerMark(size: 120, color: text),
                const SizedBox(height: 28),
                OnagerWordmark(size: 42, color: text),
                const SizedBox(height: 10),
                Container(width: 64, height: 1, color: accent),
                const SizedBox(height: 10),
                Text(
                  'SCANNER',
                  style: GoogleFonts.cormorantSc(
                    fontSize: 11,
                    letterSpacing: 0.42 * 11,
                    color: text.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),

          // Loading indicator
          Positioned(
            bottom: 110,
            left: 0,
            right: 0,
            child: Column(
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: accent,
                    backgroundColor: border,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'INITIALISIERE …',
                  style: TextStyle(fontSize: 11, letterSpacing: 0.2 * 11, color: dim),
                ),
              ],
            ),
          ),

          // Latin footer
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Text(
              'Documenta levis · onerum gravis',
              textAlign: TextAlign.center,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: dim,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
