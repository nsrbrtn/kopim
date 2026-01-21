import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/core/money/money_utils.dart';

class MoneyAmountJsonConverter
    implements JsonConverter<MoneyAmount, Map<String, dynamic>> {
  const MoneyAmountJsonConverter();

  @override
  MoneyAmount fromJson(Map<String, dynamic> json) {
    final Object? minorRaw = json['minor'];
    final String minorString = minorRaw == null ? '0' : minorRaw.toString();
    final int scale = (json['scale'] as num?)?.toInt() ?? 2;
    return MoneyAmount(minor: BigInt.parse(minorString), scale: scale);
  }

  @override
  Map<String, dynamic> toJson(MoneyAmount amount) {
    return <String, dynamic>{
      'minor': amount.minor.toString(),
      'scale': amount.scale,
    };
  }
}
