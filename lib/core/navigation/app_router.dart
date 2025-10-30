import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kopim/core/application/app_startup_controller.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/accounts/presentation/account_details_screen.dart';
import 'package:kopim/features/accounts/presentation/accounts_add_screen.dart';
import 'package:kopim/features/accounts/presentation/edit_account_screen.dart';
import 'package:kopim/features/analytics/presentation/analytics_screen.dart';
import 'package:kopim/features/app_shell/presentation/widgets/main_navigation_shell.dart';
import 'package:kopim/features/categories/presentation/screens/manage_categories_screen.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/profile/presentation/screens/general_settings_screen.dart';
import 'package:kopim/features/profile/presentation/screens/profile_management_screen.dart';
import 'package:kopim/features/profile/presentation/screens/profile_screen.dart';
import 'package:kopim/features/profile/presentation/screens/sign_in_screen.dart';
import 'package:kopim/features/recurring_transactions/presentation/screens/add_recurring_rule_screen.dart';
import 'package:kopim/features/recurring_transactions/presentation/screens/recurring_transactions_screen.dart';
import 'package:kopim/features/transactions/presentation/add_transaction_screen.dart';
import 'package:kopim/features/transactions/presentation/screens/all_transactions_screen.dart';
import 'package:kopim/features/upcoming_payments/presentation/screens/edit_payment_reminder_screen.dart';
import 'package:kopim/features/upcoming_payments/presentation/screens/edit_upcoming_payment_screen.dart';
import 'package:kopim/features/upcoming_payments/presentation/screens/upcoming_payments_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'rootNavigator',
);
final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((Ref ref) {
  final AppRouterNotifier notifier = ref.watch(_appRouterNotifierProvider)
    ..initialize();
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: MainNavigationShell.routeName,
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: <RouteBase>[
      GoRoute(
        path: MainNavigationShell.routeName,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return const NoTransitionPage<void>(child: _AppShell());
        },
      ),
      GoRoute(
        path: AnalyticsScreen.routeName,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          return const AnalyticsScreen();
        },
      ),
      GoRoute(
        path: AddAccountScreen.routeName,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          return const AddAccountScreen();
        },
      ),
      GoRoute(
        path: AccountDetailsScreen.routeName,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          final AccountDetailsScreenArgs args =
              AccountDetailsScreenArgs.fromState(state);
          return AccountDetailsScreen(accountId: args.accountId);
        },
      ),
      GoRoute(
        path: EditAccountScreen.routeName,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          final EditAccountScreenArgs args = EditAccountScreenArgs.fromState(
            state,
          );
          return EditAccountScreen(account: args.account);
        },
      ),
      GoRoute(
        path: AddTransactionScreen.routeName,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          return const AddTransactionScreen();
        },
      ),
      GoRoute(
        path: ProfileScreen.routeName,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          return const ProfileScreen();
        },
      ),
      GoRoute(
        path: GeneralSettingsScreen.routeName,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          return const GeneralSettingsScreen();
        },
      ),
      GoRoute(
        path: ProfileManagementScreen.routeName,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          return const ProfileManagementScreen();
        },
      ),
      GoRoute(
        path: ManageCategoriesScreen.routeName,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          return const ManageCategoriesScreen();
        },
      ),
      GoRoute(
        path: RecurringTransactionsScreen.routeName,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          return const RecurringTransactionsScreen();
        },
      ),
      GoRoute(
        path: AddRecurringRuleScreen.routeName,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          return const AddRecurringRuleScreen();
        },
      ),
      GoRoute(
        path: UpcomingPaymentsScreen.routeName,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          return const UpcomingPaymentsScreen();
        },
      ),
      GoRoute(
        path: EditUpcomingPaymentScreen.routeName,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          final EditUpcomingPaymentScreenArgs args =
              EditUpcomingPaymentScreenArgs.fromState(state);
          return EditUpcomingPaymentScreen(args: args);
        },
      ),
      GoRoute(
        path: EditPaymentReminderScreen.routeName,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          final EditPaymentReminderScreenArgs args =
              EditPaymentReminderScreenArgs.fromState(state);
          return EditPaymentReminderScreen(args: args);
        },
      ),
      GoRoute(
        path: AllTransactionsScreen.routeName,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          return const AllTransactionsScreen();
        },
      ),
      GoRoute(
        path: SignInScreen.routeName,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          return const SignInScreen();
        },
      ),
    ],
  );
});

final Provider<AppRouterNotifier> _appRouterNotifierProvider =
    Provider<AppRouterNotifier>((Ref ref) {
      final AppRouterNotifier notifier = AppRouterNotifier(ref);
      ref.onDispose(notifier.dispose);
      return notifier;
    });

class AppRouterNotifier extends ChangeNotifier {
  AppRouterNotifier(this._ref)
    : _startupState = _ref.read(appStartupControllerProvider),
      _authState = _ref.read(authControllerProvider);

  final Ref _ref;

  AppStartupResult _startupState;
  AsyncValue<AuthUser?> _authState;
  bool _initialized = false;

  void _handleStartupChange(AppStartupResult? _, AppStartupResult next) {
    _startupState = next;
    notifyListeners();
  }

  void _handleAuthChange(AsyncValue<AuthUser?>? _, AsyncValue<AuthUser?> next) {
    _authState = next;
    notifyListeners();
  }

  void initialize() {
    if (_initialized) {
      return;
    }
    _initialized = true;
    _ref.listen<AppStartupResult>(
      appStartupControllerProvider,
      _handleStartupChange,
      fireImmediately: true,
    );
    _ref.listen<AsyncValue<AuthUser?>>(
      authControllerProvider,
      _handleAuthChange,
      fireImmediately: true,
    );
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final bool isOnHome =
        state.matchedLocation == MainNavigationShell.routeName;

    if (_startupState.isLoading || _startupState.hasError) {
      return isOnHome ? null : MainNavigationShell.routeName;
    }

    if (_authState.hasError) {
      return isOnHome ? null : MainNavigationShell.routeName;
    }

    final AuthUser? user = _authState.asData?.value;
    if (user == null && !isOnHome) {
      return MainNavigationShell.routeName;
    }

    return null;
  }
}

class _AppShell extends ConsumerWidget {
  const _AppShell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppStartupResult startupState = ref.watch(
      appStartupControllerProvider,
    );

    return startupState.when(
      data: (_) {
        final AsyncValue<AuthUser?> authState = ref.watch(
          authControllerProvider,
        );
        return authState.when(
          data: (AuthUser? user) {
            if (user != null && !user.isGuest) {
              ref.watch(syncServiceProvider);
            }
            if (user == null) {
              return const SignInScreen();
            }
            return const MainNavigationShell();
          },
          loading: () => const _StartupPlaceholder(),
          error: (Object error, StackTrace _) =>
              _AuthenticationErrorView(error: error),
        );
      },
      loading: () => const _StartupPlaceholder(),
      error: (Object error, StackTrace _) => _StartupErrorView(error: error),
    );
  }
}

class _StartupPlaceholder extends StatelessWidget {
  const _StartupPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SizedBox(
          width: 72,
          height: 72,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class _StartupErrorView extends StatelessWidget {
  const _StartupErrorView({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Startup error: $error'),
        ),
      ),
    );
  }
}

class _AuthenticationErrorView extends StatelessWidget {
  const _AuthenticationErrorView({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Authentication error: $error'),
        ),
      ),
    );
  }
}
