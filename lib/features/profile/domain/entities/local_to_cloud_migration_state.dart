class LocalToCloudMigrationPlanRow {
  const LocalToCloudMigrationPlanRow({
    required this.familyKey,
    required this.localRowId,
    required this.documentId,
  });

  final String familyKey;
  final String localRowId;
  final String documentId;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'familyKey': familyKey,
      'localRowId': localRowId,
      'documentId': documentId,
    };
  }

  static LocalToCloudMigrationPlanRow? fromJson(Map<String, Object?> json) {
    final Object? familyKey = json['familyKey'];
    final Object? localRowId = json['localRowId'];
    final Object? documentId = json['documentId'];
    if (familyKey is! String ||
        familyKey.trim().isEmpty ||
        localRowId is! String ||
        localRowId.trim().isEmpty ||
        documentId is! String ||
        documentId.trim().isEmpty) {
      return null;
    }

    return LocalToCloudMigrationPlanRow(
      familyKey: familyKey.trim(),
      localRowId: localRowId.trim(),
      documentId: documentId.trim(),
    );
  }
}

class LocalToCloudMigrationPlan {
  const LocalToCloudMigrationPlan({
    required this.migrationId,
    required this.createdAt,
    required this.localFingerprint,
    required this.remoteFingerprint,
    required this.candidateFamilyKeys,
    required this.rows,
  });

  final String migrationId;
  final DateTime createdAt;
  final String localFingerprint;
  final String remoteFingerprint;
  final List<String> candidateFamilyKeys;
  final List<LocalToCloudMigrationPlanRow> rows;

  int get totalRowCount => rows.length;

  Map<String, int> get rowCountsByFamily {
    final Map<String, int> counts = <String, int>{};
    for (final LocalToCloudMigrationPlanRow row in rows) {
      counts.update(
        row.familyKey,
        (int current) => current + 1,
        ifAbsent: () {
          return 1;
        },
      );
    }
    return counts;
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'migrationId': migrationId,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'localFingerprint': localFingerprint,
      'remoteFingerprint': remoteFingerprint,
      'candidateFamilyKeys': candidateFamilyKeys,
      'rows': rows
          .map((LocalToCloudMigrationPlanRow row) => row.toJson())
          .toList(),
    };
  }

  static LocalToCloudMigrationPlan? fromJson(Map<String, Object?> json) {
    final Object? migrationId = json['migrationId'];
    final Object? createdAt = json['createdAt'];
    final Object? localFingerprint = json['localFingerprint'];
    final Object? remoteFingerprint = json['remoteFingerprint'];
    final Object? candidateFamilyKeys = json['candidateFamilyKeys'];
    final Object? rows = json['rows'];
    if (migrationId is! String ||
        migrationId.trim().isEmpty ||
        createdAt is! String ||
        localFingerprint is! String ||
        localFingerprint.trim().isEmpty ||
        remoteFingerprint is! String ||
        remoteFingerprint.trim().isEmpty ||
        candidateFamilyKeys is! List<Object?> ||
        rows is! List<Object?>) {
      return null;
    }

    final DateTime? parsedCreatedAt = DateTime.tryParse(createdAt);
    if (parsedCreatedAt == null) {
      return null;
    }

    final List<String> parsedCandidateFamilyKeys = <String>[];
    for (final Object? value in candidateFamilyKeys) {
      if (value is! String || value.trim().isEmpty) {
        return null;
      }
      parsedCandidateFamilyKeys.add(value.trim());
    }

    final List<LocalToCloudMigrationPlanRow> parsedRows =
        <LocalToCloudMigrationPlanRow>[];
    for (final Object? value in rows) {
      if (value is! Map) {
        return null;
      }
      final LocalToCloudMigrationPlanRow? row =
          LocalToCloudMigrationPlanRow.fromJson(
            Map<String, Object?>.from(value),
          );
      if (row == null) {
        return null;
      }
      parsedRows.add(row);
    }

    return LocalToCloudMigrationPlan(
      migrationId: migrationId.trim(),
      createdAt: parsedCreatedAt.toUtc(),
      localFingerprint: localFingerprint.trim(),
      remoteFingerprint: remoteFingerprint.trim(),
      candidateFamilyKeys: List<String>.unmodifiable(parsedCandidateFamilyKeys),
      rows: List<LocalToCloudMigrationPlanRow>.unmodifiable(parsedRows),
    );
  }
}

enum LocalToCloudMigrationStage {
  preflightPrepared,
  backupCreated,
  uploadInProgress,
  uploadPartiallyCompleted,
  uploadCompleted,
  remoteVerificationInProgress,
  remoteVerified,
  localOwnershipConversionInProgress,
  localOwnershipConverted,
  blockedNeedsUserAction,
  runtimeTransitioned,
  completed,
}

class LocalToCloudMigrationState {
  const LocalToCloudMigrationState({
    required this.uid,
    required this.stage,
    required this.createdAt,
    required this.updatedAt,
    required this.plan,
    required this.version,
    this.backupArtifactReference,
    this.backupChecksum,
    this.localFingerprintBeforeUpload,
    this.remoteFingerprintBeforeUpload,
    this.uploadedRowCountsByFamily = const <String, int>{},
    this.verifiedRowCountsByFamily = const <String, int>{},
  });

  final String uid;
  final LocalToCloudMigrationStage stage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final LocalToCloudMigrationPlan plan;
  final int version;
  final String? backupArtifactReference;
  final String? backupChecksum;
  final String? localFingerprintBeforeUpload;
  final String? remoteFingerprintBeforeUpload;
  final Map<String, int> uploadedRowCountsByFamily;
  final Map<String, int> verifiedRowCountsByFamily;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'uid': uid,
      'stage': stage.name,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'plan': plan.toJson(),
      'version': version,
      'backupArtifactReference': backupArtifactReference,
      'backupChecksum': backupChecksum,
      'localFingerprintBeforeUpload': localFingerprintBeforeUpload,
      'remoteFingerprintBeforeUpload': remoteFingerprintBeforeUpload,
      'uploadedRowCountsByFamily': uploadedRowCountsByFamily,
      'verifiedRowCountsByFamily': verifiedRowCountsByFamily,
    };
  }

  static LocalToCloudMigrationState? fromJson(Map<String, Object?> json) {
    final Object? uid = json['uid'];
    final Object? stage = json['stage'];
    final Object? createdAt = json['createdAt'];
    final Object? updatedAt = json['updatedAt'];
    final Object? plan = json['plan'];
    final Object? version = json['version'];
    if (uid is! String ||
        uid.trim().isEmpty ||
        stage is! String ||
        createdAt is! String ||
        updatedAt is! String ||
        plan is! Map<String, Object?> ||
        version is! int) {
      return null;
    }

    final DateTime? parsedCreatedAt = DateTime.tryParse(createdAt);
    final DateTime? parsedUpdatedAt = DateTime.tryParse(updatedAt);
    if (parsedCreatedAt == null || parsedUpdatedAt == null) {
      return null;
    }

    LocalToCloudMigrationStage? parsedStage;
    for (final LocalToCloudMigrationStage value
        in LocalToCloudMigrationStage.values) {
      if (value.name == stage) {
        parsedStage = value;
        break;
      }
    }
    final LocalToCloudMigrationPlan? parsedPlan =
        LocalToCloudMigrationPlan.fromJson(Map<String, Object?>.from(plan));
    if (parsedStage == null || parsedPlan == null) {
      return null;
    }

    return LocalToCloudMigrationState(
      uid: uid.trim(),
      stage: parsedStage,
      createdAt: parsedCreatedAt.toUtc(),
      updatedAt: parsedUpdatedAt.toUtc(),
      plan: parsedPlan,
      version: version,
      backupArtifactReference: json['backupArtifactReference'] as String?,
      backupChecksum: json['backupChecksum'] as String?,
      localFingerprintBeforeUpload:
          json['localFingerprintBeforeUpload'] as String?,
      remoteFingerprintBeforeUpload:
          json['remoteFingerprintBeforeUpload'] as String?,
      uploadedRowCountsByFamily: _parseCountsMap(
        json['uploadedRowCountsByFamily'],
      ),
      verifiedRowCountsByFamily: _parseCountsMap(
        json['verifiedRowCountsByFamily'],
      ),
    );
  }

  static Map<String, int> _parseCountsMap(Object? rawValue) {
    return switch (rawValue) {
      final Map<Object?, Object?> raw => Map<String, int>.unmodifiable(
        raw.map(
          (Object? key, Object? value) => MapEntry<String, int>(
            key.toString(),
            value is int ? value : int.parse(value.toString()),
          ),
        ),
      ),
      _ => const <String, int>{},
    };
  }
}
