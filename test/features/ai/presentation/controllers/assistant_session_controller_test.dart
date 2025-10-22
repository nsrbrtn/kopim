import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/services/ai_assistant_service.dart';
import 'package:kopim/features/ai/domain/entities/ai_llm_result_entity.dart';
import 'package:kopim/features/ai/domain/entities/ai_recommendation_entity.dart';
import 'package:kopim/features/ai/domain/entities/ai_user_query_entity.dart';
import 'package:kopim/features/ai/domain/repositories/ai_assistant_repository.dart';
import 'package:kopim/features/ai/domain/use_cases/ask_financial_assistant_use_case.dart';
import 'package:kopim/features/ai/presentation/controllers/assistant_session_controller.dart';
import 'package:kopim/features/ai/presentation/models/assistant_filters.dart';
import 'package:kopim/features/ai/presentation/models/assistant_message.dart';
import 'package:kopim/features/ai/presentation/models/assistant_session_state.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod/misc.dart' show Override;

class _TestConnectivity implements Connectivity {
  _TestConnectivity(List<ConnectivityResult> initial)
    : _current = initial,
      _controller = StreamController<List<ConnectivityResult>>.broadcast();

  List<ConnectivityResult> _current;
  final StreamController<List<ConnectivityResult>> _controller;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => _current;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _controller.stream;

  void emit(List<ConnectivityResult> results) {
    _current = results;
    _controller.add(results);
  }

  Future<void> disposeStream() async {
    await _controller.close();
  }
}

class _FakeAiAssistantRepository implements AiAssistantRepository {
  _FakeAiAssistantRepository(this.onSend);

  final Future<AiLlmResultEntity> Function(AiUserQueryEntity query) onSend;
  final List<AiUserQueryEntity> capturedQueries = <AiUserQueryEntity>[];

  @override
  Future<AiLlmResultEntity> sendUserQuery(AiUserQueryEntity query) async {
    capturedQueries.add(query);
    return onSend(query);
  }

  @override
  Stream<List<AiRecommendationEntity>> watchRecommendations({
    required String userId,
  }) => const Stream<List<AiRecommendationEntity>>.empty();

  @override
  Stream<Map<String, dynamic>> watchAnalytics({required String userId}) =>
      const Stream<Map<String, dynamic>>.empty();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AssistantSessionController', () {
    test('queues message while offline without hitting repository', () async {
      final _TestConnectivity connectivity = _TestConnectivity(
        <ConnectivityResult>[ConnectivityResult.none],
      );
      addTearDown(connectivity.disposeStream);
      final _FakeAiAssistantRepository repository = _FakeAiAssistantRepository(
        (AiUserQueryEntity query) async => AiLlmResultEntity(
          id: 'resp-1',
          queryId: query.id,
          content: 'stub',
          createdAt: DateTime.now(),
        ),
      );
      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          connectivityProvider.overrideWithValue(connectivity),
          askFinancialAssistantUseCaseProvider.overrideWith(
            (Ref ref) => AskFinancialAssistantUseCase(repository),
          ),
        ],
      );
      addTearDown(container.dispose);

      final AssistantSessionController controller = container.read(
        assistantSessionControllerProvider.notifier,
      );

      await controller.sendMessage(
        'Budget status',
        intentOverride: AiQueryIntent.budgeting,
        additionalFilters: const <AssistantFilter>{AssistantFilter.budgetsOnly},
      );

      final AssistantSessionState state = container.read(
        assistantSessionControllerProvider,
      );

      expect(state.isOffline, isTrue);
      expect(state.messages, hasLength(1));
      final AssistantMessage message = state.messages.first;
      expect(message.deliveryStatus, AssistantMessageDeliveryStatus.pending);
      expect(message.contextFilters, contains(AssistantFilter.budgetsOnly));
      expect(state.streamingMessage, isNull);
      expect(repository.capturedQueries, isEmpty);
    });

    test('delivers assistant reply when online', () async {
      final _TestConnectivity connectivity = _TestConnectivity(
        <ConnectivityResult>[ConnectivityResult.wifi],
      );
      addTearDown(connectivity.disposeStream);
      final DateTime responseTime = DateTime(2024, 6, 1, 12, 0);
      final _FakeAiAssistantRepository repository = _FakeAiAssistantRepository(
        (AiUserQueryEntity query) async => AiLlmResultEntity(
          id: 'resp-1',
          queryId: query.id,
          content: 'All good',
          createdAt: responseTime,
        ),
      );
      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          connectivityProvider.overrideWithValue(connectivity),
          askFinancialAssistantUseCaseProvider.overrideWith(
            (Ref ref) => AskFinancialAssistantUseCase(repository),
          ),
        ],
      );
      addTearDown(container.dispose);

      final AssistantSessionController controller = container.read(
        assistantSessionControllerProvider.notifier,
      );

      await controller.sendMessage('How am I doing?');

      final AssistantSessionState state = container.read(
        assistantSessionControllerProvider,
      );

      expect(state.isOffline, isFalse);
      expect(state.streamingMessage, isNull);
      expect(state.isSending, isFalse);
      expect(state.messages, hasLength(2));
      final AssistantMessage userMessage = state.messages.first;
      final AssistantMessage assistantMessage = state.messages.last;
      expect(
        userMessage.deliveryStatus,
        AssistantMessageDeliveryStatus.delivered,
      );
      expect(assistantMessage.author, AssistantMessageAuthor.assistant);
      expect(assistantMessage.content, 'All good');
      expect(assistantMessage.createdAt, responseTime);
      expect(repository.capturedQueries, hasLength(1));
      expect(
        repository.capturedQueries.single.intent,
        isNot(AiQueryIntent.unknown),
      );
    });

    test(
      'retryPendingMessages sends queued messages after reconnect',
      () async {
        final _TestConnectivity connectivity = _TestConnectivity(
          <ConnectivityResult>[ConnectivityResult.none],
        );
        addTearDown(connectivity.disposeStream);
        final List<AiUserQueryEntity> queries = <AiUserQueryEntity>[];
        final _FakeAiAssistantRepository repository =
            _FakeAiAssistantRepository((AiUserQueryEntity query) async {
              queries.add(query);
              return AiLlmResultEntity(
                id: 'resp-2',
                queryId: query.id,
                content: 'Synced',
                createdAt: DateTime.now(),
              );
            });
        final ProviderContainer container = ProviderContainer(
          overrides: <Override>[
            connectivityProvider.overrideWithValue(connectivity),
            askFinancialAssistantUseCaseProvider.overrideWith(
              (Ref ref) => AskFinancialAssistantUseCase(repository),
            ),
          ],
        );
        addTearDown(container.dispose);

        final AssistantSessionController controller = container.read(
          assistantSessionControllerProvider.notifier,
        );

        await controller.sendMessage(
          'Monthly summary',
          additionalFilters: const <AssistantFilter>{
            AssistantFilter.currentMonth,
          },
        );

        AssistantSessionState state = container.read(
          assistantSessionControllerProvider,
        );
        expect(
          state.messages.single.deliveryStatus,
          AssistantMessageDeliveryStatus.pending,
        );

        connectivity.emit(<ConnectivityResult>[ConnectivityResult.wifi]);
        await Future<void>.delayed(const Duration(milliseconds: 10));

        await controller.retryPendingMessages();
        await Future<void>.delayed(const Duration(milliseconds: 10));

        state = container.read(assistantSessionControllerProvider);
        expect(state.isOffline, isFalse);
        expect(state.messages, hasLength(2));
        expect(
          state.messages.first.deliveryStatus,
          AssistantMessageDeliveryStatus.delivered,
        );
        expect(
          state.messages.first.contextFilters,
          contains(AssistantFilter.currentMonth),
        );
        expect(queries, hasLength(1));
        expect(
          queries.single.contextSignals,
          contains('timeframe:month_to_date'),
        );
      },
    );

    test('sets disabled error when assistant feature flag is off', () async {
      final _TestConnectivity connectivity = _TestConnectivity(
        <ConnectivityResult>[ConnectivityResult.wifi],
      );
      addTearDown(connectivity.disposeStream);
      final _FakeAiAssistantRepository repository = _FakeAiAssistantRepository(
        (AiUserQueryEntity query) async =>
            throw AiAssistantDisabledException('disabled'),
      );
      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          connectivityProvider.overrideWithValue(connectivity),
          askFinancialAssistantUseCaseProvider.overrideWith(
            (Ref ref) => AskFinancialAssistantUseCase(repository),
          ),
        ],
      );
      addTearDown(container.dispose);

      final AssistantSessionController controller = container.read(
        assistantSessionControllerProvider.notifier,
      );

      await controller.sendMessage('Привет');

      final AssistantSessionState state = container.read(
        assistantSessionControllerProvider,
      );

      expect(state.lastError, AssistantErrorType.disabled);
      expect(
        state.messages.last.deliveryStatus,
        AssistantMessageDeliveryStatus.failed,
      );
    });

    test('maps rate limit exception to dedicated error type', () async {
      final _TestConnectivity connectivity = _TestConnectivity(
        <ConnectivityResult>[ConnectivityResult.wifi],
      );
      addTearDown(connectivity.disposeStream);
      final _FakeAiAssistantRepository repository = _FakeAiAssistantRepository(
        (AiUserQueryEntity query) async =>
            throw AiAssistantRateLimitException('rate-limit'),
      );
      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          connectivityProvider.overrideWithValue(connectivity),
          askFinancialAssistantUseCaseProvider.overrideWith(
            (Ref ref) => AskFinancialAssistantUseCase(repository),
          ),
        ],
      );
      addTearDown(container.dispose);

      final AssistantSessionController controller = container.read(
        assistantSessionControllerProvider.notifier,
      );

      await controller.sendMessage('Check budgets');

      final AssistantSessionState state = container.read(
        assistantSessionControllerProvider,
      );

      expect(state.lastError, AssistantErrorType.rateLimit);
      expect(
        state.messages.last.deliveryStatus,
        AssistantMessageDeliveryStatus.failed,
      );
    });
  });
}
