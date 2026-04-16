import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/l10n/app_localizations.dart';
import 'package:kopim/features/profile/presentation/widgets/profile_management_body.dart';

class ProfileManagementScreen extends ConsumerWidget {
  const ProfileManagementScreen({super.key});

  static const String routeName = '/profile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.profileTitle)),
      body: const ProfileManagementBody(),
    );
  }
}
