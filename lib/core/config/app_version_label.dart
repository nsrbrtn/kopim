String formatAppVersionLabel({
  required String version,
  required String buildNumber,
  String? flavor,
}) {
  final String normalizedFlavor = (flavor ?? '').trim().toLowerCase();
  final String flavorSuffix = switch (normalizedFlavor) {
    'prod' || 'dev' || 'stage' => ' [$normalizedFlavor]',
    _ => '',
  };
  return '$version ($buildNumber)$flavorSuffix';
}
