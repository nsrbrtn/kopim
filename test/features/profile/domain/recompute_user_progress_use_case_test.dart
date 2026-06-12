import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/user_progress.dart';
import 'package:kopim/features/profile/domain/models/profile_command_result.dart';
import 'package:kopim/features/profile/domain/policies/level_policy.dart';
import 'package:kopim/features/profile/domain/repositories/auth_repository.dart';
import 'package:kopim/features/profile/domain/repositories/user_progress_repository.dart';
import 'package:kopim/features/profile/domain/services/profile_sync_error_reporter.dart';
import 'package:kopim/features/profile/domain/usecases/recompute_user_progress_use_case.dart';
import 'package:mocktail/mocktail.dart';

class _MockUserProgressRepository extends Mock
    implements UserProgressRepository {}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockProfileSyncErrorReporter extends Mock
    implements ProfileSyncErrorReporter {}

void main() {
  late _MockUserProgressRepository repository;
  late _MockAuthRepository authRepository;
  late _MockProfileSyncErrorReporter errorReporter;
  late RecomputeUserProgressUseCase useCase;

  final DateTime now = DateTime.utc(2024, 6, 12, 10, 0);
  const AuthUser signedInUser = AuthUser(
    uid: 'user-1',
    isAnonymous: false,
    emailVerified: true,
  );

  setUpAll(() {
    registerFallbackValue(
      UserProgress(
        totalTx: 0,
        level: 1,
        title: 'Уровень 1',
        nextThreshold: 100,
        updatedAt: DateTime.utc(2024, 1, 1),
      ),
    );
    registerFallbackValue(StackTrace.empty);
  });

  setUp(() {
    repository = _MockUserProgressRepository();
    authRepository = _MockAuthRepository();
    errorReporter = _MockProfileSyncErrorReporter();
    useCase = RecomputeUserProgressUseCase(
      repository: repository,
      levelPolicy: const SimpleLevelPolicy(),
      authRepository: authRepository,
      syncErrorReporter: errorReporter,
      clock: () => now,
    );

    when(() => repository.cacheProgress(any())).thenAnswer((_) async {});
    when(() => repository.countTransactions()).thenAnswer((_) async => 7);
    when(
      () => repository.fetchRemoteProgress(any()),
    ).thenAnswer((_) async => null);
    when(
      () => repository.saveRemoteProgress(
        uid: any(named: 'uid'),
        totalTx: any(named: 'totalTx'),
        updatedAt: any(named: 'updatedAt'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => errorReporter.reportProgressSyncError(
        uid: any(named: 'uid'),
        error: any(named: 'error'),
        stackTrace: any(named: 'stackTrace'),
      ),
    ).thenReturn(null);
  });

  test('recomputes local derived progress from transaction count', () async {
    when(() => authRepository.currentUser).thenReturn(null);

    final ProfileCommandResult<UserProgress> result = await useCase();

    expect(result.value.totalTx, 7);
    expect(result.value.level, 1);
    expect(result.value.title, 'Уровень 1');
    expect(result.value.nextThreshold, 100);
    expect(result.value.updatedAt, now);
    verify(() => repository.cacheProgress(result.value)).called(1);
    verifyNever(() => repository.fetchRemoteProgress(any()));
    verifyNever(
      () => repository.saveRemoteProgress(
        uid: any(named: 'uid'),
        totalTx: any(named: 'totalTx'),
        updatedAt: any(named: 'updatedAt'),
      ),
    );
  });

  test('uses remote progress only as best-effort max counter', () async {
    when(() => authRepository.currentUser).thenReturn(signedInUser);
    when(() => repository.fetchRemoteProgress(signedInUser.uid)).thenAnswer(
      (_) async =>
          ProgressSnapshot(totalTx: 11, updatedAt: DateTime.utc(2024, 6, 1)),
    );

    final ProfileCommandResult<UserProgress> result = await useCase();
    await Future<void>.delayed(Duration.zero);

    expect(result.value.totalTx, 7);
    verify(() => repository.cacheProgress(result.value)).called(1);
    verify(() => repository.fetchRemoteProgress(signedInUser.uid)).called(1);
    verifyNever(
      () => repository.saveRemoteProgress(
        uid: any(named: 'uid'),
        totalTx: any(named: 'totalTx'),
        updatedAt: any(named: 'updatedAt'),
      ),
    );
  });

  test(
    'does not overwrite remote counter with smaller local derived value',
    () async {
      when(() => authRepository.currentUser).thenReturn(signedInUser);
      when(() => repository.fetchRemoteProgress(signedInUser.uid)).thenAnswer(
        (_) async =>
            ProgressSnapshot(totalTx: 7, updatedAt: DateTime.utc(2024, 6, 1)),
      );

      await useCase();
      await Future<void>.delayed(Duration.zero);

      verify(() => repository.fetchRemoteProgress(signedInUser.uid)).called(1);
      verifyNever(
        () => repository.saveRemoteProgress(
          uid: any(named: 'uid'),
          totalTx: any(named: 'totalTx'),
          updatedAt: any(named: 'updatedAt'),
        ),
      );
    },
  );
}
