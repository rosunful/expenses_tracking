import 'package:expense_tracking/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';



class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  User? get user => _user;
  bool get isLoggedIn => _user != null;

  String? errorMessage;
  bool isLoading = false;

  AuthProvider() {
    // Keep _user in sync whenever Firebase's login state changes,
    // e.g. on app startup if a session is already saved.
    _authService.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<bool> signUp(String email, String password) async {
    return _runAuthAction(() => _authService.signUp(email: email, password: password));
  }

  Future<bool> signIn(String email, String password) async {
    return _runAuthAction(() => _authService.signIn(email: email, password: password));
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  /// Shared wrapper so signUp/signIn both handle loading state and
  /// errors the same way, instead of repeating this logic twice.
  Future<bool> _runAuthAction(Future<User?> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final user = await action();
      _user = user;
      isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      isLoading = false;
      errorMessage = e.message ?? 'Something went wrong. Please try again.';
      notifyListeners();
      return false;
    }
  }
}