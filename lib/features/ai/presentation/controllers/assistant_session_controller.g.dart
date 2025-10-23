// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_session_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AssistantSessionController)
const assistantSessionControllerProvider =
    AssistantSessionControllerProvider._();

final class AssistantSessionControllerProvider
    extends
        $NotifierProvider<AssistantSessionController, AssistantSessionState> {
  const AssistantSessionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assistantSessionControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assistantSessionControllerHash();

  @$internal
  @override
  AssistantSessionController create() => AssistantSessionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AssistantSessionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AssistantSessionState>(value),
    );
  }
}

String _$assistantSessionControllerHash() =>
    r'609c51ffa2044845a29400133f536774148a7a71';

abstract class _$AssistantSessionController
    extends $Notifier<AssistantSessionState> {
  AssistantSessionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AssistantSessionState, AssistantSessionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AssistantSessionState, AssistantSessionState>,
              AssistantSessionState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
