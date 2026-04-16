import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/profile_controller.dart';

const String kDefaultCurrencyCode = 'RUB';

String profileCurrencyToCode(ProfileCurrency currency) =>
    currency.name.toUpperCase();

final Provider<String> activeCurrencyCodeProvider = Provider<String>((Ref ref) {
  final AuthUser? user = ref.watch(authControllerProvider).value;
  if (user == null) {
    return kDefaultCurrencyCode;
  }

  final Profile? profile = ref.watch(profileControllerProvider(user.uid)).value;
  if (profile == null) {
    return kDefaultCurrencyCode;
  }

  return profileCurrencyToCode(profile.currency);
});

String activeCurrencyCodeOf(BuildContext context) {
  return ProviderScope.containerOf(context).read(activeCurrencyCodeProvider);
}
