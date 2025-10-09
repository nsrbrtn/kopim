class AvatarStorageException implements Exception {
  AvatarStorageException(this.code, [this.originalMessage]);

  final String code;
  final String? originalMessage;

  @override
  String toString() => 'AvatarStorageException(code: , message: )';
}
