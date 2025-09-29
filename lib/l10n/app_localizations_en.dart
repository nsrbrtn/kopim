// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileSignInPrompt => 'Sign in to manage your profile.';

  @override
  String get profileSectionAccount => 'Account';

  @override
  String get profileNameLabel => 'Name';

  @override
  String get profileCurrencyLabel => 'Default currency';

  @override
  String get profileLocaleLabel => 'Preferred locale';

  @override
  String profileLoadError(String error) {
    return 'Unable to load profile: $error';
  }

  @override
  String get profileSaveCta => 'Save changes';

  @override
  String get signInTitle => 'Welcome to Kopim';

  @override
  String get signInSubtitle => 'Sign in to sync your finances across devices.';

  @override
  String get signInEmailLabel => 'Email';

  @override
  String get signInPasswordLabel => 'Password';

  @override
  String get signInSubmitCta => 'Sign in';

  @override
  String get signInGoogleCta => 'Continue with Google';

  @override
  String get signInError => 'Could not sign in. Please try again.';

  @override
  String get signInLoading => 'Signing in...';

  @override
  String get signInOfflineNotice =>
      'You appear to be offline. We will sync your data once you reconnect.';
}
