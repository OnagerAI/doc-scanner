import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/scan/camera_screen.dart';
import '../../features/scan/multipage_screen.dart';
import '../../features/edit/edit_screen.dart';
import '../../features/export/export_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../shared/models/document.dart';
import '../services/auth_service.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(currentUserProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final onAuth = state.matchedLocation == '/splash' || state.matchedLocation == '/login';
      if (!isLoggedIn && !onAuth) return '/login';
      if (isLoggedIn && onAuth) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
      GoRoute(
        path: '/scan',
        builder: (_, __) => const CameraScreen(),
        routes: [
          GoRoute(
            path: 'review',
            builder: (_, state) {
              final pages = state.extra as List<ScannedPage>;
              return MultipageScreen(pages: pages);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/edit',
        builder: (_, state) {
          final page = state.extra as ScannedPage;
          return EditScreen(page: page);
        },
      ),
      GoRoute(
        path: '/export',
        builder: (_, state) {
          final pages = state.extra as List<ScannedPage>;
          return ExportScreen(pages: pages);
        },
      ),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    ],
  );
});
