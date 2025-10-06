import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

enum ProfileCurrency { rub, usd, eur, uah, kzt, gel }

@freezed
abstract class Profile with _$Profile {
  const Profile._();

  const factory Profile({
    required String uid,
    @Default('') String name,
    @Default(ProfileCurrency.rub) ProfileCurrency currency,
    @Default('en') String locale,
    String? photoUrl,
    required DateTime updatedAt,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}
