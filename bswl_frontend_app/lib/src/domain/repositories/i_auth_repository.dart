import 'package:bswl_frontend_app/src/domain/entities/user.dart';

/// Abstract interface for authentication-related operations.
/// Implement this interface in a data layer class (e.g., AuthRepository).
abstract class IAuthRepository {
  /// Attempts to log in a user with [email] and [password].
  ///
  /// Returns the [UserEntity] on success.
  /// Throws a descriptive error message on failure.
  Future<UserEntity> login({
    required String email,
    required String password,
  });

  /// Attempts to register a new user with [fullName], [email], and [password].
  ///
  /// Returns the newly created [UserEntity] on success.
  /// Throws a descriptive error message on failure.
  Future<UserEntity> signUp({
    required String fullName,
    required String email,
    required String password,
  });

  /// Signs out the currently authenticated user.
  ///
  /// Throws an error if sign-out fails.
  Future<void> signOut();

  /// Retrieves the currently authenticated user, if any.
  ///
  /// Returns a [UserEntity] if a user is signed in, or `null` otherwise.
  Future<UserEntity?> getCurrentUser();

  /// Attempts to sign in a user via Google.
  ///
  /// Returns the [UserEntity] on success.
  /// Throws a descriptive error message on failure.
  Future<UserEntity> signInWithGoogle();

  /// Sends a password reset email to the user associated with the given [email].
  ///
  /// Throws an error if the email sending fails.
  Future<void> sendPasswordResetEmail({required String email});

  /// Updates the user profile and syncs to backend
  Future<void> updateProfile({String? fullName, String? photoUrl});
}
