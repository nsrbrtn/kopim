import 'package:kopim/core/di/injectors.dart';
import 'package:flutter/foundation.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/domain/models/profile_command_result.dart';
import 'package:kopim/features/profile/domain/usecases/update_profile_use_case.dart';
import 'package:kopim/features/profile/presentation/services/profile_event_recorder.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_form_controller.g.dart';

@immutable
class ProfileFormParams {
  const ProfileFormParams({required this.uid, required this.profile});

  final String uid;
  final Profile? profile;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ProfileFormParams &&
            other.uid == uid &&
            other.profile == profile;
  }

  @override
  int get hashCode => Object.hash(uid, profile);
}

class ProfileFormState {
  const ProfileFormState({
    required this.uid,
    required this.name,
    required this.currency,
    required this.locale,
    this.photoUrl,
    required this.isSaving,
    this.errorMessage,
    this.initialProfile,
  });

  factory ProfileFormState.fromProfile(String uid, Profile? profile) {
    final Profile base =
        profile ??
        Profile(
          uid: uid,
          name: '',
          currency: ProfileCurrency.rub,
          locale: 'en',
          photoUrl: null,
          updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
        );
    return ProfileFormState(
      uid: base.uid,
      name: base.name,
      currency: base.currency,
      locale: base.locale,
      photoUrl: base.photoUrl,
      isSaving: false,
      initialProfile: base,
    );
  }

  final String uid;
  final String name;
  final ProfileCurrency currency;
  final String locale;
  final String? photoUrl;
  final bool isSaving;
  final String? errorMessage;
  final Profile? initialProfile;

  bool get hasChanges {
    final Profile base =
        initialProfile ??
        Profile(
          uid: uid,
          name: '',
          currency: ProfileCurrency.rub,
          locale: 'en',
          photoUrl: null,
          updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
        );
    return name != base.name ||
        currency != base.currency ||
        locale != base.locale;
  }

  ProfileFormState copyWith({
    String? name,
    ProfileCurrency? currency,
    String? locale,
    String? photoUrl,
    bool? isSaving,
    Profile? initialProfile,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProfileFormState(
      uid: uid,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      locale: locale ?? this.locale,
      photoUrl: photoUrl ?? this.photoUrl,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      initialProfile: initialProfile ?? this.initialProfile,
    );
  }

  Profile toProfile() {
    return Profile(
      uid: uid,
      name: name,
      currency: currency,
      locale: locale,
      photoUrl: photoUrl,
      updatedAt: DateTime.now().toUtc(),
    );
  }
}

@riverpod
class ProfileFormController extends _$ProfileFormController {
  late final UpdateProfileUseCase _updateProfileUseCase;
  late final ProfileEventRecorder _eventRecorder;

  @override
  ProfileFormState build(ProfileFormParams params) {
    _updateProfileUseCase = ref.watch(updateProfileUseCaseProvider);
    _eventRecorder = ref.watch(profileEventRecorderProvider);
    return ProfileFormState.fromProfile(params.uid, params.profile);
  }

  void updateName(String value) {
    state = state.copyWith(name: value, clearError: true);
  }

  void updateCurrency(ProfileCurrency value) {
    state = state.copyWith(currency: value, clearError: true);
  }

  void updateLocale(String value) {
    state = state.copyWith(locale: value, clearError: true);
  }

  Future<void> submit() async {
    if (state.isSaving) return;
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final ProfileCommandResult<Profile> result = await _updateProfileUseCase(
        state.toProfile(),
      );
      await _eventRecorder.record(result.events);
      final Profile stored = result.value;
      state = state.copyWith(
        isSaving: false,
        initialProfile: stored,
        name: stored.name,
        currency: stored.currency,
        locale: stored.locale,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(isSaving: false, errorMessage: error.toString());
    }
  }
}
