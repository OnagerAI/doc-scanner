import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/auth_service.dart';
import '../../shared/widgets/onager_logo.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _loading = false;

  Future<void> _signIn() async {
    setState(() => _loading = true);
    final account = await ref.read(authServiceProvider).signIn();
    if (!mounted) return;
    if (account != null) {
      context.go('/');
    } else {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anmeldung fehlgeschlagen. Bitte erneut versuchen.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final div = Theme.of(context).dividerColor;
    final accent = c.primary;
    final text = c.onSurface;
    final muted = text.withOpacity(0.5);
    final dim = text.withOpacity(0.25);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Brand
              Row(children: [
                OnagerMark(size: 36, color: text),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  OnagerWordmark(size: 20, color: text),
                  const SizedBox(height: 2),
                  Text('SCANNER', style: TextStyle(fontSize: 10, color: muted, letterSpacing: 0.32 * 10)),
                ]),
              ]),

              // Hero text
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WILLKOMMEN',
                      style: GoogleFonts.cormorantSc(fontSize: 11, letterSpacing: 0.32 * 11, color: accent),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Dokumente,\nkuratiert.',
                      style: GoogleFonts.cormorantGaramond(fontSize: 40, fontWeight: FontWeight.w500, height: 1.05, color: text),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Mehrseitige Scans, OCR-Indexierung und direkte Ablage in Google Drive. Melde dich mit deinem Konto an, um fortzufahren.',
                      style: TextStyle(fontSize: 14, height: 1.55, color: muted),
                    ),
                    const SizedBox(height: 28),

                    // Google Sign-In
                    if (!_loading)
                      _GoogleSignInButton(onTap: _signIn)
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
                        decoration: BoxDecoration(
                          border: Border.all(color: div),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: accent, backgroundColor: div),
                            ),
                            const SizedBox(width: 14),
                            Text('Verbinde mit Google …', style: TextStyle(fontSize: 14, color: muted)),
                          ],
                        ),
                      ),

                    const SizedBox(height: 14),
                    Row(children: [
                      Expanded(child: Divider(color: div)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('oder', style: TextStyle(fontSize: 11, letterSpacing: 0.16 * 11, color: dim, fontWeight: FontWeight.w400)),
                      ),
                      Expanded(child: Divider(color: div)),
                    ]),
                    const SizedBox(height: 14),

                    // SSO button
                    OutlinedButton.icon(
                      onPressed: _signIn,
                      icon: const Icon(Icons.person_outline, size: 18),
                      label: const Text('Mit Arbeitskonto (SSO)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: text,
                        side: BorderSide(color: div),
                        minimumSize: const Size(double.infinity, 50),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                    ),

                    const SizedBox(height: 24),
                    Text.rich(
                      TextSpan(
                        style: TextStyle(fontSize: 11, color: dim, height: 1.55),
                        children: [
                          const TextSpan(text: 'Mit der Anmeldung akzeptierst du die '),
                          TextSpan(
                            text: 'Nutzungsbedingungen',
                            style: TextStyle(color: muted, decoration: TextDecoration.underline),
                          ),
                          const TextSpan(text: ' und die '),
                          TextSpan(
                            text: 'Datenschutzerklärung',
                            style: TextStyle(color: muted, decoration: TextDecoration.underline),
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('v 1.0.0 · DE', style: TextStyle(fontSize: 10, letterSpacing: 0.22 * 10, color: dim)),
                  Row(children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF5A9E6A), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text('Sicher', style: TextStyle(fontSize: 10, letterSpacing: 0.22 * 10, color: dim)),
                  ]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GoogleSignInButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: c.onSurface,
          foregroundColor: c.surface,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _GoogleG(),
            const SizedBox(width: 12),
            Text('Mit Google fortfahren', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: c.surface)),
          ],
        ),
      ),
    );
  }
}

class _GoogleG extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleGPainter()),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..style = PaintingStyle.fill;
    // Simplified colored G
    p.color = const Color(0xFF4285F4);
    canvas.drawArc(Rect.fromLTWH(0, 0, s.width, s.height), -1.57, 3.14, true, p);
    p.color = const Color(0xFF34A853);
    canvas.drawArc(Rect.fromLTWH(0, 0, s.width, s.height), 1.57, 1.57, true, p);
    p.color = const Color(0xFFFBBC05);
    canvas.drawArc(Rect.fromLTWH(0, 0, s.width, s.height), 3.14, 0.78, true, p);
    p.color = const Color(0xFFEA4335);
    canvas.drawArc(Rect.fromLTWH(0, 0, s.width, s.height), -1.57, -1.57, true, p);
    // White center
    p.color = Colors.white;
    canvas.drawCircle(Offset(s.width / 2, s.height / 2), s.width * 0.3, p);
    // White cutout for the G bar
    canvas.drawRect(Rect.fromLTWH(s.width * 0.5, s.height * 0.35, s.width * 0.5, s.height * 0.3), p);
  }

  @override
  bool shouldRepaint(_) => false;
}
