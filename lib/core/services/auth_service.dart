import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final _googleSignIn = GoogleSignIn(
  scopes: [
    'email',
    'profile',
    'https://www.googleapis.com/auth/drive.file',
  ],
);

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final currentUserProvider = StreamProvider<GoogleSignInAccount?>((ref) {
  return ref.watch(authServiceProvider).userStream;
});

class AuthService {
  Stream<GoogleSignInAccount?> get userStream => _googleSignIn.onCurrentUserChanged;

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  bool get isSignedIn => _googleSignIn.currentUser != null;

  Future<GoogleSignInAccount?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      return account;
    } catch (_) {
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  Future<Map<String, String>?> getAuthHeaders() async {
    final account = _googleSignIn.currentUser;
    if (account == null) return null;
    return account.authHeaders;
  }

  Future<GoogleSignInAuthentication?> getAuthentication() async {
    final account = _googleSignIn.currentUser;
    if (account == null) return null;
    return account.authentication;
  }
}
