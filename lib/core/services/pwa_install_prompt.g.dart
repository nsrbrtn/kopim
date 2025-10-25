// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pwa_install_prompt.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PwaInstallPromptController)
const pwaInstallPromptControllerProvider =
    PwaInstallPromptControllerProvider._();

final class PwaInstallPromptControllerProvider
    extends
        $NotifierProvider<PwaInstallPromptController, PwaInstallPromptState> {
  const PwaInstallPromptControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pwaInstallPromptControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pwaInstallPromptControllerHash();

  @$internal
  @override
  PwaInstallPromptController create() => PwaInstallPromptController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PwaInstallPromptState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PwaInstallPromptState>(value),
    );
  }
}

String _$pwaInstallPromptControllerHash() =>
    r'eb7037a2b6e53fb51d5f7a5a1a5d68565ca06e57';

abstract class _$PwaInstallPromptController
    extends $Notifier<PwaInstallPromptState> {
  PwaInstallPromptState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<PwaInstallPromptState, PwaInstallPromptState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PwaInstallPromptState, PwaInstallPromptState>,
              PwaInstallPromptState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
