class ExportBundleSchema {
  const ExportBundleSchema._();

  static const String currentVersion = '1.7.0';

  static const ExportBundleSchemaVersion _minimumSupported =
      ExportBundleSchemaVersion(1, 0, 0);
  static const ExportBundleSchemaVersion _liabilitiesIntroduced =
      ExportBundleSchemaVersion(1, 3, 0);
  static const ExportBundleSchemaVersion _accountHiddenIntroduced =
      ExportBundleSchemaVersion(1, 4, 0);
  static const ExportBundleSchemaVersion _fullSnapshotExpansionIntroduced =
      ExportBundleSchemaVersion(1, 5, 0);
  static const ExportBundleSchemaVersion _accountTypeVersionIntroduced =
      ExportBundleSchemaVersion(1, 6, 0);
  static const ExportBundleSchemaVersion _profileProgressIntegrityIntroduced =
      ExportBundleSchemaVersion(1, 7, 0);

  static ExportBundleSchemaVersion parseAndValidate(String rawVersion) {
    final ExportBundleSchemaVersion version = ExportBundleSchemaVersion.parse(
      rawVersion,
    );
    if (version < _minimumSupported) {
      throw FormatException(
        'Версия схемы $rawVersion больше не поддерживается. Минимальная поддерживаемая версия: ${_minimumSupported.raw}.',
      );
    }

    final ExportBundleSchemaVersion current = ExportBundleSchemaVersion.parse(
      currentVersion,
    );
    if (version > current) {
      throw FormatException(
        'Файл использует более новую схему $rawVersion. Обновите приложение перед импортом.',
      );
    }

    return version;
  }

  static bool requiresSavingGoals(ExportBundleSchemaVersion version) {
    return version >= _minimumSupported;
  }

  static bool requiresLiabilities(ExportBundleSchemaVersion version) {
    return version >= _liabilitiesIntroduced;
  }

  static bool requiresAccountHidden(ExportBundleSchemaVersion version) {
    return version >= _accountHiddenIntroduced;
  }

  static bool requiresExtendedSnapshot(ExportBundleSchemaVersion version) {
    return version >= _fullSnapshotExpansionIntroduced;
  }

  static bool requiresAccountTypeVersion(ExportBundleSchemaVersion version) {
    return version >= _accountTypeVersionIntroduced;
  }

  static bool requiresProfileProgressIntegrity(
    ExportBundleSchemaVersion version,
  ) {
    return version >= _profileProgressIntegrityIntroduced;
  }
}

class ExportBundleSchemaVersion
    implements Comparable<ExportBundleSchemaVersion> {
  const ExportBundleSchemaVersion(this.major, this.minor, this.patch);

  factory ExportBundleSchemaVersion.parse(String raw) {
    final List<String> parts = raw.trim().split('.');
    if (parts.length != 3) {
      throw FormatException('Некорректная версия схемы: $raw.');
    }

    final int? major = int.tryParse(parts[0]);
    final int? minor = int.tryParse(parts[1]);
    final int? patch = int.tryParse(parts[2]);
    if (major == null || minor == null || patch == null) {
      throw FormatException('Некорректная версия схемы: $raw.');
    }

    return ExportBundleSchemaVersion(major, minor, patch);
  }

  final int major;
  final int minor;
  final int patch;

  String get raw => '$major.$minor.$patch';

  @override
  int compareTo(ExportBundleSchemaVersion other) {
    if (major != other.major) {
      return major.compareTo(other.major);
    }
    if (minor != other.minor) {
      return minor.compareTo(other.minor);
    }
    return patch.compareTo(other.patch);
  }

  bool operator <(ExportBundleSchemaVersion other) => compareTo(other) < 0;
  bool operator <=(ExportBundleSchemaVersion other) => compareTo(other) <= 0;
  bool operator >(ExportBundleSchemaVersion other) => compareTo(other) > 0;
  bool operator >=(ExportBundleSchemaVersion other) => compareTo(other) >= 0;
}
