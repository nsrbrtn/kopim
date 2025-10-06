// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_progress_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userProgress)
const userProgressProvider = UserProgressFamily._();

final class UserProgressProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserProgress>,
          UserProgress,
          Stream<UserProgress>
        >
    with $FutureModifier<UserProgress>, $StreamProvider<UserProgress> {
  const UserProgressProvider._({
    required UserProgressFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userProgressProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userProgressHash();

  @override
  String toString() {
    return r'userProgressProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<UserProgress> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<UserProgress> create(Ref ref) {
    final argument = this.argument as String;
    return userProgress(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserProgressProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userProgressHash() => r'f7e56ecaddd4d85170bfc4ccfd43f702f0984668';

final class UserProgressFamily extends $Family
    with $FunctionalFamilyOverride<Stream<UserProgress>, String> {
  const UserProgressFamily._()
    : super(
        retry: null,
        name: r'userProgressProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UserProgressProvider call(String uid) =>
      UserProgressProvider._(argument: uid, from: this);

  @override
  String toString() => r'userProgressProvider';
}
