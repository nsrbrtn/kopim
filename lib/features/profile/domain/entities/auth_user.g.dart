// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthUser _$AuthUserFromJson(Map<String, dynamic> json) => _AuthUser(
  uid: json['uid'] as String,
  email: json['email'] as String?,
  displayName: json['displayName'] as String?,
  photoUrl: json['photoUrl'] as String?,
  isAnonymous: json['isAnonymous'] as bool? ?? false,
  emailVerified: json['emailVerified'] as bool? ?? false,
  creationTime: json['creationTime'] == null
      ? null
      : DateTime.parse(json['creationTime'] as String),
  lastSignInTime: json['lastSignInTime'] == null
      ? null
      : DateTime.parse(json['lastSignInTime'] as String),
);

Map<String, dynamic> _$AuthUserToJson(_AuthUser instance) => <String, dynamic>{
  'uid': instance.uid,
  'email': instance.email,
  'displayName': instance.displayName,
  'photoUrl': instance.photoUrl,
  'isAnonymous': instance.isAnonymous,
  'emailVerified': instance.emailVerified,
  'creationTime': instance.creationTime?.toIso8601String(),
  'lastSignInTime': instance.lastSignInTime?.toIso8601String(),
};
