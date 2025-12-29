import 'package:kopim/l10n/app_localizations.dart';

class AuthErrorMapper {
  const AuthErrorMapper._();

  static String map(String code, AppLocalizations strings) {
    switch (code) {
      case 'user-not-found':
        return strings.authErrorInvalidCredentials;
      case 'wrong-password':
        return strings.authErrorWrongPassword;
      case 'invalid-email':
        return strings.authErrorInvalidEmail;
      case 'email-already-in-use':
        return strings.authErrorEmailAlreadyInUse;
      case 'weak-password':
        return strings.authErrorWeakPassword;
      case 'user-disabled':
        return strings.authErrorUserDisabled;
      case 'too-many-requests':
        return strings.authErrorTooManyRequests;
      case 'invalid-credential':
        return strings.authErrorInvalidCredentials;
      case 'network-request-failed':
      case 'network_error':
        return strings.authErrorNetworkFailed;
      case 'unknown':
        return strings.authErrorDefault;
    }

    // Pass through if not a known code (for local validation strings)
    // Or return default?
    // If the code contains spaces, it's likely a message, so return as is.
    if (code.contains(' ')) {
      return code;
    }

    return strings.authErrorDefault;
  }
}
