// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_financial_overview_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(aiFinancialOverviewStream)
const aiFinancialOverviewStreamProvider = AiFinancialOverviewStreamFamily._();

final class AiFinancialOverviewStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<AiFinancialOverview>,
          AiFinancialOverview,
          Stream<AiFinancialOverview>
        >
    with
        $FutureModifier<AiFinancialOverview>,
        $StreamProvider<AiFinancialOverview> {
  const AiFinancialOverviewStreamProvider._({
    required AiFinancialOverviewStreamFamily super.from,
    required AiDataFilter super.argument,
  }) : super(
         retry: null,
         name: r'aiFinancialOverviewStreamProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$aiFinancialOverviewStreamHash();

  @override
  String toString() {
    return r'aiFinancialOverviewStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<AiFinancialOverview> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<AiFinancialOverview> create(Ref ref) {
    final argument = this.argument as AiDataFilter;
    return aiFinancialOverviewStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AiFinancialOverviewStreamProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$aiFinancialOverviewStreamHash() =>
    r'8f5d061be2f41dc204100f311283a4a1c27280f6';

final class AiFinancialOverviewStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<AiFinancialOverview>, AiDataFilter> {
  const AiFinancialOverviewStreamFamily._()
    : super(
        retry: null,
        name: r'aiFinancialOverviewStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  AiFinancialOverviewStreamProvider call(AiDataFilter filter) =>
      AiFinancialOverviewStreamProvider._(argument: filter, from: this);

  @override
  String toString() => r'aiFinancialOverviewStreamProvider';
}

@ProviderFor(aiFinancialOverviewSnapshot)
const aiFinancialOverviewSnapshotProvider =
    AiFinancialOverviewSnapshotFamily._();

final class AiFinancialOverviewSnapshotProvider
    extends
        $FunctionalProvider<
          AsyncValue<AiFinancialOverview>,
          AiFinancialOverview,
          FutureOr<AiFinancialOverview>
        >
    with
        $FutureModifier<AiFinancialOverview>,
        $FutureProvider<AiFinancialOverview> {
  const AiFinancialOverviewSnapshotProvider._({
    required AiFinancialOverviewSnapshotFamily super.from,
    required AiDataFilter super.argument,
  }) : super(
         retry: null,
         name: r'aiFinancialOverviewSnapshotProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$aiFinancialOverviewSnapshotHash();

  @override
  String toString() {
    return r'aiFinancialOverviewSnapshotProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<AiFinancialOverview> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AiFinancialOverview> create(Ref ref) {
    final argument = this.argument as AiDataFilter;
    return aiFinancialOverviewSnapshot(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AiFinancialOverviewSnapshotProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$aiFinancialOverviewSnapshotHash() =>
    r'025cf60168b71b1e30562ccf61b00cdf5f0d7890';

final class AiFinancialOverviewSnapshotFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<AiFinancialOverview>, AiDataFilter> {
  const AiFinancialOverviewSnapshotFamily._()
    : super(
        retry: null,
        name: r'aiFinancialOverviewSnapshotProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  AiFinancialOverviewSnapshotProvider call(AiDataFilter filter) =>
      AiFinancialOverviewSnapshotProvider._(argument: filter, from: this);

  @override
  String toString() => r'aiFinancialOverviewSnapshotProvider';
}
