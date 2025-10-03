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

String _$analyticsServiceHash() => r'4928fb3ed712b41230dcf79231ab61cb4da3f83d';

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

@ProviderFor(googleSignIn)
const googleSignInProvider = GoogleSignInProvider._();

final class GoogleSignInProvider
    extends $FunctionalProvider<GoogleSignIn, GoogleSignIn, GoogleSignIn>
    with $Provider<GoogleSignIn> {
  const GoogleSignInProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'googleSignInProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$googleSignInHash();

  @$internal
  @override
  $ProviderElement<GoogleSignIn> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoogleSignIn create(Ref ref) {
    return googleSignIn(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoogleSignIn value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoogleSignIn>(value),
    );
  }
}

String _$googleSignInHash() => r'16cf38da6ba66b02462d5ad518f809a45382089f';

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
        isAutoDispose: true,
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

String _$appDatabaseHash() => r'd45cc0b6c7795466b6a12d864805fefa097f39cd';

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

@ProviderFor(flutterLocalNotificationsPlugin)
const flutterLocalNotificationsPluginProvider =
    FlutterLocalNotificationsPluginProvider._();

final class FlutterLocalNotificationsPluginProvider
    extends
        $FunctionalProvider<
          FlutterLocalNotificationsPlugin,
          FlutterLocalNotificationsPlugin,
          FlutterLocalNotificationsPlugin
        >
    with $Provider<FlutterLocalNotificationsPlugin> {
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
  $ProviderElement<FlutterLocalNotificationsPlugin> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FlutterLocalNotificationsPlugin create(Ref ref) {
    return flutterLocalNotificationsPlugin(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FlutterLocalNotificationsPlugin value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FlutterLocalNotificationsPlugin>(
        value,
      ),
    );
  }
}

String _$flutterLocalNotificationsPluginHash() =>
    r'270976c2447345deefd91efb7ccfc64878e707f4';

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

@ProviderFor(recurringNotificationService)
const recurringNotificationServiceProvider =
    RecurringNotificationServiceProvider._();

final class RecurringNotificationServiceProvider
    extends
        $FunctionalProvider<
          RecurringNotificationService,
          RecurringNotificationService,
          RecurringNotificationService
        >
    with $Provider<RecurringNotificationService> {
  const RecurringNotificationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recurringNotificationServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recurringNotificationServiceHash();

  @$internal
  @override
  $ProviderElement<RecurringNotificationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RecurringNotificationService create(Ref ref) {
    return recurringNotificationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecurringNotificationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecurringNotificationService>(value),
    );
  }
}

String _$recurringNotificationServiceHash() =>
    r'9c3e7734b39e24acdb8e7b72c6414d5a29ec3564';

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
    r'3799c3525d6954f2ece515445c06171d0fba71ef';

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
    r'a537392d0484d7b3922a92f905ced3e6a3cbb7ec';

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
    r'66de8c0084f13ae4fb53f7a45cc0135d21c42738';

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
    r'd74ce3d07b58943fffafbe929e3577de776b45bd';

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
    r'9a588af407d61e02f7c35d5e0ec46c115704d472';

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

String _$syncServiceHash() => r'3b1f8d33016de3a04b4396c8857479d15fdb495a';

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

String _$authRepositoryHash() => r'7e797d65e0d39b813e59519dbc4634a54af22860';

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

String _$authSyncServiceHash() => r'a53d963aa290c2c23d1410c64da95d4089173caa';
