import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/sign_in_request.dart';
import 'package:kopim/features/profile/domain/failures/auth_failure.dart';
import 'package:kopim/features/profile/domain/repositories/auth_repository.dart';
import 'package:kopim/features/profile/domain/repositories/user_account_cleanup_repository.dart';

class DeleteUserAccountUseCase {
  DeleteUserAccountUseCase({
    required AuthRepository authRepository,
    required UserAccountCleanupRepository cleanupRepository,
  }) : _authRepository = authRepository,
       _cleanupRepository = cleanupRepository;

  final AuthRepository _authRepository;
  final UserAccountCleanupRepository _cleanupRepository;

  Future<void> call({required String currentPassword}) async {
    final AuthUser? authUser = _authRepository.currentUser;
    if (authUser == null || authUser.isAnonymous || authUser.email == null) {
      throw const AuthFailure(
        code: 'no-current-user',
        message: 'Нет активной учетной записи для удаления.',
      );
    }

    await _authRepository.reauthenticate(
      SignInRequest.email(email: authUser.email!, password: currentPassword),
    );
    await _cleanupRepository.deleteRemoteUserData(authUser.uid);
    await _authRepository.deleteCurrentUser();
    await _cleanupRepository.deleteLocalUserData();
  }
}
