class MigrationFreezeState {
  const MigrationFreezeState({
    required this.startedAt,
    required this.phase,
    required this.version,
    this.uid,
    this.uploadStarted = false,
  });

  factory MigrationFreezeState.fromJson(Map<String, Object?> json) {
    return MigrationFreezeState(
      uid: json['uid'] as String?,
      startedAt: DateTime.parse(json['startedAt']! as String).toUtc(),
      phase: (json['phase'] as String?)?.trim().isNotEmpty == true
          ? (json['phase']! as String).trim()
          : 'pre_inventory_capture',
      uploadStarted: json['uploadStarted'] as bool? ?? false,
      version: json['version'] as int? ?? 1,
    );
  }

  final String? uid;
  final DateTime startedAt;
  final String phase;
  final bool uploadStarted;
  final int version;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'uid': uid,
      'startedAt': startedAt.toUtc().toIso8601String(),
      'phase': phase,
      'uploadStarted': uploadStarted,
      'version': version,
    };
  }
}
