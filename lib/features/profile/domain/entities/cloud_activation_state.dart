class CloudActivationState {
  const CloudActivationState({
    required this.uid,
    required this.scenario,
    required this.activatedAt,
    required this.localFingerprint,
    required this.remoteFingerprint,
    required this.version,
    required this.activationCompleted,
  });

  final String uid;
  final String scenario;
  final DateTime activatedAt;
  final String? localFingerprint;
  final String? remoteFingerprint;
  final int version;
  final bool activationCompleted;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'uid': uid,
      'scenario': scenario,
      'activatedAt': activatedAt.toUtc().toIso8601String(),
      'localFingerprint': localFingerprint,
      'remoteFingerprint': remoteFingerprint,
      'version': version,
      'activationCompleted': activationCompleted,
    };
  }

  static CloudActivationState? fromJson(Map<String, Object?> json) {
    final Object? uid = json['uid'];
    final Object? scenario = json['scenario'];
    final Object? activatedAt = json['activatedAt'];
    final Object? version = json['version'];
    if (uid is! String ||
        uid.trim().isEmpty ||
        scenario is! String ||
        scenario.trim().isEmpty ||
        activatedAt is! String ||
        version is! int) {
      return null;
    }

    final DateTime? parsedActivatedAt = DateTime.tryParse(activatedAt);
    if (parsedActivatedAt == null) {
      return null;
    }

    return CloudActivationState(
      uid: uid,
      scenario: scenario,
      activatedAt: parsedActivatedAt.toUtc(),
      localFingerprint: json['localFingerprint'] as String?,
      remoteFingerprint: json['remoteFingerprint'] as String?,
      version: version,
      activationCompleted: json['activationCompleted'] as bool? ?? true,
    );
  }
}
