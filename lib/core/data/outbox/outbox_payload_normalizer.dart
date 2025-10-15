/// Нормализует payload сущностей перед отправкой в удалённые источники.
class OutboxPayloadNormalizer {
  const OutboxPayloadNormalizer();

  /// Возвращает копию [payload] с учётом особенностей конкретного типа сущности.
  Map<String, dynamic> normalize(
    String entityType,
    Map<String, dynamic> payload,
  ) {
    switch (entityType) {
      case 'category':
        return _normalizeCategoryPayload(payload);
      default:
        return Map<String, dynamic>.from(payload);
    }
  }

  Map<String, dynamic> _normalizeCategoryPayload(Map<String, dynamic> payload) {
    final Map<String, dynamic> normalized = Map<String, dynamic>.from(payload);

    final Object? iconRaw = normalized['icon'];
    String? iconName;
    String? iconStyle;

    if (iconRaw is Map<String, dynamic>) {
      final Map<String, dynamic> iconMap = Map<String, dynamic>.from(iconRaw);
      iconName = iconMap['name'] as String?;
      iconStyle = iconMap['style']?.toString();
    } else if (iconRaw is String) {
      iconName = iconRaw;
    }

    iconName ??= (normalized['iconName'] as String?)?.trim();
    iconStyle ??= (normalized['iconStyle'] as String?)?.trim();

    if (iconStyle != null && iconStyle.isNotEmpty) {
      iconStyle = iconStyle.toLowerCase();
    }

    if (iconName != null) {
      iconName = iconName.trim();
    }

    if (iconName != null && iconName.isNotEmpty) {
      final Map<String, dynamic> descriptor = <String, dynamic>{
        'name': iconName,
        if (iconStyle != null && iconStyle.isNotEmpty) 'style': iconStyle,
      };
      descriptor.removeWhere(
        (String key, dynamic value) =>
            value == null || (value is String && value.isEmpty),
      );
      normalized['icon'] = descriptor;
    } else {
      normalized.remove('icon');
    }

    normalized.remove('iconName');
    normalized.remove('iconStyle');

    return normalized;
  }
}
