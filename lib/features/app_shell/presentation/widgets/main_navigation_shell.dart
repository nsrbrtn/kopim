import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/core/application/firebase_availability.dart';
import 'package:kopim/core/config/theme_extensions.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:kopim/features/transactions/presentation/controllers/transaction_sheet_controller.dart';
import 'package:kopim/features/transactions/presentation/widgets/transaction_form_overlay.dart';

import '../controllers/main_navigation_controller.dart';
import '../models/navigation_tab_config.dart';
import '../models/navigation_tab_content.dart';
import '../providers/main_navigation_tabs_provider.dart';
import 'main_navigation_bar.dart';
import 'navigation_responsive_breakpoints.dart';

class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key});

  static const String routeName = '/home';

  @override
  ConsumerState<MainNavigationShell> createState() =>
      _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  List<String> _cachedTabIds = const <String>[];
  String? _cachedLocaleTag;
  bool? _cachedEnableTwoPane;
  List<Widget?> _cachedPanes = <Widget?>[];
  bool _freezeScaffoldViewInsets = false;
  bool _hideFirebaseWarning = false;
  Timer? _freezeScaffoldViewInsetsTimer;
  ProviderSubscription<bool>? _transactionSheetVisibilitySubscription;

  void _invalidateCache() {
    _cachedPanes = List<Widget?>.filled(_cachedTabIds.length, null);
  }

  bool _sameTabIds(List<NavigationTabConfig> tabs) {
    if (tabs.length != _cachedTabIds.length) return false;
    for (int i = 0; i < tabs.length; i++) {
      if (tabs[i].id != _cachedTabIds[i]) return false;
    }
    return true;
  }

  void _syncCache({
    required List<NavigationTabConfig> tabs,
    required String localeTag,
    required bool enableTwoPane,
  }) {
    final bool tabIdsChanged = !_sameTabIds(tabs);
    final bool localeChanged = _cachedLocaleTag != localeTag;
    final bool twoPaneChanged = _cachedEnableTwoPane != enableTwoPane;

    if (tabIdsChanged) {
      _cachedTabIds = tabs
          .map((NavigationTabConfig e) => e.id)
          .toList(growable: false);
      _cachedPanes = List<Widget?>.filled(_cachedTabIds.length, null);
    }

    if (localeChanged || twoPaneChanged) {
      _cachedLocaleTag = localeTag;
      _cachedEnableTwoPane = enableTwoPane;
      _invalidateCache();
    }
  }

  Widget _buildPane(
    NavigationTabContent content, {
    required bool enableTwoPane,
    required BuildContext context,
    required WidgetRef ref,
  }) {
    return _NavigationTabPane(
      primary: content.bodyBuilder(context, ref),
      secondary: enableTwoPane
          ? content.secondaryBodyBuilder?.call(context, ref)
          : null,
      enableTwoPane: enableTwoPane,
    );
  }

  @override
  void initState() {
    super.initState();
    _freezeScaffoldViewInsets = ref.read(
      transactionSheetControllerProvider.select(
        (TransactionSheetState state) => state.isVisible,
      ),
    );
    _transactionSheetVisibilitySubscription = ref.listenManual<bool>(
      transactionSheetControllerProvider.select(
        (TransactionSheetState state) => state.isVisible,
      ),
      (bool? previous, bool next) {
        if (next) {
          _freezeScaffoldViewInsetsTimer?.cancel();
          if (_freezeScaffoldViewInsets) {
            return;
          }
          setState(() {
            _freezeScaffoldViewInsets = true;
          });
          return;
        }

        if (!_freezeScaffoldViewInsets) {
          return;
        }
        _freezeScaffoldViewInsetsTimer?.cancel();
        _freezeScaffoldViewInsetsTimer = Timer(
          const Duration(milliseconds: 300),
          () {
            if (!mounted) {
              return;
            }
            setState(() {
              _freezeScaffoldViewInsets = false;
            });
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _freezeScaffoldViewInsetsTimer?.cancel();
    _transactionSheetVisibilitySubscription?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAvailabilityState firebaseState = ref.watch(
      firebaseAvailabilityProvider,
    );
    final String? firebaseWarning = firebaseState.warningMessage;
    final bool showFirebaseWarning =
        firebaseWarning != null && !_hideFirebaseWarning;
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final List<NavigationTabConfig> tabs = ref.watch(
      mainNavigationTabsProvider,
    );
    final int currentIndex = ref.watch(
      mainNavigationControllerProvider.select(
        (MainNavigationState state) => state.currentIndex,
      ),
    );
    final NavigationTabContent activeContent = tabs[currentIndex]
        .contentBuilder(context, ref);
    final bool showNavigation = ModalRoute.of(context)?.isCurrent ?? true;
    final PreferredSizeWidget? appBar = activeContent.appBarBuilder?.call(
      context,
      ref,
    );
    final Widget? floatingActionButton = activeContent
        .floatingActionButtonBuilder
        ?.call(context, ref);
    final NavigatorState rootNavigator = Navigator.of(
      context,
      rootNavigator: true,
    );

    final bool isOnHomeTab = currentIndex == 0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? _) async {
        if (didPop) {
          return;
        }

        final bool isTransactionSheetVisible = ref
            .read(transactionSheetControllerProvider)
            .isVisible;
        if (isTransactionSheetVisible) {
          ref.read(transactionSheetControllerProvider.notifier).close();
          return;
        }

        if (rootNavigator.canPop()) {
          final bool rootDidPop = await rootNavigator.maybePop();
          if (!context.mounted) {
            return;
          }
          if (rootDidPop) {
            return;
          }
        }

        final NavigatorState? currentNavigator =
            activeContent.navigatorKey?.currentState;
        final bool nestedCanPop = currentNavigator?.canPop() ?? false;

        if (nestedCanPop && currentNavigator != null) {
          final bool nestedDidPop = await currentNavigator.maybePop();
          if (!context.mounted) {
            return;
          }
          if (nestedDidPop) {
            return;
          }
        }

        final bool poppedTabHistory = ref
            .read(mainNavigationControllerProvider.notifier)
            .popHistory();
        if (poppedTabHistory) {
          return;
        }

        if (!isOnHomeTab) {
          ref.read(mainNavigationControllerProvider.notifier).setIndex(0);
          return;
        }

        final bool shouldExit = await _showExitConfirmationDialog(
          context,
          strings,
        );
        if (!context.mounted || !shouldExit) {
          return;
        }
        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
          await SystemNavigator.pop();
        }
      },
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final String localeTag = Localizations.localeOf(
            context,
          ).toLanguageTag();
          const bool enableTwoPane = false;
          final bool isLandscape =
              constraints.maxWidth > constraints.maxHeight;
          final bool isWideScreen =
              constraints.maxWidth >= kMainNavigationRailBreakpoint;
          final bool shouldConstrainBottomBar = isLandscape || isWideScreen;
          final bool useBottomBar = showNavigation;

          _syncCache(
            tabs: tabs,
            localeTag: localeTag,
            enableTwoPane: enableTwoPane,
          );

          final Widget stackedContent = IndexedStack(
            index: currentIndex,
            children: <Widget>[
              for (int index = 0; index < tabs.length; index++)
                if (index == currentIndex)
                  _cachedPanes[index] = _buildPane(
                    activeContent,
                    enableTwoPane: enableTwoPane,
                    context: context,
                    ref: ref,
                  )
                else
                  _cachedPanes[index] ?? const SizedBox.shrink(),
            ],
          );

          final Widget body = stackedContent;
          final Widget resolvedBody = firebaseWarning == null
              ? body
              : Column(
                  children: <Widget>[
                    if (showFirebaseWarning)
                      _FirebaseWarningBanner(
                        message: firebaseWarning,
                        onDismiss: () {
                          setState(() => _hideFirebaseWarning = true);
                        },
                      ),
                    Expanded(child: body),
                  ],
                );

          final Widget scaffold = Scaffold(
            extendBody: useBottomBar,
            appBar: appBar,
            body: resolvedBody,
            floatingActionButton: useBottomBar ? floatingActionButton : null,
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            bottomNavigationBar: useBottomBar
                ? SafeArea(
                    top: false,
                    left: false,
                    right: false,
                    child: SizedBox(
                      height: MainNavigationBar.height,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: shouldConstrainBottomBar
                            ? FractionallySizedBox(
                                widthFactor: 0.5,
                                child: MainNavigationBar(tabs: tabs),
                              )
                            : MainNavigationBar(tabs: tabs),
                      ),
                    ),
                  )
                : null,
          );
          final Widget scaffoldWithFrozenInsets = _freezeScaffoldViewInsets
              ? MediaQuery.removeViewInsets(
                  context: context,
                  removeBottom: true,
                  child: scaffold,
                )
              : scaffold;

          return Stack(
            children: <Widget>[
              scaffoldWithFrozenInsets,
              if (firebaseWarning != null)
                const Positioned(
                  top: 0,
                  right: 0,
                  child: SafeArea(child: _OfflineModeBadge()),
                ),
              const Material(
                type: MaterialType.transparency,
                child: TransactionFormOverlay(),
              ),
            ],
          );
        },
      ),
    );
  }
}

Future<bool> _showExitConfirmationDialog(
  BuildContext context,
  AppLocalizations strings,
) async {
  final bool? result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(strings.mainNavigationExitTitle),
        content: Text(strings.mainNavigationExitMessage),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(strings.mainNavigationExitCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(strings.mainNavigationExitConfirm),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

class _FirebaseWarningBanner extends StatelessWidget {
  const _FirebaseWarningBanner({
    required this.message,
    required this.onDismiss,
  });

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.info_outline, color: colors.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            icon: const Icon(Icons.close),
            color: colors.onSurfaceVariant,
            tooltip: 'Закрыть',
          ),
        ],
      ),
    );
  }
}

class _OfflineModeBadge extends StatelessWidget {
  const _OfflineModeBadge();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.tertiaryContainer,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.cloud_off, color: colors.onTertiaryContainer, size: 16),
          const SizedBox(width: 6),
          Text(
            'Офлайн',
            style: TextStyle(
              color: colors.onTertiaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationTabPane extends StatelessWidget {
  const _NavigationTabPane({
    required this.primary,
    this.secondary,
    required this.enableTwoPane,
  });

  final Widget primary;
  final Widget? secondary;
  final bool enableTwoPane;

  @override
  Widget build(BuildContext context) {
    final double dividerThickness = Theme.of(
      context,
    ).kopimLayout.divider.thickness;
    if (!enableTwoPane || secondary == null) {
      return primary;
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double totalWidth = constraints.maxWidth;
        final double secondaryWidth = (totalWidth * 0.38)
            .clamp(280, 420)
            .toDouble();

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(child: primary),
            VerticalDivider(
              width: dividerThickness,
              thickness: dividerThickness,
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: secondaryWidth,
                maxWidth: secondaryWidth,
              ),
              child: ClipRect(child: secondary!),
            ),
          ],
        );
      },
    );
  }
}
