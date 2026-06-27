import 'package:cloud_firestore/cloud_firestore.dart';

enum CloudDataState {
  active,
  grace,
  cleanupPending,
  deleted,
  freshUploadInProgress,
}

class CloudMetadata {
  const CloudMetadata({
    required this.cloudDataState,
    this.entitlementExpiresAt,
    this.cloudDeleteAfter,
    this.cloudDeletedAt,
    required this.updatedAt,
  });

  final CloudDataState cloudDataState;
  final DateTime? entitlementExpiresAt;
  final DateTime? cloudDeleteAfter;
  final DateTime? cloudDeletedAt;
  final DateTime updatedAt;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'cloudDataState': cloudDataState.name,
      'entitlementExpiresAt': entitlementExpiresAt != null
          ? Timestamp.fromDate(entitlementExpiresAt!)
          : null,
      'cloudDeleteAfter': cloudDeleteAfter != null
          ? Timestamp.fromDate(cloudDeleteAfter!)
          : null,
      'cloudDeletedAt': cloudDeletedAt != null
          ? Timestamp.fromDate(cloudDeletedAt!)
          : null,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static CloudMetadata? fromJson(Map<String, Object?> json) {
    final Object? stateStr = json['cloudDataState'];
    final Object? updatedAtVal = json['updatedAt'];

    if (stateStr is! String) {
      return null;
    }

    final CloudDataState? state = CloudDataState.values
        .cast<CloudDataState?>()
        .firstWhere(
          (CloudDataState? e) => e?.name == stateStr,
          orElse: () => null,
        );
    if (state == null) {
      return null;
    }

    DateTime? parseDate(Object? val) {
      if (val is Timestamp) {
        return val.toDate().toUtc();
      }
      if (val is String) {
        return DateTime.tryParse(val)?.toUtc();
      }
      return null;
    }

    final DateTime? parsedUpdatedAt = parseDate(updatedAtVal);
    if (parsedUpdatedAt == null) {
      return null;
    }

    return CloudMetadata(
      cloudDataState: state,
      entitlementExpiresAt: parseDate(json['entitlementExpiresAt']),
      cloudDeleteAfter: parseDate(json['cloudDeleteAfter']),
      cloudDeletedAt: parseDate(json['cloudDeletedAt']),
      updatedAt: parsedUpdatedAt,
    );
  }
}
