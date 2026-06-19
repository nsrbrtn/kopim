import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/core/application/sync_status_provider.dart';
import 'package:kopim/core/services/sync_status.dart';
import 'package:kopim/features/profile/presentation/controllers/feature_access_provider.dart';

class SyncStatusIndicator extends ConsumerStatefulWidget {
  const SyncStatusIndicator({super.key, this.size = 10});

  final double size;

  @override
  ConsumerState<SyncStatusIndicator> createState() =>
      _SyncStatusIndicatorState();
}

class _SyncStatusIndicatorState extends ConsumerState<SyncStatusIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SyncStatus status = ref
        .watch(syncStatusProvider)
        .maybeWhen(
          data: (SyncStatus value) => value,
          orElse: () => SyncStatus.offline,
        );
    final FeatureGate cloudSyncGate = ref.watch(
      featureAccessProvider.select((FeatureAccess access) => access.cloudSync),
    );
    final ThemeData theme = Theme.of(context);

    if (status == SyncStatus.syncing) {
      if (!_rotationController.isAnimating) {
        _rotationController.repeat();
      }
      return RotationTransition(
        turns: _rotationController,
        child: Icon(
          Icons.sync,
          size: widget.size + 6,
          color: theme.colorScheme.primary,
        ),
      );
    }

    if (_rotationController.isAnimating) {
      _rotationController.stop();
    }

    if (cloudSyncGate.status == FeatureAccessStatus.blockedByLocalData) {
      return Icon(
        Icons.warning_amber_rounded,
        size: widget.size + 6,
        color: theme.colorScheme.error,
      );
    }

    if (cloudSyncGate.status == FeatureAccessStatus.disabledByBuild ||
        cloudSyncGate.status == FeatureAccessStatus.requiresEntitlement ||
        cloudSyncGate.status == FeatureAccessStatus.requiresSignIn) {
      return Icon(
        Icons.cloud_off_outlined,
        size: widget.size + 4,
        color: theme.colorScheme.onSurfaceVariant,
      );
    }

    return const SizedBox.shrink();
  }
}
