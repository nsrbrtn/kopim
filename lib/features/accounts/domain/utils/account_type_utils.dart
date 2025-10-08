String normalizeAccountType(String value) {
  return stripCustomAccountPrefix(value).trim();
}

String stripCustomAccountPrefix(String value) {
  final String trimmed = value.trim();
  if (trimmed.isEmpty) {
    return '';
  }
  final String lower = trimmed.toLowerCase();
  if (lower.startsWith('custom:')) {
    final int separatorIndex = trimmed.indexOf(':');
    if (separatorIndex >= 0 && separatorIndex + 1 < trimmed.length) {
      final String custom = trimmed.substring(separatorIndex + 1).trim();
      return custom;
    }
    return '';
  }
  return trimmed;
}
