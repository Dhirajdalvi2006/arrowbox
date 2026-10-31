import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const String _webClientId =
      '1083971733030-nh21126hnpinup86fvarmhq39v1nb917.apps.googleusercontent.com';

  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? _webClientId : null,
    serverClientId: _webClientId,
    scopes: <String>['email', 'profile'],
  );

  bool get isAvailable => _auth != null;

  User? get currentUser => _auth?.currentUser;
  Stream<User?> get authStateChanges =>
      _auth?.authStateChanges() ?? Stream.value(null);

  Future<UserCredential?> signInWithGoogle() async {
    final auth = _auth;
    if (auth == null) {
      debugPrint('AuthService: Firebase not initialized');
      throw StateError('Firebase is not initialized. Please restart the app.');
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      throw UnsupportedError(
        'Google Sign-In is only supported on Android, iOS, or Web. Please run the app on Android or Chrome (Web).',
      );
    }

    try {
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        return await auth.signInWithPopup(googleProvider);
      }

      // Android / iOS flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null && googleAuth.accessToken == null) {
        throw StateError('Failed to obtain authentication tokens from Google.');
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    final auth = _auth;
    try {
      if (!kIsWeb && defaultTargetPlatform != TargetPlatform.windows) {
        await _googleSignIn.signOut();
      }
      await auth?.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }
}
