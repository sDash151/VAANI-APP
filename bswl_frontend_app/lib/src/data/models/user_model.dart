import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bswl_frontend_app/src/domain/entities/user.dart';

/// Data model representing a user document in Firestore.
class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String? photoUrl;
  final Timestamp? createdAt;
  final Timestamp? lastLogin;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    this.photoUrl,
    this.createdAt,
    this.lastLogin,
  });

  /// Creates a [UserModel] from a Firestore document snapshot.
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      uid: doc.id,
      fullName: data['fullName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      createdAt: data['createdAt'] as Timestamp?,
      lastLogin: data['lastLogin'] as Timestamp?,
    );
  }

  /// Creates a [UserModel] from a generic JSON map (e.g., if you fetch data via REST).
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      createdAt: json['createdAt'] is Timestamp
          ? json['createdAt'] as Timestamp
          : null,
      lastLogin: json['lastLogin'] is Timestamp
          ? json['lastLogin'] as Timestamp
          : null,
    );
  }

  /// Converts this [UserModel] into a map suitable for writing to Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'fullName': fullName,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'lastLogin': lastLogin ?? FieldValue.serverTimestamp(),
    };
  }

  /// Converts this [UserModel] into a JSON map (e.g., for REST endpoints).
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': createdAt?.toDate().toIso8601String(),
      'lastLogin': lastLogin?.toDate().toIso8601String(),
    };
  }

  /// Maps this [UserModel] to the domain-level [UserEntity].
  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      fullName: fullName,
      email: email,
      photoUrl: photoUrl,
    );
  }

  /// Creates a [UserModel] from a domain-level [UserEntity].
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      fullName: entity.fullName,
      email: entity.email,
      photoUrl: entity.photoUrl,
      createdAt: null,
      lastLogin: null,
    );
  }
}
