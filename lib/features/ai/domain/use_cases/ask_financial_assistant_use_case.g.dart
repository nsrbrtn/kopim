// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ask_financial_assistant_use_case.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Провайдер для внедрения зависимости от репозитория.

@ProviderFor(askFinancialAssistantUseCase)
const askFinancialAssistantUseCaseProvider =
    AskFinancialAssistantUseCaseProvider._();

/// Провайдер для внедрения зависимости от репозитория.

final class AskFinancialAssistantUseCaseProvider
    extends
        $FunctionalProvider<
          AskFinancialAssistantUseCase,
          AskFinancialAssistantUseCase,
          AskFinancialAssistantUseCase
        >
    with $Provider<AskFinancialAssistantUseCase> {
  /// Провайдер для внедрения зависимости от репозитория.
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
    r'ff564d1174692c06544697e39961784fa8997855';
