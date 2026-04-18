import 'dart:convert';

class GettingStartedPreferences {
  const GettingStartedPreferences({
    this.hasActivated = false,
    this.isHidden = false,
  });

  final bool hasActivated;
  final bool isHidden;

  GettingStartedPreferences copyWith({bool? hasActivated, bool? isHidden}) {
    return GettingStartedPreferences(
      hasActivated: hasActivated ?? this.hasActivated,
      isHidden: isHidden ?? this.isHidden,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'hasActivated': hasActivated,
      'isHidden': isHidden,
    };
  }

  String toRawJson() => jsonEncode(toJson());

  static GettingStartedPreferences fromJson(Map<String, dynamic> json) {
    return GettingStartedPreferences(
      hasActivated: json['hasActivated'] as bool? ?? false,
      isHidden: json['isHidden'] as bool? ?? false,
    );
  }

  static GettingStartedPreferences fromRawJson(String raw) {
    final Map<String, dynamic> json = jsonDecode(raw) as Map<String, dynamic>;
    return fromJson(json);
  }
}
