import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/core/application/sync_status_provider.dart';
import 'package:kopim/core/services/sync_status.dart';

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

    return const SizedBox.shrink();
  }
}
