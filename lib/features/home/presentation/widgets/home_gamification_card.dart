import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/profile/domain/entities/user_progress.dart';
import 'package:kopim/features/profile/domain/policies/level_policy.dart';
import 'package:kopim/features/profile/presentation/controllers/user_progress_controller.dart';
import 'package:kopim/features/profile/presentation/screens/profile_management_screen.dart';
import 'package:kopim/l10n/app_localizations.dart';

class HomeGamificationCard extends ConsumerStatefulWidget {
  const HomeGamificationCard({required this.userId, super.key});

  final String userId;

  @override
  ConsumerState<HomeGamificationCard> createState() =>
      _HomeGamificationCardState();
}

class _HomeGamificationCardState extends ConsumerState<HomeGamificationCard> {
  static const List<String> _phrases = <String>[
    'Ты экономишь как супергерой!',
    'Каждая транзакция приближает к мечте!',
    'Бюджет под контролем – ты молодец!',
    'Финансы слушаются только тебя!',
    'Продолжай в том же духе, кошелёк улыбается!',
  ];

  static const double _minHeight = 168;
  static const double _maxHeight = 260;

  double _currentHeight = _minHeight;

  bool get _isExpanded => _currentHeight > (_minHeight + 8);

  String _phraseForDate(DateTime date) {
    final DateTime anchor = DateTime.utc(2024, 1, 1);
    final int dayIndex = date.toUtc().difference(anchor).inDays;
    final int normalized = dayIndex % _phrases.length;
    final int safeIndex = normalized < 0
        ? normalized + _phrases.length
        : normalized;
    return _phrases[safeIndex];
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final double delta = details.primaryDelta ?? 0;
    if (delta.abs() < 0.5) {
      return;
    }
    setState(() {
      _currentHeight = (_currentHeight + delta).clamp(_minHeight, _maxHeight);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    const double midpoint = (_minHeight + _maxHeight) / 2;
    final bool shouldExpand = _currentHeight >= midpoint;
    setState(() {
      _currentHeight = shouldExpand ? _maxHeight : _minHeight;
    });
  }

  void _toggleExpanded() {
    setState(() {
      _currentHeight = _isExpanded ? _minHeight : _maxHeight;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AsyncValue<UserProgress> progressAsync = ref.watch(
      userProgressProvider(widget.userId),
    );
    final String headline = _phraseForDate(DateTime.now());

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      height: _currentHeight,
      child: Material(
        elevation: 6,
        color: theme.colorScheme.surface,
        surfaceTintColor: theme.colorScheme.surfaceTint,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragUpdate: _handleDragUpdate,
          onVerticalDragEnd: _handleDragEnd,
          child: InkWell(
            key: const Key('homeGamificationCard.toggle'),
            onTap: _toggleExpanded,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: progressAsync.when(
                data: (UserProgress progress) {
                  final LevelPolicy policy = ref.read(levelPolicyProvider);
                  final int previousThreshold = policy.previousThreshold(
                    progress.level,
                  );
                  final int nextThreshold = progress.nextThreshold;
                  final double ratio = nextThreshold == previousThreshold
                      ? 1.0
                      : ((progress.totalTx - previousThreshold) /
                                (nextThreshold - previousThreshold))
                            .clamp(0.0, 1.0);
                  final int xpToNext = math.max(
                    0,
                    nextThreshold - progress.totalTx,
                  );
                  final bool maxedOut = nextThreshold == progress.totalTx;
                  final TextTheme textTheme = theme.textTheme;

                  return Stack(
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  headline,
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: strings.homeProfileTooltip,
                                icon: const Icon(Icons.account_circle_outlined),
                                onPressed: () {
                                  Navigator.of(context).pushNamed(
                                    ProfileManagementScreen.routeName,
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(12),
                            ),
                            child: LinearProgressIndicator(value: ratio),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            maxedOut
                                ? strings.profileLevelMaxReached
                                : strings.profileXpToNext(xpToNext),
                            style: textTheme.bodyMedium,
                          ),
                          const Spacer(),
                          IgnorePointer(
                            ignoring: !_isExpanded,
                            child: AnimatedOpacity(
                              opacity: _isExpanded ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              child: _GamificationDetails(
                                level: progress.level,
                                title: progress.title,
                                badgeText: strings.profileLevelBadge(
                                  progress.level,
                                  progress.title,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (!_isExpanded)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: <Color>[
                                    theme.colorScheme.surface.withValues(
                                      alpha: 0.0,
                                    ),
                                    theme.colorScheme.surface,
                                  ],
                                ),
                              ),
                              child: const SizedBox(height: 28),
                            ),
                          ),
                        ),
                    ],
                  );
                },
                loading: () => const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                error: (Object error, _) => Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    strings.homeGamificationError(error.toString()),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GamificationDetails extends StatelessWidget {
  const _GamificationDetails({
    required this.level,
    required this.title,
    required this.badgeText,
  });

  final int level;
  final String title;
  final String badgeText;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Row(
      children: <Widget>[
        CircleAvatar(
          radius: 24,
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.onPrimaryContainer,
          child: Text(
            level.toString(),
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                badgeText,
                style: textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
