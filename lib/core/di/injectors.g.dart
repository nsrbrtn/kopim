// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'injectors.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(loggerService)
const loggerServiceProvider = LoggerServiceProvider._();

final class LoggerServiceProvider
    extends $FunctionalProvider<LoggerService, LoggerService, LoggerService>
    with $Provider<LoggerService> {
  const LoggerServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loggerServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loggerServiceHash();

  @$internal
  @override
  $ProviderElement<LoggerService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LoggerService create(Ref ref) {
    return loggerService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoggerService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoggerService>(value),
    );
  }
}

String _$loggerServiceHash() => r'2c6dbe326747f3ecf81511ea71202cb7c7a10dfd';

@ProviderFor(analyticsService)
const analyticsServiceProvider = AnalyticsServiceProvider._();

final class AnalyticsServiceProvider
    extends
        $FunctionalProvider<
          AnalyticsService,
          AnalyticsService,
          AnalyticsService
        >
    with $Provider<AnalyticsService> {
  const AnalyticsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'analyticsServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$analyticsServiceHash();

  @$internal
  @override
  $ProviderElement<AnalyticsService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AnalyticsService create(Ref ref) {
    return analyticsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnalyticsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnalyticsService>(value),
    );
  }
}

String _$analyticsServiceHash() => r'cab7dcfcbbca6fdfa25059607282e5f33e92576a';

@ProviderFor(firestore)
const firestoreProvider = FirestoreProvider._();

final class FirestoreProvider
    extends
        $FunctionalProvider<
          FirebaseFirestore,
          FirebaseFirestore,
          FirebaseFirestore
        >
    with $Provider<FirebaseFirestore> {
  const FirestoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firestoreProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firestoreHash();

  @$internal
  @override
  $ProviderElement<FirebaseFirestore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FirebaseFirestore create(Ref ref) {
    return firestore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseFirestore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseFirestore>(value),
    );
  }
}

String _$firestoreHash() => r'597b1a9eb96f2fae51f5b578f4b5debe4f6d30c6';

@ProviderFor(firebaseAuth)
const firebaseAuthProvider = FirebaseAuthProvider._();

final class FirebaseAuthProvider
    extends $FunctionalProvider<FirebaseAuth, FirebaseAuth, FirebaseAuth>
    with $Provider<FirebaseAuth> {
  const FirebaseAuthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firebaseAuthProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firebaseAuthHash();

  @$internal
  @override
  $ProviderElement<FirebaseAuth> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FirebaseAuth create(Ref ref) {
    return firebaseAuth(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseAuth value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseAuth>(value),
    );
  }
}

String _$firebaseAuthHash() => r'8f84097cccd00af817397c1715c5f537399ba780';

@ProviderFor(firebaseStorage)
const firebaseStorageProvider = FirebaseStorageProvider._();

final class FirebaseStorageProvider
    extends
        $FunctionalProvider<FirebaseStorage, FirebaseStorage, FirebaseStorage>
    with $Provider<FirebaseStorage> {
  const FirebaseStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firebaseStorageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firebaseStorageHash();

  @$internal
  @override
  $ProviderElement<FirebaseStorage> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FirebaseStorage create(Ref ref) {
    return firebaseStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseStorage>(value),
    );
  }
}

String _$firebaseStorageHash() => r'47903c48019f7dfa1ba82fa0a905885442d69f6b';

@ProviderFor(firebaseRemoteConfig)
const firebaseRemoteConfigProvider = FirebaseRemoteConfigProvider._();

final class FirebaseRemoteConfigProvider
    extends
        $FunctionalProvider<
          FirebaseRemoteConfig,
          FirebaseRemoteConfig,
          FirebaseRemoteConfig
        >
    with $Provider<FirebaseRemoteConfig> {
  const FirebaseRemoteConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firebaseRemoteConfigProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firebaseRemoteConfigHash();

  @$internal
  @override
  $ProviderElement<FirebaseRemoteConfig> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FirebaseRemoteConfig create(Ref ref) {
    return firebaseRemoteConfig(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseRemoteConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseRemoteConfig>(value),
    );
  }
}

String _$firebaseRemoteConfigHash() =>
    r'b4c6783736b8eac479413a21329664cf4f4edcb5';

@ProviderFor(levelPolicy)
const levelPolicyProvider = LevelPolicyProvider._();

final class LevelPolicyProvider
    extends $FunctionalProvider<LevelPolicy, LevelPolicy, LevelPolicy>
    with $Provider<LevelPolicy> {
  const LevelPolicyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'levelPolicyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$levelPolicyHash();

  @$internal
  @override
  $ProviderElement<LevelPolicy> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LevelPolicy create(Ref ref) {
    return levelPolicy(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LevelPolicy value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LevelPolicy>(value),
    );
  }
}

String _$levelPolicyHash() => r'cf33f35f707b67802f3c09b81ce189fa94a1620f';

@ProviderFor(connectivity)
const connectivityProvider = ConnectivityProvider._();

final class ConnectivityProvider
    extends $FunctionalProvider<Connectivity, Connectivity, Connectivity>
    with $Provider<Connectivity> {
  const ConnectivityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectivityProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectivityHash();

  @$internal
  @override
  $ProviderElement<Connectivity> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Connectivity create(Ref ref) {
    return connectivity(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Connectivity value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Connectivity>(value),
    );
  }
}

String _$connectivityHash() => r'dbbaa751fbd9afcb3ec3c33a3b00257f5fe5682c';

@ProviderFor(uuidGenerator)
const uuidGeneratorProvider = UuidGeneratorProvider._();

final class UuidGeneratorProvider extends $FunctionalProvider<Uuid, Uuid, Uuid>
    with $Provider<Uuid> {
  const UuidGeneratorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'uuidGeneratorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$uuidGeneratorHash();

  @$internal
  @override
  $ProviderElement<Uuid> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Uuid create(Ref ref) {
    return uuidGenerator(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Uuid value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Uuid>(value),
    );
  }
}

String _$uuidGeneratorHash() => r'037307e88c8a89227ac8c8e7d971ffd877d0cb60';

@ProviderFor(aiAssistantService)
const aiAssistantServiceProvider = AiAssistantServiceProvider._();

final class AiAssistantServiceProvider
    extends
        $FunctionalProvider<
          AiAssistantService,
          AiAssistantService,
          AiAssistantService
        >
    with $Provider<AiAssistantService> {
  const AiAssistantServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiAssistantServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiAssistantServiceHash();

  @$internal
  @override
  $ProviderElement<AiAssistantService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AiAssistantService create(Ref ref) {
    return aiAssistantService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AiAssistantService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AiAssistantService>(value),
    );
  }
}

String _$aiAssistantServiceHash() =>
    r'614402ddc3a8583de90b4cb2ce26211cd9843e61';

@ProviderFor(appDatabase)
const appDatabaseProvider = AppDatabaseProvider._();

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  const AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'd77dd55624f88ba85786c5ed36157c845beee8c5';

@ProviderFor(outboxDao)
const outboxDaoProvider = OutboxDaoProvider._();

final class OutboxDaoProvider
    extends $FunctionalProvider<OutboxDao, OutboxDao, OutboxDao>
    with $Provider<OutboxDao> {
  const OutboxDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'outboxDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$outboxDaoHash();

  @$internal
  @override
  $ProviderElement<OutboxDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OutboxDao create(Ref ref) {
    return outboxDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OutboxDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OutboxDao>(value),
    );
  }
}

String _$outboxDaoHash() => r'c134f94b8f94f536107cb7b8dd8fc6a853733b6a';

@ProviderFor(accountDao)
const accountDaoProvider = AccountDaoProvider._();

final class AccountDaoProvider
    extends $FunctionalProvider<AccountDao, AccountDao, AccountDao>
    with $Provider<AccountDao> {
  const AccountDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountDaoHash();

  @$internal
  @override
  $ProviderElement<AccountDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AccountDao create(Ref ref) {
    return accountDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountDao>(value),
    );
  }
}

String _$accountDaoHash() => r'41cf905611cf13a5f91d7f114db19c474eb63ef2';

@ProviderFor(categoryDao)
const categoryDaoProvider = CategoryDaoProvider._();

final class CategoryDaoProvider
    extends $FunctionalProvider<CategoryDao, CategoryDao, CategoryDao>
    with $Provider<CategoryDao> {
  const CategoryDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryDaoHash();

  @$internal
  @override
  $ProviderElement<CategoryDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CategoryDao create(Ref ref) {
    return categoryDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoryDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoryDao>(value),
    );
  }
}

String _$categoryDaoHash() => r'95fc41600613b8ff1335794effd4b71fca511838';

@ProviderFor(transactionDao)
const transactionDaoProvider = TransactionDaoProvider._();

final class TransactionDaoProvider
    extends $FunctionalProvider<TransactionDao, TransactionDao, TransactionDao>
    with $Provider<TransactionDao> {
  const TransactionDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionDaoHash();

  @$internal
  @override
  $ProviderElement<TransactionDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TransactionDao create(Ref ref) {
    return transactionDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransactionDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransactionDao>(value),
    );
  }
}

String _$transactionDaoHash() => r'6dd75d3118f0e2e23be1b05fe5ebcee148e69f7f';

@ProviderFor(budgetDao)
const budgetDaoProvider = BudgetDaoProvider._();

final class BudgetDaoProvider
    extends $FunctionalProvider<BudgetDao, BudgetDao, BudgetDao>
    with $Provider<BudgetDao> {
  const BudgetDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetDaoHash();

  @$internal
  @override
  $ProviderElement<BudgetDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BudgetDao create(Ref ref) {
    return budgetDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BudgetDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BudgetDao>(value),
    );
  }
}

String _$budgetDaoHash() => r'6d271f84e0c1c8337fc10b0be34145e244e5d8d5';

@ProviderFor(budgetInstanceDao)
const budgetInstanceDaoProvider = BudgetInstanceDaoProvider._();

final class BudgetInstanceDaoProvider
    extends
        $FunctionalProvider<
          BudgetInstanceDao,
          BudgetInstanceDao,
          BudgetInstanceDao
        >
    with $Provider<BudgetInstanceDao> {
  const BudgetInstanceDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetInstanceDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetInstanceDaoHash();

  @$internal
  @override
  $ProviderElement<BudgetInstanceDao> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BudgetInstanceDao create(Ref ref) {
    return budgetInstanceDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BudgetInstanceDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BudgetInstanceDao>(value),
    );
  }
}

String _$budgetInstanceDaoHash() => r'f2ff161d2210b373bff95923b0810a8acb8f09bb';

@ProviderFor(savingGoalDao)
const savingGoalDaoProvider = SavingGoalDaoProvider._();

final class SavingGoalDaoProvider
    extends $FunctionalProvider<SavingGoalDao, SavingGoalDao, SavingGoalDao>
    with $Provider<SavingGoalDao> {
  const SavingGoalDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savingGoalDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savingGoalDaoHash();

  @$internal
  @override
  $ProviderElement<SavingGoalDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SavingGoalDao create(Ref ref) {
    return savingGoalDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SavingGoalDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SavingGoalDao>(value),
    );
  }
}

String _$savingGoalDaoHash() => r'f486ee43a183e184c23f4137dcacb9c39c73aeb3';

@ProviderFor(goalContributionDao)
const goalContributionDaoProvider = GoalContributionDaoProvider._();

final class GoalContributionDaoProvider
    extends
        $FunctionalProvider<
          GoalContributionDao,
          GoalContributionDao,
          GoalContributionDao
        >
    with $Provider<GoalContributionDao> {
  const GoalContributionDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goalContributionDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goalContributionDaoHash();

  @$internal
  @override
  $ProviderElement<GoalContributionDao> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GoalContributionDao create(Ref ref) {
    return goalContributionDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoalContributionDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoalContributionDao>(value),
    );
  }
}

String _$goalContributionDaoHash() =>
    r'360ff3a0bd79e0a04ada0feeb9648c00b2f8d97a';

@ProviderFor(profileDao)
const profileDaoProvider = ProfileDaoProvider._();

final class ProfileDaoProvider
    extends $FunctionalProvider<ProfileDao, ProfileDao, ProfileDao>
    with $Provider<ProfileDao> {
  const ProfileDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileDaoHash();

  @$internal
  @override
  $ProviderElement<ProfileDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ProfileDao create(Ref ref) {
    return profileDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileDao>(value),
    );
  }
}

String _$profileDaoHash() => r'c4fb55deddb24b0dabbb189a18f0e68e259be21c';

@ProviderFor(recurringRuleDao)
const recurringRuleDaoProvider = RecurringRuleDaoProvider._();

final class RecurringRuleDaoProvider
    extends
        $FunctionalProvider<
          RecurringRuleDao,
          RecurringRuleDao,
          RecurringRuleDao
        >
    with $Provider<RecurringRuleDao> {
  const RecurringRuleDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recurringRuleDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recurringRuleDaoHash();

  @$internal
  @override
  $ProviderElement<RecurringRuleDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RecurringRuleDao create(Ref ref) {
    return recurringRuleDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecurringRuleDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecurringRuleDao>(value),
    );
  }
}

String _$recurringRuleDaoHash() => r'83f2440661655833dfdecc3692fa2232037927b2';

@ProviderFor(recurringOccurrenceDao)
const recurringOccurrenceDaoProvider = RecurringOccurrenceDaoProvider._();

final class RecurringOccurrenceDaoProvider
    extends
        $FunctionalProvider<
          RecurringOccurrenceDao,
          RecurringOccurrenceDao,
          RecurringOccurrenceDao
        >
    with $Provider<RecurringOccurrenceDao> {
  const RecurringOccurrenceDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recurringOccurrenceDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recurringOccurrenceDaoHash();

  @$internal
  @override
  $ProviderElement<RecurringOccurrenceDao> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RecurringOccurrenceDao create(Ref ref) {
    return recurringOccurrenceDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecurringOccurrenceDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecurringOccurrenceDao>(value),
    );
  }
}

String _$recurringOccurrenceDaoHash() =>
    r'396b8cbeb1142f8c5ecaba5af6c8d40f7a98a99c';

@ProviderFor(recurringRuleExecutionDao)
const recurringRuleExecutionDaoProvider = RecurringRuleExecutionDaoProvider._();

final class RecurringRuleExecutionDaoProvider
    extends
        $FunctionalProvider<
          RecurringRuleExecutionDao,
          RecurringRuleExecutionDao,
          RecurringRuleExecutionDao
        >
    with $Provider<RecurringRuleExecutionDao> {
  const RecurringRuleExecutionDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recurringRuleExecutionDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recurringRuleExecutionDaoHash();

  @$internal
  @override
  $ProviderElement<RecurringRuleExecutionDao> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RecurringRuleExecutionDao create(Ref ref) {
    return recurringRuleExecutionDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecurringRuleExecutionDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecurringRuleExecutionDao>(value),
    );
  }
}

String _$recurringRuleExecutionDaoHash() =>
    r'b9b0bc1c54eb4be3a2826559d9023a16fec60b69';

@ProviderFor(jobQueueDao)
const jobQueueDaoProvider = JobQueueDaoProvider._();

final class JobQueueDaoProvider
    extends $FunctionalProvider<JobQueueDao, JobQueueDao, JobQueueDao>
    with $Provider<JobQueueDao> {
  const JobQueueDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'jobQueueDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$jobQueueDaoHash();

  @$internal
  @override
  $ProviderElement<JobQueueDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  JobQueueDao create(Ref ref) {
    return jobQueueDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(JobQueueDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<JobQueueDao>(value),
    );
  }
}

String _$jobQueueDaoHash() => r'8c93af9c3b09afed591a9c33c68b501b7878a2c9';

@ProviderFor(upcomingPaymentsDao)
const upcomingPaymentsDaoProvider = UpcomingPaymentsDaoProvider._();

final class UpcomingPaymentsDaoProvider
    extends
        $FunctionalProvider<
          UpcomingPaymentsDao,
          UpcomingPaymentsDao,
          UpcomingPaymentsDao
        >
    with $Provider<UpcomingPaymentsDao> {
  const UpcomingPaymentsDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'upcomingPaymentsDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$upcomingPaymentsDaoHash();

  @$internal
  @override
  $ProviderElement<UpcomingPaymentsDao> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpcomingPaymentsDao create(Ref ref) {
    return upcomingPaymentsDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpcomingPaymentsDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpcomingPaymentsDao>(value),
    );
  }
}

String _$upcomingPaymentsDaoHash() =>
    r'c0a0dddc7c94c45c289da27c7aa901cda850697b';

@ProviderFor(paymentRemindersDao)
const paymentRemindersDaoProvider = PaymentRemindersDaoProvider._();

final class PaymentRemindersDaoProvider
    extends
        $FunctionalProvider<
          PaymentRemindersDao,
          PaymentRemindersDao,
          PaymentRemindersDao
        >
    with $Provider<PaymentRemindersDao> {
  const PaymentRemindersDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentRemindersDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentRemindersDaoHash();

  @$internal
  @override
  $ProviderElement<PaymentRemindersDao> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PaymentRemindersDao create(Ref ref) {
    return paymentRemindersDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaymentRemindersDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaymentRemindersDao>(value),
    );
  }
}

String _$paymentRemindersDaoHash() =>
    r'0ccf44a3a2d861621cd7f172e6760fdf1ad5934a';

@ProviderFor(recurringRuleRemoteDataSource)
const recurringRuleRemoteDataSourceProvider =
    RecurringRuleRemoteDataSourceProvider._();

final class RecurringRuleRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          RecurringRuleRemoteDataSource,
          RecurringRuleRemoteDataSource,
          RecurringRuleRemoteDataSource
        >
    with $Provider<RecurringRuleRemoteDataSource> {
  const RecurringRuleRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recurringRuleRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recurringRuleRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<RecurringRuleRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RecurringRuleRemoteDataSource create(Ref ref) {
    return recurringRuleRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecurringRuleRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecurringRuleRemoteDataSource>(
        value,
      ),
    );
  }
}

String _$recurringRuleRemoteDataSourceHash() =>
    r'479bdf0779028dc3be133916a5aecdefc79521c3';

@ProviderFor(flutterLocalNotificationsPlugin)
const flutterLocalNotificationsPluginProvider =
    FlutterLocalNotificationsPluginProvider._();

final class FlutterLocalNotificationsPluginProvider
    extends
        $FunctionalProvider<
          FlutterLocalNotificationsPlugin?,
          FlutterLocalNotificationsPlugin?,
          FlutterLocalNotificationsPlugin?
        >
    with $Provider<FlutterLocalNotificationsPlugin?> {
  const FlutterLocalNotificationsPluginProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'flutterLocalNotificationsPluginProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$flutterLocalNotificationsPluginHash();

  @$internal
  @override
  $ProviderElement<FlutterLocalNotificationsPlugin?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FlutterLocalNotificationsPlugin? create(Ref ref) {
    return flutterLocalNotificationsPlugin(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FlutterLocalNotificationsPlugin? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FlutterLocalNotificationsPlugin?>(
        value,
      ),
    );
  }
}

String _$flutterLocalNotificationsPluginHash() =>
    r'09393e85415f184f9bb02647975651dd07be74fb';

@ProviderFor(notificationFallbackPresenter)
const notificationFallbackPresenterProvider =
    NotificationFallbackPresenterProvider._();

final class NotificationFallbackPresenterProvider
    extends
        $FunctionalProvider<
          NotificationFallbackPresenter,
          NotificationFallbackPresenter,
          NotificationFallbackPresenter
        >
    with $Provider<NotificationFallbackPresenter> {
  const NotificationFallbackPresenterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationFallbackPresenterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationFallbackPresenterHash();

  @$internal
  @override
  $ProviderElement<NotificationFallbackPresenter> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationFallbackPresenter create(Ref ref) {
    return notificationFallbackPresenter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationFallbackPresenter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationFallbackPresenter>(
        value,
      ),
    );
  }
}

String _$notificationFallbackPresenterHash() =>
    r'add04bf69e3b205265b37452400a227d64ddd1ff';

@ProviderFor(pushPermissionService)
const pushPermissionServiceProvider = PushPermissionServiceProvider._();

final class PushPermissionServiceProvider
    extends
        $FunctionalProvider<
          PushPermissionService,
          PushPermissionService,
          PushPermissionService
        >
    with $Provider<PushPermissionService> {
  const PushPermissionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushPermissionServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushPermissionServiceHash();

  @$internal
  @override
  $ProviderElement<PushPermissionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PushPermissionService create(Ref ref) {
    return pushPermissionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PushPermissionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PushPermissionService>(value),
    );
  }
}

String _$pushPermissionServiceHash() =>
    r'8fe2a28067a3d865f79a96b57cb9fb30ffb90fc3';

@ProviderFor(notificationsGateway)
const notificationsGatewayProvider = NotificationsGatewayProvider._();

final class NotificationsGatewayProvider
    extends
        $FunctionalProvider<
          NotificationsGateway,
          NotificationsGateway,
          NotificationsGateway
        >
    with $Provider<NotificationsGateway> {
  const NotificationsGatewayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsGatewayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsGatewayHash();

  @$internal
  @override
  $ProviderElement<NotificationsGateway> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationsGateway create(Ref ref) {
    return notificationsGateway(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationsGateway value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationsGateway>(value),
    );
  }
}

String _$notificationsGatewayHash() =>
    r'45f10040ba3db0ab4f7bfde4a3285f7dc4948d96';

@ProviderFor(workmanager)
const workmanagerProvider = WorkmanagerProvider._();

final class WorkmanagerProvider
    extends $FunctionalProvider<Workmanager, Workmanager, Workmanager>
    with $Provider<Workmanager> {
  const WorkmanagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workmanagerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workmanagerHash();

  @$internal
  @override
  $ProviderElement<Workmanager> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Workmanager create(Ref ref) {
    return workmanager(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Workmanager value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Workmanager>(value),
    );
  }
}

String _$workmanagerHash() => r'884c489ccf3eeb94f5d425cc7ab546b9bf48747e';

@ProviderFor(upcomingPaymentsWorkScheduler)
const upcomingPaymentsWorkSchedulerProvider =
    UpcomingPaymentsWorkSchedulerProvider._();

final class UpcomingPaymentsWorkSchedulerProvider
    extends
        $FunctionalProvider<
          UpcomingPaymentsWorkScheduler,
          UpcomingPaymentsWorkScheduler,
          UpcomingPaymentsWorkScheduler
        >
    with $Provider<UpcomingPaymentsWorkScheduler> {
  const UpcomingPaymentsWorkSchedulerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'upcomingPaymentsWorkSchedulerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$upcomingPaymentsWorkSchedulerHash();

  @$internal
  @override
  $ProviderElement<UpcomingPaymentsWorkScheduler> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpcomingPaymentsWorkScheduler create(Ref ref) {
    return upcomingPaymentsWorkScheduler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpcomingPaymentsWorkScheduler value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpcomingPaymentsWorkScheduler>(
        value,
      ),
    );
  }
}

String _$upcomingPaymentsWorkSchedulerHash() =>
    r'd02f8ba9573c38966dc26073210fd2dfc45d990d';

@ProviderFor(recurringRuleEngine)
const recurringRuleEngineProvider = RecurringRuleEngineProvider._();

final class RecurringRuleEngineProvider
    extends
        $FunctionalProvider<
          RecurringRuleEngine,
          RecurringRuleEngine,
          RecurringRuleEngine
        >
    with $Provider<RecurringRuleEngine> {
  const RecurringRuleEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recurringRuleEngineProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recurringRuleEngineHash();

  @$internal
  @override
  $ProviderElement<RecurringRuleEngine> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RecurringRuleEngine create(Ref ref) {
    return recurringRuleEngine(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecurringRuleEngine value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecurringRuleEngine>(value),
    );
  }
}

String _$recurringRuleEngineHash() =>
    r'94d207ac7439ca6dcb8f24b9d37a5644705d6c6a';

@ProviderFor(budgetSchedule)
const budgetScheduleProvider = BudgetScheduleProvider._();

final class BudgetScheduleProvider
    extends $FunctionalProvider<BudgetSchedule, BudgetSchedule, BudgetSchedule>
    with $Provider<BudgetSchedule> {
  const BudgetScheduleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetScheduleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetScheduleHash();

  @$internal
  @override
  $ProviderElement<BudgetSchedule> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BudgetSchedule create(Ref ref) {
    return budgetSchedule(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BudgetSchedule value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BudgetSchedule>(value),
    );
  }
}

String _$budgetScheduleHash() => r'dd4e864d9533d6685fa5d4333c2cad4cef43b5d1';

@ProviderFor(accountRemoteDataSource)
const accountRemoteDataSourceProvider = AccountRemoteDataSourceProvider._();

final class AccountRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          AccountRemoteDataSource,
          AccountRemoteDataSource,
          AccountRemoteDataSource
        >
    with $Provider<AccountRemoteDataSource> {
  const AccountRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<AccountRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AccountRemoteDataSource create(Ref ref) {
    return accountRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountRemoteDataSource>(value),
    );
  }
}

String _$accountRemoteDataSourceHash() =>
    r'b1ef9061f7f65a0d694f0a2f070d12f13502eb74';

@ProviderFor(categoryRemoteDataSource)
const categoryRemoteDataSourceProvider = CategoryRemoteDataSourceProvider._();

final class CategoryRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          CategoryRemoteDataSource,
          CategoryRemoteDataSource,
          CategoryRemoteDataSource
        >
    with $Provider<CategoryRemoteDataSource> {
  const CategoryRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<CategoryRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CategoryRemoteDataSource create(Ref ref) {
    return categoryRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoryRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoryRemoteDataSource>(value),
    );
  }
}

String _$categoryRemoteDataSourceHash() =>
    r'41e23c7c2518c2346671ee5662564b7559ddd941';

@ProviderFor(transactionRemoteDataSource)
const transactionRemoteDataSourceProvider =
    TransactionRemoteDataSourceProvider._();

final class TransactionRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          TransactionRemoteDataSource,
          TransactionRemoteDataSource,
          TransactionRemoteDataSource
        >
    with $Provider<TransactionRemoteDataSource> {
  const TransactionRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<TransactionRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TransactionRemoteDataSource create(Ref ref) {
    return transactionRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransactionRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransactionRemoteDataSource>(value),
    );
  }
}

String _$transactionRemoteDataSourceHash() =>
    r'65d50f41155fa5905bd52f7ce1d39e2868b94004';

@ProviderFor(profileRemoteDataSource)
const profileRemoteDataSourceProvider = ProfileRemoteDataSourceProvider._();

final class ProfileRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          ProfileRemoteDataSource,
          ProfileRemoteDataSource,
          ProfileRemoteDataSource
        >
    with $Provider<ProfileRemoteDataSource> {
  const ProfileRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<ProfileRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProfileRemoteDataSource create(Ref ref) {
    return profileRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileRemoteDataSource>(value),
    );
  }
}

String _$profileRemoteDataSourceHash() =>
    r'45baf2527988bcc7389803c7cea36c9fa578effb';

@ProviderFor(avatarRemoteDataSource)
const avatarRemoteDataSourceProvider = AvatarRemoteDataSourceProvider._();

final class AvatarRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          AvatarRemoteDataSource,
          AvatarRemoteDataSource,
          AvatarRemoteDataSource
        >
    with $Provider<AvatarRemoteDataSource> {
  const AvatarRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'avatarRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$avatarRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<AvatarRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AvatarRemoteDataSource create(Ref ref) {
    return avatarRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AvatarRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AvatarRemoteDataSource>(value),
    );
  }
}

String _$avatarRemoteDataSourceHash() =>
    r'62a0f450283b5803e52fe4159c8dc4586da8244c';

@ProviderFor(userProgressRemoteDataSource)
const userProgressRemoteDataSourceProvider =
    UserProgressRemoteDataSourceProvider._();

final class UserProgressRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          UserProgressRemoteDataSource,
          UserProgressRemoteDataSource,
          UserProgressRemoteDataSource
        >
    with $Provider<UserProgressRemoteDataSource> {
  const UserProgressRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userProgressRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userProgressRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<UserProgressRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UserProgressRemoteDataSource create(Ref ref) {
    return userProgressRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserProgressRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserProgressRemoteDataSource>(value),
    );
  }
}

String _$userProgressRemoteDataSourceHash() =>
    r'009e10b99822950953d87758f1fe3aa367ab63b4';

@ProviderFor(budgetRemoteDataSource)
const budgetRemoteDataSourceProvider = BudgetRemoteDataSourceProvider._();

final class BudgetRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          BudgetRemoteDataSource,
          BudgetRemoteDataSource,
          BudgetRemoteDataSource
        >
    with $Provider<BudgetRemoteDataSource> {
  const BudgetRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<BudgetRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BudgetRemoteDataSource create(Ref ref) {
    return budgetRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BudgetRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BudgetRemoteDataSource>(value),
    );
  }
}

String _$budgetRemoteDataSourceHash() =>
    r'f2f3bcea8c010c92da9b9f1dc18eaf363350c1da';

@ProviderFor(budgetInstanceRemoteDataSource)
const budgetInstanceRemoteDataSourceProvider =
    BudgetInstanceRemoteDataSourceProvider._();

final class BudgetInstanceRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          BudgetInstanceRemoteDataSource,
          BudgetInstanceRemoteDataSource,
          BudgetInstanceRemoteDataSource
        >
    with $Provider<BudgetInstanceRemoteDataSource> {
  const BudgetInstanceRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetInstanceRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetInstanceRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<BudgetInstanceRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BudgetInstanceRemoteDataSource create(Ref ref) {
    return budgetInstanceRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BudgetInstanceRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BudgetInstanceRemoteDataSource>(
        value,
      ),
    );
  }
}

String _$budgetInstanceRemoteDataSourceHash() =>
    r'a020e9c9816dcaffaf93de641281dc389b6c4a5d';

@ProviderFor(savingGoalRemoteDataSource)
const savingGoalRemoteDataSourceProvider =
    SavingGoalRemoteDataSourceProvider._();

final class SavingGoalRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          SavingGoalRemoteDataSource,
          SavingGoalRemoteDataSource,
          SavingGoalRemoteDataSource
        >
    with $Provider<SavingGoalRemoteDataSource> {
  const SavingGoalRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savingGoalRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savingGoalRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<SavingGoalRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SavingGoalRemoteDataSource create(Ref ref) {
    return savingGoalRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SavingGoalRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SavingGoalRemoteDataSource>(value),
    );
  }
}

String _$savingGoalRemoteDataSourceHash() =>
    r'f92bab57e5d731e4d387077ea0733f42a2a95f56';

@ProviderFor(aiAssistantRepository)
const aiAssistantRepositoryProvider = AiAssistantRepositoryProvider._();

final class AiAssistantRepositoryProvider
    extends
        $FunctionalProvider<
          AiAssistantRepository,
          AiAssistantRepository,
          AiAssistantRepository
        >
    with $Provider<AiAssistantRepository> {
  const AiAssistantRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiAssistantRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiAssistantRepositoryHash();

  @$internal
  @override
  $ProviderElement<AiAssistantRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AiAssistantRepository create(Ref ref) {
    return aiAssistantRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AiAssistantRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AiAssistantRepository>(value),
    );
  }
}

String _$aiAssistantRepositoryHash() =>
    r'6cc7c01d45e7c0405fdb2c1cfb21751d3c868661';

@ProviderFor(askFinancialAssistantUseCase)
const askFinancialAssistantUseCaseProvider =
    AskFinancialAssistantUseCaseProvider._();

final class AskFinancialAssistantUseCaseProvider
    extends
        $FunctionalProvider<
          AskFinancialAssistantUseCase,
          AskFinancialAssistantUseCase,
          AskFinancialAssistantUseCase
        >
    with $Provider<AskFinancialAssistantUseCase> {
  const AskFinancialAssistantUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'askFinancialAssistantUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$askFinancialAssistantUseCaseHash();

  @$internal
  @override
  $ProviderElement<AskFinancialAssistantUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AskFinancialAssistantUseCase create(Ref ref) {
    return askFinancialAssistantUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AskFinancialAssistantUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AskFinancialAssistantUseCase>(value),
    );
  }
}

String _$askFinancialAssistantUseCaseHash() =>
    r'f6e1566dc999d9a8c249741e2a4d831a1c6b2f0e';

@ProviderFor(watchAiRecommendationsUseCase)
const watchAiRecommendationsUseCaseProvider =
    WatchAiRecommendationsUseCaseProvider._();

final class WatchAiRecommendationsUseCaseProvider
    extends
        $FunctionalProvider<
          WatchAiRecommendationsUseCase,
          WatchAiRecommendationsUseCase,
          WatchAiRecommendationsUseCase
        >
    with $Provider<WatchAiRecommendationsUseCase> {
  const WatchAiRecommendationsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchAiRecommendationsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchAiRecommendationsUseCaseHash();

  @$internal
  @override
  $ProviderElement<WatchAiRecommendationsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WatchAiRecommendationsUseCase create(Ref ref) {
    return watchAiRecommendationsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WatchAiRecommendationsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WatchAiRecommendationsUseCase>(
        value,
      ),
    );
  }
}

String _$watchAiRecommendationsUseCaseHash() =>
    r'c6587a1ab8d795ac25070be0222f5e42dd4e9d2d';

@ProviderFor(watchAiAnalyticsUseCase)
const watchAiAnalyticsUseCaseProvider = WatchAiAnalyticsUseCaseProvider._();

final class WatchAiAnalyticsUseCaseProvider
    extends
        $FunctionalProvider<
          WatchAiAnalyticsUseCase,
          WatchAiAnalyticsUseCase,
          WatchAiAnalyticsUseCase
        >
    with $Provider<WatchAiAnalyticsUseCase> {
  const WatchAiAnalyticsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchAiAnalyticsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchAiAnalyticsUseCaseHash();

  @$internal
  @override
  $ProviderElement<WatchAiAnalyticsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WatchAiAnalyticsUseCase create(Ref ref) {
    return watchAiAnalyticsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WatchAiAnalyticsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WatchAiAnalyticsUseCase>(value),
    );
  }
}

String _$watchAiAnalyticsUseCaseHash() =>
    r'5bd91aff70efe5aed2b5e802b4aa8c1c91cdaf30';

@ProviderFor(accountRepository)
const accountRepositoryProvider = AccountRepositoryProvider._();

final class AccountRepositoryProvider
    extends
        $FunctionalProvider<
          AccountRepository,
          AccountRepository,
          AccountRepository
        >
    with $Provider<AccountRepository> {
  const AccountRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountRepositoryHash();

  @$internal
  @override
  $ProviderElement<AccountRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AccountRepository create(Ref ref) {
    return accountRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountRepository>(value),
    );
  }
}

String _$accountRepositoryHash() => r'35504303f5e7045ab7c337f1041ee01cffb06875';

@ProviderFor(addAccountUseCase)
const addAccountUseCaseProvider = AddAccountUseCaseProvider._();

final class AddAccountUseCaseProvider
    extends
        $FunctionalProvider<
          AddAccountUseCase,
          AddAccountUseCase,
          AddAccountUseCase
        >
    with $Provider<AddAccountUseCase> {
  const AddAccountUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addAccountUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addAccountUseCaseHash();

  @$internal
  @override
  $ProviderElement<AddAccountUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AddAccountUseCase create(Ref ref) {
    return addAccountUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddAccountUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddAccountUseCase>(value),
    );
  }
}

String _$addAccountUseCaseHash() => r'fa2b2563af599e8d07f320da1891e100d7ae6293';

@ProviderFor(deleteAccountUseCase)
const deleteAccountUseCaseProvider = DeleteAccountUseCaseProvider._();

final class DeleteAccountUseCaseProvider
    extends
        $FunctionalProvider<
          DeleteAccountUseCase,
          DeleteAccountUseCase,
          DeleteAccountUseCase
        >
    with $Provider<DeleteAccountUseCase> {
  const DeleteAccountUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteAccountUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteAccountUseCaseHash();

  @$internal
  @override
  $ProviderElement<DeleteAccountUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeleteAccountUseCase create(Ref ref) {
    return deleteAccountUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteAccountUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteAccountUseCase>(value),
    );
  }
}

String _$deleteAccountUseCaseHash() =>
    r'b2dc0b516807d5551b3e412819409a0f2a1b0604';

@ProviderFor(watchAccountsUseCase)
const watchAccountsUseCaseProvider = WatchAccountsUseCaseProvider._();

final class WatchAccountsUseCaseProvider
    extends
        $FunctionalProvider<
          WatchAccountsUseCase,
          WatchAccountsUseCase,
          WatchAccountsUseCase
        >
    with $Provider<WatchAccountsUseCase> {
  const WatchAccountsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchAccountsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchAccountsUseCaseHash();

  @$internal
  @override
  $ProviderElement<WatchAccountsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WatchAccountsUseCase create(Ref ref) {
    return watchAccountsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WatchAccountsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WatchAccountsUseCase>(value),
    );
  }
}

String _$watchAccountsUseCaseHash() =>
    r'1e591c8756219ebead3e51c5a37138b7013df854';

@ProviderFor(watchBudgetsUseCase)
const watchBudgetsUseCaseProvider = WatchBudgetsUseCaseProvider._();

final class WatchBudgetsUseCaseProvider
    extends
        $FunctionalProvider<
          WatchBudgetsUseCase,
          WatchBudgetsUseCase,
          WatchBudgetsUseCase
        >
    with $Provider<WatchBudgetsUseCase> {
  const WatchBudgetsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchBudgetsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchBudgetsUseCaseHash();

  @$internal
  @override
  $ProviderElement<WatchBudgetsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WatchBudgetsUseCase create(Ref ref) {
    return watchBudgetsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WatchBudgetsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WatchBudgetsUseCase>(value),
    );
  }
}

String _$watchBudgetsUseCaseHash() =>
    r'2f2b4e2b4764abb13a5d62a06dad6ac899d28210';

@ProviderFor(saveBudgetUseCase)
const saveBudgetUseCaseProvider = SaveBudgetUseCaseProvider._();

final class SaveBudgetUseCaseProvider
    extends
        $FunctionalProvider<
          SaveBudgetUseCase,
          SaveBudgetUseCase,
          SaveBudgetUseCase
        >
    with $Provider<SaveBudgetUseCase> {
  const SaveBudgetUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saveBudgetUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saveBudgetUseCaseHash();

  @$internal
  @override
  $ProviderElement<SaveBudgetUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SaveBudgetUseCase create(Ref ref) {
    return saveBudgetUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaveBudgetUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaveBudgetUseCase>(value),
    );
  }
}

String _$saveBudgetUseCaseHash() => r'2b1ace00122d33da63c69892fc13e82f1323385e';

@ProviderFor(deleteBudgetUseCase)
const deleteBudgetUseCaseProvider = DeleteBudgetUseCaseProvider._();

final class DeleteBudgetUseCaseProvider
    extends
        $FunctionalProvider<
          DeleteBudgetUseCase,
          DeleteBudgetUseCase,
          DeleteBudgetUseCase
        >
    with $Provider<DeleteBudgetUseCase> {
  const DeleteBudgetUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteBudgetUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteBudgetUseCaseHash();

  @$internal
  @override
  $ProviderElement<DeleteBudgetUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeleteBudgetUseCase create(Ref ref) {
    return deleteBudgetUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteBudgetUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteBudgetUseCase>(value),
    );
  }
}

String _$deleteBudgetUseCaseHash() =>
    r'a6fb7a342d2508fdd4b4cf21c9db445192eb25d2';

@ProviderFor(computeBudgetProgressUseCase)
const computeBudgetProgressUseCaseProvider =
    ComputeBudgetProgressUseCaseProvider._();

final class ComputeBudgetProgressUseCaseProvider
    extends
        $FunctionalProvider<
          ComputeBudgetProgressUseCase,
          ComputeBudgetProgressUseCase,
          ComputeBudgetProgressUseCase
        >
    with $Provider<ComputeBudgetProgressUseCase> {
  const ComputeBudgetProgressUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'computeBudgetProgressUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$computeBudgetProgressUseCaseHash();

  @$internal
  @override
  $ProviderElement<ComputeBudgetProgressUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ComputeBudgetProgressUseCase create(Ref ref) {
    return computeBudgetProgressUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ComputeBudgetProgressUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ComputeBudgetProgressUseCase>(value),
    );
  }
}

String _$computeBudgetProgressUseCaseHash() =>
    r'6e959206f2a50fea51f6fda1927229c34dbd7a52';

@ProviderFor(createSavingGoalUseCase)
const createSavingGoalUseCaseProvider = CreateSavingGoalUseCaseProvider._();

final class CreateSavingGoalUseCaseProvider
    extends
        $FunctionalProvider<
          CreateSavingGoalUseCase,
          CreateSavingGoalUseCase,
          CreateSavingGoalUseCase
        >
    with $Provider<CreateSavingGoalUseCase> {
  const CreateSavingGoalUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createSavingGoalUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createSavingGoalUseCaseHash();

  @$internal
  @override
  $ProviderElement<CreateSavingGoalUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreateSavingGoalUseCase create(Ref ref) {
    return createSavingGoalUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateSavingGoalUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateSavingGoalUseCase>(value),
    );
  }
}

String _$createSavingGoalUseCaseHash() =>
    r'93b8c9b44deaa81ac2b26ea4867d468b914b873c';

@ProviderFor(updateSavingGoalUseCase)
const updateSavingGoalUseCaseProvider = UpdateSavingGoalUseCaseProvider._();

final class UpdateSavingGoalUseCaseProvider
    extends
        $FunctionalProvider<
          UpdateSavingGoalUseCase,
          UpdateSavingGoalUseCase,
          UpdateSavingGoalUseCase
        >
    with $Provider<UpdateSavingGoalUseCase> {
  const UpdateSavingGoalUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateSavingGoalUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateSavingGoalUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdateSavingGoalUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpdateSavingGoalUseCase create(Ref ref) {
    return updateSavingGoalUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateSavingGoalUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateSavingGoalUseCase>(value),
    );
  }
}

String _$updateSavingGoalUseCaseHash() =>
    r'de5d5f148e8edf98f06505044d1a305474246201';

@ProviderFor(archiveSavingGoalUseCase)
const archiveSavingGoalUseCaseProvider = ArchiveSavingGoalUseCaseProvider._();

final class ArchiveSavingGoalUseCaseProvider
    extends
        $FunctionalProvider<
          ArchiveSavingGoalUseCase,
          ArchiveSavingGoalUseCase,
          ArchiveSavingGoalUseCase
        >
    with $Provider<ArchiveSavingGoalUseCase> {
  const ArchiveSavingGoalUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'archiveSavingGoalUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$archiveSavingGoalUseCaseHash();

  @$internal
  @override
  $ProviderElement<ArchiveSavingGoalUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ArchiveSavingGoalUseCase create(Ref ref) {
    return archiveSavingGoalUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ArchiveSavingGoalUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ArchiveSavingGoalUseCase>(value),
    );
  }
}

String _$archiveSavingGoalUseCaseHash() =>
    r'4494b09894ee7b6685f603152b70c3107634882b';

@ProviderFor(watchSavingGoalsUseCase)
const watchSavingGoalsUseCaseProvider = WatchSavingGoalsUseCaseProvider._();

final class WatchSavingGoalsUseCaseProvider
    extends
        $FunctionalProvider<
          WatchSavingGoalsUseCase,
          WatchSavingGoalsUseCase,
          WatchSavingGoalsUseCase
        >
    with $Provider<WatchSavingGoalsUseCase> {
  const WatchSavingGoalsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchSavingGoalsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchSavingGoalsUseCaseHash();

  @$internal
  @override
  $ProviderElement<WatchSavingGoalsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WatchSavingGoalsUseCase create(Ref ref) {
    return watchSavingGoalsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WatchSavingGoalsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WatchSavingGoalsUseCase>(value),
    );
  }
}

String _$watchSavingGoalsUseCaseHash() =>
    r'4594ab8a779349cd0948384eb9c72b1beea27747';

@ProviderFor(watchSavingGoalAnalyticsUseCase)
const watchSavingGoalAnalyticsUseCaseProvider =
    WatchSavingGoalAnalyticsUseCaseProvider._();

final class WatchSavingGoalAnalyticsUseCaseProvider
    extends
        $FunctionalProvider<
          WatchSavingGoalAnalyticsUseCase,
          WatchSavingGoalAnalyticsUseCase,
          WatchSavingGoalAnalyticsUseCase
        >
    with $Provider<WatchSavingGoalAnalyticsUseCase> {
  const WatchSavingGoalAnalyticsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchSavingGoalAnalyticsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchSavingGoalAnalyticsUseCaseHash();

  @$internal
  @override
  $ProviderElement<WatchSavingGoalAnalyticsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WatchSavingGoalAnalyticsUseCase create(Ref ref) {
    return watchSavingGoalAnalyticsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WatchSavingGoalAnalyticsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WatchSavingGoalAnalyticsUseCase>(
        value,
      ),
    );
  }
}

String _$watchSavingGoalAnalyticsUseCaseHash() =>
    r'f0a8c0b88af85b43a43d2db6f3d0e87bc454547e';

@ProviderFor(getSavingGoalsUseCase)
const getSavingGoalsUseCaseProvider = GetSavingGoalsUseCaseProvider._();

final class GetSavingGoalsUseCaseProvider
    extends
        $FunctionalProvider<
          GetSavingGoalsUseCase,
          GetSavingGoalsUseCase,
          GetSavingGoalsUseCase
        >
    with $Provider<GetSavingGoalsUseCase> {
  const GetSavingGoalsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getSavingGoalsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getSavingGoalsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetSavingGoalsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetSavingGoalsUseCase create(Ref ref) {
    return getSavingGoalsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetSavingGoalsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetSavingGoalsUseCase>(value),
    );
  }
}

String _$getSavingGoalsUseCaseHash() =>
    r'0525aead0101084b70819efc8b58306fd06bd938';

@ProviderFor(addContributionUseCase)
const addContributionUseCaseProvider = AddContributionUseCaseProvider._();

final class AddContributionUseCaseProvider
    extends
        $FunctionalProvider<
          AddContributionUseCase,
          AddContributionUseCase,
          AddContributionUseCase
        >
    with $Provider<AddContributionUseCase> {
  const AddContributionUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addContributionUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addContributionUseCaseHash();

  @$internal
  @override
  $ProviderElement<AddContributionUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AddContributionUseCase create(Ref ref) {
    return addContributionUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddContributionUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddContributionUseCase>(value),
    );
  }
}

String _$addContributionUseCaseHash() =>
    r'eb04b83c03ffbb85c98b350ed41b002e420d5f72';

@ProviderFor(categoryRepository)
const categoryRepositoryProvider = CategoryRepositoryProvider._();

final class CategoryRepositoryProvider
    extends
        $FunctionalProvider<
          CategoryRepository,
          CategoryRepository,
          CategoryRepository
        >
    with $Provider<CategoryRepository> {
  const CategoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryRepositoryHash();

  @$internal
  @override
  $ProviderElement<CategoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CategoryRepository create(Ref ref) {
    return categoryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoryRepository>(value),
    );
  }
}

String _$categoryRepositoryHash() =>
    r'ea2f9b89aa4534b1f6d340901c364a0ba4a14e19';

@ProviderFor(saveCategoryUseCase)
const saveCategoryUseCaseProvider = SaveCategoryUseCaseProvider._();

final class SaveCategoryUseCaseProvider
    extends
        $FunctionalProvider<
          SaveCategoryUseCase,
          SaveCategoryUseCase,
          SaveCategoryUseCase
        >
    with $Provider<SaveCategoryUseCase> {
  const SaveCategoryUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saveCategoryUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saveCategoryUseCaseHash();

  @$internal
  @override
  $ProviderElement<SaveCategoryUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SaveCategoryUseCase create(Ref ref) {
    return saveCategoryUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaveCategoryUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaveCategoryUseCase>(value),
    );
  }
}

String _$saveCategoryUseCaseHash() =>
    r'c9df54f4aa3bfc8cf852a4007a254d499e0b60b9';

@ProviderFor(deleteCategoryUseCase)
const deleteCategoryUseCaseProvider = DeleteCategoryUseCaseProvider._();

final class DeleteCategoryUseCaseProvider
    extends
        $FunctionalProvider<
          DeleteCategoryUseCase,
          DeleteCategoryUseCase,
          DeleteCategoryUseCase
        >
    with $Provider<DeleteCategoryUseCase> {
  const DeleteCategoryUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteCategoryUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteCategoryUseCaseHash();

  @$internal
  @override
  $ProviderElement<DeleteCategoryUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeleteCategoryUseCase create(Ref ref) {
    return deleteCategoryUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteCategoryUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteCategoryUseCase>(value),
    );
  }
}

String _$deleteCategoryUseCaseHash() =>
    r'35134c5968610d737615af311aef0bb6b72cefb8';

@ProviderFor(transactionRepository)
const transactionRepositoryProvider = TransactionRepositoryProvider._();

final class TransactionRepositoryProvider
    extends
        $FunctionalProvider<
          TransactionRepository,
          TransactionRepository,
          TransactionRepository
        >
    with $Provider<TransactionRepository> {
  const TransactionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionRepositoryHash();

  @$internal
  @override
  $ProviderElement<TransactionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TransactionRepository create(Ref ref) {
    return transactionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransactionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransactionRepository>(value),
    );
  }
}

String _$transactionRepositoryHash() =>
    r'a23af9866b0cd572389fc9dda4ec53ce1b09af6f';

@ProviderFor(budgetRepository)
const budgetRepositoryProvider = BudgetRepositoryProvider._();

final class BudgetRepositoryProvider
    extends
        $FunctionalProvider<
          BudgetRepository,
          BudgetRepository,
          BudgetRepository
        >
    with $Provider<BudgetRepository> {
  const BudgetRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetRepositoryHash();

  @$internal
  @override
  $ProviderElement<BudgetRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BudgetRepository create(Ref ref) {
    return budgetRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BudgetRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BudgetRepository>(value),
    );
  }
}

String _$budgetRepositoryHash() => r'04bad8edb2ea732d9f98e0e2c0bbcf28348162f3';

@ProviderFor(homeDashboardPreferencesRepository)
const homeDashboardPreferencesRepositoryProvider =
    HomeDashboardPreferencesRepositoryProvider._();

final class HomeDashboardPreferencesRepositoryProvider
    extends
        $FunctionalProvider<
          HomeDashboardPreferencesRepository,
          HomeDashboardPreferencesRepository,
          HomeDashboardPreferencesRepository
        >
    with $Provider<HomeDashboardPreferencesRepository> {
  const HomeDashboardPreferencesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeDashboardPreferencesRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$homeDashboardPreferencesRepositoryHash();

  @$internal
  @override
  $ProviderElement<HomeDashboardPreferencesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HomeDashboardPreferencesRepository create(Ref ref) {
    return homeDashboardPreferencesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeDashboardPreferencesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeDashboardPreferencesRepository>(
        value,
      ),
    );
  }
}

String _$homeDashboardPreferencesRepositoryHash() =>
    r'c155972af33f2c3b5f38f9d979afab318ef1300d';

@ProviderFor(savingGoalRepository)
const savingGoalRepositoryProvider = SavingGoalRepositoryProvider._();

final class SavingGoalRepositoryProvider
    extends
        $FunctionalProvider<
          SavingGoalRepository,
          SavingGoalRepository,
          SavingGoalRepository
        >
    with $Provider<SavingGoalRepository> {
  const SavingGoalRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savingGoalRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savingGoalRepositoryHash();

  @$internal
  @override
  $ProviderElement<SavingGoalRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SavingGoalRepository create(Ref ref) {
    return savingGoalRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SavingGoalRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SavingGoalRepository>(value),
    );
  }
}

String _$savingGoalRepositoryHash() =>
    r'3e47a9500951bec20f156762d60e1075500bbd55';

@ProviderFor(recurringTransactionsRepository)
const recurringTransactionsRepositoryProvider =
    RecurringTransactionsRepositoryProvider._();

final class RecurringTransactionsRepositoryProvider
    extends
        $FunctionalProvider<
          RecurringTransactionsRepository,
          RecurringTransactionsRepository,
          RecurringTransactionsRepository
        >
    with $Provider<RecurringTransactionsRepository> {
  const RecurringTransactionsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recurringTransactionsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recurringTransactionsRepositoryHash();

  @$internal
  @override
  $ProviderElement<RecurringTransactionsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RecurringTransactionsRepository create(Ref ref) {
    return recurringTransactionsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecurringTransactionsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecurringTransactionsRepository>(
        value,
      ),
    );
  }
}

String _$recurringTransactionsRepositoryHash() =>
    r'e72e5469061960310698932463efbb1e6e4001d5';

@ProviderFor(upcomingPaymentsRepository)
const upcomingPaymentsRepositoryProvider =
    UpcomingPaymentsRepositoryProvider._();

final class UpcomingPaymentsRepositoryProvider
    extends
        $FunctionalProvider<
          UpcomingPaymentsRepository,
          UpcomingPaymentsRepository,
          UpcomingPaymentsRepository
        >
    with $Provider<UpcomingPaymentsRepository> {
  const UpcomingPaymentsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'upcomingPaymentsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$upcomingPaymentsRepositoryHash();

  @$internal
  @override
  $ProviderElement<UpcomingPaymentsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpcomingPaymentsRepository create(Ref ref) {
    return upcomingPaymentsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpcomingPaymentsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpcomingPaymentsRepository>(value),
    );
  }
}

String _$upcomingPaymentsRepositoryHash() =>
    r'dd4f2ff37aee1aa98051a4bec1851ab979cbadc8';

@ProviderFor(paymentRemindersRepository)
const paymentRemindersRepositoryProvider =
    PaymentRemindersRepositoryProvider._();

final class PaymentRemindersRepositoryProvider
    extends
        $FunctionalProvider<
          PaymentRemindersRepository,
          PaymentRemindersRepository,
          PaymentRemindersRepository
        >
    with $Provider<PaymentRemindersRepository> {
  const PaymentRemindersRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentRemindersRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentRemindersRepositoryHash();

  @$internal
  @override
  $ProviderElement<PaymentRemindersRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PaymentRemindersRepository create(Ref ref) {
    return paymentRemindersRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaymentRemindersRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaymentRemindersRepository>(value),
    );
  }
}

String _$paymentRemindersRepositoryHash() =>
    r'f11dfdfd8a940412458eda10dd87baa73455972b';

@ProviderFor(watchAccountTransactionsUseCase)
const watchAccountTransactionsUseCaseProvider =
    WatchAccountTransactionsUseCaseProvider._();

final class WatchAccountTransactionsUseCaseProvider
    extends
        $FunctionalProvider<
          WatchAccountTransactionsUseCase,
          WatchAccountTransactionsUseCase,
          WatchAccountTransactionsUseCase
        >
    with $Provider<WatchAccountTransactionsUseCase> {
  const WatchAccountTransactionsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchAccountTransactionsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchAccountTransactionsUseCaseHash();

  @$internal
  @override
  $ProviderElement<WatchAccountTransactionsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WatchAccountTransactionsUseCase create(Ref ref) {
    return watchAccountTransactionsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WatchAccountTransactionsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WatchAccountTransactionsUseCase>(
        value,
      ),
    );
  }
}

String _$watchAccountTransactionsUseCaseHash() =>
    r'9bfa7fea3e97b0a6baf894f5a30912f8e5582211';

@ProviderFor(watchRecentTransactionsUseCase)
const watchRecentTransactionsUseCaseProvider =
    WatchRecentTransactionsUseCaseProvider._();

final class WatchRecentTransactionsUseCaseProvider
    extends
        $FunctionalProvider<
          WatchRecentTransactionsUseCase,
          WatchRecentTransactionsUseCase,
          WatchRecentTransactionsUseCase
        >
    with $Provider<WatchRecentTransactionsUseCase> {
  const WatchRecentTransactionsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchRecentTransactionsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchRecentTransactionsUseCaseHash();

  @$internal
  @override
  $ProviderElement<WatchRecentTransactionsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WatchRecentTransactionsUseCase create(Ref ref) {
    return watchRecentTransactionsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WatchRecentTransactionsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WatchRecentTransactionsUseCase>(
        value,
      ),
    );
  }
}

String _$watchRecentTransactionsUseCaseHash() =>
    r'b8f01a6912efa1d95b04dd015e398b978beee58e';

@ProviderFor(watchMonthlyAnalyticsUseCase)
const watchMonthlyAnalyticsUseCaseProvider =
    WatchMonthlyAnalyticsUseCaseProvider._();

final class WatchMonthlyAnalyticsUseCaseProvider
    extends
        $FunctionalProvider<
          WatchMonthlyAnalyticsUseCase,
          WatchMonthlyAnalyticsUseCase,
          WatchMonthlyAnalyticsUseCase
        >
    with $Provider<WatchMonthlyAnalyticsUseCase> {
  const WatchMonthlyAnalyticsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchMonthlyAnalyticsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchMonthlyAnalyticsUseCaseHash();

  @$internal
  @override
  $ProviderElement<WatchMonthlyAnalyticsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WatchMonthlyAnalyticsUseCase create(Ref ref) {
    return watchMonthlyAnalyticsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WatchMonthlyAnalyticsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WatchMonthlyAnalyticsUseCase>(value),
    );
  }
}

String _$watchMonthlyAnalyticsUseCaseHash() =>
    r'f1d7c52a9a4fc256b1bd3ae0fff4e7e8666f58e9';

@ProviderFor(groupTransactionsByDayUseCase)
const groupTransactionsByDayUseCaseProvider =
    GroupTransactionsByDayUseCaseProvider._();

final class GroupTransactionsByDayUseCaseProvider
    extends
        $FunctionalProvider<
          GroupTransactionsByDayUseCase,
          GroupTransactionsByDayUseCase,
          GroupTransactionsByDayUseCase
        >
    with $Provider<GroupTransactionsByDayUseCase> {
  const GroupTransactionsByDayUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groupTransactionsByDayUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groupTransactionsByDayUseCaseHash();

  @$internal
  @override
  $ProviderElement<GroupTransactionsByDayUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GroupTransactionsByDayUseCase create(Ref ref) {
    return groupTransactionsByDayUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GroupTransactionsByDayUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GroupTransactionsByDayUseCase>(
        value,
      ),
    );
  }
}

String _$groupTransactionsByDayUseCaseHash() =>
    r'7a51339f0bbe69d564577c72d1f5eb9c846f63aa';

@ProviderFor(getAiFinancialOverviewUseCase)
const getAiFinancialOverviewUseCaseProvider =
    GetAiFinancialOverviewUseCaseProvider._();

final class GetAiFinancialOverviewUseCaseProvider
    extends
        $FunctionalProvider<
          GetAiFinancialOverviewUseCase,
          GetAiFinancialOverviewUseCase,
          GetAiFinancialOverviewUseCase
        >
    with $Provider<GetAiFinancialOverviewUseCase> {
  const GetAiFinancialOverviewUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getAiFinancialOverviewUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getAiFinancialOverviewUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetAiFinancialOverviewUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetAiFinancialOverviewUseCase create(Ref ref) {
    return getAiFinancialOverviewUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetAiFinancialOverviewUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetAiFinancialOverviewUseCase>(
        value,
      ),
    );
  }
}

String _$getAiFinancialOverviewUseCaseHash() =>
    r'81511f3d718a7e3ccd3f8f418a41e3f0eccc19ec';

@ProviderFor(watchAiFinancialOverviewUseCase)
const watchAiFinancialOverviewUseCaseProvider =
    WatchAiFinancialOverviewUseCaseProvider._();

final class WatchAiFinancialOverviewUseCaseProvider
    extends
        $FunctionalProvider<
          WatchAiFinancialOverviewUseCase,
          WatchAiFinancialOverviewUseCase,
          WatchAiFinancialOverviewUseCase
        >
    with $Provider<WatchAiFinancialOverviewUseCase> {
  const WatchAiFinancialOverviewUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchAiFinancialOverviewUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchAiFinancialOverviewUseCaseHash();

  @$internal
  @override
  $ProviderElement<WatchAiFinancialOverviewUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WatchAiFinancialOverviewUseCase create(Ref ref) {
    return watchAiFinancialOverviewUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WatchAiFinancialOverviewUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WatchAiFinancialOverviewUseCase>(
        value,
      ),
    );
  }
}

String _$watchAiFinancialOverviewUseCaseHash() =>
    r'aa3d9d11ec58dba0bbd9b92cc97a249ff9c12e95';

@ProviderFor(watchRecurringRulesUseCase)
const watchRecurringRulesUseCaseProvider =
    WatchRecurringRulesUseCaseProvider._();

final class WatchRecurringRulesUseCaseProvider
    extends
        $FunctionalProvider<
          WatchRecurringRulesUseCase,
          WatchRecurringRulesUseCase,
          WatchRecurringRulesUseCase
        >
    with $Provider<WatchRecurringRulesUseCase> {
  const WatchRecurringRulesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchRecurringRulesUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchRecurringRulesUseCaseHash();

  @$internal
  @override
  $ProviderElement<WatchRecurringRulesUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WatchRecurringRulesUseCase create(Ref ref) {
    return watchRecurringRulesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WatchRecurringRulesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WatchRecurringRulesUseCase>(value),
    );
  }
}

String _$watchRecurringRulesUseCaseHash() =>
    r'9cb754ec24ae0c6d8f780d6ebee2f1541b3a42a6';

@ProviderFor(watchUpcomingPaymentsUseCase)
const watchUpcomingPaymentsUseCaseProvider =
    WatchUpcomingPaymentsUseCaseProvider._();

final class WatchUpcomingPaymentsUseCaseProvider
    extends
        $FunctionalProvider<
          WatchUpcomingPaymentsUseCase,
          WatchUpcomingPaymentsUseCase,
          WatchUpcomingPaymentsUseCase
        >
    with $Provider<WatchUpcomingPaymentsUseCase> {
  const WatchUpcomingPaymentsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchUpcomingPaymentsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchUpcomingPaymentsUseCaseHash();

  @$internal
  @override
  $ProviderElement<WatchUpcomingPaymentsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WatchUpcomingPaymentsUseCase create(Ref ref) {
    return watchUpcomingPaymentsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WatchUpcomingPaymentsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WatchUpcomingPaymentsUseCase>(value),
    );
  }
}

String _$watchUpcomingPaymentsUseCaseHash() =>
    r'ad5834fc7c603e34c587e2c1ca8a56a454851bca';

@ProviderFor(watchUpcomingOccurrencesUseCase)
const watchUpcomingOccurrencesUseCaseProvider =
    WatchUpcomingOccurrencesUseCaseProvider._();

final class WatchUpcomingOccurrencesUseCaseProvider
    extends
        $FunctionalProvider<
          WatchUpcomingOccurrencesUseCase,
          WatchUpcomingOccurrencesUseCase,
          WatchUpcomingOccurrencesUseCase
        >
    with $Provider<WatchUpcomingOccurrencesUseCase> {
  const WatchUpcomingOccurrencesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchUpcomingOccurrencesUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchUpcomingOccurrencesUseCaseHash();

  @$internal
  @override
  $ProviderElement<WatchUpcomingOccurrencesUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WatchUpcomingOccurrencesUseCase create(Ref ref) {
    return watchUpcomingOccurrencesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WatchUpcomingOccurrencesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WatchUpcomingOccurrencesUseCase>(
        value,
      ),
    );
  }
}

String _$watchUpcomingOccurrencesUseCaseHash() =>
    r'19f730a003788f792fb58d296f233536fdba9da7';

@ProviderFor(saveRecurringRuleUseCase)
const saveRecurringRuleUseCaseProvider = SaveRecurringRuleUseCaseProvider._();

final class SaveRecurringRuleUseCaseProvider
    extends
        $FunctionalProvider<
          SaveRecurringRuleUseCase,
          SaveRecurringRuleUseCase,
          SaveRecurringRuleUseCase
        >
    with $Provider<SaveRecurringRuleUseCase> {
  const SaveRecurringRuleUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saveRecurringRuleUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saveRecurringRuleUseCaseHash();

  @$internal
  @override
  $ProviderElement<SaveRecurringRuleUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SaveRecurringRuleUseCase create(Ref ref) {
    return saveRecurringRuleUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaveRecurringRuleUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaveRecurringRuleUseCase>(value),
    );
  }
}

String _$saveRecurringRuleUseCaseHash() =>
    r'31453a9183048468b64f4a5241ff547c50fcb185';

@ProviderFor(deleteRecurringRuleUseCase)
const deleteRecurringRuleUseCaseProvider =
    DeleteRecurringRuleUseCaseProvider._();

final class DeleteRecurringRuleUseCaseProvider
    extends
        $FunctionalProvider<
          DeleteRecurringRuleUseCase,
          DeleteRecurringRuleUseCase,
          DeleteRecurringRuleUseCase
        >
    with $Provider<DeleteRecurringRuleUseCase> {
  const DeleteRecurringRuleUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteRecurringRuleUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteRecurringRuleUseCaseHash();

  @$internal
  @override
  $ProviderElement<DeleteRecurringRuleUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeleteRecurringRuleUseCase create(Ref ref) {
    return deleteRecurringRuleUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteRecurringRuleUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteRecurringRuleUseCase>(value),
    );
  }
}

String _$deleteRecurringRuleUseCaseHash() =>
    r'f0e6197890075b16f2babaaafa0340dbed2309d5';

@ProviderFor(toggleRecurringRuleUseCase)
const toggleRecurringRuleUseCaseProvider =
    ToggleRecurringRuleUseCaseProvider._();

final class ToggleRecurringRuleUseCaseProvider
    extends
        $FunctionalProvider<
          ToggleRecurringRuleUseCase,
          ToggleRecurringRuleUseCase,
          ToggleRecurringRuleUseCase
        >
    with $Provider<ToggleRecurringRuleUseCase> {
  const ToggleRecurringRuleUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'toggleRecurringRuleUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$toggleRecurringRuleUseCaseHash();

  @$internal
  @override
  $ProviderElement<ToggleRecurringRuleUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ToggleRecurringRuleUseCase create(Ref ref) {
    return toggleRecurringRuleUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ToggleRecurringRuleUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ToggleRecurringRuleUseCase>(value),
    );
  }
}

String _$toggleRecurringRuleUseCaseHash() =>
    r'e5f319d11a98dcc7e78da1c2f27a5dbc635a9b82';

@ProviderFor(regenerateRuleWindowUseCase)
const regenerateRuleWindowUseCaseProvider =
    RegenerateRuleWindowUseCaseProvider._();

final class RegenerateRuleWindowUseCaseProvider
    extends
        $FunctionalProvider<
          RegenerateRuleWindowUseCase,
          RegenerateRuleWindowUseCase,
          RegenerateRuleWindowUseCase
        >
    with $Provider<RegenerateRuleWindowUseCase> {
  const RegenerateRuleWindowUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'regenerateRuleWindowUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$regenerateRuleWindowUseCaseHash();

  @$internal
  @override
  $ProviderElement<RegenerateRuleWindowUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RegenerateRuleWindowUseCase create(Ref ref) {
    return regenerateRuleWindowUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RegenerateRuleWindowUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RegenerateRuleWindowUseCase>(value),
    );
  }
}

String _$regenerateRuleWindowUseCaseHash() =>
    r'b2d6210dffdbeeb1d866fcf550d576a5cdb0d6aa';

@ProviderFor(recurringWindowService)
const recurringWindowServiceProvider = RecurringWindowServiceProvider._();

final class RecurringWindowServiceProvider
    extends
        $FunctionalProvider<
          RecurringWindowService,
          RecurringWindowService,
          RecurringWindowService
        >
    with $Provider<RecurringWindowService> {
  const RecurringWindowServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recurringWindowServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recurringWindowServiceHash();

  @$internal
  @override
  $ProviderElement<RecurringWindowService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RecurringWindowService create(Ref ref) {
    return recurringWindowService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecurringWindowService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecurringWindowService>(value),
    );
  }
}

String _$recurringWindowServiceHash() =>
    r'ae1478fae0a0f90c6986c556f9bcb19e19ab5f30';

@ProviderFor(recurringWorkScheduler)
const recurringWorkSchedulerProvider = RecurringWorkSchedulerProvider._();

final class RecurringWorkSchedulerProvider
    extends
        $FunctionalProvider<
          RecurringWorkScheduler,
          RecurringWorkScheduler,
          RecurringWorkScheduler
        >
    with $Provider<RecurringWorkScheduler> {
  const RecurringWorkSchedulerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recurringWorkSchedulerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recurringWorkSchedulerHash();

  @$internal
  @override
  $ProviderElement<RecurringWorkScheduler> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RecurringWorkScheduler create(Ref ref) {
    return recurringWorkScheduler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecurringWorkScheduler value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecurringWorkScheduler>(value),
    );
  }
}

String _$recurringWorkSchedulerHash() =>
    r'6f722883d3cc59bd7ee82be79b0ceffa9386aca9';

@ProviderFor(exactAlarmPermissionService)
const exactAlarmPermissionServiceProvider =
    ExactAlarmPermissionServiceProvider._();

final class ExactAlarmPermissionServiceProvider
    extends
        $FunctionalProvider<
          ExactAlarmPermissionService,
          ExactAlarmPermissionService,
          ExactAlarmPermissionService
        >
    with $Provider<ExactAlarmPermissionService> {
  const ExactAlarmPermissionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exactAlarmPermissionServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exactAlarmPermissionServiceHash();

  @$internal
  @override
  $ProviderElement<ExactAlarmPermissionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ExactAlarmPermissionService create(Ref ref) {
    return exactAlarmPermissionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExactAlarmPermissionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExactAlarmPermissionService>(value),
    );
  }
}

String _$exactAlarmPermissionServiceHash() =>
    r'e8e6b22ef0ae997d27dfb94299d65f3c12ef94a1';

@ProviderFor(profileRepository)
const profileRepositoryProvider = ProfileRepositoryProvider._();

final class ProfileRepositoryProvider
    extends
        $FunctionalProvider<
          ProfileRepository,
          ProfileRepository,
          ProfileRepository
        >
    with $Provider<ProfileRepository> {
  const ProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProfileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProfileRepository create(Ref ref) {
    return profileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileRepository>(value),
    );
  }
}

String _$profileRepositoryHash() => r'50349dac8ba8e300957ef12232c08d9febe5ec97';

@ProviderFor(profileAvatarRepository)
const profileAvatarRepositoryProvider = ProfileAvatarRepositoryProvider._();

final class ProfileAvatarRepositoryProvider
    extends
        $FunctionalProvider<
          ProfileAvatarRepository,
          ProfileAvatarRepository,
          ProfileAvatarRepository
        >
    with $Provider<ProfileAvatarRepository> {
  const ProfileAvatarRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileAvatarRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileAvatarRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProfileAvatarRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProfileAvatarRepository create(Ref ref) {
    return profileAvatarRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileAvatarRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileAvatarRepository>(value),
    );
  }
}

String _$profileAvatarRepositoryHash() =>
    r'539f637f58f3297d5d3067de950ce44eabbf6a6f';

@ProviderFor(userProgressRepository)
const userProgressRepositoryProvider = UserProgressRepositoryProvider._();

final class UserProgressRepositoryProvider
    extends
        $FunctionalProvider<
          UserProgressRepository,
          UserProgressRepository,
          UserProgressRepository
        >
    with $Provider<UserProgressRepository> {
  const UserProgressRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userProgressRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userProgressRepositoryHash();

  @$internal
  @override
  $ProviderElement<UserProgressRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UserProgressRepository create(Ref ref) {
    return userProgressRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserProgressRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserProgressRepository>(value),
    );
  }
}

String _$userProgressRepositoryHash() =>
    r'27ecf4905dc13c7c3c31285e5b659c5eb236a8f8';

@ProviderFor(updateProfileUseCase)
const updateProfileUseCaseProvider = UpdateProfileUseCaseProvider._();

final class UpdateProfileUseCaseProvider
    extends
        $FunctionalProvider<
          UpdateProfileUseCase,
          UpdateProfileUseCase,
          UpdateProfileUseCase
        >
    with $Provider<UpdateProfileUseCase> {
  const UpdateProfileUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateProfileUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateProfileUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdateProfileUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpdateProfileUseCase create(Ref ref) {
    return updateProfileUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateProfileUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateProfileUseCase>(value),
    );
  }
}

String _$updateProfileUseCaseHash() =>
    r'df5b968b7d1366622eb17431ae0e2f17bee33f27';

@ProviderFor(recomputeUserProgressUseCase)
const recomputeUserProgressUseCaseProvider =
    RecomputeUserProgressUseCaseProvider._();

final class RecomputeUserProgressUseCaseProvider
    extends
        $FunctionalProvider<
          RecomputeUserProgressUseCase,
          RecomputeUserProgressUseCase,
          RecomputeUserProgressUseCase
        >
    with $Provider<RecomputeUserProgressUseCase> {
  const RecomputeUserProgressUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recomputeUserProgressUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recomputeUserProgressUseCaseHash();

  @$internal
  @override
  $ProviderElement<RecomputeUserProgressUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RecomputeUserProgressUseCase create(Ref ref) {
    return recomputeUserProgressUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecomputeUserProgressUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecomputeUserProgressUseCase>(value),
    );
  }
}

String _$recomputeUserProgressUseCaseHash() =>
    r'351f72a8ecfdd69a2709660e08779b3681970718';

@ProviderFor(onTransactionCreatedUseCase)
const onTransactionCreatedUseCaseProvider =
    OnTransactionCreatedUseCaseProvider._();

final class OnTransactionCreatedUseCaseProvider
    extends
        $FunctionalProvider<
          OnTransactionCreatedUseCase,
          OnTransactionCreatedUseCase,
          OnTransactionCreatedUseCase
        >
    with $Provider<OnTransactionCreatedUseCase> {
  const OnTransactionCreatedUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onTransactionCreatedUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onTransactionCreatedUseCaseHash();

  @$internal
  @override
  $ProviderElement<OnTransactionCreatedUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OnTransactionCreatedUseCase create(Ref ref) {
    return onTransactionCreatedUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnTransactionCreatedUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnTransactionCreatedUseCase>(value),
    );
  }
}

String _$onTransactionCreatedUseCaseHash() =>
    r'60e379acfa755ba8d782045d31577f39c7bef68d';

@ProviderFor(onTransactionDeletedUseCase)
const onTransactionDeletedUseCaseProvider =
    OnTransactionDeletedUseCaseProvider._();

final class OnTransactionDeletedUseCaseProvider
    extends
        $FunctionalProvider<
          OnTransactionDeletedUseCase,
          OnTransactionDeletedUseCase,
          OnTransactionDeletedUseCase
        >
    with $Provider<OnTransactionDeletedUseCase> {
  const OnTransactionDeletedUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onTransactionDeletedUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onTransactionDeletedUseCaseHash();

  @$internal
  @override
  $ProviderElement<OnTransactionDeletedUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OnTransactionDeletedUseCase create(Ref ref) {
    return onTransactionDeletedUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnTransactionDeletedUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnTransactionDeletedUseCase>(value),
    );
  }
}

String _$onTransactionDeletedUseCaseHash() =>
    r'34dc92ca2db0124451716e5cd2aa0ab9525d96bf';

@ProviderFor(updateProfileAvatarUseCase)
const updateProfileAvatarUseCaseProvider =
    UpdateProfileAvatarUseCaseProvider._();

final class UpdateProfileAvatarUseCaseProvider
    extends
        $FunctionalProvider<
          UpdateProfileAvatarUseCase,
          UpdateProfileAvatarUseCase,
          UpdateProfileAvatarUseCase
        >
    with $Provider<UpdateProfileAvatarUseCase> {
  const UpdateProfileAvatarUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateProfileAvatarUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateProfileAvatarUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdateProfileAvatarUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpdateProfileAvatarUseCase create(Ref ref) {
    return updateProfileAvatarUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateProfileAvatarUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateProfileAvatarUseCase>(value),
    );
  }
}

String _$updateProfileAvatarUseCaseHash() =>
    r'bfe251b0b5b2e8b23cd482675f08eb3bbf1f9f84';

@ProviderFor(syncService)
const syncServiceProvider = SyncServiceProvider._();

final class SyncServiceProvider
    extends $FunctionalProvider<SyncService, SyncService, SyncService>
    with $Provider<SyncService> {
  const SyncServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncServiceHash();

  @$internal
  @override
  $ProviderElement<SyncService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncService create(Ref ref) {
    return syncService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncService>(value),
    );
  }
}

String _$syncServiceHash() => r'1c5a44db41601ecaa14ed9f79b980d42eff82db7';

@ProviderFor(authRepository)
const authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  const AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'7c64f3ffafdd910af07c1c9cfd72a9550534f646';

@ProviderFor(authSyncService)
const authSyncServiceProvider = AuthSyncServiceProvider._();

final class AuthSyncServiceProvider
    extends
        $FunctionalProvider<AuthSyncService, AuthSyncService, AuthSyncService>
    with $Provider<AuthSyncService> {
  const AuthSyncServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authSyncServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authSyncServiceHash();

  @$internal
  @override
  $ProviderElement<AuthSyncService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthSyncService create(Ref ref) {
    return authSyncService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthSyncService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthSyncService>(value),
    );
  }
}

String _$authSyncServiceHash() => r'b6233bcc0f00471b7b3510b51b18bcb0f1206c1a';
