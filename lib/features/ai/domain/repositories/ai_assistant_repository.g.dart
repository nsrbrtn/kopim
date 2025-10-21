// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_assistant_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Провайдер, который должен быть переопределён конкретной реализацией репозитория.

@ProviderFor(aiAssistantRepository)
const aiAssistantRepositoryProvider = AiAssistantRepositoryProvider._();

/// Провайдер, который должен быть переопределён конкретной реализацией репозитория.

final class AiAssistantRepositoryProvider
    extends
        $FunctionalProvider<
          AiAssistantRepository,
          AiAssistantRepository,
          AiAssistantRepository
        >
    with $Provider<AiAssistantRepository> {
  /// Провайдер, который должен быть переопределён конкретной реализацией репозитория.
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
    r'e5fe154b3049bca8b9ee02ed1d00341fe88cf568';
