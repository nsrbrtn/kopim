import 'package:flutter/widgets.dart';
import 'package:kopim/l10n/app_localizations.dart';

extension ContextExtensions on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this)!;
}
