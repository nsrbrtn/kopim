class FreshUploadFinalizationMarker {
  const FreshUploadFinalizationMarker({
    required this.uid,
    required this.uploadSessionId,
    required this.remoteStateConfirmedAt,
    required this.localFinalizationCompletedAt,
    required this.version,
  });

  final String uid;
  final String uploadSessionId;
  final DateTime remoteStateConfirmedAt;
  final DateTime localFinalizationCompletedAt;
  final int version;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'uid': uid,
      'uploadSessionId': uploadSessionId,
      'remoteStateConfirmedAt': remoteStateConfirmedAt
          .toUtc()
          .toIso8601String(),
      'localFinalizationCompletedAt': localFinalizationCompletedAt
          .toUtc()
          .toIso8601String(),
      'version': version,
    };
  }

  static FreshUploadFinalizationMarker? fromJson(Map<String, Object?> json) {
    final Object? uid = json['uid'];
    final Object? uploadSessionId = json['uploadSessionId'];
    final Object? remoteStateConfirmedAt = json['remoteStateConfirmedAt'];
    final Object? localFinalizationCompletedAt =
        json['localFinalizationCompletedAt'];
    final Object? version = json['version'];
    if (uid is! String ||
        uid.trim().isEmpty ||
        uploadSessionId is! String ||
        uploadSessionId.trim().isEmpty ||
        remoteStateConfirmedAt is! String ||
        localFinalizationCompletedAt is! String ||
        version is! int) {
      return null;
    }

    final DateTime? parsedRemote = DateTime.tryParse(remoteStateConfirmedAt);
    final DateTime? parsedLocal = DateTime.tryParse(
      localFinalizationCompletedAt,
    );
    if (parsedRemote == null || parsedLocal == null) {
      return null;
    }

    return FreshUploadFinalizationMarker(
      uid: uid.trim(),
      uploadSessionId: uploadSessionId.trim(),
      remoteStateConfirmedAt: parsedRemote.toUtc(),
      localFinalizationCompletedAt: parsedLocal.toUtc(),
      version: version,
    );
  }
}
