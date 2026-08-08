import 'package:firebase_auth/firebase_auth.dart';

/// Talks directly to Firebase. Nothing else in the app should call
/// FirebaseAuth.instance directly — everything goes through here.
/// This is the "Repository" layer in MVVM: it knows about Firebase,
/// but nothing else does.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// The currently logged-in user, or null if nobody is logged in.
  User? get currentUser => _auth.currentUser;

  /// Fires every time login state changes (login, logout, app restart
  /// with a saved session). We'll use this to decide which screen to show.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signUp({required String email, required String password}) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  Future<User?> signIn({required String email, required String password}) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}