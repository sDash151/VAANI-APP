import 'package:flutter/material.dart';
import 'package:bswl_frontend_app/src/data/repositories/auth_repository.dart';
import 'package:bswl_frontend_app/src/domain/entities/user.dart';
import 'package:bswl_frontend_app/src/utils/helpers.dart';
import 'dart:async';

/// A ChangeNotifier provider that wraps [AuthRepository] and exposes
/// authentication state and methods to the UI.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepo;

  UserEntity? _user;
  bool _isLoading = false;
  String? _errorMessage;

  /// Constructs the provider with a concrete [AuthRepository].
  AuthProvider(this._authRepo);

  /// The currently signed-in user, or `null` if none.
  UserEntity? get user => _user;

  /// Whether a user is authenticated.
  bool get isAuthenticated => _user != null;

  /// Whether an authentication operation is in progress.
  bool get isLoading => _isLoading;

  /// Last error message (if any) from auth operations.
  String? get errorMessage => _errorMessage;

  /// Attempts to sign in with email & password.
  Future<void> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    notifyListeners();

    try {
      final normalizedEmail = email.trim().toLowerCase();
      final userEntity = await _authRepo.login(
        email: normalizedEmail,
        password: password,
      );
      _user = userEntity;
      print(
          'LOGIN SUCCESS: user=\x1B[32m\x1B[1m\x1B[4m\x1B[7m\x1B[5m\x1B[3m\x1B[9m\x1B[21m\x1B[22m\x1B[23m\x1B[24m\x1B[27m\x1B[39m\x1B[49m' +
              (_user?.email ?? 'null'));
    } catch (e) {
      _errorMessage = Helpers.parseErrorMessage(e);
      print('LOGIN ERROR: ' + _errorMessage.toString());
    } finally {
      _setLoading(false);
      notifyListeners();
      print('LOGIN: notifyListeners called, isAuthenticated=' +
          isAuthenticated.toString());
    }
  }

  /// Attempts to register a new user.
  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    notifyListeners();

    try {
      final normalizedEmail = email.trim().toLowerCase();
      final userEntity = await _authRepo.signUp(
        fullName: fullName,
        email: normalizedEmail,
        password: password,
      );
      _user = userEntity;
    } catch (e) {
      _errorMessage = Helpers.parseErrorMessage(e);
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    _setLoading(true);
    notifyListeners();

    try {
      // If you use refresh tokens, call backend to revoke them
      try {
        await _authRepo
            .logoutFromBackend(); // Implement this in AuthRepository if using refresh tokens
      } catch (_) {}
      await _authRepo.signOut();
      _user = null;
    } catch (e) {
      _errorMessage = Helpers.parseErrorMessage(e);
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Attempts to sign in via Google.
  Future<void> signInWithGoogle() async {
    _setLoading(true);
    _errorMessage = null;
    notifyListeners();

    try {
      final userEntity = await _authRepo.signInWithGoogle();
      _user = userEntity;
    } catch (e) {
      _errorMessage = Helpers.parseErrorMessage(e);
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Attempts to sign in via Facebook (placeholder).
  Future<void> signInWithFacebook() async {
    _setLoading(true);
    _errorMessage = null;
    notifyListeners();

    try {
      // If you implement Facebook sign-in in AuthRepository, call it here:
      // final userEntity = await _authRepo.signInWithFacebook();
      // _user = userEntity;
      throw 'Facebook sign-in not implemented yet';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Attempts to sign in via Apple (placeholder).
  Future<void> signInWithApple() async {
    _setLoading(true);
    _errorMessage = null;
    notifyListeners();

    try {
      // If you implement Apple sign-in in AuthRepository, call it here:
      // final userEntity = await _authRepo.signInWithApple();
      // _user = userEntity;
      throw 'Apple sign-in not implemented yet';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Generic social login that calls the appropriate method based on [provider].
  Future<void> socialLogin(String provider) async {
    switch (provider.toLowerCase()) {
      case 'google':
        await signInWithGoogle();
        break;
      case 'facebook':
        await signInWithFacebook();
        break;
      case 'apple':
        await signInWithApple();
        break;
      default:
        throw 'Unsupported social login provider: $provider';
    }
  }

  Future<void> socialSignUp(String provider) async {
    _setLoading(true);
    _errorMessage = null;
    notifyListeners();

    try {
      // For now, using the same Google login method assuming first-time users get registered
      final userEntity = await _authRepo.signInWithGoogle();
      _user = userEntity;
    } catch (e) {
      _errorMessage = Helpers.parseErrorMessage(e);
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Checks if a user is already signed in and fetches their data.
  Future<void> loadCurrentUser() async {
    _setLoading(true);
    notifyListeners();

    try {
      final current = await _authRepo.getCurrentUser();
      _user = current;
    } catch (e) {
      _errorMessage = Helpers.parseErrorMessage(e);
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Updates user profile and syncs to backend
  Future<void> updateProfile({String? fullName, String? photoUrl}) async {
    _setLoading(true);
    _errorMessage = null;
    notifyListeners();
    try {
      await _authRepo.updateProfile(fullName: fullName, photoUrl: photoUrl);
      // Also sync to backend
      final fbUser = _authRepo.currentFirebaseUser;
      if (fbUser != null) {
        await _authRepo.syncUserProfile(
          uid: fbUser.uid,
          email: fbUser.email ?? '',
          fullName: fullName,
          photoUrl: photoUrl,
        );
      }
      // Reload user data
      final current = await _authRepo.getCurrentUser();
      _user = current;
    } catch (e) {
      _errorMessage = Helpers.parseErrorMessage(e);
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
  }

  bool isLoading2 = false;

  // Dummy user database (just for example)
  final List<String> _registeredEmails = [
    'user1@example.com',
    'user2@example.com',
    'test@example.com',
  ];

  Future<void> sendPasswordResetEmail(String email) async {
    // Use only Firebase for password reset, comment out backend logic
    // isLoading2 = true;
    // notifyListeners();
    // Simulate network delay
    // await Future.delayed(const Duration(seconds: 2));
    // Basic email validation
    // if (email.isEmpty) {
    //   isLoading2 = false;
    //   notifyListeners();
    //   throw Exception('Email cannot be empty');
    // }
    // final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    // if (!emailRegex.hasMatch(email)) {
    //   isLoading2 = false;
    //   notifyListeners();
    //   throw Exception('Invalid email format');
    // }
    // Check if email exists in dummy db
    // if (!_registeredEmails.contains(email.trim().toLowerCase())) {
    //   isLoading2 = false;
    //   notifyListeners();
    //   throw Exception('No user found with this email');
    // }
    // If all good, simulate successful reset email sent
    // isLoading2 = false;
    // notifyListeners();
    // You can add more logic here if needed
    // ---
    // Call Firebase Auth only
    await _authRepo.sendPasswordResetEmail(email: email);
  }
}
