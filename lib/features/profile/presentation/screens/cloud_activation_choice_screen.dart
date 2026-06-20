import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kopim/features/profile/presentation/controllers/cloud_activation_decision_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_intent_controller.dart';

class CloudActivationChoiceScreen extends ConsumerWidget {
  const CloudActivationChoiceScreen({super.key});

  static const String routeName = '/cloud-activation-choice';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final CloudActivationDecisionState state = ref.watch(
      cloudActivationDecisionProvider,
    );
    final CloudActivationIntentState intentState = ref.watch(
      cloudActivationIntentProvider,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Подключение облака')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: <Widget>[
                Text(
                  state.title,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  state.subtitle,
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  state.body,
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                _InfoBanner(message: state.followupNote),
                if (intentState.hasPendingChoice) ...<Widget>[
                  const SizedBox(height: 12),
                  _InfoBanner(
                    message:
                        'Для следующего этапа сохранён выбор: ${cloudActivationChoiceLabel(intentState.pendingChoice!)}. Данные и синхронизация пока не менялись.',
                  ),
                ],
                if (state.canChoose) ...<Widget>[
                  const SizedBox(height: 24),
                  for (final CloudActivationDecisionOption option
                      in state.options) ...<Widget>[
                    _ChoiceCard(
                      option: option,
                      isSelected: intentState.pendingChoice == option.choice,
                      onPressed: () =>
                          _handleChoice(context, ref, state, option),
                    ),
                    const SizedBox(height: 12),
                  ],
                ] else ...<Widget>[
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _dismiss(context),
                    child: const Text('Вернуться'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleChoice(
    BuildContext context,
    WidgetRef ref,
    CloudActivationDecisionState state,
    CloudActivationDecisionOption option,
  ) async {
    switch (option.availability) {
      case CloudActivationChoiceAvailability.available:
        if (option.choice == CloudActivationChoice.stayLocalOnly) {
          ref.read(cloudActivationIntentProvider.notifier).clearPendingChoice();
          final ScaffoldMessengerState messenger = ScaffoldMessenger.of(
            context,
          );
          _dismiss(context);
          messenger.showSnackBar(
            const SnackBar(
              content: Text(
                'Остаёмся в локальном режиме. Данные и подключение не менялись.',
              ),
            ),
          );
          return;
        }
        _savePendingChoice(ref, state, option);
        _showPendingChoiceSnackBar(context, option);
        return;
      case CloudActivationChoiceAvailability.requiresConfirmation:
        final bool confirmed =
            await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(option.title),
                  content: Text(
                    option.followupNote ??
                        'На этом шаге выбор только фиксирует направление следующего этапа без изменения данных.',
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Отмена'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Понятно'),
                    ),
                  ],
                );
              },
            ) ??
            false;
        if (!context.mounted) {
          return;
        }
        if (confirmed) {
          _savePendingChoice(ref, state, option);
          _showPendingChoiceSnackBar(context, option);
        }
        return;
      case CloudActivationChoiceAvailability.unavailableForCurrentScenario:
      case CloudActivationChoiceAvailability.unavailableUntilExecutionFlow:
        _showPlaceholderSnackBar(context, option);
        return;
    }
  }

  void _savePendingChoice(
    WidgetRef ref,
    CloudActivationDecisionState state,
    CloudActivationDecisionOption option,
  ) {
    ref
        .read(cloudActivationIntentProvider.notifier)
        .savePendingChoice(choice: option.choice, decisionState: state);
  }

  void _showPendingChoiceSnackBar(
    BuildContext context,
    CloudActivationDecisionOption option,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          option.followupNote ??
              'Выбор сохранён для следующего этапа. Данные и подключение пока не менялись.',
        ),
      ),
    );
  }

  void _showPlaceholderSnackBar(
    BuildContext context,
    CloudActivationDecisionOption option,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          option.followupNote ??
              'Этот сценарий пока доступен только как подготовительный продуктовый выбор без изменения данных.',
        ),
      ),
    );
  }

  void _dismiss(BuildContext context) {
    final GoRouter? router = GoRouter.maybeOf(context);
    if (router != null && router.canPop()) {
      router.pop();
      return;
    }
    Navigator.of(context).maybePop();
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          message,
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.option,
    required this.isSelected,
    required this.onPressed,
  });

  final CloudActivationDecisionOption option;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String availabilityLabel = switch (option.availability) {
      CloudActivationChoiceAvailability.available => 'Доступно',
      CloudActivationChoiceAvailability.requiresConfirmation =>
        'Нужно подтверждение',
      CloudActivationChoiceAvailability.unavailableForCurrentScenario =>
        'Пока недоступно',
      CloudActivationChoiceAvailability.unavailableUntilExecutionFlow =>
        'Следующий этап',
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Text(option.title, style: theme.textTheme.titleMedium),
                Chip(label: Text(availabilityLabel)),
                if (isSelected) const Chip(label: Text('Выбрано')),
              ],
            ),
            const SizedBox(height: 12),
            Text(option.body, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                onPressed: onPressed,
                child: const Text('Выбрать'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
