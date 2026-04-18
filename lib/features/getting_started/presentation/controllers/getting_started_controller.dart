import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/getting_started/data/repositories/getting_started_preferences_repository_impl.dart';
import 'package:kopim/features/getting_started/domain/entities/getting_started_preferences.dart';
import 'package:kopim/features/getting_started/domain/entities/getting_started_progress.dart';
import 'package:kopim/features/getting_started/domain/entities/getting_started_view_model.dart';
import 'package:kopim/features/getting_started/domain/repositories/getting_started_preferences_repository.dart';
import 'package:kopim/features/home/presentation/controllers/home_providers.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/profile_controller.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';

final Provider<GettingStartedPreferencesRepository>
gettingStartedPreferencesRepositoryProvider =
    Provider<GettingStartedPreferencesRepository>(
      (Ref ref) => GettingStartedPreferencesRepositoryImpl(),
    );

final AsyncNotifierProvider<
  GettingStartedPreferencesController,
  GettingStartedPreferences
>
gettingStartedPreferencesControllerProvider =
    AsyncNotifierProvider<
      GettingStartedPreferencesController,
      GettingStartedPreferences
    >(GettingStartedPreferencesController.new);

final StreamProvider<List<Budget>> gettingStartedBudgetsProvider =
    StreamProvider<List<Budget>>((Ref ref) {
      return ref.watch(watchBudgetsUseCaseProvider).call();
    });

final Provider<AsyncValue<GettingStartedProgress>>
gettingStartedProgressProvider = Provider<AsyncValue<GettingStartedProgress>>((
  Ref ref,
) {
  final AsyncValue<List<AccountEntity>> accountsAsync = ref.watch(
    homeAccountsProvider,
  );
  final AsyncValue<List<Category>> categoriesAsync = ref.watch(
    homeCategoriesProvider,
  );
  final AsyncValue<List<TransactionEntity>> transactionsAsync = ref.watch(
    homeRecentTransactionsProvider(limit: 1),
  );
  final AsyncValue<List<SavingGoal>> goalsAsync = ref.watch(
    homeSavingGoalsProvider,
  );
  final AsyncValue<List<Budget>> budgetsAsync = ref.watch(
    gettingStartedBudgetsProvider,
  );
  final AsyncValue<AuthUser?> authAsync = ref.watch(authControllerProvider);

  final Object? asyncError = _firstAsyncError(<AsyncValue<Object?>>[
    accountsAsync,
    categoriesAsync,
    transactionsAsync,
    goalsAsync,
    budgetsAsync,
    authAsync,
  ]);
  if (asyncError != null) {
    return AsyncValue<GettingStartedProgress>.error(
      asyncError,
      StackTrace.current,
    );
  }
  final bool isLoadingBase = <AsyncValue<Object?>>[
    accountsAsync,
    categoriesAsync,
    transactionsAsync,
    goalsAsync,
    budgetsAsync,
    authAsync,
  ].any((AsyncValue<Object?> value) => value.isLoading);
  if (isLoadingBase) {
    return const AsyncValue<GettingStartedProgress>.loading();
  }

  final AuthUser? user = authAsync.value;
  final AsyncValue<Profile?> profileAsync = user == null
      ? const AsyncValue<Profile?>.data(null)
      : ref.watch(profileControllerProvider(user.uid));
  if (profileAsync.hasError) {
    return AsyncValue<GettingStartedProgress>.error(
      profileAsync.error!,
      profileAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (profileAsync.isLoading) {
    return const AsyncValue<GettingStartedProgress>.loading();
  }

  final List<Category> categories = categoriesAsync.value ?? const <Category>[];
  final bool hasUserCategories = categories.any(
    (Category category) => category.isSystem != true,
  );

  return AsyncValue<GettingStartedProgress>.data(
    GettingStartedProgress(
      hasAccounts: (accountsAsync.value ?? const <AccountEntity>[]).isNotEmpty,
      hasUserCategories: hasUserCategories,
      hasTransactions:
          (transactionsAsync.value ?? const <TransactionEntity>[]).isNotEmpty,
      hasProfileName: (profileAsync.value?.name.trim().isNotEmpty ?? false),
      hasSavingGoal: (goalsAsync.value ?? const <SavingGoal>[]).isNotEmpty,
      hasBudget: (budgetsAsync.value ?? const <Budget>[]).isNotEmpty,
    ),
  );
});

final Provider<AsyncValue<GettingStartedViewModel>>
gettingStartedViewModelProvider = Provider<AsyncValue<GettingStartedViewModel>>(
  (Ref ref) {
    final AsyncValue<GettingStartedPreferences> preferencesAsync = ref.watch(
      gettingStartedPreferencesControllerProvider,
    );
    final AsyncValue<GettingStartedProgress> progressAsync = ref.watch(
      gettingStartedProgressProvider,
    );

    if (preferencesAsync.hasError) {
      return AsyncValue<GettingStartedViewModel>.error(
        preferencesAsync.error!,
        preferencesAsync.stackTrace ?? StackTrace.current,
      );
    }
    if (progressAsync.hasError) {
      return AsyncValue<GettingStartedViewModel>.error(
        progressAsync.error!,
        progressAsync.stackTrace ?? StackTrace.current,
      );
    }
    if (preferencesAsync.isLoading || progressAsync.isLoading) {
      return const AsyncValue<GettingStartedViewModel>.loading();
    }

    final GettingStartedPreferences preferences =
        preferencesAsync.value ?? const GettingStartedPreferences();
    final GettingStartedProgress progress =
        progressAsync.value ??
        const GettingStartedProgress(
          hasAccounts: false,
          hasUserCategories: false,
          hasTransactions: false,
          hasProfileName: false,
          hasSavingGoal: false,
          hasBudget: false,
        );
    final bool shouldAutoActivate =
        !preferences.hasActivated && !progress.hasMeaningfulData;
    final bool shouldDisplayOnHome =
        !progress.isCompleted &&
        !preferences.isHidden &&
        (preferences.hasActivated || shouldAutoActivate);

    return AsyncValue<GettingStartedViewModel>.data(
      GettingStartedViewModel(
        preferences: preferences,
        progress: progress,
        shouldAutoActivate: shouldAutoActivate,
        shouldDisplayOnHome: shouldDisplayOnHome,
      ),
    );
  },
);

class GettingStartedPreferencesController
    extends AsyncNotifier<GettingStartedPreferences> {
  late final GettingStartedPreferencesRepository _repository;
  late final LoggerService _logger;

  @override
  Future<GettingStartedPreferences> build() async {
    _repository = ref.watch(gettingStartedPreferencesRepositoryProvider);
    _logger = ref.watch(loggerServiceProvider);
    return _repository.load();
  }

  Future<void> activate() async {
    final GettingStartedPreferences current = await _ensureLoaded();
    if (current.hasActivated && !current.isHidden) {
      return;
    }
    await _persist(
      current.copyWith(hasActivated: true, isHidden: false),
      previous: current,
    );
  }

  Future<void> hide() async {
    final GettingStartedPreferences current = await _ensureLoaded();
    await _persist(
      current.copyWith(hasActivated: true, isHidden: true),
      previous: current,
    );
  }

  Future<void> reopen() async {
    final GettingStartedPreferences current = await _ensureLoaded();
    await _persist(
      current.copyWith(hasActivated: true, isHidden: false),
      previous: current,
    );
  }

  Future<GettingStartedPreferences> _ensureLoaded() async {
    final AsyncValue<GettingStartedPreferences> current = state;
    if (current case AsyncData<GettingStartedPreferences>(
      :final GettingStartedPreferences value,
    )) {
      return value;
    }
    return future;
  }

  Future<void> _persist(
    GettingStartedPreferences next, {
    required GettingStartedPreferences previous,
  }) async {
    state = AsyncValue<GettingStartedPreferences>.data(next);
    try {
      await _repository.save(next);
    } catch (error, stackTrace) {
      state = AsyncValue<GettingStartedPreferences>.data(previous);
      _logger.logError('Failed to save getting started preferences', error);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}

Object? _firstAsyncError(List<AsyncValue<Object?>> values) {
  for (final AsyncValue<Object?> value in values) {
    if (value.hasError) {
      return value.error;
    }
  }
  return null;
}
