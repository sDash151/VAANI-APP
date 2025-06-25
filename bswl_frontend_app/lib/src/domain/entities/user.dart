/// Domain-level representation of a User in the application.
/// This entity is independent of any external data source (e.g., Firestore).
class UserEntity {
  /// Unique identifier for the user (e.g., Firebase UID).
  final String uid;

  /// Full name of the user.
  final String fullName;

  /// Email address of the user.
  final String email;

  /// (Optional) URL to the user's profile photo.
  final String? photoUrl;

  /// Constructor for creating a [UserEntity].
  const UserEntity({
    required this.uid,
    required this.fullName,
    required this.email,
    this.photoUrl,
  });

  /// Creates a copy of this [UserEntity] with the given fields replaced.
  UserEntity copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? photoUrl,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  String toString() {
    return 'UserEntity(uid: $uid, fullName: $fullName, email: $email, photoUrl: $photoUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is UserEntity &&
            other.uid == uid &&
            other.fullName == fullName &&
            other.email == email &&
            other.photoUrl == photoUrl);
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        fullName.hashCode ^
        email.hashCode ^
        (photoUrl?.hashCode ?? 0);
  }
}
