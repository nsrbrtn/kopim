import 'package:freezed_annotation/freezed_annotation.dart';

class BigIntJsonConverter implements JsonConverter<BigInt, String> {
  const BigIntJsonConverter();

  @override
  BigInt fromJson(String json) => BigInt.parse(json);

  @override
  String toJson(BigInt object) => object.toString();
}
