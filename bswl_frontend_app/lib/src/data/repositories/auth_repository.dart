import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bswl_frontend_app/src/data/models/user_model.dart';
import 'package:bswl_frontend_app/src/domain/entities/user.dart';
import 'package:bswl_frontend_app/src/domain/repositories/i_auth_repository.dart';
import 'package:bswl_frontend_app/src/utils/helpers.dart';
import 'package:bswl_frontend_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Implementation of [IAuthRepository] using Firebase Authentication
/// and Firestore for user persistence.
class AuthRepository implements IAuthRepository {
  final fb_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final ApiService apiService = ApiService(
      baseUrl: 'http://localhost:3000/api'); // Update to your backend URL

  AuthRepository({
    fb_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? fb_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> syncUserWithBackend(fb_auth.User fbUser) async {
    final idToken = await fbUser.getIdToken();
    await apiService.post(
      'user/sync',
      {
        'uid': fbUser.uid,
        'email': fbUser.email,
        'fullName': fbUser.displayName ?? '',
      },
      headers: {'Authorization': 'Bearer $idToken'},
    );
  }

  Future<void> _saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('refreshToken', token);
  }

  Future<String?> _getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refreshToken');
  }

  Future<void> _removeRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('refreshToken');
  }

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    try {
      // // Call backend login to get tokens
      // final response = await apiService.post('auth/login', {
      //   'email': email,
      //   'password': password,
      // });
      // final refreshToken = response['refreshToken'] as String?;
      // if (refreshToken != null) await _saveRefreshToken(refreshToken);

      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final fbUser = credential.user;
      if (fbUser == null) {
        throw 'Login failed: User is null';
      }
      // await syncUserWithBackend(fbUser); // <-- Sync to backend
      // await _updateLastLogin(fbUser.uid);
      final userDoc =
          await _firestore.collection('users').doc(fbUser.uid).get();
      final userModel = userDoc.exists
          ? UserModel.fromFirestore(userDoc)
          : UserModel(
              uid: fbUser.uid,
              fullName: fbUser.displayName ?? '',
              email: fbUser.email ?? '',
              photoUrl: fbUser.photoURL ?? '',
            );
      return userModel.toEntity();
    } on fb_auth.FirebaseAuthException catch (e) {
      throw Helpers.getAuthErrorMessage(e.code);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserEntity> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      developer.log('SIGNUP: Starting Firebase Auth signup for $email');
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      developer.log(
          'SIGNUP: Firebase Auth signup complete, credential: \\${credential.user}');
      final fbUser = credential.user;
      if (fbUser == null) {
        developer.log('SIGNUP: Firebase user is null after signup!');
        throw 'Sign-up failed: User is null';
      }

      // Update display name
      await fbUser.updateDisplayName(fullName);
      await fbUser.reload();
      developer.log('SIGNUP: Display name updated and user reloaded.');
      // await syncUserWithBackend(fbUser); // <-- Sync to backend
      // developer.log('SIGNUP: Synced user with backend.');

      developer.log('SIGNUP: About to write Firestore user document.');

      // Create Firestore document
      final userModel = UserModel(
        uid: fbUser.uid,
        fullName: fullName,
        email: email,
        photoUrl: '',
      );
      await _firestore
          .collection('users')
          .doc(fbUser.uid)
          .set(userModel.toFirestore());
      developer.log('SIGNUP: Firestore user document created.');

      return userModel.toEntity();
    } on fb_auth.FirebaseAuthException catch (e) {
      developer
          .log('SIGNUP: FirebaseAuthException: \\${e.code} - \\${e.message}');
      throw Helpers.getAuthErrorMessage(e.code);
    } catch (e) {
      developer.log('SIGNUP: Unknown error: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _removeRefreshToken();
    await _firebaseAuth.signOut();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser == null) return null;

    final doc = await _firestore.collection('users').doc(fbUser.uid).get();
    if (!doc.exists) {
      // If no Firestore record, create a minimal model
      return UserModel(
        uid: fbUser.uid,
        fullName: fbUser.displayName ?? '',
        email: fbUser.email ?? '',
        photoUrl: fbUser.photoURL ?? '',
      ).toEntity();
    }
    return UserModel.fromFirestore(doc).toEntity();
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    try {
      final GoogleAuthProvider = fb_auth.GoogleAuthProvider();
      // Force account picker every time by signing out first
      await _firebaseAuth.signOut();
      final googleUser = await fb_auth.FirebaseAuth.instance
          .signInWithPopup(GoogleAuthProvider);
      final fbUser = googleUser.user;
      if (fbUser == null ||
          fbUser.isAnonymous ||
          fbUser.email == null ||
          fbUser.email!.isEmpty) {
        await _firebaseAuth.signOut();
        throw 'Google sign-in failed: No account selected or guest/anonymous user.';
      }

      final userDoc =
          await _firestore.collection('users').doc(fbUser.uid).get();
      if (!userDoc.exists) {
        final userModel = UserModel(
          uid: fbUser.uid,
          fullName: fbUser.displayName ?? '',
          email: fbUser.email ?? '',
          photoUrl: fbUser.photoURL ?? '',
        );
        await _firestore
            .collection('users')
            .doc(fbUser.uid)
            .set(userModel.toFirestore());
        return userModel.toEntity();
      } else {
        await _updateLastLogin(fbUser.uid);
        return UserModel.fromFirestore(userDoc).toEntity();
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      throw Helpers.getAuthErrorMessage(e.code);
    } catch (e) {
      rethrow;
    }
  }

  /// Call backend to revoke refresh token (if using refresh tokens)
  Future<void> logoutFromBackend() async {
    final refreshToken = await _getRefreshToken();
    if (refreshToken != null) {
      await apiService.post('auth/logout', {'refreshToken': refreshToken});
    }
  }

  Future<void> _updateLastLogin(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'lastLogin': FieldValue.serverTimestamp(),
    });
  }

  /// Sends a password reset email using Firebase Auth
  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on fb_auth.FirebaseAuthException catch (e) {
      throw Helpers.getAuthErrorMessage(e.code);
    } catch (e) {
      rethrow;
    }
  }

  /// Updates user profile in Firebase and syncs to backend
  Future<void> updateProfile({String? fullName, String? photoUrl}) async {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser == null) throw 'No authenticated user.';
    if (fullName != null && fullName != fbUser.displayName) {
      await fbUser.updateDisplayName(fullName);
    }
    if (photoUrl != null && photoUrl != fbUser.photoURL) {
      await fbUser.updatePhotoURL(photoUrl);
    }
    await fbUser.reload();
    await syncUserWithBackend(_firebaseAuth.currentUser!);
    // Optionally update Firestore as well
    final userDoc = _firestore.collection('users').doc(fbUser.uid);
    final updates = <String, dynamic>{};
    if (fullName != null) updates['fullName'] = fullName;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;
    if (updates.isNotEmpty) await userDoc.update(updates);
  }

  /// Syncs user profile to backend (call after profile update)
  Future<void> syncUserProfile(
      {required String uid,
      required String email,
      String? fullName,
      String? photoUrl}) async {
    await apiService.post(
      'auth/sync-profile',
      {
        'uid': uid,
        'email': email,
        if (fullName != null) 'fullName': fullName,
        if (photoUrl != null) 'photoUrl': photoUrl,
      },
    );
  }

  fb_auth.User? get currentFirebaseUser => _firebaseAuth.currentUser;
}
